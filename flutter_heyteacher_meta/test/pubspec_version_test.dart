import 'dart:io';

import 'package:clock/clock.dart';
import 'package:flutter_heyteacher_meta/src/pubspec_version.dart';
import 'package:test/test.dart';

class _FakePubspecVersion extends PubspecVersion {
  _FakePubspecVersion() {
    tempDir = Directory.systemTemp.createTempSync();
    pubspecFile = File('${tempDir.path}/pubspec.yaml');
    pubspecFile.writeAsStringSync('name: test_pkg\nversion: 1.2.3+4');
  }

  late Directory tempDir;
  late File pubspecFile;

  @override
  void dispose() {
    tempDir.deleteSync(recursive: true);
  }

  @override
  File getPubspecFile() => pubspecFile;
}

void main() {
  group('pubspec_version', () {
    setUp(() async {
      PubspecVersion.instance = _FakePubspecVersion();
    });

    tearDown(() async {
      PubspecVersion.instance.dispose();
    });

    test('major increments major version and resets others', () async {
      await withClock(Clock.fixed(DateTime(2023, 1, 1, 10)), () async {
        final newVersion = await PubspecVersion.instance.version(
          versionCommand: PubspecVersionCommand.major,
        );
        expect(newVersion, '2.0.0+230101100');
        expect(
          await PubspecVersion.instance.getPubspecFile().readAsString(),
          contains('version: 2.0.0+230101100'),
        );
      });
    });

    test('minor increments minor version and resets patch', () async {
      await withClock(Clock.fixed(DateTime(2023, 1, 1, 10)), () async {
        final newVersion = await PubspecVersion.instance.version(
          versionCommand: PubspecVersionCommand.minor,
        );
        expect(newVersion, '1.3.0+230101100');
        expect(
          await PubspecVersion.instance.getPubspecFile().readAsString(),
          contains('version: 1.3.0+230101100'),
        );
      });
    });

    test('patch increments patch version', () async {
      await withClock(Clock.fixed(DateTime(2023, 1, 1, 10)), () async {
        final newVersion = await PubspecVersion.instance.version(
          versionCommand: PubspecVersionCommand.patch,
        );
        expect(newVersion, '1.2.4+230101100');
        expect(
          await PubspecVersion.instance.getPubspecFile().readAsString(),
          contains('version: 1.2.4+230101100'),
        );
      });
    });

    test('build updates only build number', () async {
      await withClock(Clock.fixed(DateTime(2023, 1, 1, 10)), () async {
        final newVersion = await PubspecVersion.instance.version(
          versionCommand: PubspecVersionCommand.build,
        );
        expect(newVersion, '1.2.3+230101100');
        expect(
          await PubspecVersion.instance.getPubspecFile().readAsString(),
          contains('version: 1.2.3+230101100'),
        );
      });
    });

    test('show returns current version without modification', () async {
      final currentVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.show,
      );
      expect(currentVersion, '1.2.3+4');
      // Ensure file content hasn't changed
      expect(
        await PubspecVersion.instance.getPubspecFile().readAsString(),
        contains('version: 1.2.3+4'),
      );
    });

    test('show-build returns current build number', () async {
      final buildNumber = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.showBuild,
      );
      expect(buildNumber, '4');
    });

    test('dryRun does not update the file', () async {
      await withClock(Clock.fixed(DateTime(2023, 1, 1, 10)), () async {
        final newVersion = await PubspecVersion.instance.version(
          versionCommand: PubspecVersionCommand.major,
          dryRun: true,
        );
        // Returns the calculated version
        expect(newVersion, '2.0.0+230101100');
        // File should still have the old version
        expect(
          await PubspecVersion.instance.getPubspecFile().readAsString(),
          contains('version: 1.2.3+4'),
        );
      });
    });
  });
}
