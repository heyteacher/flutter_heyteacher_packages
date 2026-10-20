import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A floating action button with text and an icon.
class FloatingActionTextIconButtom extends StatefulWidget {
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
  final AsyncCallback _onPressed;

  /// The width of the button.
  final double _width;

  /// The height of the button.
  final double _height;

  /// The size of the icon.
  final double _iconSize;

  @override
  State<FloatingActionTextIconButtom> createState() =>
      _FloatingActionTextIconButtomState();
}

class _FloatingActionTextIconButtomState
    extends State<FloatingActionTextIconButtom> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1),
    child: SizedBox(
      height: widget._height,
      width: widget._width,
      child: _loading
          ? Center(
              child: CircularProgressIndicator(
                constraints: BoxConstraints(
                  minHeight: widget._iconSize,
                  minWidth: widget._iconSize,
                  maxHeight: widget._iconSize,
                  maxWidth: widget._iconSize,
                ),
              ),
            )
          : FloatingActionButton(
              key: widget._fabKey,
              // heroTag must be set unique in app for each FloatingActionButton
              // to avoid warning introduce by go_router
              heroTag: '${widget._fabKey ?? GlobalKey()}HeroTag',
              backgroundColor: widget.backgroundColor,
              onPressed: () async {
                setState(() {
                  _loading = true;
                });
                await widget._onPressed();
                if (mounted) {
                  setState(() {
                    _loading = false;
                  });
                }
              },
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                direction: Axis.vertical,
                alignment: WrapAlignment.center,
                children: [
                  Icon(size: widget._iconSize, widget.iconData),
                  Text(
                    widget._text,
                    style: TextStyle(
                      fontSize: Theme.of(
                        context,
                      ).textTheme.labelSmall!.fontSize,
                    ),
                  ),
                ],
              ),
            ),
    ),
  );
}
