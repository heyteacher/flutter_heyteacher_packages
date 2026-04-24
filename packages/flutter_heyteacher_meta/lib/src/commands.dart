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
/// dartsemver major|minor|patch|build|set|show|show-build
///            [--dry-run]
///            [--version <X.Y.Z>]
/// ```
///
/// - `major|minor|patch|build`: Increments the respective version component and
///    resets subsequent components to 0.
/// - `set --version <X.Y.Z>`: the new version to set.
/// - `show`: Prints the full current version string (e.g., "1.2.3+001").
/// - `show-build`: Prints only the current build number.
/// - `--dry-run`: run command without modify `pubspec.yaml`.
Future<void> dartSemver(List<String> arguments) async {
  try {
    final command = arguments.isNotEmpty ? arguments[0] : '';
    final dryRun = arguments.contains('--dry-run');
    final version =
        arguments.contains('--version') &&
            arguments.length > (arguments.indexOf('--version') + 1)
        ? arguments[arguments.indexOf('--version') + 1]
        : null;
    stdout.write(
      await PubspecVersion.instance.version(
        versionCommand: PubspecVersionCommand.fromString(command),
        dryRun: dryRun,
        version: version,
      ),
    );
  } on Exception catch (error) {
    stdout
      ..write('\n$error\n')
      ..write(
        '\nusage: dartsemver major|minor|patch|build|set|show|show-build '
        '[--dry-run] [--version <X.Y.Z>]\n\n'
        '- major|minor|patch|build: Increments the respective version and '
        'resets subsequent components to 0.\n'
        '- set --version <X.Y.Z>: set the version to <X.Y.Z>.\n'
        '- show: Prints the current version in pubspec.yaml\n'
        '- show-build: Prints the current build number in pubspec.yaml.\n'
        '- --dry-run: run command without modify pubspec.yaml.\n\n',
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
    stdout.write('.git/hooks/commit-msg created\n');
    // pre-commit hook
    await _createFile(
      fromPath: '../assets/git-hooks/pre-commit',
      toPath: '.git/hooks/pre-commit',
      executable: true,
    );
    stdout.write('.git/hooks/pre-commit created\n');
  } on Exception catch (e) {
    stdout.write('configure_git_hooks: error $e\n');
  }
}

/// Configure a Flutter application
Future<void> configureFlutterPackage() async {
  try {
    await configureGitHooks();
    await _createFile(
      fromPath: '../assets/fastlane/Fastfile',
      toPath: 'fastlane/Fastfile',
    );
    stdout.write('fastlane/Fastfile created\n');
    await _createFile(
      fromPath: '../fastlane/cliff.toml',
      toPath: 'fastlane/cliff.toml',
    );
    stdout.write('fastlane/cliff.toml created\n');
    await _createFile(
      fromPath: '../assets/ruby-version',
      toPath: '.ruby-version',
    );
    stdout.write('.ruby-version created\n');
    await _createFile(fromPath: '../assets/Gemfile', toPath: 'Gemfile');
    stdout.write('Gemfile created\n');
  } on Exception catch (e) {
    stdout.write('configure_flutter_package: error $e\n');
  }
}

/// Configure a Flutter package
Future<void> configureFlutterApp() async {
  try {
    await configureGitHooks();
    await _createFile(
      fromPath: '../assets/fastlane/AppFastfile',
      toPath: 'fastlane/Fastfile',
    );
    stdout.write('fastlane/Fastfile created\n');
    await _createFile(
      fromPath: '../fastlane/cliff.toml',
      toPath: 'fastlane/cliff.toml',
    );
    stdout.write('fastlane/cliff.toml created\n');
    await _createFile(
      fromPath: '../assets/fastlane/Pluginfile',
      toPath: 'fastlane/Pluginfile',
    );
    stdout.write('fastlane/Pluginfile created\n');
    await copyPath(
      await _getSourceFilePath('../assets/fastlane/metadata'),
      'fastlane/metadata',
    );
    stdout.write('fastlane/metadata/* created\n');
    await _createFile(
      fromPath: '../assets/ruby-version',
      toPath: '.ruby-version',
    );
    stdout.write('.ruby-version created\n');
    await _createFile(fromPath: '../assets/AppGemfile', toPath: 'Gemfile');
    stdout.write('Gemfile created\n');
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
