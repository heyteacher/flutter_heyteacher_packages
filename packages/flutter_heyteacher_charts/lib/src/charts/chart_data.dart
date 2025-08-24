import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ChartDataItem {
  final num x;
  final num y;
  final Color? yColor;
  const ChartDataItem({required this.x, required this.y, this.yColor});

  @override
  toString() => 'x $x y $y';
}

class BarChartDataItem extends ChartDataItem {
  final num? y1;
  final num? y2;
  final num fromY;

  BarChartDataItem(
      {this.fromY = 0,
      required super.x,
      required super.y,
      super.yColor,
      this.y1,
      this.y2});

  @override
  toString() => 'x $x fromY $fromY y $y y1 $y1 y2 $y2';
}

class CandlestickDataItem extends ChartDataItem {
  final num yPrec;
  final num yHigh;
  final num yLow;

  CandlestickDataItem({
    required super.x,
    required super.y,
    required this.yPrec,
    required this.yHigh,
    required this.yLow,
  });

  bool get isUp => yPrec < y;

  num get minY => min(y, min(yLow, yHigh));
  num get maxY => max(y, max(yLow, yHigh));

  @override
  toString() => 'x $x y $y  yPrec $yPrec yHigh: $yHigh yLow: $yLow';
}

class ExtraLineData extends Equatable {
  final num value;
  final String label;
  final Color color;
  
  const ExtraLineData(
      {required this.value, required this.color, required this.label});

  @override
  List<Object?> get props => [value, color, label];
}

class RangeAnnotationData extends Equatable {
  final num min, max, value;
  final String label;
  final Color color;

  const RangeAnnotationData(
      {required this.min,
      required this.max,
      required this.value,
      required this.label,
      required this.color});

  @override
  List<Object?> get props => [min, max, value, color, label];
}
