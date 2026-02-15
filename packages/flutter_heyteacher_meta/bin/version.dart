/// A command-line utility to manage the version string in `pubspec.yaml`.
///
/// This script allows for incrementing major, minor, or patch versions,
/// setting the build number based on the current date and time,
/// and displaying the current version or build number.
///
/// Usage:
/// ```bash
/// dart run flutter_heyteacher_meta:version major|minor|patch|build|show|
///                                           show-build [--dry-run]
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
library;

export '../lib/version.dart' show main;
