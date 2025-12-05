import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/adaptive_layout.dart' show ScreenSize;
import 'package:flutter_heyteacher_utils/src/adaptive_layout/adaptive_layout_view.dart';
import 'package:flutter_heyteacher_utils/src/theme.dart';

/// A widget that adapts to the current display size, displaying a [Drawer],
class AdaptiveScaffold extends StatefulWidget {
  /// Creates a [AdaptiveScaffold].
  const AdaptiveScaffold({
    required this.drawler,
    required this.bodyForLargeBuilder,
    required this.bodyForSmallBuilder,
    this.title,
    this.actions = const [],
    this.floatingActionButton,
    super.key,
  });

  /// The title of the screen
  final Widget? title;

  /// The actions of the screen
  final List<Widget> actions;

  /// The drawer of the screen
  final Widget drawler;

  /// The expanded of the screen
  final Widget Function() bodyForLargeBuilder;

  /// The expanded of the screen
  final Widget Function() bodyForSmallBuilder;

  /// The floating action button of the screen
  final FloatingActionButton? floatingActionButton;

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}


class _AdaptiveScaffoldState extends State<AdaptiveScaffold>
    with AdaptiveStateMixin<AdaptiveScaffold> {
  @override
  Widget build(BuildContext context) => switch (currentScreenSize) {
    ScreenSize.large => Row(
      children: [
        Drawer(
          shape: const RoundedRectangleBorder(),
          width: MediaQuery.sizeOf(context).width * 0.3,
          child: widget.drawler,
        ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: ThemeViewModel.instance.darkGreyColor,
        ),
        Expanded(
          child: Scaffold(
            appBar: widget.title == null && widget.actions.isEmpty
                ? null
                : AppBar(title: widget.title, actions: widget.actions),
            body: widget.bodyForLargeBuilder.call(),
            floatingActionButton: widget.floatingActionButton,
          ),
        ),
      ],
    ),
    // ScreenSize.medium and ScreenSize.small
    _ => Scaffold(
      body: widget.bodyForSmallBuilder.call(),
      appBar: widget.title == null && widget.actions.isEmpty
          ? null
          : AppBar(title: widget.title, actions: widget.actions),
      floatingActionButton: widget.floatingActionButton,
    ),
  };
}
