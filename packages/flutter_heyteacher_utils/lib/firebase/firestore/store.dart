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
/// * implement distinct and group by counter [Store.groupByCounterFields]
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
///            groupByCounterFields: {
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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import './store_filters.dart';
import '../auth.dart';
import 'package:logging/logging.dart';

abstract class Store<LightDataType extends FirestoreData,
    DetailsDataType extends LightDataType> {
  final _log = Logger("Store");

  late final FirebaseFirestore _firestore;

  Map<String, bool>? orderByFields;
  List<String>? aggregateFields;
  StoreFilter? storeFilter;
  @protected
  Map<String, String Function(DetailsDataType)?>? groupByCounterFields;

  @protected
  late String objectCollection;

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
      this.orderByFields,
      required Function fromFirestoreFactory,
      Function? detailsFromFirestoreFactory,
      this.aggregateFields,
      this.storeFilter,
      this.groupByCounterFields,
      FirebaseFirestore? firebaseFirestore})
      : _separatedDetailsCollection = LightDataType != DetailsDataType {
    _firestore = firebaseFirestore ?? FirebaseFirestore.instance;
    _log.fine(
        "costructor: $_collectionPathLog userProfile $userProfile  separatedDetailsCollection $_separatedDetailsCollection orderByFields $orderByFields");

    _log.fine("costructor: register fromFireStoreFactory");
    FirestoreData.registerFromFirestoreFactory<LightDataType>(
        fromFirestoreFactory);
    // manage the separated detail collection
    if (_separatedDetailsCollection) {
      this.objectCollection = "${collection}_details";
      _log.fine("costructor: objectCollection $_objectCollectionPathLog ");

      if (detailsFromFirestoreFactory != null) {
        _log.fine("costructor: register objectFromFirestoreFactory");
        FirestoreData.registerFromFirestoreFactory<DetailsDataType>(
            detailsFromFirestoreFactory);
      } else {
        throw ObjectFromFirestoreFactoryNullException(
            "objectFromFirestoreFactory parameters is null and separatedDetailsCollection is true");
      }
    } else {
      this.objectCollection = collection;
    }
    // check and initializa group by counter
    if (groupByCounterFields != null) {
      if (!userProfile) {
        throw InvalidGroupByCounterConfigurationException(
            collection: collection);
      }
      _initGroupByCounter();
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
    _aggregatesSubscription ??= Auth.instance()
        .stateChangesStream
        .where((user) => user != null)
        .listen(((_) => notifyAggregatesChanges()));
  }

  Query<LightDataType> query(
      {bool applyOrderBy = false, bool applyFilterBy = true}) {
    Query<LightDataType> retQuery = _collectionReference;
    // apply filter
    if (applyFilterBy && storeFilter != null) {
      _log.fine("query: apply storeFilter $storeFilter");
      retQuery = retQuery.where(storeFilter!.toFirestore());
    }
    // apply order by
    if (applyOrderBy) {
      for (MapEntry<String, bool> orderbyField
          in orderByFields?.entries ?? {}) {
        retQuery =
            retQuery.orderBy(orderbyField.key, descending: orderbyField.value);
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
    _log.fine("exists($_objectCollectionPathLog/$id)");
    _checkAuthenticated();
    bool ret = (await _objectCollectionReference.doc(id).get()).exists;
    return ret;
  }


  Future<DetailsDataType> get(String id) async {
    _log.fine("get($_objectCollectionPathLog/$id)");
    _checkAuthenticated();

    DocumentSnapshot<DetailsDataType>? objectDocumentSnapshot =
        await _objectCollectionReference.doc(id).get();
    // check if exists
    if (objectDocumentSnapshot.exists) {
      DetailsDataType details = objectDocumentSnapshot.data()!;
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
          throw ("get($_collectionPathLog/$id): document not found");
        }
      } else {
        return details;
      }
    } else {
      throw ("get($_objectCollectionPath/$id): document not found");
    }
  }

  Future<void> delete(String id, {WriteBatch? batch}) async {
    _log.fine("delete($_objectCollectionPathLog/$id)");
    _checkAuthenticated();
    if (groupByCounterFields != null) {
      await _changeGrouByCounter(await get(id), increment: false);
    }
    if (batch != null) {
      batch.delete(_objectCollectionReference.doc(id));
    } else {
      await _objectCollectionReference.doc(id).delete();
    }
    if (_separatedDetailsCollection) {
      _log.fine("delete($_collectionPathLog/$id)");
      if (batch != null) {
        batch.delete(_collectionReference.doc(id));
      } else {
        await _collectionReference.doc(id).delete();
      }
    }
    notifyAggregatesChanges();
  }

  Future<void> bulkDelete(
    List<String> ids,
  ) async {
    _log.fine("bulkDelete($_objectCollectionPathLog, ids: $ids)");
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < ids.length; i++) {
      delete(ids[i], batch: batch);
    }
    await batch.commit();
  }

  Future<void> set(DetailsDataType document,
      {String? id, WriteBatch? batch}) async {
    id ??= document.id;
    _log.fine("set($_objectCollectionPathLog/$id)");
    _checkAuthenticated();
    DetailsDataType? oldDocument;
    if (groupByCounterFields != null && await exists(id)) {
      oldDocument = await get(id);
    }
    _log.fine("set($_objectCollectionPathLog/$id)");
    if (batch != null) {
      batch.set(_objectCollectionReference.doc(id), document);
    } else {
      await _objectCollectionReference.doc(id).set(document);
    }
    if (_separatedDetailsCollection) {
      LightDataType? parentData = document.getParentData() as LightDataType?;
      if (parentData != null) {
        _log.fine("set($_collectionPathLog/$id)");
        if (batch != null) {
          batch.set(_collectionReference.doc(id), parentData);
        } else {
          await _collectionReference.doc(id).set(parentData);
        }
      } else {
        throw ParentDataNullException(
            "${DetailsDataType.runtimeType}.getParentData() returns null");
      }
    }
    if (groupByCounterFields != null) {
      await _changeGrouByCounter(document,
          increment: true, oldDocument: oldDocument);
    }
    notifyAggregatesChanges();
  }

  Future<void> bulkSet(List<DetailsDataType> documents,
      {List<String>? ids}) async {
    _log.fine("bulkSet($_objectCollectionPathLog)");
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < documents.length; i++) {
      set(documents[i], id: ids?[i], batch: batch);
    }
    await batch.commit();
  }

  Future<void> update(DetailsDataType document,
      {required List<String> fields, String? id, WriteBatch? batch}) async {
    id ??= document.id;
    _log.fine("update($_objectCollectionPathLog/$id, fields: $fields)");
    _checkAuthenticated();
    if (await exists(id)) {
      if (batch != null) {
        batch.update(_objectCollectionReference.doc(id),
            document.toFirestore(fields: fields));
      } else {
        _objectCollectionReference
            .doc(id)
            .update(document.toFirestore(fields: fields));
      }
      if (_separatedDetailsCollection) {
        if (document.getParentData() != null) {
          _log.fine("update($_collectionPathLog/$id)");
          if (batch != null) {
            batch.update(_collectionReference.doc(id),
                document.getParentData()!.toFirestore(fields: fields));
          } else {
            _collectionReference
                .doc(id)
                .update(document.getParentData()!.toFirestore(fields: fields));
          }
        } else {
          throw ParentDataNullException(
              "${DetailsDataType.runtimeType}.getParentData() returns null");
        }
      }
      // document not found, create it
    } else {
      set(document, batch: batch);
    }
    notifyAggregatesChanges();
  }

  Future<void> bulkUpdate(List<DetailsDataType> documents,
      {required List<String> fields, List<String>? ids}) async {
    _log.fine("bulkUpdate($_objectCollectionPathLog, $fields)");
    _checkAuthenticated();
    final batch = _firestore.batch();
    for (var i = 0; i < documents.length; i++) {
      update(documents[i], fields: fields, id: ids?[i], batch: batch);
    }
    await batch.commit();
  }

  Future<Map<String, dynamic>?> groupByCounter(String field) async {
    _log.fine("groupByCounter($field) collection $_objectCollectionPathLog");
    _checkAuthenticated();
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _firestore.collection("users").doc(_uid).get();
    return documentSnapshot.data()?[_groupByCounterCollectionField(field)];
  }

  Future<void> notifyAggregatesChanges() async {
    _log.fine("notifyAggregatesChanges()");
    _checkAuthenticated();
    if (aggregateFields == null) return;

    List<AggregateField?> aggregateParams = [
      for (var i = 0; i < 29; i++)
        aggregateFields!.length > i ? sum(aggregateFields![i]) : null
    ];
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
          toFirestore: (LightDataType obj, _) => obj.toFirestore());

  CollectionReference<DetailsDataType> get _objectCollectionReference =>
      _firestore.collection(_objectCollectionPath!).withConverter(
          fromFirestore: (snapshot, _) =>
              FirestoreData.fromFirestoreFactory<DetailsDataType>(
                  snapshot.data()!),
          toFirestore: (DetailsDataType obj, _) => obj.toFirestore());

  Future<void> _changeGrouByCounter(DetailsDataType object,
      {required bool increment, DetailsDataType? oldDocument}) async {
    if (groupByCounterFields == null) {
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

    for (MapEntry groupByCounterField in groupByCounterFields!.entries) {
      String groupByCounterCollectionField =
          _groupByCounterCollectionField(groupByCounterField.key);
      // get the user document map which store group by values
      // into field <collection>_<groupByCounterField>
      _log.fine(
          "_changeGrouByCounter: get map $groupByCounterCollectionField in /user/<uid> document");
      Map<String, dynamic> userDocumentMap =
          userDocument[groupByCounterCollectionField] ?? {};
      // retrieve the group by counter key calling groupByCounterFunction provided
      String groupByCounterKey = groupByCounterField.value(object);
      // get the group by counter value
      int groupByCounterValue = userDocumentMap[groupByCounterKey] ?? 0;
      groupByCounterValue =
          increment ? groupByCounterValue + 1 : groupByCounterValue - 1;
      _log.fine(
          "_changeGrouByCounter: $groupByCounterKey new value $groupByCounterValue");
      // increment/decrement group by counter value based
      userDocumentMap[groupByCounterKey] = groupByCounterValue;
      // if increment and oldDocument is set, decrement counter for old document
      if (oldDocument != null && increment) {
        String oldGroupByCounterKey = groupByCounterField.value(oldDocument);
        int oldGroupByCounterValue = userDocumentMap[oldGroupByCounterKey] ?? 0;
        oldGroupByCounterValue--;
        userDocumentMap[oldGroupByCounterKey] = oldGroupByCounterValue;
      }
      // update the user document
      userDocument[groupByCounterCollectionField] = userDocumentMap;
    }
    if ((await userDocumentReference.get()).exists) {
      await userDocumentReference.update(userDocument);
    } else {
      await userDocumentReference.set(userDocument);
    }
  }

  String _groupByCounterCollectionField(String field) => "${collection}_$field";

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

  String? get _objectCollectionPath => userProfile
      ? "users"
          "${objectCollection == "" ? "" : "/$_uid/$objectCollection"}"
      : objectCollection;
  String? get _objectCollectionPathLog => userProfile
      ? "users"
          "${objectCollection == "" ? "" : "/<uid>/$objectCollection"}"
      : objectCollection;

  static String get _uid =>
      Auth.instance().notAutenticated ? "guest" : Auth.instance().uid!;

  void _initGroupByCounter() async {
    if (Auth.instance().notAutenticated) {
      _log.fine("_initGroupByCounter: user not authenticate, do nothing");
      return;
    }
    for (MapEntry groupByCounterField in groupByCounterFields?.entries ?? {}) {
      String groupByCounterCollectionField =
          _groupByCounterCollectionField(groupByCounterField.key);
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore.collection("users").doc(_uid).get();
      if (documentSnapshot.data()?[groupByCounterCollectionField] != null) {
        _log.fine(
            "_initGroupByCounter: user $groupByCounterCollectionField already initialized. Do nothing");
        return;
      }
      _log.fine(
          "_initGroupByCounter: start scan on $collection and update $groupByCounterCollectionField");
      for (var objectList in await list()) {
        DetailsDataType objectDetail = await get(objectList.id);
        await _changeGrouByCounter(objectDetail, increment: true);
      }
    }
    _log.fine("_initGroupByCounter: stop scan");
  }
}

class TooManyAggregateFieldsException {
  String collection;

  int count;

  TooManyAggregateFieldsException(
      {required this.collection, required this.count});
  @override
  String toString() =>
      "too many aggregateFields for collection $collection. Expected <= 29 found "
      " groupByCounterFields works only in user profile collections";
}

abstract class FirestoreData<T> {
  String get id;

  static final Map<Type, Function> _registeredToFirestoreFn = {};

  static registerFromFirestoreFactory<T>(Function toFirestoreFn) {
    if (T == dynamic) {
      throw InvalidFirestoreDataTypeException(
          "please specify the correct type calling registerFromFirestoreFactory<T>");
    }
    _registeredToFirestoreFn[T] = toFirestoreFn;
  }

  static T fromFirestoreFactory<T extends FirestoreData>(
      Map<String, dynamic> map) {
    T? object = _registeredToFirestoreFn[T]?.call(map);
    if (object != null) {
      return object;
    } else {
      throw FirestoreTypeUnregistredException(
          "function toFirestore not registered for type ${T.runtimeType} ");
    }
  }

  FirestoreData? getParentData() {
    return null;
  }

  void setParentData(FirestoreData parentData) {}

  Map<String, dynamic> toFirestore({List<String>? fields});

  static Timestamp? toFirestoreTimestamp(DateTime? dateTime) {
    return dateTime == null ? null : Timestamp.fromDate(dateTime);
  }

  static DateTime? fromFirestoreTimestamp(Timestamp? timestamp) {
    return timestamp?.toDate();
  }
}

class InvalidGroupByCounterConfigurationException implements Exception {
  String collection;

  InvalidGroupByCounterConfigurationException({required this.collection});

  @override
  String toString() =>
      "groupByCounterFields is set and userProfile is false for collection $collection."
      " groupByCounterFields works only in user profile collections";
}

class FirestoreTypeUnregistredException implements Exception {
  String message;

  FirestoreTypeUnregistredException(this.message);

  @override
  String toString() => message;
}

class InvalidFirestoreDataTypeException {
  String message;

  InvalidFirestoreDataTypeException(this.message);

  @override
  String toString() => message;
}

class ObjectFromFirestoreFactoryNullException {
  String message;

  ObjectFromFirestoreFactoryNullException(this.message);

  @override
  String toString() => message;
}
