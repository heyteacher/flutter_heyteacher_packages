import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:logging/logging.dart';

class StorageViewModel {
  final log = Logger('StorageViewModel');

  static StorageViewModel? _instance;
  StorageViewModel._();

  /// Provides the singleton instance of [StorageViewModel].
  static StorageViewModel get instance => _instance ??= StorageViewModel._();

  final _storage = FirebaseStorage.instance;

  Future<String?> uploadString(String filePath, String fileContent) async {
    log.finest('<uploadFile>: filePath $filePath');
    try {
      if (AuthViewModel.instance().notAutenticated) {
        log.warning('(uploadFile): filePath $filePath. User not authenticated, '
            'cannot upload file in Storage');
        return null;
      }
      final storageRef = _storage.ref();
      final fileRef = storageRef.child(filePath);
      await fileRef.putString(fileContent);
      final downloadURL = await fileRef.getDownloadURL();
      log.info('(uploadFile): filePath $filePath. File uploaded successfully '
          '$downloadURL');
      return downloadURL;
    } on FirebaseException catch (error, stackTrace) {
      log.severe(
          '(uploadFile): filePath $filePath. Failed tu upload file in Storage', error, stackTrace);
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
