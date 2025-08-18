import 'dart:math';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class ChartDataItem {
  final num x;
  final num y;
  final Color? yColor;
  const ChartDataItem({required this.x, required this.y, this.yColor});

  @override
  toString() => 'x: $x, y: $y';
}

abstract class ChartView extends StatelessWidget {
  final Widget title;
  final Iterable<ChartDataItem> chartDataList;
  late final num minX;
  late final num maxX;
  late final int intervalX;
  final String Function(ChartDataItem) formatterX;
  final String Function(int) formatterAxisX;
  final Color Function(double) formatterColorAxisX;
  final Widget? axisNameWidgetX;
  late final num minY;
  late final num maxY;
  late final int intervalY;
  final String Function(ChartDataItem) formatterY;
  final String Function(double) formatterAxisY;
  final Color Function(double) formatterColorAxisY;
  final Widget? axisNameWidgetY;

  ChartView(
      {required this.chartDataList,
      required this.title,
      num? maxX,
      num? minX,
      int minIntervalX = 1,
      required this.formatterX,
      required this.formatterAxisX,
      required this.formatterColorAxisX,
      this.axisNameWidgetX,
      num? maxY,
      num? minY,
      int minIntervalY = 1,
      required this.formatterY,
      required this.formatterAxisY,
      required this.formatterColorAxisY,
      this.axisNameWidgetY,
      super.key}) {
    // set intervalX maxX minX
    maxX ??= chartDataList.isNotEmpty ? chartDataList.map((e) => e.x).max : 0;
    minX ??= chartDataList.isNotEmpty ? chartDataList.map((e) => e.x).min : 0;
    intervalX = interval(minX, maxX, minInterval: minIntervalX);
    this.minX = ChartView.floorToInterval(minX, intervalX);
    this.maxX = ChartView.ceilToInterval(maxX, intervalX);
    // set intervalY maxY minY
    var iterableY = chartDataList.map((e) => e.y).nonNulls;
    if (iterableY.isNotEmpty) {
      maxY ??= iterableY.max;
      minY ??= iterableY.min;
      intervalY = interval(minY, maxY, minInterval: minIntervalY);
      this.minY = ChartView.floorToInterval(minY, intervalY);
      this.maxY = ChartView.ceilToInterval(maxY, intervalY) + intervalY;
    } else {
      this.maxY = 0;
      this.minY = 0;
      intervalY = minIntervalY;
    }
  }

  @protected
  int interval(num minValue, num maxValue,
          {int minInterval = 5, int occurences = 10}) =>
      max(
          ((maxValue - minValue) /
                      occurences // the interval to have <occurrences> in axies
                      /
                      minInterval)
                  .round() *
              minInterval, // round the value to multiplier
          minInterval); // if inverval is less than multiplier, use multiplier

  @protected
  static int roundToInterval(num value, num interval) =>
      interval != 0 ? ((value / interval).round() * interval).toInt() : 0;

  @protected
  static int ceilToInterval(num value, num interval) =>
      interval != 0 ? ((value / interval).ceil() * interval).toInt() : 0;

  @protected
  static int floorToInterval(num value, num interval) =>
      interval != 0 ? ((value / interval).floor() * interval).toInt() : 0;
}
