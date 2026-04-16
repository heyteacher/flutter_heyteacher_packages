import 'package:flutter_heyteacher_meta/src/fake_pubspec_version.dart'
    show FakePubspecVersion;
import 'package:flutter_heyteacher_meta/src/pubspec_version.dart'
    show PubspecVersion, PubspecVersionCommand;
import 'package:test/test.dart';

void main() {
  group('pubspec_version', () {
    setUp(() async {
      PubspecVersion.instance = FakePubspecVersion();
    });

    tearDown(() async {
      PubspecVersion.instance.dispose();
    });

    test('major increments major version and resets others', () async {
      final newVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.major,
      );
      expect(newVersion, '2.0.0+2');
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 2.0.0+2'),
      );
    });

    test('minor increments minor version and resets patch', () async {
      final newVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.minor,
      );
      expect(newVersion, '1.1.0+2');
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 1.1.0+2'),
      );
    });

    test('patch increments patch version', () async {
      final newVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.patch,
      );
      expect(newVersion, '1.0.1+2');
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 1.0.1+2'),
      );
    });

    test('build updates only build number', () async {
      final newVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.build,
      );
      expect(newVersion, '1.0.0+2');
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 1.0.0+2'),
      );
    });

    test('set with valid version', () async {
      final newVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.set,
        version: '2.0.0',
      );
      expect(newVersion, '2.0.0+2');
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 2.0.0+2'),
        reason: "version doesn't match",
      );
    });

    test('set without version', () async {
      expect(
        () => PubspecVersion.instance.version(
          versionCommand: PubspecVersionCommand.set,
        ),
        throwsA(isA<Exception>()),
        reason: 'expected exception to be thrown without version',
      );
    });

    test('set with invalid version', () async {
      expect(
        () => PubspecVersion.instance.version(
          versionCommand: PubspecVersionCommand.set,
          version: 'invalid',
        ),
        throwsA(isA<Exception>()),
        reason: 'expected exception to be thrown without version',
      );
    });

    test('show returns current version without modification', () async {
      final currentVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.show,
      );
      expect(currentVersion, '1.0.0+1');
      // Ensure file content hasn't changed
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 1.0.0+1'),
      );
    });

    test('show-build returns current build number', () async {
      final buildNumber = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.showBuild,
      );
      expect(buildNumber, '1');
    });

    test('dryRun does not update the file', () async {
      final newVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.major,
        dryRun: true,
      );
      // Returns the calculated version
      expect(newVersion, '2.0.0+2');
      // File should still have the old version
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 1.0.0+1'),
      );
    });
  });
}
