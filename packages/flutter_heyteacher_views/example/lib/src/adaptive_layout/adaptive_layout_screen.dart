import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeModeButton;
import 'package:flutter_heyteacher_views_example/src/app_router.dart'
    show AppRouteName;
import 'package:go_router/go_router.dart' show GoRouter;

/// This Widget is the main application widget.
class AdaptiveLayoutScreen extends StatelessWidget {
  /// Creates the [AdaptiveLayoutScreen].
  const AdaptiveLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Views'),
      actions: const [ThemeModeButton()],
    ),
    body: ListView(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          title: const Text('Adaptive State'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            unawaited(
              GoRouter.of(
                context,
              ).pushNamed(AppRouteName.adaptiveState.name),
            );
          },
        ),
        const Divider(height: 1, color: Colors.white24),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          title: const Text('Adaptive Wrap and Scaffold'),
          trailing: const Icon(Icons.keyboard_arrow_right),
          onTap: () {
            unawaited(
              GoRouter.of(
                context,
              ).pushNamed(AppRouteName.wrapAndScaffold.name),
            );
          },
        ),
        const Divider(height: 1, color: Colors.white24),
      ],
    ),
  );
}
