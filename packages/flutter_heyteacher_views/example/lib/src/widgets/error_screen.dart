import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// Error View example
class ErrorScreen extends StatelessWidget {
  /// Creates an [ErrorScreen].
  const ErrorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    try {
      throw Exception('Something went wrong');
    } on Exception catch (e, s) {
      return ErrorView(e, s, title: 'Error View');
    }
  }
}
