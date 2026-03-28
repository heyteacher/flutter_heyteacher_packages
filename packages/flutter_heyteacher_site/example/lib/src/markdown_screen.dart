import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/flutter_heyteacher_site.dart' show MarkdownView;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart' show ThemeModeButton;

/// The home screen
class MarkdownScreen extends StatefulWidget {
  /// Creates the [MarkdownScreen].
  const MarkdownScreen({super.key});

  @override
  State<MarkdownScreen> createState() => _MarkdownScreenState();
}

class _MarkdownScreenState extends State<MarkdownScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Markdown'),
      actions: const [
        ThemeModeButton(),
      ],
    ),
    body: const Padding(
      padding: EdgeInsets.only(top: 8),
      child: MarkdownView(page: 'demo'),
    ),
  );
}
