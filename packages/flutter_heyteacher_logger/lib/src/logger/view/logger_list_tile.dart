import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_logger/flutter_heyteacher_logger.dart';
import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';
import 'package:go_router/go_router.dart';

/// A list tile that provides navigation to the [LoggerScreen].
///
/// This widget is conditionally visible, appearing only when the application
/// is in debug mode (`kDebugMode` is true) or after a specific tap gesture
/// has been registered (listened via
/// `InfoDevicePackageViewModel.tapCounterReachedStream`). This makes it a
/// useful tool for developers and testers without cluttering the release UI.
class LoggerListTile extends StatelessWidget {
  /// Creates a [LoggerListTile].
  /// Requires a [_pathPrefix] to construct the navigation route.
  const LoggerListTile(this._pathPrefix, {bool visible = false, super.key})
    : _visible = visible;

  /// The prefix for the route path to the logger screen.
  final String _pathPrefix;

  final bool _visible;

  @override
  StreamBuilder<bool> build(BuildContext context) => StreamBuilder<bool>(
    initialData: InfoDevicePackageViewModel.instance.tapCounterReached,
    stream: InfoDevicePackageViewModel.instance.tapCounterReachedStream,
    builder: (_, tapCounterReachedSnapshot) => Visibility(
      visible: _visible || (tapCounterReachedSnapshot.data ?? false),
      child: ListTile(
        key: const ValueKey('lt_fhu_logger'),
        leading: const Icon(Icons.list),
        title: Text(
          FlutterHeyteacherLoggerLocalizations.of(context)!.logging,
        ),
        onTap: () {
          // Navigates to the logger screen using GoRouter.
          GoRouter.of(context).go('$_pathPrefix/${LoggingRouter.path}');
        },
        trailing: const Icon(Icons.keyboard_arrow_right),
      ),
    ),
  );
}
