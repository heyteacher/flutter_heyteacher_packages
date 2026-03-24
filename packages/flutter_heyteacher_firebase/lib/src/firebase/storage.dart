/// Provides a view model for interacting with Firebase Cloud Storage.
///
/// This library offers a singleton `StorageViewModel` to handle file uploads,
/// including optional GZip compression and automatic directory structuring for
/// logs.
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:clock/clock.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart';
import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';
import 'package:logging/logging.dart';

/// A view model for managing file uploads to Firebase Cloud Storage.
///
/// This class provides a singleton interface to upload string content,
/// with an option for GZip compression. It handles authentication checks
/// and throws a custom exception on failure.
class StorageViewModel {
  StorageViewModel._();
  final _logger = Logger('StorageViewModel');

  static StorageViewModel? _instance;

  /// Provides the singleton instance of [StorageViewModel].
  // ignore: prefer_constructors_over_static_methods
  static StorageViewModel get instance => _instance ??= StorageViewModel._();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads application log content to a dated directory in Firebase Storage.
  ///
  /// This is a convenience method that uses [upload] to store log files.
  /// The directory is automatically set to `applogs/<current_date>`.
  ///
  /// - [relativeFilename]: The name of the file to be created within the
  ///   directory.
  /// - [content]: The string content to upload.
  /// - [encodeGZip]: If `true`, the content will be GZip compressed before
  ///   uploading.
  ///
  /// Returns a `Future<String?>` with the download URL upon success, or `null`
  /// if the user is not authenticated. Throws [UploadStorageException] on a
  /// Firebase error.
  Future<String?> appLogsUpload({
    required String relativeFilename,
    required String content,
    bool encodeGZip = false,
  }) => upload(
    directory: 'applogs/${FormatterHelper.machineDateFormat(clock.now())}',
    relativeFilename: relativeFilename,
    content: content,
    encodeGZip: encodeGZip,
  );

  /// Uploads string content to a specified path in Firebase Storage.
  ///
  /// - [directory]: The destination directory in the storage bucket.
  /// - [relativeFilename]: The name of the file.
  /// - [content]: The string content to upload.
  /// - [encodeGZip]: If `true`, the content will be GZip compressed before
  ///   uploading.
  ///
  /// Returns a `Future<String?>` with the download URL upon success, or `null`
  /// if the user is not authenticated. Throws [UploadStorageException] on a
  /// Firebase error.
  Future<String?> upload({
    required String directory,
    required String relativeFilename,
    required String content,
    bool encodeGZip = false,
  }) async {
    var absFilename = '$directory/$relativeFilename';

    var fileContent = utf8.encode(content);
    if (encodeGZip && PlatformHelper.isNotWeb) {
      fileContent = Uint8List.fromList(gzip.encode(fileContent));
      if (!absFilename.endsWith('.gz')) {
        absFilename = '$absFilename.gz';
      }
    }
    _logger.finer('<uploadFile>: filePath $absFilename');
    try {
      if (AuthViewModel.instance.notAutenticated) {
        _logger.warning(
          '(uploadFile): filePath $absFilename. User not authenticated, '
          'cannot upload file in Storage',
        );
        return null;
      }
      _logger.info(
        '(uploadFile): filePath $absFilename. Uploading file to Storage bucket '
        '${_storage.bucket}',
      );
      final storageRef = _storage.ref();
      final fileRef = storageRef.child(absFilename);
      await fileRef.putData(fileContent);
      final downloadURL = await fileRef.getDownloadURL();
      _logger.info(
        '(uploadFile): filePath $absFilename. File uploaded successfully '
        '$downloadURL',
      );
      return downloadURL;
    } on FirebaseException catch (error, stackTrace) {
      _logger.severe(
        '(uploadFile): filePath $absFilename. Failed tu upload file in Storage',
        error,
        stackTrace,
      );
      throw UploadStorageException(absFilename);
    }
  }
}

/// An exception thrown when a file upload to Firebase Storage fails.
class UploadStorageException implements Exception {
  /// Creates an instance of [UploadStorageException].
  ///
  /// - [filePath]: The path of the file that failed to upload.
  UploadStorageException(this.filePath);

  /// The path of the file that failed to upload.
  String filePath;

  @override
  String toString() => 'failed to upload file $filePath';
}
