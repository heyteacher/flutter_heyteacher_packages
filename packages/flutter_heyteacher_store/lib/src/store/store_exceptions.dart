import 'package:flutter_heyteacher_store/flutter_heyteacher_store.dart';

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
      'Expected <= 29 found $count';
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
