import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;
import 'package:flutter_heyteacher_views/src/view/dialogs.dart';

/// An icon button that displays an informational dialog when tapped.
///
/// This widget shows an `info` icon. When the user taps on it, a dialog
/// is displayed using [showConfirmCancelDialog], showing the provided [title]
/// and [content]. It's a convenient way to provide more detailed information
/// without cluttering the main UI.
class TooltipIconButton extends StatelessWidget {
  /// Creates a [TooltipIconButton].
  const TooltipIconButton({
    required this.content,
    super.key,
    this.title,
    this.iconSize = 14,
    this.iconColor,
  });

  /// The optional title widget to display at the top of the dialog.
  final Widget? title;

  /// The main content widget to display in the dialog.
  final Widget content;

  /// The size of the info icon.
  ///
  /// Defaults to 14.
  final double iconSize;

  /// The color of the info icon.
  ///
  /// Defaults to the theme's `onSurface` color.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => InkResponse(
    child: Padding(
      padding: const EdgeInsets.only(left: 3, top: 3),
      child: Icon(
        Icons.info,
        size: iconSize,
        color: iconColor ?? ThemeViewModel.instance.colorScheme.onSurface,
      ),
    ),
    onTap: () => showConfirmCancelDialog<void>(
      context: context,
      title: title ?? const SizedBox.shrink(),
      content: content,
    ),
  );
}
