/// A command-line utility to manage the version string in `pubspec.yaml`.
///
/// This script allows for incrementing major, minor, or patch versions,
/// setting the build number based on the current date and time,
/// and displaying the current version or build number.
///
/// Usage:
/// `dart run flutter_heyteacher_meta:version major|minor|patch|build|
///     show|show-build [--dry-run]`
///
/// - `major|minor|patch`: Increments the respective version component and
///   resets subsequent components to 0.
/// - `build`: Updates the build number to a format `yyMMddHHm` (9 digits).
/// - `show`: Prints the full current version string (e.g., "1.2.3+001").
/// - `show-build`: Prints only the current build number.
/// - `--dry-run`: Shows the new version without modifying `pubspec.yaml`.
///
/// The script automatically updates the build number to `yyMMddHHm`
/// (first 9 digits)
/// for `major`, `minor`, `patch`, and `build` commands unless `--dry-run`
/// is specified.
library;

import 'dart:io';

import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// The version commands
enum PubspecVersionCommand {
  /// Increment the major version.
  major,

  /// Increment the minor version.
  minor,

  /// Increment the patch version.
  patch,

  /// Increment the build number.
  build,

  /// Show the current version.
  show,

  /// Show the current build number.
  showBuild;

  /// Returns the [PubspecVersionCommand] from the given [command].
  ///
  /// Throws an exception if the [command] is not valid.
  static PubspecVersionCommand fromString(String command) {
    switch (command) {
      case 'major':
        return PubspecVersionCommand.major;
      case 'minor':
        return PubspecVersionCommand.minor;
      case 'patch':
        return PubspecVersionCommand.patch;
      case 'build':
        return PubspecVersionCommand.build;
      case 'show':
        return PubspecVersionCommand.show;
      case 'show-build':
        return PubspecVersionCommand.showBuild;
      default:
        throw Exception('Invalid command: $command');
    }
  }
}

/// A utility class for managing the version string in `pubspec.yaml`.
class PubspecVersion {
  /// constructor for the singleton pattern, only visible for testing
  PubspecVersion();

  static PubspecVersion? _instance;

  /// The singleton instance of [PubspecVersion].
  // ignore: prefer_constructors_over_static_methods
  static PubspecVersion get instance => _instance ??= PubspecVersion();

  static set instance(PubspecVersion value) => _instance = value;

  static const _majorRegexIndex = 0;
  static const _minorRegexIndex = 1;
  static const _patchRegexIndex = 2;
  static const _buildRegexIndex = 3;

  /// Dispose
  void dispose() {}

  /// Execute [versionCommand].
  ///
  /// if [dryRun] is true, show only the command actions without executing it.
  Future<String?> version({
    required PubspecVersionCommand versionCommand,
    bool dryRun = false,
  }) async {
    final buildNumberDateFormat = DateFormat('yyMMddHHmm');
    final pubspecFile = getPubspecFile();
    final yamlEditor = YamlEditor(await pubspecFile.readAsString());
    final regex = RegExp(r'^(\d+)\.(\d+)\.(\d+)\s?(\+(\d+))?$');
    final curretVersion = yamlEditor.parseAt(['version']).value as String;
    // apply the regex to the current version
    final currentVersionRegexed = regex
        .allMatches(curretVersion)
        .firstOrNull
        ?.groups([
          _majorRegexIndex + 1,
          _minorRegexIndex + 1,
          _patchRegexIndex + 1,
          _buildRegexIndex + 1,
        ]);
    switch (versionCommand) {
      case PubspecVersionCommand.major:
        _incrementVersion(currentVersionRegexed, _majorRegexIndex);
        _setVersion(currentVersionRegexed, _minorRegexIndex, '0');
        _setVersion(currentVersionRegexed, _patchRegexIndex, '0');
      case PubspecVersionCommand.minor:
        _incrementVersion(currentVersionRegexed, _minorRegexIndex);
        _setVersion(currentVersionRegexed, _patchRegexIndex, '0');
      case PubspecVersionCommand.patch:
        _incrementVersion(currentVersionRegexed, _patchRegexIndex);
      case PubspecVersionCommand.build:
        break;
      case PubspecVersionCommand.show:
        return curretVersion;
      case PubspecVersionCommand.showBuild:
        return currentVersionRegexed?[_buildRegexIndex]?.substring(1);
    }

    /// Updated build number with current date in 9-digit format YYMMddHHm
    /// (android build number limited to 2100000000)
    _setVersion(
      currentVersionRegexed,
      _buildRegexIndex,
      buildNumberDateFormat.format(clock.now()).substring(0, 9),
    );
    // update version in yaml
    final newVersion =
        '${currentVersionRegexed![_majorRegexIndex]}.'
        '${currentVersionRegexed[_minorRegexIndex]}.'
        '${currentVersionRegexed[_patchRegexIndex]}'
        '+${currentVersionRegexed[_buildRegexIndex]}';
    if (!dryRun) {
      yamlEditor.update(['version'], newVersion);
      // write pubsec.yaml
      await pubspecFile.writeAsString(yamlEditor.toString());
    }
    return newVersion;
  }

  /// Returns the pubspec.yaml [File].
  File getPubspecFile() {
    final pubspecFile = File('pubspec.yaml').existsSync()
        // run on root project
        ? File('pubspec.yaml')
        // fastlane run inside android or ios subdir
        : File('../../pubspec.yaml');
    return pubspecFile;
  }

  /// Increments the version component at the given [index] in the [version]
  /// list.
  void _incrementVersion(List<String?>? version, int index) {
    final value = (int.parse(version![index]!) + 1).toString();
    _setVersion(version, index, value);
  }

  /// Sets the version component at the given [index] in the [version] list
  /// to the specified [value].
  void _setVersion(List<String?>? version, int index, String value) {
    version![index] = value;
  }
}
