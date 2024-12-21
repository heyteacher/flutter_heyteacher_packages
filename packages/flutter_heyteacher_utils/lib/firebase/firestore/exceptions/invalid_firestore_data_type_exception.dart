class InvalidFirestoreDataTypeException {
  String message;
  
  InvalidFirestoreDataTypeException(this.message);

  @override
  String toString() => message;
}
