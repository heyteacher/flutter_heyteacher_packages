import 'dart:io';
import 'package:intl/intl.dart';
import 'package:yaml_edit/yaml_edit.dart';


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
      buildNumberDateFormat.format(DateTime.now()).substring(0, 9));
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

void _incrementVersion(List<String?>? version, int index) {
  String value = (int.parse(version![index]!) + 1).toString();
  _setVersion(version, index, value);
}

void _setVersion(List<String?>? version, int index, String value) {
  version![index] = value;
}
