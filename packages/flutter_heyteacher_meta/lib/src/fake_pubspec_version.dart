import 'dart:io';
import 'package:flutter_heyteacher_meta/src/pubspec_version.dart';

/// A fake [PubspecVersion] working on e `pubspec.yaml` file.
class FakePubspecVersion extends PubspecVersion {
  /// Creates a [FakePubspecVersion].
  FakePubspecVersion() {
    _tempDir = Directory.systemTemp.createTempSync();
    _pubspecFile = File('${_tempDir.path}/pubspec.yaml');
    _pubspecFile.writeAsStringSync('name: test_pkg\nversion: 1.0.0+1');
  }

  late Directory _tempDir;
  late File _pubspecFile;

  @override
  void dispose() {
    _tempDir.deleteSync(recursive: true);
  }

  @override
  File get pubspecFile => _pubspecFile;
}
