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
/// * manage the user collection `/users/<uid>/` with [Store.userProfile] integrating [FirebaseAuth] using
///   automatically the `uid` of authenticated user
///
/// * manage data filtering with [StoreFilter]
///
/// * manage multiple order by field with [Store.orderByFields]
///
/// * implement distinct and group by [Store.groupByFields]
///
/// * manage aggregate field via [Store.aggregateFields] and notify aggregate value changes via [Store.aggregateStream]
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
/// Stores on user collection `/users/<uid>` ([Store.collection] is empty).
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
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/e2ee.dart';
import './store_filters.dart';
import '../auth.dart';
import 'package:logging/logging.dart';

enum Order { desc, asc }

class GroupByResult {
  final Map<String, String> groupByFields;
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

abstract class Store<LightDataType extends FirestoreData,
    DetailsDataType extends LightDataType> {
  final _log = Logger("Store");

  late final FirebaseFirestore _firestore;

  Map<String, Order>? orderByFields;
  List<String>? aggregateFields;
  StoreFilter? storeFilter;
  GroupByResult? groupBySelected;

  @protected
  Map<String, String Function(DetailsDataType)?>? groupByFields;

  @protected
  late String detailsCollection;

  @protected
  String collection;
  @protected
  bool userProfile;

  final bool _separatedDetailsCollection;
  StreamSubscription<User?>? _aggregatesSubscription;

  final StreamController<AggregateQuerySnapshot> _aggregateStreamController =
      StreamController<AggregateQuerySnapshot>.broadcast();

  Stream<AggregateQuerySnapshot> get aggregateStream =>
      _aggregateStreamController.stream;

  @protected
  Store(
      {required this.collection,
      required this.userProfile,
      required LightDataType Function(Map<String, dynamic> map)
          fromFirestoreFactory,
      DetailsDataType Function(Map<String, dynamic> map)?
          detailsFromFirestoreFactory,
      this.orderByFields,
      this.aggregateFields,
      this.storeFilter,
      this.groupByFields,
      FirebaseFirestore? firebaseFirestore})
      : _separatedDetailsCollection = LightDataType != DetailsDataType {
    _firestore = firebaseFirestore ?? FirebaseFirestore.instance;
    _log.fine("costructor: $_collectionPathLog "
        "userProfile $userProfile  "
        "separatedDetailsCollection $_separatedDetailsCollection "
        "orderByFields $orderByFields "
        "aggregateFields $aggregateFields "
        "groupByFields $groupByFields");

    _log.fine("costructor: register fromFireStoreFactory");
    FirestoreData.registerFromFirestoreFactory<LightDataType>(
        fromFirestoreFactory);
    // manage the separated detail collection
    if (_separatedDetailsCollection) {
      this.detailsCollection = "${collection}_details";
      _log.fine("costructor: detailsCollection $_detailsCollectionPathLog ");

      if (detailsFromFirestoreFactory != null) {
        _log.fine("costructor: register detailsFromFirestoreFactory");
        FirestoreData.registerFromFirestoreFactory<DetailsDataType>(
            detailsFromFirestoreFactory);
      } else {
        throw DetailsFromFirestoreFactoryNullException(
            LightDataType, DetailsDataType);
      }
    } else {
      this.detailsCollection = collection;
    }
    // check and initialize group by
    if (groupByFields != null) {
      if (!userProfile) {
        throw InvalidGroupByConfigurationException(collection: collection);
      }
      _initGroupBy();
    }
    // check aggregate fields
    if (aggregateFields != null) {
      if (aggregateFields!.length > 29) {
        throw TooManyAggregateFieldsException(
            collection: collection, count: aggregateFields!.length);
      }
    }
  }

  void listenAggregatesStream() {
    _aggregatesSubscription?.cancel();
    _aggregatesSubscription = Auth.instance()
        .stateChangesStream
        .where((user) => user != null)
        .listen(((_) => notifyAggregatesChanges()));
  }

  dispose() {
    _aggregatesSubscription?.cancel();
  }

  Query<LightDataType> query(
      {bool applyOrderBy = false, bool applyFilterBy = true}) {
    Query<LightDataType> retQuery = _collectionReference;
    // apply filter
    if (applyFilterBy && storeFilter != null) {
      _log.fine("query: storeFilter $storeFilter");
      retQuery = retQuery.where(storeFilter!.toFirestore());
    }
    // apply order by
    if (applyOrderBy) {
      for (MapEntry<String, Order> orderbyField
          in orderByFields?.entries ?? {}) {
        retQuery = retQuery.orderBy(orderbyField.key,
            descending: orderbyField.value == Order.desc);
      }
    }
    return retQuery;
  }

  Stream<QuerySnapshot<LightDataType>> get stream =>
      query(applyOrderBy: true).snapshots();

  Future<bool> empty() async {
    _log.fine("empty($_collectionPathLog,orderByFields: $orderByFields)");
    _checkAuthenticated();
    return ((await query(applyOrderBy: true).count().get()).count ?? 0) == 0;
  }

  Future<bool> notEmpty() async {
    _log.fine("notEmpty($_collectionPathLog,orderByFields: $orderByFields)");
    _checkAuthenticated();
    return !await empty();
  }

  Future<Iterable<LightDataType>> list() async {
    _log.fine("list($_collectionPathLog,orderByFields: $orderByFields)");
    _checkAuthenticated();
    return (await query(applyOrderBy: true).get()).docs.map((e) => e.data());
  }

  Future<bool> exists(String id) async {
    _log.fine("exists($_detailsCollectionPathLog/$id)");
    _checkAuthenticated();
    bool ret = (await _detailsCollectionReference.doc(id).get()).exists;
    return ret;
  }

  Future<DetailsDataType> get(String id) async {
    _log.fine("get($_detailsCollectionPathLog/$id)");
    _checkAuthenticated();

    DocumentSnapshot<DetailsDataType>? detailsDocumentSnapshot =
        await _detailsCollectionReference.doc(id).get();
    // check if exists
    if (detailsDocumentSnapshot.exists) {
      DetailsDataType details = detailsDocumentSnapshot.data()!;
      if (_separatedDetailsCollection) {
        _log.fine("get($_collectionPathLog/$id)");
        DocumentSnapshot<LightDataType> documentSnapshot =
            await _collectionReference.doc(id).get();
        // populate parent data fields
        if (documentSnapshot.exists) {
          _log.fine("setParentData $id");
          details.setParentData(documentSnapshot.data()!);
          return details;
        } else {
          throw DocumentNotFoundException("$_collectionPathLog/$id");
        }
      } else {
        return details;
      }
    } else {
      throw DocumentNotFoundException("$_collectionPathLog/$id");
    }
  }

  Future<DetailsDataType?> getOrNull(String? id) async {
    _log.fine("getOrNull($_detailsCollectionPathLog/$id)");
    if (id == null) return null;
    _checkAuthenticated();
    return await exists(id) ? get(id) : null;
  }

  Future<void> delete(String id, {WriteBatch? batch}) async {
    _log.fine("delete($_detailsCollectionPathLog/$id)");
    _checkAuthenticated();
    if (groupByFields != null) {
      try {
        await _changeGroupBy(await get(id), increment: false);
      } catch (e, s) {
        _log.warning(
            "delete($_detailsCollectionPathLog/$id) error on _changeGroupBy",
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
      _log.fine("delete($_collectionPathLog/$id)");
      if (batch != null) {
        batch.delete(_collectionReference.doc(id));
      } else {
        await _collectionReference.doc(id).delete();
      }
    }
    // if batch in set, delegate thee caller to notify changes
    if (batch == null) {
      notifyAggregatesChanges();
    }
  }

  Future<void> bulkDelete(
    List<String> ids,
  ) async {
    _log.fine("bulkDelete($_detailsCollectionPathLog, ids: $ids)");
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < ids.length; i++) {
      // need await operation in order batch commit will by executed as last operation
      await delete(ids[i], batch: batch);
    }
    await batch.commit();
    notifyAggregatesChanges();
  }

  Future<void> set(DetailsDataType detailsData,
      {String? id, WriteBatch? batch}) async {
    id ??= detailsData.id;
    _log.fine("set($_detailsCollectionPathLog/$id)");
    _checkAuthenticated();
    DetailsDataType? oldDetailsData;
    if (groupByFields != null && await exists(id)) {
      oldDetailsData = await get(id);
    }
    _log.fine("set($_detailsCollectionPathLog/$id)");
    if (batch != null) {
      batch.set(_detailsCollectionReference.doc(id), detailsData);
    } else {
      await _detailsCollectionReference.doc(id).set(detailsData);
    }
    if (_separatedDetailsCollection) {
      LightDataType? parentData = detailsData.getParentData() as LightDataType?;
      if (parentData != null) {
        _log.fine("set($_collectionPathLog/$id)");
        if (batch != null) {
          batch.set(_collectionReference.doc(id), parentData);
        } else {
          await _collectionReference.doc(id).set(parentData);
        }
      } else {
        throw ParentDataNullException(DetailsDataType.runtimeType);
      }
    }
    if (groupByFields != null) {
      await _changeGroupBy(detailsData,
          increment: true, oldDetailsData: oldDetailsData);
    }
    // if batch in set, delegate thee caller to notify changes
    if (batch == null) {
      notifyAggregatesChanges();
    }
  }

  Future<void> bulkSet(List<DetailsDataType> documents,
      {List<String>? ids}) async {
    _log.fine("bulkSet($_detailsCollectionPathLog)");
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < documents.length; i++) {
      // need await operation in order batch commit will by executed as last operation
      await set(documents[i], id: ids?[i], batch: batch);
    }
    await batch.commit();
    notifyAggregatesChanges();
  }

  Future<void> update(DetailsDataType document,
      {required List<String> fields, String? id, WriteBatch? batch}) async {
    if (fields.isEmpty) {
      throw InvalidFieldsUpdate("$_detailsCollectionPathLog/$id");
    }
    id ??= document.id;
    _log.fine("update($_detailsCollectionPathLog/$id, fields: $fields)");
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
          _log.fine("update($_collectionPathLog/$id)");
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
      notifyAggregatesChanges();
    }
  }

  Future<void> bulkUpdate(List<DetailsDataType> documents,
      {required List<String> fields, List<String>? ids}) async {
    _log.fine("bulkUpdate($_detailsCollectionPathLog, $fields)");
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < documents.length; i++) {
      // need await operation in order batch commit will by executed as last operation
      await update(documents[i], fields: fields, id: ids?[i], batch: batch);
    }
    await batch.commit();
    notifyAggregatesChanges();
  }

  Future<Iterable<GroupByResult>?> groupBy(
      {Order groupByFieldsOrder = Order.asc}) async {
    _log.fine("groupBy: collection $_detailsCollectionPathLog");
    String? groupByUserField = _groupByUserField();
    if (groupByUserField == null) return null;
    _checkAuthenticated();
    var user = await _firestore.collection("users").doc(_uid).get();
    Map<String, dynamic>? groupByKey = user.data()?[groupByUserField];
    var iterable = groupByKey?.entries.map(
      (mapEntry) => GroupByResult(
          groupByFields: _groupByFields(mapEntry.key)!, value: mapEntry.value),
    );
    return iterable?.sorted((a, b) =>
        _sortByGroupByFields(a, b, groupByFieldsOrder: groupByFieldsOrder));
  }

  Future<void> notifyAggregatesChanges() async {
    _checkAuthenticated();
    if (aggregateFields == null || aggregateFields!.isEmpty) return;
    List<AggregateField?> aggregateParams = [
      for (var i = 0; i < 29; i++)
        aggregateFields!.length > i ? sum(aggregateFields![i]) : null
    ];
    _log.fine("notifyAggregatesChanges: notify");
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

  void _initGroupBy() async {
    if (Auth.instance().notAutenticated) {
      _log.fine("_initGroupBy: user not authenticate, do nothing");
      return;
    }
    String? groupByUserField = _groupByUserField();
    if (groupByUserField != null) {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection("users").doc(_uid).get();
      if (documentSnapshot.data()?[groupByUserField] != null) {
        _log.fine(
            "_initGroupBy: user $groupByUserField already initialized. Do nothing");
        return;
      }
      _log.fine(
          "_initGroupBy: start scan on $collection and update $groupByUserField");
      for (var lightData in await list()) {
        DetailsDataType detailsData = await get(lightData.id);
        await _changeGroupBy(detailsData, increment: true);
      }
    }
    _log.fine("_initGroupBy: stop scan");
  }

  Future<void> _changeGroupBy(DetailsDataType detailsData,
      {required bool increment, DetailsDataType? oldDetailsData}) async {
    if (groupByFields == null) {
      return;
    }
    assert(userProfile);
    // user document reference
    DocumentReference<Map<String, dynamic>> userDocumentReference =
        _firestore.collection("users").doc(_uid);
    // get the user document snapshot
    DocumentSnapshot<Map<String, dynamic>> userDocumentSnapshot =
        await userDocumentReference.get();
    // get the user document
    Map<String, dynamic> userDocument = userDocumentSnapshot.data() ?? {};

    String? groupByUserField = _groupByUserField();
    String? groupByUserValue = _groupByUserValue(detailsData);
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
      _log.fine("_changeGroupBy: $groupByUserValue new value $groupByValue");
      // increment/decrement group by value based
      userDocumentMap[groupByUserValue] = groupByValue;
      // oldDocument is set, decrement/increment value for old document
      if (oldDetailsData != null) {
        int oldGroupByValue = userDocumentMap[oldGroupByUserValue] ?? 0;
        if (oldGroupByValue > 0) {
          oldGroupByValue =
              increment ? oldGroupByValue - 1 : oldGroupByValue + 1;
          _log.fine(
              "_changeGroupBy: $oldGroupByUserValue (old) new value $oldGroupByValue");
          userDocumentMap[oldGroupByUserValue!] = oldGroupByValue;
        }
      }
      // update the user document
      userDocument[groupByUserField] = userDocumentMap;
    }
    if ((await userDocumentReference.get()).exists) {
      await userDocumentReference.update(userDocument);
    } else {
      await userDocumentReference.set(userDocument);
    }
  }

  String? _groupByUserField() => groupByFields?.isNotEmpty ?? false
      ? "_groupBy${collection.capitalize()}${groupByFields!.keys.reduce((value, element) => "${value.capitalize()}${element.capitalize()}")}"
      : null;

  String? _groupByUserValue(DetailsDataType details) =>
      groupByFields?.isNotEmpty ?? false
          ? groupByFields!.values.nonNulls
              .map(
                (e) => e(details),
              )
              .reduce((value, element) => "$value|$element")
          : null;

  Map<String, String>? _groupByFields(String? groupByKeyValue) {
    if (groupByKeyValue == null) return null;
    Map<String, String> ret = {};
    List<String> values = groupByKeyValue.split("|").toList();
    for (var i = 0; i < values.length; i++) {
      String keyValue = values[i];
      ret[groupByFields!.keys.elementAt(i)] = keyValue;
    }
    return ret;
  }

  int _sortByGroupByFields(GroupByResult a, GroupByResult b,
      {required Order groupByFieldsOrder}) {
    // compare each groupByField returning when comparison differs
    return a.compareTo(b) * (groupByFieldsOrder == Order.desc ? -1 : 1);
  }

  void _checkAuthenticated() {
    if (userProfile && Auth.instance().notAutenticated) {
      throw UserNotAuthenticatedException();
    }
  }

  CollectionReference<LightDataType> get _collectionReference =>
      _firestore.collection(_collectionPath).withConverter(
          fromFirestore: (snapshot, _) =>
              FirestoreData.fromFirestoreFactory<LightDataType>(
                  snapshot.data()!),
          toFirestore: (LightDataType lightData, _) =>
              lightData.toFirestore(null));

  CollectionReference<DetailsDataType> get _detailsCollectionReference =>
      _firestore.collection(_detailsCollectionPath!).withConverter(
          fromFirestore: (snapshot, _) =>
              FirestoreData.fromFirestoreFactory<DetailsDataType>(
                  snapshot.data()!),
          toFirestore: (DetailsDataType detailsData, _) =>
              detailsData.toFirestore(null));

  // userProfile false: <collection>
  // userProfile true: /users/<uid>/<collection>
  String get _collectionPath => userProfile
      ? "users"
          "${collection == "" ? "" : "/$_uid/$collection"}"
      : collection;
  String get _collectionPathLog => userProfile
      ? "users"
          "${collection == "" ? "" : "/<uid>/$collection"}"
      : collection;

  String? get _detailsCollectionPath => userProfile
      ? "users"
          "${detailsCollection == "" ? "" : "/$_uid/$detailsCollection"}"
      : detailsCollection;
  String? get _detailsCollectionPathLog => userProfile
      ? "users"
          "${detailsCollection == "" ? "" : "/<uid>/$detailsCollection"}"
      : detailsCollection;

  String get _uid => Auth.instance().autenticated
      ? Auth.instance().uid!
      : throw UserNotAuthenticatedException();
}

class TooManyAggregateFieldsException {
  String collection;

  int count;

  TooManyAggregateFieldsException(
      {required this.collection, required this.count});
  @override
  String toString() =>
      "too many aggregateFields for collection $collection. Expected <= 29 found "
      " groupByFields works only in user profile collections";
}

abstract class FirestoreData<T> {
  String get id;

  static final Map<Type, Function(Map<String, dynamic> map)>
      _registeredFromFirestoreFactory = {};

  static registerFromFirestoreFactory<T>(
      T Function(Map<String, dynamic> map) fromFirestoreFactory) {
    if (T == dynamic) {
      throw InvalidFirestoreDataTypeException();
    }
    _registeredFromFirestoreFactory[T] = fromFirestoreFactory;
  }

  static T fromFirestoreFactory<T extends FirestoreData>(
      Map<String, dynamic> map) {
    T? object = _registeredFromFirestoreFactory[T]?.call(map);
    if (object != null) {
      return object;
    } else {
      throw FirestoreTypeUnregistredException(T.runtimeType);
    }
  }

  FirestoreData? getParentData() {
    return null;
  }

  void setParentData(FirestoreData parentData) {}

  Map<String, dynamic> toFirestore(List<String>? fields);

  static Timestamp? toFirestoreTimestamp(DateTime? dateTime) {
    return dateTime == null ? null : Timestamp.fromDate(dateTime);
  }

  static DateTime? fromFirestoreTimestamp(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  static Future<String> fromFirestoreE2EE(Map<String, dynamic> map) async {
    return await E2EE.instance
        .decrypt(E2EEValue(value: map["value"], iv: map["iv"]));
  }

  static Future<Map<String, dynamic>> toFirestoreE2EE(String value) async {
    final encrypted = await E2EE.instance.encrypt(value);
    return {"value": encrypted.value, "iv": encrypted.iv};
  }
}

class InvalidGroupByConfigurationException implements Exception {
  String collection;
  InvalidGroupByConfigurationException({required this.collection});

  @override
  String toString() =>
      "groupByFields is set and userProfile is false for collection $collection."
      " groupByFields works only in user profile collections";
}

class FirestoreTypeUnregistredException implements Exception {
  Type type;
  FirestoreTypeUnregistredException(this.type);

  @override
  String toString() => "function toFirestore not registered for type $type ";
}

class InvalidFieldsUpdate {
  String path;
  InvalidFieldsUpdate(this.path);

  @override
  String toString() => "try to update $path with empty fields";
}

class DocumentNotFoundException {
  String path;
  DocumentNotFoundException(this.path);

  @override
  String toString() => "document not found at $path";
}

class InvalidFirestoreDataTypeException {
  @override
  String toString() => "type <T> cannot by 'dynamic'. "
      "Set correct type <T> calling registerFromFirestoreFactory<T>";
}

class DetailsFromFirestoreFactoryNullException {
  Type lightDataType, detailsDataType;
  DetailsFromFirestoreFactoryNullException(
      this.lightDataType, this.detailsDataType);

  @override
  String toString() => "detailsFromFirestoreFactory parameters is null "
      "and <LightDataType> $lightDataType != <DetailsDataType> $detailsDataType";
}

class ParentDataNullException {
  Type detailsDataType;

  ParentDataNullException(this.detailsDataType);

  @override
  String toString() =>
      "<DetailsDataType> $detailsDataType getParentData() returns null";
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : "${this[0].toUpperCase()}${substring(1)}";
  }
}
