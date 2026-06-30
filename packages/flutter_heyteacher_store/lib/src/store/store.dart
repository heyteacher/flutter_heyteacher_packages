/// # `flutter_heyteacher_store`

/// Firebase Firestore library using [generics](https://dart.dev/language/generics|generics).

/// * use [generics](https://dart.dev/language/generics|generics) to define two
///   different DataType in [firestore.CollectionReference.withConverter]
///   * `<LightDataType>` the lighweight [FirestoreData] document used in
///      [Store.list] and [Store._query]
///   * `<DetailsDataType>` the full detailed [FirestoreData] document used in
///     [Store.get], [Store.set] and [Store.update]

/// * manage collection separation in a main collection wich store
///   `<LightDataType>` documents and a `<collection>_details` which store
///   `<DetailsDataType>` documents (only if `<LightDataType>` and
///   `<DetailsDataType>` differs)

/// * manage the user collection `/users/<uid>/` with [Store.userProfile]
///   integrating [FirebaseAuth] using automatically the `uid` of authenticated
///   user

/// * manage data filtering with [StoreFilter]

/// * manage multiple order by field with [Store.orderByFields]

/// * manage aggregate field via [Store.aggregateFields] and notify aggregate
///   value changes via [Store.aggregateStream]

/// * cache `DetailsDataType` object in [SharedPreferencesAsync]

/// ## Usage

/// Consider the following example, store tracks in `Firestore` in these way:

/// * store in `/users/<uid>/tracks` `BaseTrackData` document (`<LightDataType>`)
/// * store in `/users<uid>/tracks_details` `TrackData` document (`<DetailsDataType>`)
/// * order by track `startTime` descending
/// * aggregate `distance` and `duration`
/// * group by track `year`

/// Define `TrackStore` class:

/// ```dart
/// class TrackStore extends Store<BaseTrackData, TrackData> {
///  TrackStore._()
///      : super(
///            /// the main collection which store BaseTrackData document
///            collection: "tracks",
///            /// store data into /users/<uid>/tracks
///            userProfile: true,
///            /// order by track start time
///            orderByFields: {"startTime": true},
///            /// aggregate per track distance and track duration
///            aggregateFields: ["distance", "duration"],
///            /// factory per BaseTrackData creation
///            fromFirestoreFactory: BaseTrackData.fromFirestore,
///            /// factory per TrackData creation
///            detailsFromFirestoreFactory: TrackData.fromFirestore);

///  /// singleton
///  static TrackStore? _instance;
///  static TrackStore get instance {
///    _instance ??= TrackStore._();
///    return _instance!;
///  }
/// ```

/// Define the `BaseTrackData` class, the `<LightDataType>` which store basic data in `/users/<uid>/tracks` collection

/// ```dart
/// class BaseTrackData extends FirestoreData {
///  static final DateFormat keyDateTimeFormatter =
///  DateFormat("yyyyMMdd_HHmmss");

///  DateTime startTime;
///  DateTime? stopTime;
///  num? duration;
///  num? distance;

///  @override
///  String get id => keyDateTimeFormatter.format(startTime.toLocal());

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

///  @override
///  Map<String, dynamic> toFirestore() => {
///        'startTime': FirestoreData.toFirestoreTimestamp(startTime),
///        'stopTime': FirestoreData.toFirestoreTimestamp(stopTime),
///        'duration': duration,
///        'distance': distance,
///  };
/// ```

/// Define the`TrackData`, the `<DetailsDataType>` which store details data in `/users/<uid>/tracks_details` collection.

/// * extends the `<LightDataType>` `TrackData`

/// * implements [FirestoreData.getParentData] and [FirestoreData.setParentData]
///   used to get and set data of super class `BaseTrackData` which store data
///   in `/users/<uid>/tracks`

/// So, `<DetailsDataType>` contains the merge of data stored
/// `/users/<uid>/tracks` `/users/<uid>/tracks_details`

/// ```dart
/// class TrackData extends BaseTrackData {
///   late List<LocationData> locations;

///   TrackData(
///       {required super.startTime,
///       super.stopTime,
///       super.duration,
///       super.distance,
///       super.average,
///       this.locations = const []});

///   factory TrackData.fromFirestore(Map<String, dynamic> map) {
///     List<LocationData> locations = [];
///     for (var location in jsonDecode(map["locations"])) {
///       locations.add(LocationData.fromJson(location));
///     }
///     return TrackData(
///         startTime: FirestoreData.fromFirestoreTimestamp(map['startTime'])!,
///         locations: locations);
///   }

///   @override
///   Map<String, dynamic> toFirestore() => {
///         'startTime': FirestoreData.toFirestoreTimestamp(startTime),
///         'locations': jsonEncode(locations)
///       };

///   @override
///   void setParentData(FirestoreData parentData) {
///     BaseTrackData baseTrackData = parentData as BaseTrackData;
///     startTime = baseTrackData.startTime;
///     distance = baseTrackData.distance;
///     duration = baseTrackData.duration;
///     stopTime = baseTrackData.stopTime;
///   }

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

/// Define the `UserStore`  an user collection `/users/<uid>` ([Store.collection] is empty).
/// Since `<LightDataType>` and `<DetailsDataType>` are equal to `UserData`
/// *_details collection isn't created

/// ```dart
/// class UserStore extends Store<UserData, UserData> {
/// UserStore._()
///      : super(
///            collection: "",
///            userProfile: true,
///            fromFirestoreFactory: UserData.fromFirestore);

/// /// singleton
/// static UserStore? _instance;
/// static UserStore get instance {
///   _instance ??= UserStore._();
///   return _instance!;
/// }
/// ```

/// ## Example

/// The complete example can be found in [`track_store.dart`](test/track_store.dart) inside [`unit tests`](test/store_test.dart)

library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart'
    show AuthViewModel;
import 'package:flutter_heyteacher_store/src/store/base_store.dart';
import 'package:flutter_heyteacher_store/src/store/store_data.dart';
import 'package:flutter_heyteacher_store/src/store/store_exceptions.dart';
import 'package:flutter_heyteacher_store/src/store/store_filters.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The abstract [Store] class to be extended.
///
/// Sub classes must supplying generics [LightDataType], [DetailsDataType] and
/// constructor parameters.
abstract class Store<LightDataType extends FirestoreData<dynamic>,
        DetailsDataType extends LightDataType>
    extends BaseStore<LightDataType, DetailsDataType> {
  /// The store constructor.
  ///
  /// Create a store with these paramenters:
  /// - [collection]: the collection name
  /// - [userProfile]:  if is a user collection
  /// - [fromFirestoreFactory]: the factory for [LightDataType]
  /// - [fromFirestoreFactory]: the factory for [DetailsDataType]
  /// - [orderByFields]: the order by fields
  /// - [aggregateFields]: the aggregate fields
  /// - [storeFilter]: the filters applied to [_query]
  /// - [cacheEnabled]: `True` if cache is enabled
  @protected
  Store({
    required super.collection,
    required super.userProfile,
    required super.fromFirestoreFactory,
    super.detailsFromFirestoreFactory,
    super.orderByFields,
    super.aggregateFields,
    super.storeFilter,
    super.databaseId,
    super.cacheEnabled = true,
    super.offlineEnabled = true,
    firestore.FirebaseFirestore? firebaseFirestore,
  }) {
    _firestore = firebaseFirestore ??
        (databaseId == null
            ? firestore.FirebaseFirestore.instance
            : firestore.FirebaseFirestore.instanceFor(
                app: firestore.FirebaseFirestore.instance.app,
                databaseId: databaseId,
              ));
    if (!fakeFirestore) {
      // enable persistence for offline access
      _firestore.settings = firestore.Settings(
        persistenceEnabled: offlineEnabled,
      );
    }
  }
  final _logger = Logger('Store');

  late final firestore.FirebaseFirestore _firestore;

  /// return True if [_firestore] is a `FakeFirebaseFirestore`
  @override
  bool get fakeFirestore =>
      _firestore.runtimeType.toString() == 'FakeFirebaseFirestore';

  /// Returns the stream on [Store._query].
  ///
  /// If [applyOrderBy] and [limit] not equals 1, order by
  /// [Store.orderByFields].
  ///
  /// If [applyFilterBy], filter by [Store.storeFilter].
  ///
  /// If [limit] is not null, apply limit.
  @override
  Stream<Iterable<LightDataType>> stream({
    bool applyOrderBy = false,
    bool applyFilterBy = true,
    int? limit,
  }) =>
      AuthViewModel.instance.notAutenticated
          ? const Stream.empty()
          : _query(
              applyOrderBy: applyOrderBy,
              applyFilterBy: applyFilterBy,
              limit: limit,
            ).snapshots().map(
                (querySnapshot) =>
                    querySnapshot.docs.map((document) => document.data()),
              );

  /// Returns the list of [LightDataType] based on [Store.storeFilter] ordered
  /// by [Store.orderByFields] limited to [limit]
  @override
  Future<Iterable<LightDataType>> list({int? limit}) async {
    _logger.finest('<$runtimeType.list>: $collectionPathLog orderByFields: '
        '$orderByFields limit: $limit)');
    checkAuthenticated();
    return (await _query(applyOrderBy: true, limit: limit).get())
        .docs
        .map((e) => e.data());
  }

  /// Returns the count of [LightDataType] based on [Store.storeFilter] ordered
  @override
  Future<int> count() async {
    _logger.finer('<$runtimeType.count>: $collectionPathLog '
        'storeFilter $storeFilter');
    checkAuthenticated();
    return (await _query().count().get()).count ?? 0;
  }

  /// Returns the list of [DetailsDataType].
  ///
  /// If [applyFilterBy] is true, filter by [Store.storeFilter].
  /// If [applyOrderBy] is true order by [Store.orderByFields].
  /// If [limit] is not null, apply limit.
  @override
  Future<Iterable<DetailsDataType>> listDetails({
    bool applyOrderBy = false,
    bool applyFilterBy = true,
    int? limit,
  }) async {
    _logger
        .finer('<$runtimeType.listDetailed>: $collectionPathLog orderByFields: '
            '$orderByFields limit: $limit)');
    checkAuthenticated();
    firestore.Query<DetailsDataType> retQuery = _detailsCollectionReference;
    // apply filter
    if (applyFilterBy && storeFilter != null) {
      _logger.finest('($runtimeType.listDetailed): storeFilter $storeFilter');
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

  /// Returns the [DetailsDataType ] document identified by [id].
  ///
  /// [DocumentNotFoundException] is throw if document doesn't exist.
  @override
  Future<DetailsDataType> get(String id) async => lock.synchronized(() async {
        _logger.finer(
          '<$runtimeType.get[synchronized]>: $detailsCollectionPathLog/$id)',
        );
        if (storeCache?.exists(id) ?? false) {
          final cached = await storeCache?.get(id);
          if (cached != null) {
            return cached;
          } else {
            // document cached but null
            throw DocumentNotFoundException('$detailsCollectionPathLog/$id');
          }
        }
        checkAuthenticated();
        final detailsDocumentSnapshot =
            await _detailsCollectionReference.doc(id).get();
        // check if exists
        if (detailsDocumentSnapshot.exists) {
          DetailsDataType details = detailsDocumentSnapshot.data()!;
          if (separatedDetailsCollection) {
            final documentSnapshot = await _collectionReference.doc(id).get();
            // populate parent data fields
            if (documentSnapshot.exists) {
              details = details.setParentData(documentSnapshot.data()!)
                  as DetailsDataType;
              storeCache?.set(id, details);
              return details;
            } else {
              storeCache?.set(id, null);
              throw DocumentNotFoundException('$collectionPathLog/$id');
            }
          } else {
            storeCache?.set(id, details);
            return details;
          }
        } else {
          throw DocumentNotFoundException('$detailsCollectionPathLog/$id');
        }
      });

  /// Delete document identified by [id].
  ///
  /// If [batch] is not null, apply the `delete` operationto batch that will be
  /// esecuted by [firestore.WriteBatch.commit].
  @override
  Future<void> delete(String id, {dynamic batch}) async {
    _logger.finer('<$runtimeType.delete>: $detailsCollectionPathLog/$id');
    batch as firestore.WriteBatch?;
    checkAuthenticated();
    if (batch != null) {
      batch.delete(_detailsCollectionReference.doc(id));
    } else {
      storeCache?.delete(id);
      await _detailsCollectionReference.doc(id).delete();
    }
    if (separatedDetailsCollection) {
      _logger.finer('($runtimeType.delete): $collectionPathLog/$id');
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
  @override
  Future<void> bulkDelete(
    Iterable<String> ids,
  ) async {
    _logger.finer(
      '<$runtimeType.bulkDelete>: $detailsCollectionPathLog, ids: $ids)',
    );
    checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < ids.length; i++) {
      // need await operation in order batch commit will by executed as last
      // operation
      await delete(ids.elementAt(i), batch: batch);
      storeCache?.delete(ids.elementAt(i));
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
  @override
  Future<void> set(
    DetailsDataType detailsData, {
    String? id,
    dynamic batch,
  }) async {
    id ??= detailsData.id;
    batch as firestore.WriteBatch?;
    _logger.finer('<$runtimeType.set>: $detailsCollectionPathLog/$id');
    checkAuthenticated();
    if (batch != null) {
      batch.set(_detailsCollectionReference.doc(id), detailsData);
    } else {
      await _detailsCollectionReference.doc(id).set(detailsData);
    }
    if (separatedDetailsCollection) {
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
    // if batch in set, delegate thee caller to notify changes
    if (batch == null) {
      storeCache?.set(id, detailsData);
      unawaited(notifyAggregatesChanges());
    }
  }

  /// Creates (override) massively [documents] identified by list [ids].
  @override
  Future<void> bulkSet(
    List<DetailsDataType> documents, {
    Iterable<String>? ids,
  }) async {
    _logger.finer('<$runtimeType.bulkSet>: $detailsCollectionPathLog ids $ids');
    checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < documents.length; i++) {
      // need await operation in order batch commit will by executed as
      // last operation
      await set(documents[i], id: ids?.elementAt(i), batch: batch);
      storeCache?.set(ids?.elementAt(i) ?? documents[i].id, documents[i]);
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
  @override
  Future<void> update(
    DetailsDataType document, {
    required List<String> fields,
    String? id,
    dynamic batch,
  }) async {
    id ??= document.id;
    _logger.finer(
      '<$runtimeType.update>: $detailsCollectionPathLog/$id fields: $fields)',
    );
    if (fields.isEmpty) {
      throw InvalidFieldsUpdateException('$detailsCollectionPathLog/$id');
    }
    checkAuthenticated();
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
      if (separatedDetailsCollection) {
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
      // if batch in set, delegate thee caller to notify changes
      if (batch == null) {
        storeCache?.set(id, document);
        unawaited(notifyAggregatesChanges());
      }
    } else {
      _logger.finer(
        '<$runtimeType.update>: $detailsCollectionPathLog/$id fields: $fields) '
        ' document not found, create it with `set`',
      );
      // document not found, create it with `set`
      unawaited(set(document, batch: batch));
    }
  }

  /// Updates massively documents identified by list [ids].
  ///
  /// Updates only fields specified in [fields].
  @override
  Future<void> bulkUpdate(
    List<DetailsDataType> documents, {
    required List<String> fields,
    Iterable<String>? ids,
  }) async {
    _logger.finer(
      '<$runtimeType.bulkUpdate>: $detailsCollectionPathLog fields $fields',
    );
    checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < documents.length; i++) {
      // need await operation in order batch commit will by executed as last
      // operation
      await update(
        documents[i],
        fields: fields,
        id: ids?.elementAt(i),
        batch: batch,
      );
      storeCache?.set(ids?.elementAt(i) ?? documents[i].id, documents[i]);
    }
    await batch.commit();
    unawaited(notifyAggregatesChanges());
  }

  /// Returns a [firestore.Pipeline] declared on collection path.
  firestore.Pipeline get collectionPipeline {
    _logger.finest('<$runtimeType.collectionPipeline>:');
    checkAuthenticated();
    return _firestore.pipeline().collection(collectionPath);
  }

  /// Returns a [firestore.Pipeline] declared on detailed collection path.
  firestore.Pipeline? get detailedCollectionPipeline {
    _logger.finest('<$runtimeType.detailedCollectionPipeline>:');
    checkAuthenticated();
    return _firestore.pipeline().collection(detailsCollectionPath);
  }

  /// Yields an aggregation result based on [aggregateFields].
  @override
  Future<AggregateData?> get aggregates async {
    _logger.finest('<$runtimeType.aggregates>:');
    checkAuthenticated();
    if (aggregateFields == null || aggregateFields!.isEmpty) return null;
    final aggregateParams = <firestore.AggregateField?>[
      for (var i = 0; i < 29; i++)
        aggregateFields!.length > i
            ? aggregateFields![i].aggregatationType == AggregatationType.sum
                ? firestore.sum(aggregateFields![i].field)
                : firestore.average(aggregateFields![i].field)
            : null,
    ];
    _logger.finest('($runtimeType.aggregates): not null');
    return _AggregateQueryData(
      await _query()
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
          .get(),
    );
  }

  /// Return a query of [LightDataType].
  ///
  /// If [applyOrderBy] and [limit] not equals 1, order by
  /// [Store.orderByFields].
  ///
  /// If [applyFilterBy], filter by [Store.storeFilter].
  ///
  /// If [limit] is not null, apply limit.
  firestore.Query<LightDataType> _query({
    bool applyOrderBy = false,
    bool applyFilterBy = true,
    int? limit,
  }) {
    assert(limit == null || limit > 0, 'if set, limit must be > 0');
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

  /// Gets the collection reference for [LightDataType] applying `fromFirestore`
  /// and `toFirestore` converters.
  firestore.CollectionReference<LightDataType> get _collectionReference =>
      _firestore.collection(collectionPath).withConverter(
            fromFirestore: (snapshot, _) =>
                FirestoreData.fromFirestoreFactory<LightDataType>(
              snapshot.data()!,
            ),
            toFirestore: (lightData, _) => lightData.toFirestore(null),
          );

  /// Gets the collection reference for [DetailsDataType] applying
  /// `fromFirestore` and `toFirestore` converters.
  firestore.CollectionReference<DetailsDataType>
      get _detailsCollectionReference =>
          _firestore.collection(detailsCollectionPath).withConverter(
                fromFirestore: (snapshot, _) =>
                    FirestoreData.fromFirestoreFactory<DetailsDataType>(
                  snapshot.data()!,
                ),
                toFirestore: (detailsData, _) => detailsData.toFirestore(null),
              );
}

class _AggregateQueryData implements AggregateData {
  _AggregateQueryData(this._snapshot);

  final firestore.AggregateQuerySnapshot _snapshot;

  @override
  int? get count => _snapshot.count;

  @override
  double? getSum(String field) => _snapshot.getSum(field);

  @override
  double? getAverage(String field) => _snapshot.getAverage(field);
}
