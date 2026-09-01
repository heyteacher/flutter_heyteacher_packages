import 'package:flutter/material.dart';

/// A floating action button with text and an icon.
class FloatingActionTextIconButtom extends StatelessWidget {
  /// Creates a floating action button with text and an icon.
  const FloatingActionTextIconButtom({
    required this.text,
    required this.iconData,
    required this.onPressed,
    super.key,
    this.fabKey,
    this.backgroundColor,
  });

  /// An optional key for the floating action button.
  final Key? fabKey;

  /// The text to display below the icon.
  final String text;

  /// The icon to display.
  final IconData iconData;

  /// The background color of the button.
  final Color? backgroundColor;

  /// The callback that is called when the button is tapped.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1),
    child: SizedBox(
      height: 88,
      width: 88,
      child: FloatingActionButton(
        key: fabKey,
        // heroTag must be set unique in app for each FloatingActionButton
        // to avoid warning introduce by go_router
        heroTag: '${fabKey ?? GlobalKey()}HeroTag',
        backgroundColor: backgroundColor,
        onPressed: onPressed,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.vertical,
          alignment: WrapAlignment.end,
          children: [
            Icon(size: 72, iconData),
            Text(
              text,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
