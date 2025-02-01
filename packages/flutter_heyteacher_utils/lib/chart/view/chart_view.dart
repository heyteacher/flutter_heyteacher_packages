import 'dart:math';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class ChartData {
  final num x;
  final num y;
  final Color? yColor;
  final num? y1;
  const ChartData({required this.x, required this.y, this.yColor, this.y1});
}

abstract class ChartView extends StatelessWidget {
  final String title;
  final Iterable<ChartData> chartDataList;
  late final num minX;
  late final num maxX;
  late final int intervalX;
  final Color colorX;
  final String Function(ChartData) formatterX;
  final String Function(ChartData) formatterAxisX;
  late final num minY;
  late final num maxY;
  late final int intervalY;
  final Color colorY;
  final String Function(ChartData) formatterY;
  final String Function(ChartData) formatterAxisY;

  ChartView(
      {required this.chartDataList,
      required this.title,
      num? maxX,
      num? minX,
      int minIntervalX = 1,
      required this.formatterX,
      String Function(ChartData)? formatterAxisX,
      required this.colorX,
      num? maxY,
      num? minY,
      int minIntervalY = 1,
      required this.formatterY,
      String Function(ChartData)? formatterAxisY,
      required this.colorY,
      super.key})
      : formatterAxisX = formatterAxisX ?? formatterX,
        formatterAxisY = formatterAxisY ?? formatterY {
    // set intervalX maxX minX
    maxX ??= chartDataList.map((e) => e.x).max;
    minX ??= chartDataList.map((e) => e.x).min;
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
