import 'package:flutter/material.dart';

class ChartDataItem {
  final num x;
  final num y;
  final Color? yColor;
  const ChartDataItem({required this.x, required this.y, this.yColor});

  @override
  toString() => 'x: $x, y: $y';
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
  toString() => 'x: $x, fromY: $fromY, y: $y,  y1: $y1,  y2: $y2';
}

class ExtraLineData {
  final num value;
  final String label;
  final Color color;
  ExtraLineData(
      {required this.value, required this.color, required this.label});
}

class RangeAnnotationData {
  final num min, max, value;
  final String label;
  final Color color;
  RangeAnnotationData(
      {required this.min,
      required this.max,
      required this.value,
      required this.label,
      required this.color});
}
