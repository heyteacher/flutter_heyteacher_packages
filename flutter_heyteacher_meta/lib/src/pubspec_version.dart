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
/// - `build`: Updates the build number (e.g. 456).
/// - `show`: Prints the full current version string (e.g., "1.2.3+345").
/// - `show-build`: Prints only the current build number.
/// - `--dry-run`: Shows the new version without modifying `pubspec.yaml`.
///
/// The script automatically updates the build number to `yyMMddHHm`
/// (first 9 digits)
/// for `major`, `minor`, `patch`, and `build` commands unless `--dry-run`
/// is specified.
library;

import 'dart:io';

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

  /// Dispose
  void dispose() {}

  /// Execute [versionCommand].
  ///
  /// if [dryRun] is true, show only the command actions without executing it.
  Future<String?> version({
    required PubspecVersionCommand versionCommand,
    bool dryRun = false,
  }) async {
    final yamlEditor = YamlEditor(await pubspecFile.readAsString());
    final regex = RegExp(r'^(\d+)\.(\d+)\.(\d+)\s?(\+(\d+))?$');
    final curretVersion = yamlEditor.parseAt(['version']).value as String;
    // apply the regex to the current version
    final currentVersionRegexed = regex
        .allMatches(curretVersion)
        .firstOrNull
        ?.groups([
          PubspecVersionCommand.major.index + 1,
          PubspecVersionCommand.minor.index + 1,
          PubspecVersionCommand.patch.index + 1,
          PubspecVersionCommand.build.index + 1,
        ]);
    switch (versionCommand) {
      case PubspecVersionCommand.major:
        _incrementVersion(currentVersionRegexed, PubspecVersionCommand.major);
        _setVersion(currentVersionRegexed, PubspecVersionCommand.minor, '0');
        _setVersion(currentVersionRegexed, PubspecVersionCommand.patch, '0');
      case PubspecVersionCommand.minor:
        _incrementVersion(currentVersionRegexed, PubspecVersionCommand.minor);
        _setVersion(currentVersionRegexed, PubspecVersionCommand.patch, '0');
      case PubspecVersionCommand.patch:
        _incrementVersion(currentVersionRegexed, PubspecVersionCommand.patch);
      case PubspecVersionCommand.build:
        break;
      case PubspecVersionCommand.show:
        return curretVersion;
      case PubspecVersionCommand.showBuild:
        return currentVersionRegexed?[PubspecVersionCommand.build.index]
            ?.substring(1);
    }
    if (currentVersionRegexed?[PubspecVersionCommand.build.index] != null) {
      _incrementVersion(currentVersionRegexed, PubspecVersionCommand.build);
    }
    // update version in yaml
    final newVersion =
        '${currentVersionRegexed![PubspecVersionCommand.major.index]}.'
        '${currentVersionRegexed[PubspecVersionCommand.minor.index]}.'
        '${currentVersionRegexed[PubspecVersionCommand.patch.index]}'
        '+${currentVersionRegexed[PubspecVersionCommand.build.index]}';
    if (!dryRun) {
      yamlEditor.update(['version'], newVersion);
      // write pubsec.yaml
      await pubspecFile.writeAsString(yamlEditor.toString());
    }
    return newVersion;
  }

  /// Returns the pubspec.yaml [File].
  File get pubspecFile {
    final pubspecFile = File('pubspec.yaml').existsSync()
        // run on root project
        ? File('pubspec.yaml')
        // fastlane run inside android or ios subdir
        : File('../../pubspec.yaml');
    return pubspecFile;
  }

  /// Increments the version component at the given [command] in the [version]
  /// list.
  void _incrementVersion(
    List<String?>? version,
    PubspecVersionCommand command,
  ) {
    final value = (int.parse(version![command.index]!) + 1).toString();
    _setVersion(version, command, value);
  }

  /// Sets the version component at the given [command] in the [version] list
  /// to the specified [value].
  void _setVersion(
    List<String?>? version,
    PubspecVersionCommand command,
    String value,
  ) {
    version![command.index] = value;
  }
}
