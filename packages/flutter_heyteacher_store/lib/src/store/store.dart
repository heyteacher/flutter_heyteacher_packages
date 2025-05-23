/// Firebase Firestore library using [generics](https://dart.dev/language/generics|generics).
///
/// Main funtionality are:
///
/// * use [generics](https://dart.dev/language/generics|generics) to define two different DataType in [CollectionReference.withConverter]
///   * `<LightDataType>` the lighweight [FirestoreData] document used in [Store.list] and [Store.query]
///   * `<DetailsDataType>` the full detailed [FirestoreData] document used in [Store.get], [Store.set] and [Store.update]
///
/// * manage collection separation in a main collection wich store `<LightDataType>` documents
///   and a `<collection>_details` which store `<DetailsDataType>` documents (only if `<LightDataType>` and `<DetailsDataType>` differs)
///
/// * manage the user collection `/users/<uid>/` with [Store._userProfile] integrating [FirebaseAuth] using
///   automatically the `uid` of authenticated user
///
/// * manage data filtering with [StoreFilter]
///
/// * manage multiple order by field with [Store.orderByFields]
///
/// * implement distinct and group by [Store._groupByFields]
///
/// * manage aggregate field via [Store.aggregateFields] and notify aggregate value changes via [Store.aggregateStream]
///
/// * cache [DetailsDataType] object in [SharedPreferencesAsync]
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
///  static final DateFormat keyDateTimeFormatter = DateFormat("yyyyMMdd_HHmmss");
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
///                DateTime.now(),
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
/// * implements [FirestoreData.getParentData] and [FirestoreData.setParentData] used to get and set data
///   of super class `BaseTrackData` which store data in `/users/<uid>/tracks`
///
/// So, `<DetailsDataType>` contains the merge of data stored `/users/<uid>/tracks` `/users/<uid>/tracks_details`
///
///```
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
///       locations.add(LocationData.fromMap(location));
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
/// Since `<LightDataType>` and `<DetailsDataType>` are equal to [UserData] *_details collection isn't created
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
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_store/src/store/store_filters.dart';
import 'package:flutter_heyteacher_utils/e2ee.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Order enumeration.
///
/// Defines [desc] and [asc] constants used to define order by
enum OrderDirection {
  /// descendent order
  desc,
  // ascedent order
  asc
}

/// A group-by result.
///
/// Stores a group-by result as a pair of
/// - [groupByFields] map which contains group by field and the field value
/// - [value] the aggregate values
class GroupByResult {
  /// map which contains group by field and the field value
  final Map<String, String> groupByFields;

  /// the aggregate values
  final Object value;
  GroupByResult({required this.groupByFields, required this.value});

  @override
  bool operator ==(Object other) {
    if (other is! GroupByResult) return false;
    return compareTo(other) == 0;
  }

  compareTo(GroupByResult b) {
    for (var key in groupByFields.keys) {
      int compare = groupByFields[key]!.compareTo(b.groupByFields[key]!);
      if (compare != 0) return compare;
    }
    return 0;
  }

  @override
  int get hashCode {
    var result = 17;
    for (var key in groupByFields.keys) {
      result = 37 * result + key.hashCode;
    }
    return result;
  }
}

/// The abstract [Store] class to be extended.
///
/// Sub classes must supplying generics [LightDataType], [DetailsDataType] and
/// constructor parameters.
abstract class Store<LightDataType extends FirestoreData,
    DetailsDataType extends LightDataType> {
  final _log = Logger('Store');

  late final FirebaseFirestore _firestore;

  /// the map of order by fields.
  ///
  /// An key of entry is the field, the value of entry must be [OrderDirection.desc] or
  /// [OrderDirection.asc]
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

  /// The subscrition to listen aggregate changes.
  StreamSubscription<User?>? _aggregatesSubscription;

  /// The stream controller to yield aggregates changes.
  final StreamController<AggregateQuerySnapshot> _aggregateStreamController =
      StreamController<AggregateQuerySnapshot>.broadcast();

  /// The aggregate stream where aggregate changes are notified
  Stream<AggregateQuerySnapshot> get aggregateStream =>
      _aggregateStreamController.stream;

  final SharedPreferencesAsync _sharedPreferences = SharedPreferencesAsync();

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
  Store(
      {required String collection,
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
      FirebaseFirestore? firebaseFirestore})
      : _offlineEnabled = offlineEnabled, _cacheEnabled = cacheEnabled, _userProfile = userProfile,
        _collection = collection,
        _groupByFields = groupByFields,
        _separatedDetailsCollection = LightDataType != DetailsDataType {
    _firestore = firebaseFirestore ?? FirebaseFirestore.instance;

    // enable persistence for offline access
    _firestore.settings = Settings(persistenceEnabled: _offlineEnabled);
    _log.finest('Store: $_collectionPathLog '
        'userProfile $_userProfile  '
        'separatedDetailsCollection $_separatedDetailsCollection '
        'orderByFields $orderByFields '
        'aggregateFields $aggregateFields '
        'groupByFields ${_groupByUserField()}'
        'cacheEnabled $_cacheEnabled '
        'offlineEnabled $_offlineEnabled');

    _log.finest('Store: register fromFireStoreFactory');
    FirestoreData.registerFromFirestoreFactory<LightDataType>(
        fromFirestoreFactory);
    // manage the separated detail collection
    if (_separatedDetailsCollection) {
      this._detailsCollection = '${_collection}_details';
      _log.finest('Store: detailsCollection $_detailsCollectionPathLog ');

      if (detailsFromFirestoreFactory != null) {
        _log.finest('Store: register detailsFromFirestoreFactory');
        FirestoreData.registerFromFirestoreFactory<DetailsDataType>(
            detailsFromFirestoreFactory);
      } else {
        throw DetailsFromFirestoreFactoryNullException(
            LightDataType, DetailsDataType);
      }
    } else {
      this._detailsCollection = _collection;
    }
    // check and initialize group by
    if (_groupByFields != null) {
      if (!_userProfile) {
        throw InvalidGroupByConfigurationException(collection: _collection);
      }
      _initGroupByCounter();
    }
    // check aggregate fields
    if (aggregateFields != null) {
      if (aggregateFields!.length > 29) {
        throw TooManyAggregateFieldsException(
            collection: _collection, count: aggregateFields!.length);
      }
    }
    // clear cache
    if (_cacheEnabled) {
      _log.finest('clear StoreCache-$runtimeType');
      _sharedPreferences.getAll().then((all) {
        for (var key in all.keys) {
          if (key.startsWith('StoreCache-$runtimeType')) {
            _sharedPreferences.remove(key);
            _log.finest('remove $key');
          }
        }
      });
    }
  }

  /// Initializes the aggregate stream when user i authenticathed.
  void initAggregatesStream() {
    _aggregatesSubscription?.cancel();
    _aggregatesSubscription = AuthModel.instance()
        .stateChangesStream
        .where((user) => user != null)
        .listen(((_) => notifyAggregatesChanges()));
  }

  /// On dispose, cancel the subscriptions.
  dispose() {
    _aggregatesSubscription?.cancel();
  }

  /// Return a Query of LightDataType.
  ///
  /// Apply [applyOrderBy], applies filter if [applyFilterBy] and applies
  /// [limit] if not null.
  Query<LightDataType> query(
      {bool applyOrderBy = false, bool applyFilterBy = true, int? limit}) {
    Query<LightDataType> retQuery = _collectionReference;
    // apply filter
    if (applyFilterBy && storeFilter != null) {
      _log.finest('query: storeFilter $storeFilter');
      retQuery = retQuery.where(storeFilter!.toFirestore());
    }
    // apply order by
    if (applyOrderBy) {
      for (MapEntry<String, OrderDirection> orderbyField
          in orderByFields?.entries ?? {}) {
        retQuery = retQuery.orderBy(orderbyField.key,
            descending: orderbyField.value == OrderDirection.desc);
      }
    }
    // apply limit
    if (limit != null && limit > 0) {
      retQuery = retQuery.limit(limit);
    }
    return retQuery;
  }

  /// Returns the stream on [Store.query]
  Stream<Iterable<LightDataType>> get stream =>
      query(applyOrderBy: true).snapshots().map((querySnapshot) =>
          querySnapshot.docs.map((document) => document.data()));

  /// Returns `true` if collection is empty based on [Store.storeFilter] defined.
  Future<bool> empty() async {
    _log.finest('empty($_collectionPathLog,orderByFields: $orderByFields)');
    _checkAuthenticated();
    return ((await query(applyOrderBy: true).count().get()).count ?? 0) == 0;
  }

  /// Returns `true` if collection is not empty based on [Store.storeFilter]
  /// defined.
  Future<bool> notEmpty() async {
    _log.finest('notEmpty($_collectionPathLog,orderByFields: $orderByFields)');
    _checkAuthenticated();
    return !await empty();
  }

  /// Returns the list of [LightDataType] based on [Store.storeFilter] ordered
  /// by [Store.orderByFields] limited to [limit]
  Future<Iterable<LightDataType>> list({int? limit}) async {
    _log.finest('list($_collectionPathLog,orderByFields: $orderByFields)');
    _checkAuthenticated();
    return (await query(applyOrderBy: true, limit: limit).get())
        .docs
        .map((e) => e.data());
  }

  Future<void> _dumpCache() async {
    final all = await _sharedPreferences.getAll();
    for (var key in all.keys) {
      if (key.startsWith('StoreCache-$runtimeType')) {
        _log.finest('_dumpCache $key: ${all[key]}');
      }
    }
  }

  String _cacheKey(String id) =>
      'StoreCache-$runtimeType-$_detailsCollectionPath-$id';

  Future<DetailsDataType?> _getCached(String id) async {
    if (!_cacheEnabled) return null;
    final key = _cacheKey(id);
    await _dumpCache();
    if (await _sharedPreferences.containsKey(key)) {
      _log.finest('_getCached($key) HIT');
      return FirestoreData.fromFirestoreFactory<DetailsDataType>(
          jsonDecode((await _sharedPreferences.getString(key))!));
    }
    _log.finest('_getCached($key) MISS');
    return null;
  }

  Future<void> _updateCache(String id, DetailsDataType detailsData) async {
    if (!_cacheEnabled) return;
    final key = _cacheKey(id);
    _log.finest('_updateCache($key)');
    await _sharedPreferences.setString(
        key, jsonEncode(detailsData.toFirestore(null)));
    await _dumpCache();
  }

  Future<void> _removeCache(String id) async {
    if (!_cacheEnabled) return;
    final key = _cacheKey(id);
    _log.finest('_removeCache($key)');
    await _sharedPreferences.remove(key);
    await _dumpCache();
  }

  /// Returns `true` if exists a document identified by [id].
  Future<bool> exists(String id) async {
    _log.finest('exists($_detailsCollectionPathLog/$id)');
    final cached = await _getCached(id);
    if (cached != null) return true;
    try {
      await get(id);
      return true;
    } on DocumentNotFoundException {
      return false;
    }
  }

  /// Returns the [DetailsDataType ] document identified by [id].
  ///
  /// [DocumentNotFoundException] is throw if document doesn't exist.
  Future<DetailsDataType> get(String id) async {
    _log.finest('get($_detailsCollectionPathLog/$id)');
    final cached = await _getCached(id);
    if (cached != null) return cached;

    _checkAuthenticated();

    DocumentSnapshot<DetailsDataType>? detailsDocumentSnapshot =
        await _detailsCollectionReference.doc(id).get();
    // check if exists
    if (detailsDocumentSnapshot.exists) {
      DetailsDataType details = detailsDocumentSnapshot.data()!;
      if (_separatedDetailsCollection) {
        _log.finest('get($_collectionPathLog/$id)');
        DocumentSnapshot<LightDataType> documentSnapshot =
            await _collectionReference.doc(id).get();
        // populate parent data fields
        if (documentSnapshot.exists) {
          details.setParentData(documentSnapshot.data()!);
          await _updateCache(id, details);
          return details;
        } else {
          throw DocumentNotFoundException('$_collectionPathLog/$id');
        }
      } else {
        await _updateCache(id, details);
        return details;
      }
    } else {
      throw DocumentNotFoundException('$_collectionPathLog/$id');
    }
  }

  /// Returns the [DetailsDataType ] document identified by [id].
  ///
  /// Returns null if document doesn't exist.
  Future<DetailsDataType?> getOrNull(String? id) async {
    _log.finest('getOrNull($_detailsCollectionPathLog/$id)');
    if (id == null) return null;
    //
    final cached = await _getCached(id);
    if (cached != null) return cached;
    try {
      return get(id);
    } on DocumentNotFoundException {
      return null;
    }
  }

  /// Delete document identified by [id].
  ///
  /// If [batch] is not null, apply the `delete` operationto batch that will be
  /// esecuted by [WriteBatch.commit].
  Future<void> delete(String id, {WriteBatch? batch}) async {
    _log.fine('delete($_detailsCollectionPathLog/$id)');
    _checkAuthenticated();
    if (_groupByFields != null) {
      try {
        await _updateGroupByCounter(await get(id), increment: false);
      } catch (e, s) {
        _log.severe(
            'delete($_detailsCollectionPathLog/$id) error on _changeGroupBy',
            e,
            s);
      }
    }
    if (batch != null) {
      batch.delete(_detailsCollectionReference.doc(id));
    } else {
      await _detailsCollectionReference.doc(id).delete();
    }
    if (_separatedDetailsCollection) {
      _log.fine('delete($_collectionPathLog/$id)');
      if (batch != null) {
        batch.delete(_collectionReference.doc(id));
      } else {
        await _collectionReference.doc(id).delete();
      }
    }
    // if batch in set, delegate thee caller to notify changes
    if (batch == null) {
      await _removeCache(id);
      notifyAggregatesChanges();
    }
  }

  /// Deletes massively documents identified by list [ids].
  Future<void> bulkDelete(
    List<String> ids,
  ) async {
    _log.fine('bulkDelete($_detailsCollectionPathLog, ids: $ids)');
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < ids.length; i++) {
      // need await operation in order batch commit will by executed as last operation
      await delete(ids[i], batch: batch);
      await _removeCache(ids[i]);
    }
    await batch.commit();
    notifyAggregatesChanges();
  }

  /// Creates (override) the document [detailsData] with identifier [id].
  ///
  /// If a document identified by [id] already exists, ovverride it.
  ///
  /// If [batch] is not null, apply the `set` operation to batch that will be
  /// esecuted by [WriteBatch.commit].
  Future<void> set(DetailsDataType detailsData,
      {String? id, WriteBatch? batch}) async {
    id ??= detailsData.id;
    _log.fine('set($_detailsCollectionPathLog/$id)');
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
      LightDataType? parentData = detailsData.getParentData() as LightDataType?;
      if (parentData != null) {
        _log.fine('set($_collectionPathLog/$id)');
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
      await _updateGroupByCounter(detailsData,
          increment: true, oldDetailsData: oldDetailsData);
    }
    // if batch in set, delegate thee caller to notify changes
    if (batch == null) {
      await _updateCache(id, detailsData);
      notifyAggregatesChanges();
    }
  }

  /// Creates (override) massively [documents] identified by list [ids].
  Future<void> bulkSet(List<DetailsDataType> documents,
      {List<String>? ids}) async {
    _log.fine('bulkSet($_detailsCollectionPathLog)');
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < documents.length; i++) {
      // need await operation in order batch commit will by executed as last operation
      await set(documents[i], id: ids?[i], batch: batch);
      await _updateCache(ids?[i] ?? documents[i].id, documents[i]);
    }
    await batch.commit();
    notifyAggregatesChanges();
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
  /// esecuted by [WriteBatch.commit].
  Future<void> update(DetailsDataType document,
      {required List<String> fields, String? id, WriteBatch? batch}) async {
    if (fields.isEmpty) {
      throw InvalidFieldsUpdateException('$_detailsCollectionPathLog/$id');
    }
    id ??= document.id;
    _log.fine('update($_detailsCollectionPathLog/$id, fields: $fields)');
    _checkAuthenticated();
    if (await exists(id)) {
      if (batch != null) {
        batch.update(
            _detailsCollectionReference.doc(id), document.toFirestore(fields));
      } else {
        _detailsCollectionReference
            .doc(id)
            .update(document.toFirestore(fields));
      }
      if (_separatedDetailsCollection) {
        if (document.getParentData() != null) {
          _log.fine('update($_collectionPathLog/$id)');
          if (batch != null) {
            batch.update(_collectionReference.doc(id),
                document.getParentData()!.toFirestore(fields));
          } else {
            _collectionReference
                .doc(id)
                .update(document.getParentData()!.toFirestore(fields));
          }
        } else {
          throw ParentDataNullException(DetailsDataType.runtimeType);
        }
      }
      // document not found, create it
    } else {
      set(document, batch: batch);
    }
    // if batch in set, delegate thee caller to notify changes
    if (batch == null) {
      await _updateCache(id, document);
      notifyAggregatesChanges();
    }
  }

  /// Updates massively documents identified by list [ids].
  ///
  /// Updates only fields specified in [fields].
  Future<void> bulkUpdate(List<DetailsDataType> documents,
      {required List<String> fields, List<String>? ids}) async {
    _log.fine('bulkUpdate($_detailsCollectionPathLog, $fields)');
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < documents.length; i++) {
      // need await operation in order batch commit will by executed as last operation
      await update(documents[i], fields: fields, id: ids?[i], batch: batch);
      await _updateCache(ids?[i] ?? documents[i].id, documents[i]);
    }
    await batch.commit();
    notifyAggregatesChanges();
  }

  /// Returns the list of group by result, with order direction
  /// [groupByFieldsOrderDirection].
  Future<Iterable<GroupByResult>?> groupBy(
      {OrderDirection groupByFieldsOrderDirection = OrderDirection.asc}) async {
    _log.finest('groupBy: collection $_detailsCollectionPathLog');
    String? groupByUserField = _groupByUserField();
    if (groupByUserField == null) return null;
    _checkAuthenticated();
    var user = await _firestore.collection('users').doc(_uid).get();
    Map<String, dynamic>? groupByKey = user.data()?[groupByUserField];
    var iterable = groupByKey?.entries.map(
      (mapEntry) => GroupByResult(
          groupByFields: _splitGroupByFields(mapEntry.key)!,
          value: mapEntry.value),
    );
    return iterable?.sorted((a, b) => _sortByGroupByFields(a, b,
        groupByFieldsOrder: groupByFieldsOrderDirection));
  }

  /// Yields an aggregation result based on [aggregateFields].
  Future<void> notifyAggregatesChanges() async {
    _checkAuthenticated();
    if (aggregateFields == null || aggregateFields!.isEmpty) return;
    List<AggregateField?> aggregateParams = [
      for (var i = 0; i < 29; i++)
        aggregateFields!.length > i ? sum(aggregateFields![i]) : null
    ];
    _log.finest('notifyAggregatesChanges: notify');
    _aggregateStreamController.sink.add(await query()
        .aggregate(
          count(),
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
        .get());
  }

  /// Returns if _initGroupByCounter is already running.
  static bool _initGroupByCounterAlreadyRunning = false;

  /// Initialize the group by counter.
  ///
  /// If already initialized, do nothing. Otherwise load all documents and
  /// update the group by counter.
  void _initGroupByCounter() async {
    if (AuthModel.instance().notAutenticated) {
      _log.finest('_initGroupByCounter: user not authenticate, do nothing');
      return;
    }
    if (_initGroupByCounterAlreadyRunning) {
      _log.finest('_initGroupByCounter: already running, do nothing');
      return;
    } else {
      _initGroupByCounterAlreadyRunning = true;
    }
    String? groupByUserField = _groupByUserField();
    if (groupByUserField != null) {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection('users').doc(_uid).get();
      if (documentSnapshot.data()?[groupByUserField] != null) {
        _log.finest(
            '_initGroupByCounter: user $groupByUserField already initialized. Do nothing');
        return;
      }
      _log.finest(
          '_initGroupByCounter: start scan on $_collection and update $groupByUserField');
      for (var lightData in await list()) {
        DetailsDataType detailsData = await get(lightData.id);
        await _updateGroupByCounter(detailsData, increment: true);
      }
    }
    _initGroupByCounterAlreadyRunning = false;
    _log.finest('_initGroupByCounter: stop scan');
  }

  /// Update the group by counter.
  ///
  /// increment/decrement the group by value based from [document] data.
  ///
  /// if [increment] is true add 1 otherwise subtract 1.
  ///
  /// Il [oldDetailsData] is not null, decrement/increment the counter.
  Future<void> _updateGroupByCounter(DetailsDataType document,
      {required bool increment, DetailsDataType? oldDetailsData}) async {
    if (_groupByFields == null) {
      return;
    }
    assert(_userProfile);
    // user document reference
    DocumentReference<Map<String, dynamic>> userDocumentReference =
        _firestore.collection('users').doc(_uid);
    await _firestore.runTransaction((Transaction transaction) =>
        _updateGroupByCounterTransaction(transaction, userDocumentReference,
            document, increment, oldDetailsData));
    _log.finest('_updateGroupByCounter: transaction completed');
  }

  /// Update the group by counter transaction.
  Future<void> _updateGroupByCounterTransaction(
      Transaction transaction,
      DocumentReference<Map<String, dynamic>> userDocumentReference,
      DetailsDataType document,
      bool increment,
      DetailsDataType? oldDetailsData) async {
    // get the user document snapshot
    DocumentSnapshot<Map<String, dynamic>> userDocumentSnapshot =
        await transaction.get(userDocumentReference);
    // get the user document
    Map<String, dynamic> userDocument = userDocumentSnapshot.data() ?? {};

    String? groupByUserField = _groupByUserField();
    String? groupByUserValue = _groupByUserValue(document);
    String? oldGroupByUserValue =
        oldDetailsData != null ? _groupByUserValue(oldDetailsData) : null;

    if (groupByUserField != null &&
        groupByUserValue != null &&
        groupByUserValue != oldGroupByUserValue) {
      // get the user document map which store group by values
      // into field <collection>_<groupByField>
      Map<String, dynamic> userDocumentMap =
          userDocument[groupByUserField] ?? {};
      // get the group by value
      int groupByValue = userDocumentMap[groupByUserValue] ?? 0;
      groupByValue = increment ? groupByValue + 1 : groupByValue - 1;
      _log.finest(
          '_updateGroupByCounterTransaction: $groupByUserValue new value $groupByValue');
      // increment/decrement group by value based
      userDocumentMap[groupByUserValue] = groupByValue;
      // oldDocument is set, decrement/increment value for old document
      if (oldDetailsData != null) {
        int oldGroupByValue = userDocumentMap[oldGroupByUserValue] ?? 0;
        if (oldGroupByValue > 0) {
          oldGroupByValue =
              increment ? oldGroupByValue - 1 : oldGroupByValue + 1;
          _log.finest(
              '_updateGroupByCounterTransaction: $oldGroupByUserValue (old) new value $oldGroupByValue');
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
      ? "_groupBy${_collection.capitalize()}${_groupByFields!.keys.reduce((value, element) => "${value.capitalize()}${element.capitalize()}")}"
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
    Map<String, String> ret = {};
    List<String> values = groupByKeyValue.split('|').toList();
    for (var i = 0; i < values.length; i++) {
      String keyValue = values[i];
      ret[_groupByFields!.keys.elementAt(i)] = keyValue;
    }
    return ret;
  }

  /// Sort function of [GroupByResult].
  int _sortByGroupByFields(GroupByResult a, GroupByResult b,
      {required OrderDirection groupByFieldsOrder}) {
    // compare each groupByField returning when comparison differs
    return a.compareTo(b) *
        (groupByFieldsOrder == OrderDirection.desc ? -1 : 1);
  }

  /// Check is user is autentichate.
  ///
  /// if [_userProfile] is `true` and user not authenticated, throws
  /// [UserNotAuthenticatedException]
  void _checkAuthenticated() {
    if (_userProfile && AuthModel.instance().notAutenticated) {
      throw UserNotAuthenticatedException();
    }
  }

  /// Gets the collection reference for [LightDataType] applying `fromFirestore`
  /// and `toFirestore` converters.
  CollectionReference<LightDataType> get _collectionReference =>
      _firestore.collection(_collectionPath).withConverter(
          fromFirestore: (snapshot, _) =>
              FirestoreData.fromFirestoreFactory<LightDataType>(
                  snapshot.data()!),
          toFirestore: (LightDataType lightData, _) =>
              lightData.toFirestore(null));

  /// Gets the collection reference for [DetailsDataType] applying
  /// `fromFirestore` and `toFirestore` converters.
  CollectionReference<DetailsDataType> get _detailsCollectionReference =>
      _firestore.collection(_detailsCollectionPath!).withConverter(
          fromFirestore: (snapshot, _) =>
              FirestoreData.fromFirestoreFactory<DetailsDataType>(
                  snapshot.data()!),
          toFirestore: (DetailsDataType detailsData, _) =>
              detailsData.toFirestore(null));

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
  String get _uid => AuthModel.instance().autenticated
      ? AuthModel.instance().uid!
      : throw UserNotAuthenticatedException();
}

/// the abstract Firestore Data class that must be extended by `LightDataType`
/// and `DetailsDataType` generics for [Store].
abstract class FirestoreData<T> {
  /// The id getter.
  String get id;

  /// global map wich contains al fromFirestoreFactory for type `T`
  static final Map<Type, Function(Map<String, dynamic> map)>
      _registeredFromFirestoreFactory = {};

  /// register a `fromFirestore` Factory for type `T`
  static registerFromFirestoreFactory<T>(
      T Function(Map<String, dynamic> map) fromFirestoreFactory) {
    if (T == dynamic) {
      throw InvalidFirestoreDataTypeException();
    }
    _registeredFromFirestoreFactory[T] = fromFirestoreFactory;
  }

  /// call the `fromFirestore` Factory for type `T` with [map] parameter
  /// and return the object created.
  static T fromFirestoreFactory<T extends FirestoreData>(
      Map<String, dynamic> map) {
    T? object = _registeredFromFirestoreFactory[T]?.call(map);
    if (object != null) {
      return object;
    } else {
      throw FirestoreTypeUnregistredException(T.runtimeType);
    }
  }

  /// Returns the parent data.
  ///
  /// Used in [Store] to read data from `LightDataType` from `DetailsDataType`
  /// object.
  FirestoreData? getParentData() {
    return null;
  }

  /// Sets the parent data.
  ///
  /// Used in [Store] to set the data of `LightDataType` object.
  void setParentData(FirestoreData parentData) {}

  /// Returns the map of object used to save into firestore.
  ///
  /// if [fields] is set, map contains only field defined in.
  Map<String, dynamic> toFirestore(List<String>? fields);

  /// Converts [DateTime] into firestore [Timestamp]
  static Timestamp? toFirestoreTimestamp(DateTime? dateTime) {
    return dateTime == null ? null : Timestamp.fromDate(dateTime);
  }

  /// Converts firestore [Timestamp] into [DateTime]
  static DateTime? fromFirestoreTimestamp(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  /// Decrypts End-2-End Encryped data from firestore.
  ///
  /// [map] contains ecrypted `value` and initial vector `iv`.
  static Future<String> fromFirestoreE2EE(Map<String, dynamic> map) async {
    return await E2EE.instance
        .decrypt(E2EEValue(value: map['value'], iv: map['iv']));
  }

  /// Encrypts [value] in End-2-End Dncrypted data to firestore.
  ///
  /// Returns a map containing ecrypted `value` and initial vector `iv`.

  static Future<Map<String, dynamic>> toFirestoreE2EE(String value) async {
    final encrypted = await E2EE.instance.encrypt(value);
    return {'value': encrypted.value, 'iv': encrypted.iv};
  }
}

/// Exceptions throws when the [count] of [Store.aggregateFields] for
/// [collection] exceeds 29.
class TooManyAggregateFieldsException implements Exception {
  String collection;

  int count;

  TooManyAggregateFieldsException(
      {required this.collection, required this.count});
  @override
  String toString() =>
      'too many aggregateFields for collection $collection. Expected <= 29 found '
      ' groupByFields works only in user profile collections';
}

/// Exceptions throws when the [Store._groupByFields] is set but
/// [collection] isn't a user collection ([Store._userProfile] is `false`).
class InvalidGroupByConfigurationException implements Exception {
  String collection;
  InvalidGroupByConfigurationException({required this.collection});

  @override
  String toString() =>
      'groupByFields is set and userProfile is false for collection $collection.'
      ' groupByFields works only in user profile collections';
}

class FirestoreTypeUnregistredException implements Exception {
  Type type;
  FirestoreTypeUnregistredException(this.type);

  @override
  String toString() => 'function toFirestore not registered for type $type ';
}

class InvalidFieldsUpdateException {
  String path;
  InvalidFieldsUpdateException(this.path);

  @override
  String toString() => 'try to update $path with empty fields';
}

class DocumentNotFoundException implements Exception {
  String path;
  DocumentNotFoundException(this.path);

  @override
  String toString() => 'document not found at $path';
}

class InvalidFirestoreDataTypeException implements Exception {
  @override
  String toString() => "type <T> cannot by 'dynamic'. "
      'Set correct type <T> calling registerFromFirestoreFactory<T>';
}

class DetailsFromFirestoreFactoryNullException implements Exception {
  Type lightDataType, detailsDataType;
  DetailsFromFirestoreFactoryNullException(
      this.lightDataType, this.detailsDataType);

  @override
  String toString() => 'detailsFromFirestoreFactory parameters is null '
      'and <LightDataType> $lightDataType != <DetailsDataType> $detailsDataType';
}

class ParentDataNullException implements Exception {
  Type detailsDataType;

  ParentDataNullException(this.detailsDataType);

  @override
  String toString() =>
      '<DetailsDataType> $detailsDataType getParentData() returns null';
}

/// extension of String adding [StringExtension.capitalize] function.
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
