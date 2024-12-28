import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/exceptions/object_from_firestore_factory_null_exception.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/exceptions/parent_data_null_exception.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/filters.dart';

import '../auth.dart';
import 'firestore_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

abstract class Store<ListType extends FirestoreData,
    ObjectType extends FirestoreData> {
  final _log = Logger("Store");
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @protected
  String collection;
  @protected
  bool userProfile;
  @protected
  bool separatedDetailCollection;

  Map<String, bool>? orderByFields;
  List<String>? aggregateFields;
  StoreFilter? storeFilter;
  @protected
  Map<String, String Function(ObjectType)?>? groupByCounterFields;

  @protected
  late String objectCollection;

  final StreamController<AggregateQuerySnapshot> _aggregateStreamController =
      StreamController<AggregateQuerySnapshot>.broadcast();

  Stream<AggregateQuerySnapshot> get aggregateStream =>
      _aggregateStreamController.stream;

  StreamSubscription<User?>? _aggregatesSubscription;

  @protected
  Store(
      {required this.collection,
      this.userProfile = true,
      this.separatedDetailCollection = false,
      this.orderByFields,
      required Function fromFirestoreFactory,
      Function? objectFromFirestoreFactory,
      this.aggregateFields,
      this.storeFilter,
      this.groupByCounterFields}) {
    _log.fine(
        "costructor: $_collectionPathLog userProfile $userProfile  separatedDetailCollection $separatedDetailCollection orderByFields $orderByFields");

    _log.fine("costructor: register fromFireStoreFactory");
    FirestoreData.registerFromFirestoreFactory<ListType>(fromFirestoreFactory);
    // manage the separated detail collection
    if (separatedDetailCollection) {
      this.objectCollection = "${collection}_details";
      _log.fine("costructor: objectCollection $_objectCollectionPathLog ");

      if (objectFromFirestoreFactory != null) {
        _log.fine("costructor: register objectFromFirestoreFactory");
        FirestoreData.registerFromFirestoreFactory<ObjectType>(
            objectFromFirestoreFactory);
      } else {
        throw ObjectFromFirestoreFactoryNullException(
            "objectFromFirestoreFactory parameters is null and separatedDetailCollection is true");
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
        throw TooManyAggregateFieldsException(collection: collection, count: aggregateFields!.length);
      }
    }
  }

  void listenAggregatesStream() {
    _aggregatesSubscription?.cancel();
    _aggregatesSubscription ??= authStateChangesStream
        .where((user) => user != null)
        .listen(((_) => notifyAggregatesChanges()));
  }

  Query<ListType> query(
      {bool applyOrderBy = false, bool applyFilterBy = true}) {
    Query<ListType> retQuery = _collectionReference;
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

  Stream<QuerySnapshot<ListType>> get stream =>
      query(applyOrderBy: true).snapshots();

  Future<Iterable<ListType>> list() async {
    _log.fine("list($_collectionPathLog,orderByFields: $orderByFields)");
    return (await query(applyOrderBy: true).get()).docs.map((e) => e.data());
  }

  Future<bool> exists(String id) async {
    _log.fine("exists($_objectCollectionPathLog/$id)");
    bool ret = (await _objectCollectionReference.doc(id).get()).exists;
    return ret;
  }

  Future<void> delete(String id) async {
    await _changeGrouByCounter(await get(id), increment: false);
    _log.fine("delete($_objectCollectionPathLog/$id)");
    await _objectCollectionReference.doc(id).delete();
    if (separatedDetailCollection) {
      _log.fine("delete($_collectionPathLog/$id)");
      await _collectionReference.doc(id).delete();
    }
    notifyAggregatesChanges();
  }

  Future<ObjectType> get(String id) async {
    _log.fine("get($_objectCollectionPathLog/$id)");
    DocumentSnapshot<ObjectType>? objectDocumentSnapshot =
        await _objectCollectionReference.doc(id).get();
    // check if exists
    if (objectDocumentSnapshot.exists) {
      ObjectType details = objectDocumentSnapshot.data()!;
      if (separatedDetailCollection) {
        _log.fine("get($_collectionPathLog/$id)");
        DocumentSnapshot<ListType> documentSnapshot =
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

  Future<void> set(String id, ObjectType object) async {
    _log.fine("set($_objectCollectionPathLog/$id)");
    await _objectCollectionReference.doc(id).set(object);
    if (separatedDetailCollection) {
      ListType? parentData = object.getParentData() as ListType?;
      if (parentData != null) {
        _log.fine("set($_collectionPathLog/$id)");
        await _collectionReference.doc(id).set(parentData);
      } else {
        throw ParentDataNullException(
            "${ObjectType.runtimeType}.getParentData() returns null");
      }
    }
    await _changeGrouByCounter(object, increment: true);
    notifyAggregatesChanges();
  }

  Future<void> update(String id, ObjectType document) async {
    _log.fine("update($_objectCollectionPathLog/$id)");
    if (await exists(id)) {
      _objectCollectionReference.doc(id).update(document.toFirestore());
      if (separatedDetailCollection) {
        if (document.getParentData() != null) {
          _log.fine("update($_collectionPathLog/$id)");
          _collectionReference
              .doc(id)
              .update(document.getParentData()!.toFirestore());
        } else {
          throw ParentDataNullException(
              "${ObjectType.runtimeType}.getParentData() returns null");
        }
      }
      // document not found, create it
    } else {
      set(id, document);
    }
    notifyAggregatesChanges();
  }

  Future<Map<String, dynamic>?> groupByCounter(String field) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _firestore.collection("users").doc(_uid).get();
    return documentSnapshot.data()?[_groupByCounterCollectionField(field)];
  }

  notifyAggregatesChanges() async {
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

  CollectionReference<ListType> get _collectionReference =>
      _firestore.collection(_collectionPath).withConverter(
          fromFirestore: (snapshot, _) =>
              FirestoreData.fromFirestoreFactory<ListType>(snapshot.data()!),
          toFirestore: (ListType obj, _) => obj.toFirestore());

  CollectionReference<ObjectType> get _objectCollectionReference =>
      _firestore.collection(_objectCollectionPath!).withConverter(
          fromFirestore: (snapshot, _) =>
              FirestoreData.fromFirestoreFactory<ObjectType>(snapshot.data()!),
          toFirestore: (ObjectType obj, _) => obj.toFirestore());

  Future<void> _changeGrouByCounter(ObjectType object,
      {required bool increment}) async {
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
      // update the user document
      userDocument[groupByCounterCollectionField] = userDocumentMap;
    }
    await userDocumentReference.update(userDocument);
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

  static String get _uid {
    if (userNotAutenticated) {
      throw UserNotAuthenticatedException("not autenticated");
    }
    return authUserUid!;
  }

  void _initGroupByCounter() async {
    if (userNotAutenticated) {
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
        ObjectType objectDetail = await get(objectList.id);
        await _changeGrouByCounter(objectDetail, increment: true);
      }
    }
    _log.fine("_initGroupByCounter: stop scan");
  }
}

class TooManyAggregateFieldsException {
  String collection;
  
  int count;

  TooManyAggregateFieldsException({required this.collection, required this.count});
  @override
  String toString() =>
      "too many aggregateFields for collection $collection. Expected <= 29 found "
      " groupByCounterFields works only in user profile collections";
}

class InvalidGroupByCounterConfigurationException implements Exception {
  String collection;

  InvalidGroupByCounterConfigurationException({required this.collection});

  @override
  String toString() =>
      "groupByCounterFields is set and userProfile is false for collection $collection."
      " groupByCounterFields works only in user profile collections";
}
