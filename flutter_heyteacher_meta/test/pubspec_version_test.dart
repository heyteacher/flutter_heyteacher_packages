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
      expect(newVersion, '2.0.0+5');
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 2.0.0+5'),
      );
    });

    test('minor increments minor version and resets patch', () async {
      final newVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.minor,
      );
      expect(newVersion, '1.3.0+5');
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 1.3.0+5'),
      );
    });

    test('patch increments patch version', () async {
      final newVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.patch,
      );
      expect(newVersion, '1.2.4+5');
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 1.2.4+5'),
      );
    });

    test('build updates only build number', () async {
      final newVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.build,
      );
      expect(newVersion, '1.2.3+5');
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 1.2.3+5'),
      );
    });

    test('show returns current version without modification', () async {
      final currentVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.show,
      );
      expect(currentVersion, '1.2.3+4');
      // Ensure file content hasn't changed
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
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
      final newVersion = await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.major,
        dryRun: true,
      );
      // Returns the calculated version
      expect(newVersion, '2.0.0+5');
      // File should still have the old version
      expect(
        await PubspecVersion.instance.pubspecFile.readAsString(),
        contains('version: 1.2.3+4'),
      );
    });
  });
}
