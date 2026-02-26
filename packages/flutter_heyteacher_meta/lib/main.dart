import 'dart:io';
import 'package:flutter_heyteacher_meta/src/pubspec_version.dart';

/// Main entry point for the version management script.
void main(List<String> arguments) async {
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
      '\nusage dart version.dart major|minor|patch|build|show|show-build '
      '[--dry-run]\n\n',
    );
  }
}
