/// Firebase Firestore library using [generics](https://dart.dev/language/generics|generics).
///
/// Main funtionality are:
///
/// * use [generics](https://dart.dev/language/generics|generics) to define two
///   different DataType in [firestore.CollectionReference.withConverter]

///   * `<LightDataType>` the lighweight [FirestoreData] document used in
///      [Store.list] and [Store.query]

///   * `<DetailsDataType>` the full detailed [FirestoreData] document used in
///     [Store.get], [Store.set] and [Store.update]
///
/// * manage collection separation in a main collection wich store
///   `<LightDataType>` documents and a `<collection>_details` which store
///   `<DetailsDataType>` documents (only if `<LightDataType>` and
///   `<DetailsDataType>` differs)
///
/// * manage the user collection `/users/<uid>/` with [Store._userProfile]
///   integrating [FirebaseAuth] using automatically the `uid` of authenticated
///   user
///
/// * manage data filtering with [StoreFilter]
///
/// * manage multiple order by field with [Store.orderByFields]
///
/// * implement distinct and group by [Store._groupByFields]
///
/// * manage aggregate field via [Store.aggregateFields] and notify aggregate
///   value changes via [Store.aggregateStream]
///
/// * cache `DetailsDataType` object in [SharedPreferencesAsync]
///
/// # Usage
///
/// * Import the library in your code
///   ```dart
///   import 'package:flutter_heyteacher_utils/firebase/firestore/store.dart';
///   ```
///
/// * Extends the `abstract` `class` [Store] supplying configuration parameters.
///
/// # Examples
///
/// ## TrackStore
///
/// * store in `/users/<uid>/tracks` `BaseTrackData` document (`<LightDataType>`)
/// * store in `/users<uid>/tracks_details` `TrackData` document (`<DetailsDataType>`)
/// * order by track `startTime` descending
/// * aggregate `distance` and `duration`
/// * group by track `year`
///
/// ### Definition
/// ```dart
/// class TrackStore extends Store<BaseTrackData, TrackData> {
///  TrackStore._()
///      : super(
///            // the main collection which store BaseTrackData document
///            collection: "tracks",
///            // store data into /users/<uid>/tracks
///            userProfile: true,
///            // order by track start time
///            orderByFields: {"startTime": true},
///            // aggregate per track distance and track duration
///            aggregateFields: ["distance", "duration"],
///            // factory per BaseTrackData creation
///            fromFirestoreFactory: BaseTrackData.fromFirestore,
///            // factory per TrackData creation
///            detailsFromFirestoreFactory: TrackData.fromFirestore,
///            // group by track year, the map field /users/<uid>/tracks_years store years and // track count per year
///            groupByFields: {
///              "years": _groupByYear,
///            });
///
///  // function used for group by year the track
///  static String _groupByYear(TrackData trackData) {
///    return "${trackData.startTime.year}";
///  }
///
///  // singleton
///  static TrackStore? _instance;
///  static TrackStore get instance {
///    _instance ??= TrackStore._();
///    return _instance!;
///  }
///}
///```
/// ### DataType Definitions
///
/// `BaseTrackData` is the `<LightDataType>` which store basic data in `/users/<uid>/tracks` collection
///
/// ```dart
/// class BaseTrackData extends FirestoreData {
///  static final DateFormat keyDateTimeFormatter =
///  DateFormat("yyyyMMdd_HHmmss");
///
///  DateTime startTime;
///  DateTime? stopTime;
///  num? duration;
///  num? distance;
///
///  @override
///  String get id => keyDateTimeFormatter.format(startTime.toLocal());
///
///  BaseTrackData(
///      {required this.startTime,
///      this.stopTime,
///      this.duration,
///      this.distance});

///  factory BaseTrackData.fromFirestore(Map<String, dynamic> map) {
///    return BaseTrackData(
///        startTime: FirestoreData.fromFirestoreTimestamp(map["startTime"])!,
///        stopTime: map["stopTime"] != null
///            ? FirestoreData.fromFirestoreTimestamp(map["stopTime"])
///            : null,
///        duration: map["stopTime"] != null
///           ? map["duration"]
///            : calculateDuration(
///                FirestoreData.fromFirestoreTimestamp(map["startTime"])!,
///                clock.now(),
///                0),
///        distance: ((map["distance"] as num? ?? 0) * 10).round() / 10);
///  }
///
///  @override
///  Map<String, dynamic> toFirestore() => {
///        'startTime': FirestoreData.toFirestoreTimestamp(startTime),
///        'stopTime': FirestoreData.toFirestoreTimestamp(stopTime),
///        'duration': duration,
///        'distance': distance,
///  };
///}
///```
///
/// `TrackData` is the `<DetailsDataType>` which store details data in `/users/<uid>/tracks_details` collection.
///
/// * extends the `<LightDataType>` `TrackData`
///
/// * implements [FirestoreData.getParentData] and [FirestoreData.setParentData]
///   used to get and set data of super class `BaseTrackData` which store data
///   in `/users/<uid>/tracks`
///
/// So, `<DetailsDataType>` contains the merge of data stored
/// `/users/<uid>/tracks` `/users/<uid>/tracks_details`
///
///```dart
///class TrackData extends BaseTrackData {
///   late List<LocationData> locations;
///
///   TrackData(
///       {required super.startTime,
///       super.stopTime,
///       super.duration,
///       super.distance,
///       super.average,
///       this.locations = const []});
///
///   factory TrackData.fromFirestore(Map<String, dynamic> map) {
///     List<LocationData> locations = [];
///     for (var location in jsonDecode(map["locations"])) {
///       locations.add(LocationData.fromJson(location));
///     }
///     return TrackData(
///         startTime: FirestoreData.fromFirestoreTimestamp(map['startTime'])!,
///         locations: locations);
///   }
///
///   @override
///   Map<String, dynamic> toFirestore() => {
///         'startTime': FirestoreData.toFirestoreTimestamp(startTime),
///         'locations': jsonEncode(locations)
///       };
///
///   @override
///   void setParentData(FirestoreData parentData) {
///     BaseTrackData baseTrackData = parentData as BaseTrackData;
///     startTime = baseTrackData.startTime;
///     distance = baseTrackData.distance;
///     duration = baseTrackData.duration;
///     stopTime = baseTrackData.stopTime;
///   }
///
///   @override
///   FirestoreData getParentData() {
///     return BaseTrackData(
///         startTime: startTime,
///         distance: distance,
///         duration: duration,
///         stopTime: stopTime);
///   }
/// }
/// ```
///
///
/// ## UserStore
///
/// Stores on user collection `/users/<uid>` ([Store._collection] is empty).
/// Since `<LightDataType>` and `<DetailsDataType>` are equal to `UserData`
/// *_details collection isn't created
/// ```dart
/// class UserStore extends Store<UserData, UserData> {
/// UserStore._()
///      : super(
///            collection: "",
///            userProfile: true,
///            fromFirestoreFactory: UserData.fromFirestore);
///
/// // singleton
/// static UserStore? _instance;
/// static UserStore get instance {
///   _instance ??= UserStore._();
///   return _instance!;
/// }
///}
///```
///
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_store/src/store/store_filters.dart';
import 'package:flutter_heyteacher_utils/connectivity.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:synchronized/synchronized.dart';

/// Order enumeration.
///
/// Defines [desc] and [asc] constants used to define order by
enum OrderDirection {
  /// descendent order
  desc,

  /// ascedent order
  asc
}

/// A group-by result.
///
/// Stores a group-by result as a pair of
/// - [groupByFields] map which contains group by field and the field value
/// - [value] the aggregate values
class GroupByResult extends Equatable implements Comparable<GroupByResult> {
  /// Creates a group-by result.
  const GroupByResult({required this.groupByFields, required this.value});

  /// map which contains group by field and the field value
  final Map<String, String> groupByFields;

  /// the aggregate values
  final Comparable<dynamic> value;

  @override
  List<Object?> get props => [groupByFields, value];

  @override
  int compareTo(GroupByResult other) {
    return other.value.compareTo(value);
  }
}

/// An in-memory cache for Firestore documents.
///
/// This class provides a simple key-value store to temporarily hold
/// `DetailsDataType` objects, reducing redundant reads from Firestore.
class StoreCache<DetailsDataType extends FirestoreData<dynamic>> {
  final _logger = Logger('StoreCache');

  final Map<String, DetailsDataType?> _cache = {};

  /// Checks if a document with the given [id] exists in the cache.
  bool exists(String id) => _cache.containsKey(id);

  /// Retrieves a document with the given [id] from the cache.
  ///
  /// Returns the cached `DetailsDataType` object if found, otherwise `null`.
  Future<DetailsDataType?> get(String id) async {
    _logger.finest('<get>:');
    if (exists(id)) {
      _logger.finest('(get): id $id. HIT runtimeType '
          '${DetailsDataType.runtimeType} hashCode $hashCode');
      return _cache[id];
    }
    _logger.finest('(get): id $id. MISS runtimeType '
        '${DetailsDataType.runtimeType} hashCode $hashCode');
    return null;
  }

  /// Adds or updates a document in the cache.
  ///
  /// - [id]: The unique identifier for the document.
  /// - [detailsData]: The document data to cache. Can be `null` to cache a
  ///   non-existent document.
  void set(String id, DetailsDataType? detailsData) {
    _logger.finest('<set>: id $id');
    _cache[id] = detailsData;
  }

  /// delete object [id] from cache
  void delete(String id) {
    _logger.finest('<delete>: id $id');
    _cache.remove(id);
  }
}

/// The abstract [Store] class to be extended.
///
/// Sub classes must supplying generics [LightDataType], [DetailsDataType] and
/// constructor parameters.
abstract class Store<LightDataType extends FirestoreData<dynamic>,
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
  /// - [storeFilter]: the filters applied to [query]
  /// - [groupByFields]: the group by filters
  /// - [cacheEnabled]: `True` if cache is enabled
  @protected
  Store({
    required String collection,
    required bool userProfile,
    required LightDataType Function(Map<String, dynamic> map)
        fromFirestoreFactory,
    DetailsDataType Function(Map<String, dynamic> map)?
        detailsFromFirestoreFactory,
    this.orderByFields,
    this.aggregateFields,
    this.storeFilter,
    bool cacheEnabled = true,
    bool offlineEnabled = true,
    Map<String, String Function(DetailsDataType)?>? groupByFields,
    firestore.FirebaseFirestore? firebaseFirestore,
  })  : _offlineEnabled = offlineEnabled,
        _cacheEnabled = cacheEnabled,
        _userProfile = userProfile,
        _collection = collection,
        _groupByFields = groupByFields,
        _separatedDetailsCollection = LightDataType != DetailsDataType {
    _firestore = firebaseFirestore ?? firestore.FirebaseFirestore.instance;

    // FirebaseFirestore.instanceFor(
    //     app: FirebaseFirestore.instance.app, databaseId: 'bkdb');

    final fakeFirestore =
        _firestore.runtimeType.toString() == 'FakeFirebaseFirestore';
    if (!fakeFirestore) {
      // enable persistence for offline access
      _firestore.settings = firestore.Settings(
        persistenceEnabled: _offlineEnabled,
      );
    }
    _logger
      ..finest(
        '<$runtimeType>: $_collectionPathLog '
            'userProfile $_userProfile  '
            'database ${fakeFirestore ? 'fake' : _firestore.databaseId} '
            'separatedDetailsCollection $_separatedDetailsCollection '
            'orderByFields $orderByFields '
            'aggregateFields $aggregateFields '
            'groupByFields ${_groupByUserField()}'
            'cacheEnabled $_cacheEnabled '
            'offlineEnabled $_offlineEnabled',
        'storeFilter $storeFilter',
      )
      ..finest('($runtimeType): register fromFireStoreFactory');
    FirestoreData.registerFromFirestoreFactory<LightDataType>(
      fromFirestoreFactory,
    );
    // manage the separated detail collection
    if (_separatedDetailsCollection) {
      _detailsCollection = '${_collection}_details';
      _logger.finest(
        '($runtimeType): detailsCollection $_detailsCollectionPathLog ',
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
      _detailsCollection = _collection;
    }
    // check and initialize group by
    if (_groupByFields != null) {
      if (!_userProfile) {
        throw InvalidGroupByConfigurationException(collection: _collection);
      }
      unawaited(_initGroupByCounter());
    }
    // check aggregate fields
    if (aggregateFields != null) {
      if (aggregateFields!.length > 29) {
        throw TooManyAggregateFieldsException(
          collection: _collection,
          count: aggregateFields!.length,
        );
      }
    }
    // clear cache
    if (_cacheEnabled) {
      _storeCache = StoreCache<DetailsDataType>();
    }
  }
  final _logger = Logger('Store');

  late final firestore.FirebaseFirestore _firestore;

  /// the map of order by fields.
  ///
  /// An key of entry is the field, the value of entry must be
  /// [OrderDirection.desc] or [OrderDirection.asc]
  Map<String, OrderDirection>? orderByFields;

  /// list of field to be aggregate.
  List<String>? aggregateFields;

  /// the filter to apply in [Store.query].
  StoreFilter? storeFilter;

  /// contains the state of group by selected, used to filter results
  GroupByResult? groupBySelected;

  /// if `True` the cache is enabled
  final bool _cacheEnabled;

  /// if `True`  offline is enabled
  final bool _offlineEnabled;

  /// The map of group by fields with the function which estract the value
  /// to group by.
  final Map<String, String Function(DetailsDataType)?>? _groupByFields;

  /// The detail collection name.
  ///
  /// if [LightDataType] differs [DetailsDataType] will be
  /// `[_collection]_details`
  late String _detailsCollection;

  /// the firestore collection name.
  final String _collection;

  /// If the collection is e user collection.
  ///
  /// If `true`, data are store in collection `/users/[uid]/[_collection]`
  final bool _userProfile;

  /// If details are stored into the separate collecton `[_collection]_details`.
  ///
  /// `true` if [LightDataType] differs [DetailsDataType], `false` otherwise.
  final bool _separatedDetailsCollection;

  final _lock = Lock(reentrant: true);

  /// The subscrition to listen aggregate changes.
  StreamSubscription<User?>? _aggregatesSubscription;

  /// The stream controller to yield aggregates changes.
  final StreamController<firestore.AggregateQuerySnapshot>
      _aggregateStreamController =
      StreamController<firestore.AggregateQuerySnapshot>.broadcast();

  /// The aggregate stream where aggregate changes are notified
  Stream<firestore.AggregateQuerySnapshot> get aggregateStream =>
      _aggregateStreamController.stream.where(
        (aggregateQuerySnapshot) => aggregateQuerySnapshot.count != null,
      );

  /// On dispose, cancel the subscriptions.
  @mustCallSuper
  void dispose() {
    unawaited(_aggregatesSubscription?.cancel());
  }

  /// Return a Query of LightDataType.
  ///
  /// Apply [applyOrderBy], applies filter if [applyFilterBy] and applies
  /// [limit] if not null.
  firestore.Query<LightDataType> query({
    bool applyOrderBy = false,
    bool applyFilterBy = true,
    int? limit,
  }) {
    firestore.Query<LightDataType> retQuery = _collectionReference;
    _logger.finest('<$runtimeType.query>: applyOrderBy $applyOrderBy '
        ' applyFilterBy $applyFilterBy limit $limit');
    // apply filter
    if (applyFilterBy && storeFilter != null) {
      _logger.finest('($runtimeType.query): storeFilter $storeFilter');
      retQuery = retQuery.where(storeFilter!.toFirestore());
    }
    // apply order by
    if (applyOrderBy && orderByFields != null) {
      for (final orderbyField in orderByFields!.entries) {
        retQuery = retQuery.orderBy(
          orderbyField.key,
          descending: orderbyField.value == OrderDirection.desc,
        );
      }
    }
    // apply limit
    if (limit != null && limit > 0) {
      retQuery = retQuery.limit(limit);
    }
    return retQuery;
  }

  /// Returns the stream on [Store.query]
  Stream<Iterable<LightDataType>> stream({
    bool applyOrderBy = false,
    bool applyFilterBy = true,
    int? limit,
  }) =>
      AuthViewModel.instance.notAutenticated
          ? const Stream.empty()
          : query(
              applyOrderBy: applyOrderBy,
              applyFilterBy: applyFilterBy,
              limit: limit,
            ).snapshots().map(
                (querySnapshot) =>
                    querySnapshot.docs.map((document) => document.data()),
              );

  /// Returns `true` if collection is empty based on [Store.storeFilter]
  /// defined.
  Future<bool> empty() async {
    _logger.finest('<$runtimeType.empty>: $_collectionPathLog');
    _checkAuthenticated();
    return (await count()) == 0;
  }

  /// Returns `true` if collection is not empty based on [Store.storeFilter]
  /// defined.
  Future<bool> notEmpty() async {
    _logger.finest('<$runtimeType.notEmpty>: $_collectionPathLog');
    return (await count()) > 0;
  }

  /// Returns the list of [LightDataType] based on [Store.storeFilter] ordered
  /// by [Store.orderByFields] limited to [limit]
  Future<Iterable<LightDataType>> list({int? limit}) async {
    _logger.finest('<$runtimeType.list>: $_collectionPathLog orderByFields: '
        '$orderByFields limit: $limit)');
    _checkAuthenticated();
    return (await query(applyOrderBy: true, limit: limit).get())
        .docs
        .map((e) => e.data());
  }

  /// Returns the count of [LightDataType] based on [Store.storeFilter] ordered
  Future<int> count() async {
    _logger.finest('<$runtimeType.count>: $_collectionPathLog '
        'storeFilter $storeFilter');
    _checkAuthenticated();
    return (await query().count().get()).count ?? 0;
  }

  /// Returns the list of [DetailsDataType].
  ///
  /// If [applyFilterBy] is true, filter by [Store.storeFilter].
  /// If [applyOrderBy] is true order by [Store.orderByFields].
  /// If [limit] is not null, apply limit.
  Future<Iterable<DetailsDataType>> listDetails({
    bool applyOrderBy = false,
    bool applyFilterBy = true,
    int? limit,
  }) async {
    _logger.finest(
        '<$runtimeType.listDetailed>: $_collectionPathLog orderByFields: '
        '$orderByFields limit: $limit)');
    _checkAuthenticated();
    firestore.Query<DetailsDataType> retQuery = _detailsCollectionReference;
    // apply filter
    if (applyFilterBy && storeFilter != null) {
      _logger.finest('($runtimeType.listDetailed): '
          'storeFilter ${storeFilter!.toFirestore()}');
      retQuery = retQuery.where(storeFilter!.toFirestore());
    }
    // apply order by
    if (applyOrderBy && orderByFields != null) {
      for (final orderbyField in orderByFields!.entries) {
        retQuery = retQuery.orderBy(
          orderbyField.key,
          descending: orderbyField.value == OrderDirection.desc,
        );
      }
    }
    // apply limit
    if (limit != null && limit > 0) {
      retQuery = retQuery.limit(limit);
    }
    return (await retQuery.get()).docs.map((e) => e.data());
  }

  /// Returns `true` if exists a document identified by [id].
  Future<bool> exists(String id) => _lock.synchronized(() async {
        _logger.finest(
          '<$runtimeType.exists[synchronized]>:  $_detailsCollectionPathLog/$id',
        );
        final cached = await _storeCache?.get(id);
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
    _logger.finest('<$runtimeType.notExists>:  $_detailsCollectionPathLog/$id');
    return id == null || !(await exists(id));
  }

  /// Returns the [DetailsDataType ] document identified by [id].
  ///
  /// [DocumentNotFoundException] is throw if document doesn't exist.
  Future<DetailsDataType> get(String id) async => _lock.synchronized(() async {
        _logger.finest(
          '<$runtimeType.get[synchronized]>: $_detailsCollectionPathLog/$id)',
        );
        if (_storeCache?.exists(id) ?? false) {
          final cached = await _storeCache?.get(id);
          if (cached != null) {
            return cached;
          } else {
            // document cached but null
            throw DocumentNotFoundException('$_detailsCollectionPathLog/$id');
          }
        }
        _checkAuthenticated();
        final detailsDocumentSnapshot =
            await _detailsCollectionReference.doc(id).get();
        // check if exists
        if (detailsDocumentSnapshot.exists) {
          DetailsDataType details = detailsDocumentSnapshot.data()!;
          if (_separatedDetailsCollection) {
            final documentSnapshot = await _collectionReference.doc(id).get();
            // populate parent data fields
            if (documentSnapshot.exists) {
              details = details.setParentData(documentSnapshot.data()!)
                  as DetailsDataType;
              _storeCache?.set(id, details);
              return details;
            } else {
              _storeCache?.set(id, null);
              throw DocumentNotFoundException('$_collectionPathLog/$id');
            }
          } else {
            _storeCache?.set(id, details);
            return details;
          }
        } else {
          throw DocumentNotFoundException('$_detailsCollectionPathLog/$id');
        }
      });

  /// Returns the [DetailsDataType ] document identified by [id].
  ///
  /// Returns null if document doesn't exist.
  Future<DetailsDataType?> getOrNull(String? id) async {
    _logger.finest('<$runtimeType.getOrNull>: $_detailsCollectionPathLog/$id');
    return await notExists(id) ? null : get(id!);
  }

  /// Delete document identified by [id].
  ///
  /// If [batch] is not null, apply the `delete` operationto batch that will be
  /// esecuted by [firestore.WriteBatch.commit].
  Future<void> delete(String id, {firestore.WriteBatch? batch}) async {
    _logger.fine('<$runtimeType.delete>: $_detailsCollectionPathLog/$id');
    _checkAuthenticated();
    if (_groupByFields != null) {
      try {
        await _updateGroupByCounter(await get(id), increment: false);
      } on Exception catch (e, s) {
        _logger.severe(
          '($runtimeType.delete): $_detailsCollectionPathLog/$id) error on '
          '_updateGroupByCounter',
          e,
          s,
        );
      }
    }
    if (batch != null) {
      batch.delete(_detailsCollectionReference.doc(id));
    } else {
      _storeCache?.delete(id);
      await _detailsCollectionReference.doc(id).delete();
    }
    if (_separatedDetailsCollection) {
      _logger.fine('($runtimeType.delete): $_collectionPathLog/$id');
      if (batch != null) {
        batch.delete(_collectionReference.doc(id));
      } else {
        await _collectionReference.doc(id).delete();
      }
    }
    // if isn't a bulk delete (batch == null), delegate thee caller to notify
    // changes
    if (batch == null) {
      unawaited(notifyAggregatesChanges());
    }
  }

  /// Deletes massively documents identified by list [ids].
  Future<void> bulkDelete(
    List<String> ids,
  ) async {
    _logger.fine(
      '<$runtimeType.bulkDelete>: $_detailsCollectionPathLog, ids: $ids)',
    );
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < ids.length; i++) {
      // need await operation in order batch commit will by executed as last
      // operation
      await delete(ids[i], batch: batch);
      _storeCache?.delete(ids[i]);
    }
    await batch.commit();
    unawaited(notifyAggregatesChanges());
  }

  /// Creates (override) the document [detailsData] with identifier [id].
  ///
  /// If a document identified by [id] already exists, ovverride it.
  ///
  /// If [batch] is not null, apply the `set` operation to batch that will be
  /// esecuted by [firestore.WriteBatch.commit].
  Future<void> set(
    DetailsDataType detailsData, {
    String? id,
    firestore.WriteBatch? batch,
  }) async {
    id ??= detailsData.id;
    _logger.finest('<$runtimeType.set>: $_detailsCollectionPathLog/$id');
    _checkAuthenticated();
    DetailsDataType? oldDetailsData;
    if (_groupByFields != null && await exists(id)) {
      oldDetailsData = await get(id);
    }
    if (batch != null) {
      batch.set(_detailsCollectionReference.doc(id), detailsData);
    } else {
      await _detailsCollectionReference.doc(id).set(detailsData);
    }
    if (_separatedDetailsCollection) {
      final parentData = detailsData.getParentData() as LightDataType?;
      if (parentData != null) {
        if (batch != null) {
          batch.set(_collectionReference.doc(id), parentData);
        } else {
          await _collectionReference.doc(id).set(parentData);
        }
      } else {
        throw ParentDataNullException(DetailsDataType.runtimeType);
      }
    }
    if (_groupByFields != null) {
      await _updateGroupByCounter(
        detailsData,
        increment: true,
        oldDetailsData: oldDetailsData,
      );
    }
    // if batch in set, delegate thee caller to notify changes
    if (batch == null) {
      _storeCache?.set(id, detailsData);
      unawaited(notifyAggregatesChanges());
    }
  }

  /// Creates (override) massively [documents] identified by list [ids].
  Future<void> bulkSet(
    List<DetailsDataType> documents, {
    List<String>? ids,
  }) async {
    _logger.fine('<$runtimeType.bulkSet>: $_detailsCollectionPathLog ids $ids');
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < documents.length; i++) {
      // need await operation in order batch commit will by executed as
      // last operation
      await set(documents[i], id: ids?[i], batch: batch);
      _storeCache?.set(ids?[i] ?? documents[i].id, documents[i]);
    }
    await batch.commit();
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
  /// If [batch] is not null, apply the `update` operation to batch that will be
  /// esecuted by [firestore.WriteBatch.commit].
  Future<void> update(
    DetailsDataType document, {
    required List<String> fields,
    String? id,
    dynamic batch,
  }) async {
    _logger.fine(
      '<$runtimeType.update>: $_detailsCollectionPathLog/$id fields: $fields)',
    );
    if (fields.isEmpty) {
      throw InvalidFieldsUpdateException('$_detailsCollectionPathLog/$id');
    }
    id ??= document.id;
    _checkAuthenticated();
    if (await exists(id)) {
      if (batch != null) {
        batch as firestore.WriteBatch;
        batch.update(
          _detailsCollectionReference.doc(id),
          document.toFirestore(fields),
        );
      } else {
        unawaited(
          _detailsCollectionReference
              .doc(id)
              .update(document.toFirestore(fields)),
        );
      }
      if (_separatedDetailsCollection) {
        if (document.getParentData() != null) {
          if (batch != null) {
            batch as firestore.WriteBatch;
            batch.update(
              _collectionReference.doc(id),
              document.getParentData()!.toFirestore(fields),
            );
          } else {
            unawaited(
              _collectionReference
                  .doc(id)
                  .update(document.getParentData()!.toFirestore(fields)),
            );
          }
        } else {
          throw ParentDataNullException(DetailsDataType.runtimeType);
        }
      }
      // document not found, create it
    } else {
      unawaited(set(document, batch: batch as firestore.WriteBatch?));
    }
    // if batch in set, delegate thee caller to notify changes
    if (batch == null) {
      _storeCache?.set(id, document);
      unawaited(notifyAggregatesChanges());
    }
  }

  /// Updates massively documents identified by list [ids].
  ///
  /// Updates only fields specified in [fields].
  Future<void> bulkUpdate(
    List<DetailsDataType> documents, {
    required List<String> fields,
    List<String>? ids,
  }) async {
    _logger.finest(
      '<$runtimeType.bulkUpdate>: $_detailsCollectionPathLog fields $fields',
    );
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < documents.length; i++) {
      // need await operation in order batch commit will by executed as last
      // operation
      await update(documents[i], fields: fields, id: ids?[i], batch: batch);
      _storeCache?.set(ids?[i] ?? documents[i].id, documents[i]);
    }
    await batch.commit();
    unawaited(notifyAggregatesChanges());
  }

  /// Returns the list of group by result, with order direction
  /// [groupByFieldsOrderDirection].
  Future<Iterable<GroupByResult>?> groupBy({
    OrderDirection groupByFieldsOrderDirection = OrderDirection.asc,
  }) async {
    _logger.finest('<$runtimeType.groupBy>: $_detailsCollectionPathLog '
        'groupByFieldsOrderDirection ${groupByFieldsOrderDirection.name}');
    final groupByUserField = _groupByUserField();
    if (groupByUserField == null) return null;
    _checkAuthenticated();
    final user = await _firestore.collection('users').doc(_uid).get();
    final groupByKey = user.data()?[groupByUserField] as Map<String, dynamic>?;
    if (groupByKey == null) return null;
    final iterable = groupByKey.entries.map(
      (mapEntry) => GroupByResult(
        groupByFields: _splitGroupByFields(mapEntry.key)!,
        value: mapEntry.value as Comparable<dynamic>,
      ),
    );
    return iterable.sorted(
      (a, b) => _sortByGroupByFields(
        a,
        b,
        groupByFieldsOrder: groupByFieldsOrderDirection,
      ),
    );
  }

  /// Yields an aggregation result based on [aggregateFields].
  Future<firestore.AggregateQuerySnapshot?> get aggregates async {
    _logger.finest('<$runtimeType.aggregates>:');
    _checkAuthenticated();
    if (aggregateFields == null || aggregateFields!.isEmpty) return null;
    final aggregateParams = <firestore.AggregateField?>[
      for (var i = 0; i < 29; i++)
        aggregateFields!.length > i ? firestore.sum(aggregateFields![i]) : null,
    ];
    _logger.finest('($runtimeType.aggregates): not null');
    return query()
        .aggregate(
          firestore.count(),
          aggregateParams[0],
          aggregateParams[1],
          aggregateParams[2],
          aggregateParams[3],
          aggregateParams[4],
          aggregateParams[5],
          aggregateParams[6],
          aggregateParams[7],
          aggregateParams[8],
          aggregateParams[9],
          aggregateParams[10],
          aggregateParams[11],
          aggregateParams[12],
          aggregateParams[13],
          aggregateParams[14],
          aggregateParams[15],
          aggregateParams[16],
          aggregateParams[17],
          aggregateParams[18],
          aggregateParams[19],
          aggregateParams[20],
          aggregateParams[21],
          aggregateParams[22],
          aggregateParams[23],
          aggregateParams[24],
          aggregateParams[25],
          aggregateParams[26],
          aggregateParams[27],
          aggregateParams[28],
        )
        .get();
  }

  /// Yields an aggregation result based on [aggregateFields].
  Future<void> notifyAggregatesChanges() async {
    _logger.finest('<$runtimeType.notifyAggregatesChanges>:');
    if (AuthViewModel.instance.autenticated &&
        await ConnectivityViewModel.instance.connected) {
      final aggregatesValue = await aggregates;
      if (aggregatesValue != null) {
        _aggregateStreamController.sink.add(aggregatesValue);
      }
    }
  }

  /// Returns if _initGroupByCounter is already running.
  static bool _initGroupByCounterAlreadyRunning = false;

  StoreCache<DetailsDataType>? _storeCache;

  /// Initialize the group by counter.
  ///
  /// If already initialized, do nothing. Otherwise load all documents and
  /// update the group by counter.
  Future<void> _initGroupByCounter() async {
    _logger.finest('<$runtimeType._initGroupByCounter>:');
    if (AuthViewModel.instance.notAutenticated) {
      _logger.finest(
        '($runtimeType._initGroupByCounter): user not authenticate, do nothing',
      );
      return;
    }
    if (_initGroupByCounterAlreadyRunning) {
      _logger.finest(
        '($runtimeType._initGroupByCounter): already running, do nothing',
      );
      return;
    } else {
      _initGroupByCounterAlreadyRunning = true;
    }
    final groupByUserField = _groupByUserField();
    if (groupByUserField != null) {
      final documentSnapshot =
          await _firestore.collection('users').doc(_uid).get();
      if (documentSnapshot.data()?[groupByUserField] != null) {
        _logger.finest(
          '($runtimeType._initGroupByCounter): user $groupByUserField already '
          'initialized. Do nothing',
        );
        return;
      }
      _logger.finest(
        '($runtimeType._initGroupByCounter): start scan on $_collection and '
        'update $groupByUserField',
      );
      for (final lightData in await list()) {
        final detailsData = await get(lightData.id);
        await _updateGroupByCounter(detailsData, increment: true);
      }
    }
    _initGroupByCounterAlreadyRunning = false;
    _logger.finest('($runtimeType._initGroupByCounter): stop scan');
  }

  /// Update the group by counter.
  ///
  /// increment/decrement the group by value based from [document] data.
  ///
  /// if [increment] is true add 1 otherwise subtract 1.
  ///
  /// Il [oldDetailsData] is not null, decrement/increment the counter.
  Future<void> _updateGroupByCounter(
    DetailsDataType document, {
    required bool increment,
    DetailsDataType? oldDetailsData,
  }) async {
    if (_groupByFields == null) {
      return;
    }
    _logger.finest('<$runtimeType._updateGroupByCounter>: '
        'document ${document.id} increment $increment, '
        'oldDetailsData ${oldDetailsData?.id}');
    assert(_userProfile, 'user profile must be true');
    // user document reference
    final userDocumentReference = _firestore.collection('users').doc(_uid);
    await _firestore.runTransaction(
      (firestore.Transaction transaction) => _updateGroupByCounterTransaction(
        transaction,
        userDocumentReference,
        document,
        increment,
        oldDetailsData,
      ),
    );
    _logger.finest('($runtimeType._updateGroupByCounter): '
        'document ${document.id} increment $increment, '
        'oldDetailsData ${oldDetailsData?.id} transaction completed');
  }

  /// Update the group by counter transaction.
  Future<void> _updateGroupByCounterTransaction(
    firestore.Transaction transaction,
    firestore.DocumentReference<Map<String, dynamic>> userDocumentReference,
    DetailsDataType document,
    bool increment,
    DetailsDataType? oldDetailsData,
  ) async {
    _logger.finest('<$runtimeType._updateGroupByCounterTransaction<)>: '
        'document ${document.id} increment $increment, '
        'oldDetailsData ${oldDetailsData?.id} ');
    // get the user document snapshot
    final userDocumentSnapshot = await transaction.get(userDocumentReference);
    // get the user document
    final userDocument = userDocumentSnapshot.data() ?? {};

    final groupByUserField = _groupByUserField();
    final groupByUserValue = _groupByUserValue(document);
    final oldGroupByUserValue =
        oldDetailsData != null ? _groupByUserValue(oldDetailsData) : null;

    if (groupByUserField != null &&
        groupByUserValue != null &&
        groupByUserValue != oldGroupByUserValue) {
      // get the user document map which store group by values
      // into field <collection>_<groupByField>
      final userDocumentMap = (userDocument[groupByUserField] ??
          <String, dynamic>{}) as Map<String, dynamic>;
      // get the group by value
      var groupByValue = userDocumentMap[groupByUserValue] as int? ?? 0;
      groupByValue = increment ? groupByValue + 1 : groupByValue - 1;
      _logger.finest(
          '($runtimeType._updateGroupByCounterTransaction): document '
          '${document.id} increment $increment, oldDetailsData '
          '${oldDetailsData?.id}. $groupByUserValue new value $groupByValue');
      // increment/decrement group by value based
      userDocumentMap[groupByUserValue] = groupByValue;
      // oldDocument is set, decrement/increment value for old document
      if (oldDetailsData != null) {
        var oldGroupByValue = userDocumentMap[oldGroupByUserValue] as int? ?? 0;
        if (oldGroupByValue > 0) {
          oldGroupByValue =
              increment ? oldGroupByValue - 1 : oldGroupByValue + 1;
          _logger.finest('($runtimeType._updateGroupByCounterTransaction): '
              'document ${document.id} increment $increment, '
              'oldDetailsData ${oldDetailsData.id} '
              '$oldGroupByUserValue (old) new value $oldGroupByValue');
          userDocumentMap[oldGroupByUserValue!] = oldGroupByValue;
        }
      }
      // update the user document
      userDocument[groupByUserField] = userDocumentMap;
    }
    if ((await transaction.get(userDocumentReference)).exists) {
      transaction.update(userDocumentReference, userDocument);
    } else {
      transaction.set(userDocumentReference, userDocument);
    }
  }

  /// Returns the group by field stored in user collection.
  ///
  /// The field format is `_groupBy<Collection><Field1>...<FieldN>`.
  String? _groupByUserField() => _groupByFields?.isNotEmpty ?? false
      ? '_groupBy${_collection.capitalize()}'
          '${_groupByFields!.keys.reduce(
          (
            value,
            element,
          ) =>
              '${value.capitalize()}${element.capitalize()}',
        )}'
      : null;

  /// Returns the group by value stored in user collection.
  ///
  /// The value format is `<Field1Value>|...|<FieldNValue>`.
  String? _groupByUserValue(DetailsDataType details) =>
      _groupByFields?.isNotEmpty ?? false
          ? _groupByFields!.values.nonNulls
              .map(
                (e) => e(details),
              )
              .reduce((value, element) => '$value|$element')
          : null;

  /// Splits the group by value stored in user collection based of
  /// [_groupByFields].
  ///
  /// The map format is `{field1: Field1Value,...,fieldM: fieldNValue}`.
  Map<String, String>? _splitGroupByFields(String? groupByKeyValue) {
    if (groupByKeyValue == null) return null;
    final ret = <String, String>{};
    final values = groupByKeyValue.split('|').toList();
    for (var i = 0; i < values.length; i++) {
      final keyValue = values[i];
      ret[_groupByFields!.keys.elementAt(i)] = keyValue;
    }
    return ret;
  }

  /// Sort function of [GroupByResult].
  int _sortByGroupByFields(
    GroupByResult a,
    GroupByResult b, {
    required OrderDirection groupByFieldsOrder,
  }) {
    // compare each groupByField returning when comparison differs
    return a.compareTo(b) *
        (groupByFieldsOrder == OrderDirection.desc ? -1 : 1);
  }

  /// Check is user is autentichate.
  ///
  /// if [_userProfile] is `true` and user not authenticated, throws
  /// [UserNotAuthenticatedException]
  void _checkAuthenticated() {
    if (_userProfile && AuthViewModel.instance.notAutenticated) {
      throw UserNotAuthenticatedException();
    }
  }

  /// Gets the collection reference for [LightDataType] applying `fromFirestore`
  /// and `toFirestore` converters.
  firestore.CollectionReference<LightDataType> get _collectionReference =>
      _firestore.collection(_collectionPath).withConverter(
            fromFirestore: (snapshot, _) =>
                FirestoreData.fromFirestoreFactory<LightDataType>(
              snapshot.data()!,
            ),
            toFirestore: (LightDataType lightData, _) =>
                lightData.toFirestore(null),
          );

  /// Gets the collection reference for [DetailsDataType] applying
  /// `fromFirestore` and `toFirestore` converters.
  firestore.CollectionReference<DetailsDataType>
      get _detailsCollectionReference =>
          _firestore.collection(_detailsCollectionPath!).withConverter(
                fromFirestore: (snapshot, _) =>
                    FirestoreData.fromFirestoreFactory<DetailsDataType>(
                  snapshot.data()!,
                ),
                toFirestore: (DetailsDataType detailsData, _) =>
                    detailsData.toFirestore(null),
              );

  /// Gets the collection path for [LightDataType] based on [_collection]
  /// and [_userProfile].
  ///
  /// [_userProfile] false: `/[collection]`
  /// [_userProfile] true: `/users/[uid]/[collection]`
  String get _collectionPath => _userProfile
      ? 'users'
          "${_collection == "" ? "" : "/$_uid/$_collection"}"
      : _collection;

  /// Gets the collection for [LightDataType]  path obfuscating `uid`.
  String get _collectionPathLog => _userProfile
      ? 'users'
          "${_collection == "" ? "" : "/<uid>/$_collection"}"
      : _collection;

  /// Gets the collection path for [DetailsDataType] based on [_collection]
  /// and [_userProfile].
  ///
  /// [_userProfile] false: `/[collection]_details`
  /// [_userProfile] true: `/users/[uid]/[collection]_details`
  String? get _detailsCollectionPath => _userProfile
      ? 'users'
          "${_detailsCollection == "" ? "" : "/$_uid/$_detailsCollection"}"
      : _detailsCollection;

  /// Gets the collection for [DetailsDataType]  path obfuscating `uid`.
  String? get _detailsCollectionPathLog => _userProfile
      ? 'users'
          "${_detailsCollection == "" ? "" : "/<uid>/$_detailsCollection"}"
      : _detailsCollection;

  /// Gets the uid of authenticated user.
  ///
  /// If user isn't authenticathed, throw [UserNotAuthenticatedException]
  String get _uid => AuthViewModel.instance.autenticated
      ? AuthViewModel.instance.uid!
      : throw UserNotAuthenticatedException();
}

/// the abstract Firestore Data class that must be extended by `LightDataType`
/// and `DetailsDataType` generics for [Store].
abstract class FirestoreData<T> {
  /// Create a firestore data object.
  const FirestoreData();

  /// The id getter.
  String get id;

  /// global map wich contains al fromFirestoreFactory for type `T`
  static final Map<Type, dynamic Function(Map<String, dynamic> map)>
      _registeredFromFirestoreFactory = {};

  /// register a `fromFirestore` Factory for type `T`
  static void registerFromFirestoreFactory<T>(
    T Function(Map<String, dynamic> map) fromFirestoreFactory,
  ) {
    if (T == dynamic) {
      throw InvalidFirestoreDataTypeException();
    }
    _registeredFromFirestoreFactory[T] = fromFirestoreFactory;
  }

  /// call the `fromFirestore` Factory for type `T` with [map] parameter
  /// and return the object created.
  static T fromFirestoreFactory<T extends FirestoreData<dynamic>>(
    Map<String, dynamic> map,
  ) {
    final object = _registeredFromFirestoreFactory[T]?.call(map);
    if (object != null) {
      return object! as T;
    } else {
      throw FirestoreTypeUnregistredException(T.runtimeType);
    }
  }

  /// Returns the parent data.
  ///
  /// Used in [Store] to read data from `LightDataType` from `DetailsDataType`
  /// object.
  FirestoreData<dynamic>? getParentData() {
    return null;
  }

  /// Sets the parent data.
  ///
  /// Used in [Store] to set the data of `LightDataType` object.
  T setParentData(FirestoreData<dynamic> parentData) =>
      fromFirestoreFactory({});

  /// Returns the map of object used to save into firestore.
  ///
  ///
  /// if [fields] is set, map contains only field defined in.
  Map<String, dynamic> toFirestore(List<String>? fields);

  /// Converts [DateTime] into firestore [firestore.Timestamp]
  static firestore.Timestamp? toFirestoreTimestamp(DateTime? dateTime) {
    return dateTime == null ? null : firestore.Timestamp.fromDate(dateTime);
  }

  /// Converts firestore [firestore.Timestamp] into [DateTime]
  static DateTime? fromFirestoreTimestamp(Object? timestamp) {
    return (timestamp as firestore.Timestamp?)?.toDate();
  }
}

/// Exceptions throws when the [count] of [Store.aggregateFields] for
/// [collection] exceeds 29.
class TooManyAggregateFieldsException implements Exception {
  /// Create a TooManyAggregateFieldsException.
  TooManyAggregateFieldsException({
    required this.collection,
    required this.count,
  });

  /// The name of the collection where the exception occurred.
  String collection;

  /// The number of aggregate fields that caused the exception.
  int count;
  @override
  String toString() => 'too many aggregateFields for collection $collection. '
      'Expected <= 29 found '
      ' groupByFields works only in user profile collections';
}

/// Exceptions throws when the [Store._groupByFields] is set but
/// [collection] isn't a user collection ([Store._userProfile] is `false`).
class InvalidGroupByConfigurationException implements Exception {
  /// Create a InvalidGroupByConfigurationException.
  InvalidGroupByConfigurationException({required this.collection});

  /// The name of the collection where the exception occurred.
  String collection;

  @override
  String toString() => 'groupByFields is set and userProfile is false for '
      'collection $collection.'
      ' groupByFields works only in user profile collections';
}

/// An exception thrown when a `fromFirestore` factory is not registered for a
/// specific [FirestoreData] type.
class FirestoreTypeUnregistredException implements Exception {
  /// Create a FirestoreTypeUnregistredException.
  FirestoreTypeUnregistredException(this.type);

  /// The type for which the factory was not found.
  Type type;

  @override
  String toString() => 'function toFirestore not registered for type $type ';
}

/// An exception thrown when an update operation is attempted with an empty
/// list of fields.
class InvalidFieldsUpdateException implements Exception {
  /// Create a InvalidFieldsUpdateException.
  InvalidFieldsUpdateException(this.path);

  /// The path of the document that was being updated.
  String path;

  @override
  String toString() => 'try to update $path with empty fields';
}

/// An exception thrown when a requested document is not found in Firestore.
class DocumentNotFoundException implements Exception {
  /// Create a DocumentNotFoundException.
  DocumentNotFoundException(this.path);

  /// The path of the document that was not found.
  String path;

  @override
  String toString() => 'document not found at $path';
}

/// An exception thrown when `registerFromFirestoreFactory` is called with a
/// `dynamic` type.
class InvalidFirestoreDataTypeException implements Exception {
  @override
  String toString() => "type <T> cannot by 'dynamic'. "
      'Set correct type <T> calling registerFromFirestoreFactory<T>';
}

/// An exception thrown when a store is configured with separate light and
/// detailed types, but the `detailsFromFirestoreFactory` is not provided.
class DetailsFromFirestoreFactoryNullException implements Exception {
  /// Create a DetailsFromFirestoreFactoryNullException.
  DetailsFromFirestoreFactoryNullException(
    this.lightDataType,
    this.detailsDataType,
  );

  /// The lightweight data type.
  Type lightDataType;

  /// The detailed data type.
  Type detailsDataType;

  @override
  String toString() => 'detailsFromFirestoreFactory parameters is null '
      'and <LightDataType> $lightDataType != <DetailsDataType> '
      '$detailsDataType';
}

/// An exception thrown when `getParentData()` returns `null` in a store with
/// separate light and detailed types.
class ParentDataNullException implements Exception {
  /// Create a ParentDataNullException.
  ParentDataNullException(this.detailsDataType);

  /// The detailed data type.
  Type detailsDataType;

  @override
  String toString() =>
      '<DetailsDataType> $detailsDataType getParentData() returns null';
}

/// extension of String adding [StringExtension.capitalize] function.
extension StringExtension on String {
  /// Returns a new string with the first character capitalized.
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
