import 'dart:io';
import 'dart:isolate';

import 'package:flutter_heyteacher_meta/src/pubspec_version.dart';
import 'package:io/io.dart' show copyPath;

/// A command-line utility to manage the version string in `pubspec.yaml`.
///
/// This script allows for incrementing major, minor, or patch versions,
/// setting the build number based on the current date and time,
/// and displaying the current version or build number.
///
/// Usage:
/// ```bash
/// dartsemver major|minor|patch|build|show|show-build [--dry-run]
/// ```
///
/// - `major|minor|patch`: Increments the respective version component and
///    resets subsequent components to 0.
/// - `build`: Updates the build number to a format `yyMMddHHm` (9 digits).
/// - `show`: Prints the full current version string (e.g., "1.2.3+001").
/// - `show-build`: Prints only the current build number.
/// - `--dry-run`: Shows the new version without modifying `pubspec.yaml`.
///
/// The script automatically updates the build number to `yyMMddHHm`
/// (first 9 digits)
/// for `major`, `minor`, `patch`, and `build` commands unless `--dry-run`
/// is specified.
Future<void> dartSemver(List<String> arguments) async {
  try {
    final command = arguments.isNotEmpty ? arguments[0] : '';
    final dryRun = arguments.length > 1 && arguments[1] == '--dry-run';
    stdout.write(
      await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.fromString(command),
        dryRun: dryRun,
      ),
    );
  } on Exception catch (_) {
    stdout.write(
      '\nusage: dartsemver major|minor|patch|build|show|show-build '
      '[--dry-run]\n\n',
    );
  }
}

/// Creates `.git/hooks/commit-msg` and `.git/hooks/pre-commit`
Future<void> configureGitHooks() async {
  try {
    // commit-msg hook
    await _createFile(
      fromPath: '../assets/git-hooks/commit-msg',
      toPath: '.git/hooks/commit-msg',
      executable: true,
    );
    // pre-commit hook
    await _createFile(
      fromPath: '../assets/git-hooks/pre-commit',
      toPath: '.git/hooks/pre-commit',
      executable: true,
    );
  } on Exception catch (e) {
    stdout.write('configure_git_hooks: error $e\n');
  }
}

/// Configure a Flutter application
Future<void> configureFlutterPackage() async {
  try {
    await configureGitHooks();
    await _createFile(fromPath: '../assets/Gemfile', toPath: 'Gemfile');
    await _createFile(
      fromPath: '../assets/.ruby-version',
      toPath: '.ruby-version',
    );
    await _createFile(
      fromPath: '../assets/fastlane/Fastfile',
      toPath: 'fastlane/Fastfile',
    );
  } on Exception catch (e) {
    stdout.write('configure_flutter_package: error $e\n');
  }
}

/// Configure a Flutter package
Future<void> configureFlutterApp() async {
  try {
    await configureGitHooks();
    await _createFile(fromPath: '../assets/AppGemfile', toPath: 'Gemfile');
    await _createFile(
      fromPath: '../assets/.ruby-version',
      toPath: '.ruby-version',
    );
    await _createFile(
      fromPath: '../assets/fastlane/Pluginfile',
      toPath: 'fastlane/Pluginfile',
    );
    await _createFile(
      fromPath: '../assets/fastlane/AppFastfile',
      toPath: 'fastlane/Fastfile',
    );
    await copyPath(
      await _getSourceFilePath('../assets/fastlane/metadata'),
      'fastlane/metadata',
    );
    stdout.write('fastlane/metadata/ created\n');
  } on Exception catch (e) {
    stdout.write('configure_flutter_app: error $e\n');
  }
}

Future<void> _createFile({
  required String fromPath,
  required String toPath,
  bool executable = false,
}) async {
  final sourceFile = File(await _getSourceFilePath(fromPath));
  final destFile = File(toPath);
  if (destFile.existsSync()) {
    await destFile.delete();
  }
  await destFile.create(recursive: true);
  await sourceFile.copy(destFile.path);
  if (executable &&
      !Platform.isWindows &&
      Process.runSync('chmod', ['u+x', destFile.path]).exitCode != 0) {
    throw Exception('chmod u+x ${destFile.path} failed');
  }
  stdout.write('$toPath created\n');
}

Future<String> _getSourceFilePath(String path) async {
  final packageUri = Uri.parse('package:flutter_heyteacher_meta/');
  final absoluteUri = await Isolate.resolvePackageUri(packageUri);
  return File.fromUri(absoluteUri!).path + path;
}
