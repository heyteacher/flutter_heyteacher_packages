import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/flutter_heyteacher_charts.dart';

/// A generic data item for a chart, representing a point with x and y
/// coordinates.
class ChartDataItem {
  /// Creates a [ChartDataItem].
  const ChartDataItem({required this.x, required this.y, this.yColor});
  /// The value on the X-axis.
  final num x;
  /// The value on the Y-axis.
  final num y;
  /// An optional color for this specific data point.
  final Color? yColor;

  @override
  String toString() => 'x $x y $y';
}

/// A data item specifically for a [BarChartView], extending [ChartDataItem].
///
/// It includes optional properties like [y1] and [y2] for creating stacked or
/// grouped bars, and [fromY] to specify the bar's starting point on the y-axis.
class BarChartDataItem extends ChartDataItem {
  /// Creates a data item for a bar chart, used by [BarChartView].
  BarChartDataItem(
      {required super.x, required super.y, this.fromY = 0,
      super.yColor,
      this.y1,
      this.y2,});
  /// An optional secondary y-value, for stacked or grouped bars.
  final num? y1;
  /// An optional tertiary y-value, for stacked or grouped bars.
  final num? y2;
  /// The starting y-value for the bar, defaulting to 0.
  final num fromY;

  @override
  String toString() => 'x $x fromY $fromY y $y y1 $y1 y2 $y2';
}

/// A data item for a candlestick chart, representing open, high, low, and
/// close values.
class CandlestickDataItem extends ChartDataItem {
  /// Creates a [CandlestickDataItem].
  ///
  /// [y] represents the closing value.
  CandlestickDataItem({
    required super.x,
    required super.y,
    required this.yPrec,
    required this.yHigh,
    required this.yLow,
  });
  /// The opening value (or previous closing value).
  final num yPrec;
  /// The highest value in the period.
  final num yHigh;
  /// The lowest value in the period.
  final num yLow;

  /// Returns `true` if the closing value is greater than the opening value.
  bool get isUp => yPrec < y;

  /// The minimum value among the open, close, low, and high values.
  num get minY => min(y, min(yLow, yHigh));
  /// The maximum value among the open, close, low, and high values.
  num get maxY => max(y, max(yLow, yHigh));

  @override
  String toString() => 'x $x y $y  yPrec $yPrec yHigh: $yHigh yLow: $yLow';
}

/// Represents an extra horizontal or vertical line to be drawn on a chart.
class ExtraLineData extends Equatable {
  
  /// Creates an [ExtraLineData] instance.
  const ExtraLineData(
      {required this.value, required this.color, required this.label,});
  /// The position of the line on its axis (e.g., y-value for a horizontal
  /// line).
  final num value;
  /// The text label to display with the line.
  final String label;
  /// The color of the line.
  final Color color;

  @override
  List<Object?> get props => [value, color, label];
}

/// Represents a colored range annotation on a chart, either horizontally or
/// vertically.
class RangeAnnotationData extends Equatable {
  /// Creates a [RangeAnnotationData] instance.
  const RangeAnnotationData(
      {required this.min,
      required this.max,
      required this.value,
      required this.label,
      required this.color,});
  /// The starting point of the range on the axis.
  final num min;
  /// The ending point of the range on the axis.
  final num max;
  /// A specific value associated with the range, for labeling or calculation.
  final num value;
  /// The text label for the range.
  final String label;
  /// The color of the range annotation.
  final Color color;

  @override
  List<Object?> get props => [min, max, value, color, label];
}
