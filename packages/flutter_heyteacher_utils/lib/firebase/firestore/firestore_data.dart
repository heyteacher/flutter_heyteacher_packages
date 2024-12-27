import 'package:cloud_firestore/cloud_firestore.dart';

import 'exceptions/firestore_type_unregistred_exception.dart';
import 'exceptions/invalid_firestore_data_type_exception.dart';

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

  Map<String, dynamic> toFirestore();

  static Timestamp? toFirestoreTimestamp(DateTime? dateTime) {
    return dateTime == null? null: Timestamp.fromDate(dateTime);
  }

  static DateTime? fromFirestoreTimestamp(Timestamp? timestamp) {
    return timestamp?.toDate();
  }
}
