class FirestoreTypeUnregistredException implements Exception {
  String message;

  FirestoreTypeUnregistredException(this.message);

  @override
  String toString() => message;
}
