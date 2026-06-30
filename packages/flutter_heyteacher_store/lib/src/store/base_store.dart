import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart'
    show AuthViewModel, UserNotAuthenticatedException;
import 'package:flutter_heyteacher_connectivity/flutter_heyteacher_connectivity.dart';
import 'package:flutter_heyteacher_store/src/store/store_cache.dart';
import 'package:flutter_heyteacher_store/src/store/store_data.dart';
import 'package:flutter_heyteacher_store/src/store/store_exceptions.dart';
import 'package:flutter_heyteacher_store/src/store/store_filters.dart';
import 'package:logging/logging.dart';
import 'package:synchronized/synchronized.dart';

/// The abstract [BaseStore] class to be extended.
///
/// Sub classes must supplying generics [LightDataType], [DetailsDataType] and
/// constructor parameters.
abstract class BaseStore<LightDataType extends FirestoreData<dynamic>,
    DetailsDataType extends LightDataType> {
  /// The store constructor.
  ///
  /// Create a store with these paramenters:
  /// - [collection]: the collection name
  /// - [userProfile]:  if is a user collection
  /// - [fromFirestoreFactory]: the factory for [LightDataType]
  /// - [fromFirestoreFactory]: the factory for [DetailsDataType]
  /// - [orderByFields]: the order by fields
  /// - [aggregateFields]: the aggregate fields
  /// - [storeFilter]: the filters applied to query
  /// - [cacheEnabled]: `True` if cache is enabled
  @protected
  BaseStore({
    required this.collection,
    required this.userProfile,
    required LightDataType Function(Map<String, dynamic> map)
        fromFirestoreFactory,
    DetailsDataType Function(Map<String, dynamic> map)?
        detailsFromFirestoreFactory,
    this.orderByFields,
    this.aggregateFields,
    this.storeFilter,
    this.databaseId,
    this.cacheEnabled = true,
    this.offlineEnabled = true,
  })  : assert(
          databaseId?.isNotEmpty ?? true,
          'databaseId must be null or not empty',
        ),
        separatedDetailsCollection = LightDataType != DetailsDataType {
    _logger
      ..finer(
        '<$runtimeType>: $collectionPathLog '
            'userProfile $this.userProfile  '
            'databaseId $databaseId} '
            'separatedDetailsCollection $separatedDetailsCollection '
            'orderByFields $orderByFields '
            'aggregateFields $aggregateFields '
            'cacheEnabled $this.cacheEnabled '
            'offlineEnabled $this.offlineEnabled',
        'storeFilter $storeFilter',
      )
      ..finest('($runtimeType): register fromFireStoreFactory');
    FirestoreData.registerFromFirestoreFactory<LightDataType>(
      fromFirestoreFactory,
    );
    // manage the separated detail collection
    if (separatedDetailsCollection) {
      detailsCollection = '${collection}_details';
      _logger.finest(
        '($runtimeType): detailsCollection $detailsCollectionPathLog ',
      );

      if (detailsFromFirestoreFactory != null) {
        _logger.finest('($runtimeType): register detailsFromFirestoreFactory');
        FirestoreData.registerFromFirestoreFactory<DetailsDataType>(
          detailsFromFirestoreFactory,
        );
      } else {
        throw DetailsFromFirestoreFactoryNullException(
          LightDataType,
          DetailsDataType,
        );
      }
    } else {
      detailsCollection = collection;
    }
    // check aggregate fields
    if (aggregateFields != null) {
      if (aggregateFields!.length > 29) {
        throw TooManyAggregateFieldsException(
          collection: collection,
          count: aggregateFields!.length,
        );
      }
    }
    // clear cache
    if (cacheEnabled) {
      storeCache = StoreCache<DetailsDataType>();
    }
  }
  final _logger = Logger('BaseStore');

  /// The database id.
  String? databaseId;

  /// the map of order by fields.
  ///
  /// An key of entry is the field, the value of entry must be
  /// [OrderDirection.desc] or [OrderDirection.asc]
  Map<String, OrderDirection>? orderByFields;

  /// list of field to be aggregate.
  List<({String field, AggregatationType aggregatationType})>? aggregateFields;

  /// the filter to apply in query.
  StoreFilter? storeFilter;

  /// if `True` the cache is enabled
  @protected
  final bool cacheEnabled;

  /// if `True`  offline is enabled
  @protected
  final bool offlineEnabled;

  /// The detail collection name.
  ///
  /// if [LightDataType] differs [DetailsDataType] will be
  /// `[_collection]_details`
  @protected
  late String detailsCollection;

  /// the firestore collection name.
  @protected
  final String collection;

  /// If the collection is e user collection.
  ///
  /// If `true`, data are store in collection `/users/[uid]/[_collection]`
  @protected
  final bool userProfile;

  /// If details are stored into the separate collecton `[_collection]_details`.
  ///
  /// `true` if [LightDataType] differs [DetailsDataType], `false` otherwise.
  @protected
  final bool separatedDetailsCollection;

  /// the lock to synchronized access to the store.
  @protected
  final lock = Lock(reentrant: true);

  /// The subscrition to listen aggregate changes.
  StreamSubscription<User?>? _aggregatesSubscription;

  /// The stream controller to yield aggregates changes.
  final StreamController<AggregateData> _aggregateStreamController =
      StreamController<AggregateData>.broadcast();

  /// return the aggregate stream controller
  @protected
  StreamController<AggregateData> get aggregateStreamController =>
      _aggregateStreamController;

  /// return True if is a `FakeFirebaseFirestore`
  bool get fakeFirestore;

  /// The aggregate stream where aggregate changes are notified
  Stream<AggregateData> get aggregateStream =>
      _aggregateStreamController.stream.where(
        (aggregateData) => aggregateData.count != null,
      );

  /// On dispose, cancel the subscriptions.
  @mustCallSuper
  void dispose() {
    unawaited(_aggregatesSubscription?.cancel());
  }

  /// Returns the stream.
  ///
  /// If [applyOrderBy] and [limit] not equals 1, order by
  /// [BaseStore.orderByFields].
  ///
  /// If [applyFilterBy], filter by [BaseStore.storeFilter].
  ///
  /// If [limit] is not null, apply limit.
  Stream<Iterable<LightDataType>> stream({
    bool applyOrderBy = false,
    bool applyFilterBy = true,
    int? limit,
  });

  /// Returns `true` if collection is empty based on [BaseStore.storeFilter]
  /// defined.
  Future<bool> empty() async {
    _logger.finer('<$runtimeType.empty>: $collectionPathLog');
    checkAuthenticated();
    return (await count()) == 0;
  }

  /// Returns `true` if collection is not empty based on [BaseStore.storeFilter]
  /// defined.
  Future<bool> notEmpty() async {
    _logger.finer('<$runtimeType.notEmpty>: $collectionPathLog');
    return (await count()) > 0;
  }

  /// Returns the list of [LightDataType] based on [BaseStore.storeFilter]
  /// ordered by [BaseStore.orderByFields] limited to [limit]
  Future<Iterable<LightDataType>> list({int? limit});

  /// Returns the count of [LightDataType] based on [BaseStore.storeFilter]
  /// ordered
  Future<int> count();

  /// Returns the list of [DetailsDataType].
  ///
  /// If [applyFilterBy] is true, filter by [BaseStore.storeFilter].
  /// If [applyOrderBy] is true order by [BaseStore.orderByFields].
  /// If [limit] is not null, apply limit.
  Future<Iterable<DetailsDataType>> listDetails({
    bool applyOrderBy = false,
    bool applyFilterBy = true,
    int? limit,
  });

  /// Returns `true` if exists a document identified by [id].
  Future<bool> exists(String id) => lock.synchronized(() async {
        _logger.finer(
          '<$runtimeType.exists[synchronized]>:  $detailsCollectionPathLog/$id',
        );
        final cached = await storeCache?.get(id);
        if (cached != null) return true;
        try {
          await get(id);
          return true;
        } on DocumentNotFoundException {
          return false;
        } on FirebaseException catch (e) {
          if (e.code == 'unavailable') {
            return false;
          }
          rethrow;
        }
      });

  /// Returns `true` if doesn't exists a document identified by [id].
  Future<bool> notExists(String? id) async {
    _logger.finer('<$runtimeType.notExists>:  $detailsCollectionPathLog/$id');
    return id == null || !(await exists(id));
  }

  /// Returns the [DetailsDataType ] document identified by [id].
  ///
  /// [DocumentNotFoundException] is throw if document doesn't exist.
  Future<DetailsDataType> get(String id);

  /// Returns the [DetailsDataType ] document identified by [id].
  ///
  /// Returns null if document doesn't exist.
  Future<DetailsDataType?> getOrNull(String? id) async {
    _logger.finer('<$runtimeType.getOrNull>: $detailsCollectionPathLog/$id');
    return await notExists(id) ? null : get(id!);
  }

  /// Delete document identified by [id].
  ///
  /// If [batch] is not null, apply the `delete` operation to a batch .
  Future<void> delete(String id, {dynamic batch});

  /// Deletes massively documents identified by list [ids].
  Future<void> bulkDelete(
    Iterable<String> ids,
  ) async {
    _logger.finer(
      '<$runtimeType.bulkDelete>: $detailsCollectionPathLog, ids: $ids)',
    );
    checkAuthenticated();
    for (var i = 0; i < ids.length; i++) {
      // need await operation in order batch commit will by executed as last
      // operation
      await delete(ids.elementAt(i));
      storeCache?.delete(ids.elementAt(i));
    }
    unawaited(notifyAggregatesChanges());
  }

  /// Creates (override) the document [detailsData] with identifier [id].
  ///
  /// If a document identified by [id] already exists, ovverride it.
  ///
  /// If [batch] is not null, apply the `set` operation to batch.
  Future<void> set(
    DetailsDataType detailsData, {
    String? id,
    dynamic batch,
  });

  /// Creates (override) massively [documents] identified by list [ids].
  Future<void> bulkSet(
    List<DetailsDataType> documents, {
    Iterable<String>? ids,
  }) async {
    _logger.finer('<$runtimeType.bulkSet>: $detailsCollectionPathLog ids $ids');
    checkAuthenticated();
    for (var i = 0; i < documents.length; i++) {
      // need await operation in order batch commit will by executed as
      // last operation
      await set(documents[i], id: ids?.elementAt(i));
      storeCache?.set(ids?.elementAt(i) ?? documents[i].id, documents[i]);
    }
    unawaited(notifyAggregatesChanges());
  }

  /// Updates the document [document] with identifier [id].
  ///
  /// Updates only fields specified in [fields].
  ///
  /// If [fields] is empty, an [InvalidFieldsUpdateException] is throws
  ///
  /// If a document identified by [id] doesn't esists, create it.
  ///
  /// If [batch] is not null, apply the `update` operation to batch.
  Future<void> update(
    DetailsDataType document, {
    required List<String> fields,
    String? id,
    dynamic batch,
  });

  /// Updates massively documents identified by list [ids].
  ///
  /// Updates only fields specified in [fields].
  Future<void> bulkUpdate(
    List<DetailsDataType> documents, {
    required List<String> fields,
    Iterable<String>? ids,
  }) async {
    _logger.finer(
      '<$runtimeType.bulkUpdate>: $detailsCollectionPathLog fields $fields',
    );
    checkAuthenticated();
    for (var i = 0; i < documents.length; i++) {
      // need await operation in order batch commit will by executed as last
      // operation
      await update(
        documents[i],
        fields: fields,
        id: ids?.elementAt(i),
      );
      storeCache?.set(ids?.elementAt(i) ?? documents[i].id, documents[i]);
    }
    unawaited(notifyAggregatesChanges());
  }

  /// Yields an aggregation result based on [aggregateFields].
  Future<AggregateData?> get aggregates;

  /// Yields an aggregation result based on [aggregateFields].
  Future<void> notifyAggregatesChanges() async {
    _logger.finer('<$runtimeType.notifyAggregatesChanges>:');
    if (AuthViewModel.instance.autenticated &&
        await ConnectivityViewModel.instance.connected) {
      final aggregatesValue = await aggregates;
      if (aggregatesValue != null) {
        _aggregateStreamController.sink.add(aggregatesValue);
      }
    }
  }

  /// The cache used to store [DetailsDataType] objects.
  @protected
  StoreCache<DetailsDataType>? storeCache;

  /// Check is user is autentichate.
  ///
  /// if [userProfile] is `true` and user not authenticated, throws
  /// [UserNotAuthenticatedException]
  @protected
  void checkAuthenticated() {
    if (userProfile && AuthViewModel.instance.notAutenticated) {
      throw UserNotAuthenticatedException();
    }
  }

  /// Gets the uid of authenticated user.
  ///
  /// If user isn't authenticathed, throw [UserNotAuthenticatedException]
  @protected
  String get uid => AuthViewModel.instance.autenticated
      ? AuthViewModel.instance.uid!
      : throw UserNotAuthenticatedException();

  /// Gets the collection path for [LightDataType] based on [collection]
  /// and [userProfile].
  ///
  /// [userProfile] false: `/[collection]`
  /// [userProfile] true: `/users/[uid]/[collection]`
  @protected
  String get collectionPath => userProfile
      ? 'users'
          "${collection == "" ? "" : "/$uid/$collection"}"
      : collection;

  /// Gets the collection for [LightDataType]  path obfuscating `uid`.
  @protected
  String get collectionPathLog => userProfile
      ? 'users'
          "${collection == "" ? "" : "/<uid>/$collection"}"
      : collection;

  /// Gets the collection path for [DetailsDataType] based on [collection]
  /// and [userProfile].
  ///
  /// [userProfile] false: `/[collection]_details`
  /// [userProfile] true: `/users/[uid]/[collection]_details`
  @protected
  String get detailsCollectionPath => userProfile
      ? 'users'
          "${detailsCollection == "" ? "" : "/$uid/$detailsCollection"}"
      : detailsCollection;

  /// Gets the collection for [DetailsDataType]  path obfuscating `uid`.
  @protected
  String? get detailsCollectionPathLog => userProfile
      ? 'users'
          "${detailsCollection == "" ? "" : "/<uid>/$detailsCollection"}"
      : detailsCollection;
}
