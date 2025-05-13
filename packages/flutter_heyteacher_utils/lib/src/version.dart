/// A command-line utility to manage the version string in `pubspec.yaml`.
///
/// This script allows for incrementing major, minor, or patch versions,
/// setting the build number based on the current date and time,
/// and displaying the current version or build number.
///
/// Usage:
/// `dart run flutter_heyteacher_utils:version mayor|minor|patch|build|show|show-build [--dry-run]`
///
/// - `mayor|minor|patch`: Increments the respective version component and resets subsequent components to 0.
/// - `build`: Updates the build number to a format `yyMMddHHm` (9 digits).
/// - `show`: Prints the full current version string (e.g., "1.2.3+001").
/// - `show-build`: Prints only the current build number.
/// - `--dry-run`: Shows the new version without modifying `pubspec.yaml`.
///
/// The script automatically updates the build number to `yyMMddHHm` (first 9 digits)
/// for `mayor`, `minor`, `patch`, and `build` commands unless `--dry-run` is specified.
library;

import 'dart:io';
import 'package:clock/clock.dart';
import 'package:intl/intl.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// Main entry point for the version management script.
void main(List<String> arguments) async {
  const int mayor = 0, minor = 1, patch = 2, build = 3;
  final DateFormat buildNumberDateFormat = DateFormat("yyMMddHHmm");
  final File pubspecFile = await File('pubspec.yaml').exists()
      // run on root project
      ? File('pubspec.yaml')
      // fastlane run inside android or ios subdir
      : File('../../pubspec.yaml');
  final yamlEditor = YamlEditor(await pubspecFile.readAsString());
  final regex = RegExp(r'^(\d+)\.(\d+)\.(\d+)\+(\d+)$');
  final String curretVersion = yamlEditor.parseAt(["version"]).value as String;
  final List<String?>? version =
      regex.firstMatch(curretVersion)?.groups([1, 2, 3, 4]);
  switch (arguments.isNotEmpty ? arguments[0] : "") {
    case "mayor":
      _incrementVersion(version, mayor);
      _setVersion(version, minor, "0");
      _setVersion(version, patch, "0");
    case "minor":
      _incrementVersion(version, minor);
      _setVersion(version, patch, "0");
    case "patch":
      _incrementVersion(version, patch);
    case "build":
      break;
    case "show":
      stdout.write(curretVersion);
      return;
    case "show-build":
      stdout.write(version?[build]);
      return;
    default:
        // ignore: avoid_print
        print(
            "usage dart version.dart mayor|minor|patch|build|show|show-build [--dry-run]\n"
            "found $arguments");
      exit(-1);
  }
  // update build number with current date in 9-digit format YYMMddHHm (android build number limited to 2100000000)
  _setVersion(version, build,
      buildNumberDateFormat.format(clock.now()).substring(0, 9));
  // update version in yaml
  String newVersion =
      "${version![0]}.${version[1]}.${version[2]}+${version[3]}";
  if (arguments.length < 2 || arguments[1] != "--dry-run") {
    yamlEditor.update(['version'], newVersion);
    //write pubsec
    await pubspecFile.writeAsString(yamlEditor.toString());
  }
  stdout.write(newVersion);
}

/// Increments the version component at the given [index] in the [version] list.
void _incrementVersion(List<String?>? version, int index) {
  String value = (int.parse(version![index]!) + 1).toString();
  _setVersion(version, index, value);
}

/// Sets the version component at the given [index] in the [version] list
/// to the specified [value].
void _setVersion(List<String?>? version, int index, String value) {
  version![index] = value;
}
