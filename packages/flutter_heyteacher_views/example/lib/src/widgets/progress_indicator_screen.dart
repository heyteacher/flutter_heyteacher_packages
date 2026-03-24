import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// Progress Indicator View example
class ProgressIndicatorScreen extends StatelessWidget {
  /// Creates the [ProgressIndicatorScreen]
  const ProgressIndicatorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress Indicator View')),
      body: ProgressIndicatorView(
        timeout: const Duration(seconds: 5),
        timeoutWidget: Text(
          'Timeout Widget',
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
    );
  }
}
