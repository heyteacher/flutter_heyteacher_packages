import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';

/// Adaptive [Wrap] based to the screen size.
class AdaptiveWrap extends StatelessWidget {
  /// Creates an instance of [AdaptiveWrap].
  ///
  /// the [_children] width are adapted to Screen width and [_crossAxisCount]
  const AdaptiveWrap({
    required this._children,
    required this._crossAxisCount,
    this._runSpacing = 4,
    this._spacing = 4,
    this._direction = Axis.horizontal,
    this._alignment = WrapAlignment.center,
    super.key,
  });

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
  /// Creates an instance of Wrap with [_crossAxisCount]
  /// columns ([_direction] = [Axis.horizontal] default) or
  /// rows ([_direction] = [Axis.vertical]) with remaining items centered.
  ///
  /// Childredn are spaced by [_runSpacing] (default = 4) and [_spacing]
  /// (default = 4).
  const SliverAdaptiveWrap({
    required this._children,
    required this._crossAxisCount,
    this._direction = Axis.horizontal,
    this._runSpacing = 4,
    this._spacing = 4,
    this._alignment = WrapAlignment.center,
    super.key,
  });

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
