import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/exceptions/object_from_firestore_factory_null_exception.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/exceptions/parent_data_null_exception.dart';

import '../auth.dart';
import 'firestore_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logging/logging.dart';

abstract class Store<ListType extends FirestoreData,
    ObjectType extends FirestoreData> {
  final _log = Logger("Store");
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String collection;
  bool userProfile;
  bool separatedDetailCollection;
  Map<String, bool>? orderByFields;

  late String objectCollection;

  @protected
  Store({
    required this.collection,
    this.userProfile = true,
    this.separatedDetailCollection = false,
    this.orderByFields,
    required Function fromFirestoreFactory,
    Function? objectFromFirestoreFactory,
  }) {
    _log.fine(
        "costructor: $_collectionPathLog userProfile $userProfile  separatedDetailCollection $separatedDetailCollection orderByFields $orderByFields");

    _log.fine("costructor: register fromFireStoreFactory");
    FirestoreData.registerFromFirestoreFactory<ListType>(fromFirestoreFactory);

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
  }

  Query<ListType> get query {
    Query<ListType>? retQuery;
    // apply order by
    for (MapEntry<String, bool> orderbyField in orderByFields?.entries ?? {}) {
      retQuery = (retQuery ?? _collectionReference)
          .orderBy(orderbyField.key, descending: orderbyField.value);
    }
    retQuery ??= _collectionReference;
    return retQuery;
  }

  Query<Map<String, dynamic>> queryCollection(String collection) {
    Query<Map<String, dynamic>>? retQuery;
    // apply order by
    for (MapEntry<String, bool> orderbyField in orderByFields?.entries ?? {}) {
      retQuery = (retQuery ??
              _firestore.collection(_collectionPathDynamic(collection)))
          .orderBy(orderbyField.key, descending: orderbyField.value);
    }
    retQuery ??= _firestore.collection(_collectionPathDynamic(collection));
    return retQuery;
  }

  Future<Iterable<Map<String, dynamic>>> listCollection(
      {required String collection}) async {
    _log.fine(
        "listCollection(${_collectionPathLogDynamic(collection)},orderByFields: $orderByFields)");
    return (await queryCollection(collection).get()).docs.map((e) => e.data());
  }

  Future<Iterable<ListType>> list() async {
    _log.fine("list($_collectionPathLog,orderByFields: $orderByFields)");
    return (await query.get()).docs.map((e) => e.data());
  }

  Future<bool> exists(String id) async {
    _log.fine("exists($_objectCollectionPathLog/$id)");
    bool ret = (await _objectCollectionReference.doc(id).get()).exists;
    return ret;
  }

  Future<void> delete(String id) async {
    _log.fine("delete($_objectCollectionPathLog/$id)");
    await _objectCollectionReference.doc(id).delete();
    if (separatedDetailCollection) {
      _log.fine("delete($_collectionPathLog/$id)");
      await _collectionReference.doc(id).delete();
    }
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

  Future<void> set(String id, ObjectType document) async {
    _log.fine("set($_objectCollectionPathLog/$id)");
    await _objectCollectionReference.doc(id).set(document);
    if (separatedDetailCollection) {
      ListType? parentData = document.getParentData() as ListType?;
      if (parentData != null) {
        _log.fine("set($_collectionPathLog/$id)");
        await _collectionReference.doc(id).set(parentData);
      } else {
        throw ParentDataNullException(
            "${ObjectType.runtimeType}.getParentData() returns null");
      }
    }
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

  String _collectionPathDynamic(String collection) => userProfile
      ? "users"
          "${collection == "" ? "" : "/$_uid/$collection"}"
      : collection;
  String _collectionPathLogDynamic(String collection) => userProfile
      ? "users"
          "${collection == "" ? "" : "/<uid>/$collection"}"
      : collection;

  String get _uid {
    if (userNotAutenticated) {
      throw UserNotAuthenticatedException("not autenticated");
    }
    return authUserUid!;
  }
}
