import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// This Widget is the main application widget.
class WrapAndScaffold extends StatelessWidget {
  /// Creates the [WrapAndScaffold].
  const WrapAndScaffold({super.key});

  @override
  Widget build(BuildContext context) => AdaptiveScaffold(
    appBar: AppBar(title: const Text('Adaptive Wrap and Scaffold')),
    drawler: const Placeholder(
      child: Text('Drawer'),
    ),
    bodyForLargeBuilder: ({required crossAxisCount, required screenSize}) =>
        AdaptiveWrap(
          crossAxisCount: crossAxisCount,
          children: _childred,
        ),
    bodyForSmallBuilder: ({required crossAxisCount, required screenSize}) =>
        AdaptiveWrap(crossAxisCount: crossAxisCount, children: _childred),
  );

  List<Widget> get _childred => [
    for (var i = 0; i < 10; i++)
      Column(
        children: [
          ListTile(
            title: Center(child: Text('Adaptive Wrap Child #${i + 1}')),
          ),
          const Divider(height: 1, color: Colors.white24),
        ],
      ),
  ];
}
