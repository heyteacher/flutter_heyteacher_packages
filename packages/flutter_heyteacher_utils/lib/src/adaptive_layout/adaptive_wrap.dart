import 'package:flutter/material.dart';

/// Adaptive [Wrap] based to the screen size.
class AdaptiveWrap extends StatelessWidget {
 
  /// Creates an instance of [AdaptiveWrap].
  ///
  /// the [children] width are adapted to Screen width and [crossAxisCount]
  const AdaptiveWrap({
    required List<Widget> children,
    required int crossAxisCount,
    double runSpacing = 4,
    double spacing = 4,
    Axis direction = Axis.horizontal,
    WrapAlignment alignment = WrapAlignment.center,
    super.key,
  }) : _spacing = spacing,
       _runSpacing = runSpacing,
       _direction = direction,
       _crossAxisCount = crossAxisCount,
       _alignment = alignment,
       _children = children;

  final List<Widget> _children;
  final double _spacing;
  final double _runSpacing;
  final Axis _direction;
  final WrapAlignment _alignment;

  final int _crossAxisCount;

  @override
  Widget build(BuildContext context) => Wrap(
    direction: _direction,
    spacing: _spacing,
    runSpacing: _runSpacing,
    alignment: _alignment,
    children: _children
        .map(
          (child) => ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: _width(context),
              maxHeight: _height(context)
            ),
            child: child,
          ),
        )
        .toList(),
  );

  double _width(BuildContext context) {
    assert(_crossAxisCount > 0, 'columns must be greater than 0');
    return _direction == Axis.horizontal
        ? (MediaQuery.of(context).size.width -
                  _runSpacing * (_crossAxisCount - 1)) /
              _crossAxisCount
        : double.infinity;
  }

  double _height(BuildContext context) {
    assert(_crossAxisCount > 0, 'columns must be greater than 0');
    return _direction == Axis.vertical
        ? (MediaQuery.of(context).size.height -
                  _runSpacing * (_crossAxisCount - 1)) /
              _crossAxisCount
        : double.infinity;
  }
}

/// Create a Sliver Adaptive with remaining items centered
class SliverAdaptiveWrap extends StatelessWidget {
  /// Creates an instance of Wrap with [crossAxisCount]
  /// columns ([direction] = [Axis.horizontal] default) or
  /// rows ([direction] = [Axis.vertical]) with remaining items centered.
  ///
  /// Childredn are spaced by [runSpacing] (default = 4) and [spacing]
  /// (default = 4).
  const SliverAdaptiveWrap({
    required List<Widget> children,
    required int crossAxisCount,
    Axis direction = Axis.horizontal,
    //ScrollController? controller,
    double runSpacing = 4,
    double spacing = 4,
    super.key,
  }) : _direction = direction,
    //   _controller = controller,
       _crossAxisCount = crossAxisCount,
       _children = children,
       _spacing = spacing,
       _runSpacing = runSpacing;

  final double _runSpacing;
  final double _spacing;
  final List<Widget> _children;
  final int _crossAxisCount;
  final Axis _direction;
  //final ScrollController? _controller;

@override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: AdaptiveWrap(
      direction: _direction,
      runSpacing: _runSpacing,
      spacing: _spacing,
      crossAxisCount: _crossAxisCount,
      children: _children
    ),
  );
}
