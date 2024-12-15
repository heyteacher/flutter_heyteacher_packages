import 'dart:async';

import '../auth.dart';
import 'firestore_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

abstract class Store<ListType extends FirestoreData,
    ObjectType extends FirestoreData> {
  final _log = Logger("Store");

  String collection;
  bool userProfile;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Store(
      {required this.collection,
      required Function listFromFirestoreFactory,
      required Function objectFromFirestoreFactory,
      this.userProfile = true}) {
    _log.fine("costructor: $_collectionPathLog");
    // register fromFireStoreFactory of ListType
    FirestoreData.registerFromFirestoreFactory<ListType>(
        listFromFirestoreFactory);
    // register fromFireStoreFactory of ObjectType
    FirestoreData.registerFromFirestoreFactory<ObjectType>(
        objectFromFirestoreFactory);
  }

  void listenQueryList(
      {Map<String, bool>? orderByFields,
      required StreamController<Iterable<ListType>> streamController}) async {
    _log.fine(
        "listenQueryList($_collectionPathLog, orderByFields: $orderByFields)");
    // build query
    Query<Map<String, dynamic>>? query = _buildQuery(orderByFields);
    // listen results
    Stream<QuerySnapshot<Map<String, dynamic>>> stream =
        (query ?? _collectionReference).snapshots();
    stream.listen(
      _onData(streamController.sink),
      // error
      onError: _onError(streamController.sink, orderByFields),
    );
    // manage timeout
  }

  Function(QuerySnapshot<Map<String, dynamic>>) _onData(
          StreamSink<Iterable<ListType>> sink) =>
      (QuerySnapshot<Map<String, dynamic>> snapShot) => sink.add(snapShot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot) =>
              FirestoreData.fromFirestoreFactory<ListType>(
                  documentSnapshot.data())));

  Function(dynamic, dynamic) _onError(StreamSink<Iterable<ListType>> sink,
          Map<String, bool>? orderByFields) =>
      (error, stacktrace) {
        _log.severe(
            "error on listenQueryList($_collectionPathLog, orderByFields: $orderByFields))",
            error,
            stacktrace);
        sink.addError(error, stacktrace);
      };

  Future<Iterable<ListType>> list({Map<String, bool>? orderByFields}) async {
    _log.fine("list($_collectionPathLog,orderByFields: $orderByFields)");
    // build query
    Query<Map<String, dynamic>>? query = _buildQuery(orderByFields);
    // get query snapshot
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await (query ?? _collectionReference).get();
    // retun Iterable of ListType objects
    return querySnapshot.docs
        .map((e) => FirestoreData.fromFirestoreFactory<ListType>(e.data()));
  }

  // TODO: Store_buildQuery, implements paging (limit) and filtering
  Query<Map<String, dynamic>>? _buildQuery(Map<String, bool>? orderByFields) {
    Query<Map<String, dynamic>>? query;
    // apply order by
    for (MapEntry<String, bool> orderbyField in orderByFields?.entries ?? {}) {
      query = (query ?? _collectionReference)
          .orderBy(orderbyField.key, descending: orderbyField.value);
    }
    return query;
  }

  Future<bool> exists(String id) async {
    _log.fine("exists($_collectionPathLog/$id)");
    bool ret = (await _collectionReference.doc(id).get()).exists;
    return ret;
  }

  Future<ObjectType> get(String id) async {
    DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await _collectionReference.doc(id).get();
    // check if exists
    if (documentSnapshot.exists) {
      _log.fine("get($_collectionPathLog/$id)");
      return FirestoreData.fromFirestoreFactory<ObjectType>(
          documentSnapshot.data()!);
    } else {
      throw ("get($_collectionPathLog/$id): document not found");
    }
  }

  void set(String id, ObjectType document) {
    _log.fine("set($_collectionPathLog/$id)");
    _collectionReference.doc(id).set(document.toFirestore());
  }

  void update(String id, ObjectType document) async {
    _log.fine("update($_collectionPathLog/$id)");
    await exists(id)
        ? _collectionReference.doc(id).update(document.toFirestore())
        : set(id, document);
  }

  void delete(String id) {
    _log.fine("delete($_collectionPathLog/$id)");
    _collectionReference.doc(id).delete();
  }

  CollectionReference<Map<String, dynamic>> get _collectionReference =>
      _firestore.collection(_collectionPath);

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
  String get _uid {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) throw UserNotAuthenticatedException("not autenticated");
    return user.uid;
  }
}
