import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';
import 'package:flutter_heyteacher_views_example/src/app_router.dart'
    show AppRouteName;
import 'package:go_router/go_router.dart';

/// This Widget is the main application widget.
class AnimationsScreen extends StatefulWidget {
  /// Creates the [AnimationsScreen].
  const AnimationsScreen({super.key});

  @override
  State<AnimationsScreen> createState() => _AnimationsScreenState();
}

class _AnimationsScreenState extends State<AnimationsScreen> {
  int counter = 1;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Views'),
      actions: const [ThemeModeButton()],
    ),
    body: ListView(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      children: [
        Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),

              title: const Text('Paging Sliver Animated State'),
              trailing: const Icon(Icons.keyboard_arrow_right),
              onTap: () {
                unawaited(
                  GoRouter.of(
                    context,
                  ).pushNamed(AppRouteName.pagingSliverAnimatedState.name),
                );
              },
            ),
            const Divider(height: 1, color: Colors.white24),
          ],
        ),
        const Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              title: BlinkingText(
                'BlinkingText',
                textAlign: TextAlign.center,
              ),
            ),
            Divider(height: 1, color: Colors.white24),
          ],
        ),
        Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),

              title: AnimateText('AnimateText #$counter'),
              trailing: OutlinedButton(
                child: const Icon(Icons.plus_one),
                onPressed: () => setState(() => counter++),
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
          ],
        ),
      ],
    ),
  );
}
