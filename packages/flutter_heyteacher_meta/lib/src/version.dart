/// A command-line utility to manage the version string in `pubspec.yaml`.
///
/// This script allows for incrementing major, minor, or patch versions,
/// setting the build number based on the current date and time,
/// and displaying the current version or build number.
///
/// Usage:
/// `dart run flutter_heyteacher_fastlane:version mayor|minor|patch|build|
///     show|show-build [--dry-run]`
///
/// - `mayor|minor|patch`: Increments the respective version component and
///   resets subsequent components to 0.
/// - `build`: Updates the build number to a format `yyMMddHHm` (9 digits).
/// - `show`: Prints the full current version string (e.g., "1.2.3+001").
/// - `show-build`: Prints only the current build number.
/// - `--dry-run`: Shows the new version without modifying `pubspec.yaml`.
///
/// The script automatically updates the build number to `yyMMddHHm`
/// (first 9 digits)
/// for `mayor`, `minor`, `patch`, and `build` commands unless `--dry-run`
/// is specified.
library;

import 'dart:developer' show log;
import 'dart:io';

import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Main entry point for the version management script.
void main(List<String> arguments) async {
  const mayor = 0;
  const minor = 1;
  const patch = 2;
  const build = 3;
  final buildNumberDateFormat = DateFormat('yyMMddHHmm');
  final pubspecFile = File('pubspec.yaml').existsSync()
      // run on root project
      ? File('pubspec.yaml')
      // fastlane run inside android or ios subdir
      : File('../../pubspec.yaml');
  final yamlEditor = YamlEditor(await pubspecFile.readAsString());
  final regex = RegExp(r'^(\d+)\.(\d+)\.(\d+)\s?(\+(\d+))?$');
  final curretVersion = yamlEditor.parseAt(['version']).value as String;
  //print('curretVersion: $curretVersion');
  final currentVersionRegexed = regex.firstMatch(curretVersion)?.groups([
    1,
    2,
    3,
    4,
  ]);
  //print('currentVersionRegexed: $currentVersionRegexed');
  switch (arguments.isNotEmpty ? arguments[0] : '') {
    case 'mayor':
      _incrementVersion(currentVersionRegexed, mayor);
      _setVersion(currentVersionRegexed, minor, '0');
      _setVersion(currentVersionRegexed, patch, '0');
    case 'minor':
      _incrementVersion(currentVersionRegexed, minor);
      _setVersion(currentVersionRegexed, patch, '0');
    case 'patch':
      _incrementVersion(currentVersionRegexed, patch);
    case 'build':
      break;
    case 'show':
      stdout.write(curretVersion);
      return;
    case 'show-build':
      stdout.write(currentVersionRegexed?[build]?.substring(1));
      return;
    default:
      log(
        'usage dart version.dart mayor|minor|patch|build|show|show-build '
        '[--dry-run]\n'
        'found $arguments',
      );
      exit(-1);
  }

  /// Updated build number with current date in 9-digit format YYMMddHHm
  /// (android build number limited to 2100000000)
  _setVersion(
    currentVersionRegexed,
    build,
    buildNumberDateFormat.format(clock.now()).substring(0, 9),
  );
  // update version in yaml
  final newVersion =
      '${currentVersionRegexed![0]}.'
      '${currentVersionRegexed[1]}.'
      '${currentVersionRegexed[2]}'
      '+${currentVersionRegexed[3]}';
  if (arguments.length < 2 || arguments[1] != '--dry-run') {
    yamlEditor.update(['version'], newVersion);
    //write pubsec
    await pubspecFile.writeAsString(yamlEditor.toString());
  }
  //print('newVersion: $newVersion');
  stdout.write(newVersion);
}

/// Increments the version component at the given [index] in the [version] list.
void _incrementVersion(List<String?>? version, int index) {
  final value = (int.parse(version![index]!) + 1).toString();
  _setVersion(version, index, value);
}

/// Sets the version component at the given [index] in the [version] list
/// to the specified [value].
void _setVersion(List<String?>? version, int index, String value) {
  version![index] = value;
}
