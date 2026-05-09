import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';

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
          (child) => LayoutBuilder(
            builder: (context, constraints) => ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: _width(
                  context: context,
                  parentWidth: constraints.maxWidth,
                ),
                maxHeight: _height(
                  context: context,
                  parentHeight: constraints.maxHeight,
                ),
              ),
              child: child,
            ),
          ),
        )
        .toList(),
  );

  double _width({required BuildContext context, required double parentWidth}) =>
      _direction == Axis.horizontal
      ? max(
              parentWidth -
                  (MediaQuery.of(context).orientation ==
                              Orientation.landscape &&
                          PlatformHelper.isMobile
                      ? AppBar().preferredSize.shortestSide
                      : 0) -
                  _spacing * (_crossAxisCount - 1),
              0,
            ) /
            max(_crossAxisCount, 1)
      : double.infinity;

  double _height({
    required BuildContext context,
    required double parentHeight,
  }) => _direction == Axis.vertical
      ? max(parentHeight - _runSpacing * (max(_crossAxisCount, 1) - 1), 0) /
            max(_crossAxisCount, 1)
      : double.infinity;
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
    WrapAlignment alignment = WrapAlignment.center,
    super.key,
  }) : _direction = direction,
       //   _controller = controller,
       _crossAxisCount = crossAxisCount,
       _children = children,
       _spacing = spacing,
       _runSpacing = runSpacing,
       _alignment = alignment;

  final double _runSpacing;
  final double _spacing;
  final List<Widget> _children;
  final int _crossAxisCount;
  final Axis _direction;
  final WrapAlignment _alignment;

  //final ScrollController? _controller;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: AdaptiveWrap(
      direction: _direction,
      runSpacing: _runSpacing,
      spacing: _spacing,
      crossAxisCount: _crossAxisCount,
      alignment: _alignment,
      children: _children,
    ),
  );
}
