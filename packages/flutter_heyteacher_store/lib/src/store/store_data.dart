import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_heyteacher_store/src/store/store.dart';
import 'package:flutter_heyteacher_store/src/store/store_exceptions.dart';

/// Aggregation type enumeration.
///
/// Defines [sum] and [average] constants used to aggregate date
enum AggregatationType {
  /// sum aggregation
  sum,

  /// average aggregation
  average
}

/// Order enumeration.
///
/// Defines [desc] and [asc] constants used to define order by
enum OrderDirection {
  /// descendent order
  desc,

  /// ascedent order
  asc
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

/// represents a response of a aggregation query.
abstract class AggregateData {
  /// Returns the count of the documents that match the query.
  int? get count;

  /// Returns the sum of the values of the documents that match the query.
  double? getSum(String field);

  /// Returns the average of the values of the documents that match the query.
  double? getAverage(String field);
}

/// extension of String adding [StringExtension.capitalize] function.
extension StringExtension on String {
  /// Returns a new string with the first character capitalized.
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
