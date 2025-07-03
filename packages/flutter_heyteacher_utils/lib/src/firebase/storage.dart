import 'package:firebase_storage/firebase_storage.dart';
import 'package:logging/logging.dart';

class StorageModelView {
  final log = Logger('StorageModel');

  static StorageModelView? _instance;
  StorageModelView._();

  /// Provides the singleton instance of [StorageModelView].
  static StorageModelView get instance => _instance ??= StorageModelView._();

  final _storage = FirebaseStorage.instance;

  Future<String> uploadString(String filePath, String fileContent) async {
    try {
      log.info('uploadFile: upload file $filePath');
      final storageRef = _storage.ref();
      final fileRef = storageRef.child(filePath);
      await fileRef.putString(fileContent);
      return fileRef.getDownloadURL();
    } on FirebaseException catch (e, s) {
      log.severe('uploadFile: failed to upload file $filePath', e, s);
      throw UploadStorageException(filePath);
    }
  }
}

class UploadStorageException implements Exception {

  String filePath;

  UploadStorageException(this.filePath);

  @override
  String toString() => 'failed to upload file $filePath';
}
