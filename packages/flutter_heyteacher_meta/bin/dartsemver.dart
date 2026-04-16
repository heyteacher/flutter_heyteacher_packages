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
library;

import 'package:flutter_heyteacher_meta/src/commands.dart';

void main(List<String> arguments) => dartSemver(arguments);
