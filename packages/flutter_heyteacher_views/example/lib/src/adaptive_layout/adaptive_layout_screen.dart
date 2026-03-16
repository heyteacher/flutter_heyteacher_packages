import 'dart:async' show unawaited;

import 'package:example/src/app_router.dart' show AppRouteName;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart' show GoRouter;

/// This Widget is the main application widget.
class AdaptiveLayoutScreen extends StatelessWidget {
  /// Creates the [AdaptiveLayoutScreen].
  const AdaptiveLayoutScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Adaptive Layout'),
    ),
    body: ListView(
      padding: const EdgeInsets.only(top: 8),
      children: [
        Card(
          child: ListTile(
            title: const Text('Adaptive State'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              unawaited(
                GoRouter.of(context).pushNamed(AppRouteName.adaptiveState.name),
              );
            },
          ),
        ),
        Card(
          child: ListTile(
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
        ),
      ],
    ),
  );
}
