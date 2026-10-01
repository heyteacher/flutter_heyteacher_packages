import 'package:flutter/material.dart';

/// A floating action button with text and an icon.
class FloatingActionTextIconButtom extends StatelessWidget {
  /// Creates a floating action button with text and an icon.
  const FloatingActionTextIconButtom({
    required this._text,
    required this.iconData,
    required this._onPressed,
    this._width = 88,
    this._height = 88,
    this._iconSize = 64,
    super.key,
    this._fabKey,
    this.backgroundColor,
  });

  /// An optional key for the floating action button.
  final Key? _fabKey;

  /// The text to display below the icon.
  final String _text;

  /// The icon to display.
  final IconData iconData;

  /// The background color of the button.
  final Color? backgroundColor;

  /// The callback that is called when the button is tapped.
  final VoidCallback _onPressed;

  /// The width of the button.
  final double _width;

  /// The height of the button.
  final double _height;

  /// The size of the icon.
  final double _iconSize;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1),
    child: SizedBox(
      height: _height,
      width: _width,
      child: FloatingActionButton(
        key: _fabKey,
        // heroTag must be set unique in app for each FloatingActionButton
        // to avoid warning introduce by go_router
        heroTag: '${_fabKey ?? GlobalKey()}HeroTag',
        backgroundColor: backgroundColor,
        onPressed: _onPressed,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.vertical,
          alignment: WrapAlignment.center,
          children: [
            Icon(size: _iconSize, iconData),
            Text(
              _text,
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
