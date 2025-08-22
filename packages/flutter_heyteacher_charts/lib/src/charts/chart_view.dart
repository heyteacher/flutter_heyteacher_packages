import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_heyteacher_charts/src/charts/bar_chart_view.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_data.dart';
import 'package:flutter_heyteacher_utils/theme.dart';

abstract class ChartView extends StatelessWidget {
  final Widget title;
  final Iterable<ChartDataItem> chartDataList;
  late final double minX;
  late final double maxX;
  late final double intervalX;
  final String Function(ChartDataItem)? formatterX;
  final String Function(double) formatterAxisX;
  final Color Function(double) formatterColorAxisX;
  final Widget? axisNameWidgetX;
  late final double minY;
  late final double maxY;
  late final double intervalY;
  final String Function(ChartDataItem)? formatterY;
  final String Function(double) formatterAxisY;
  final Color Function(double) formatterColorAxisY;
  final Widget? axisNameWidgetY;
  final Iterable<RangeAnnotationData>? _horizontalRangeAnnotations;
  final Iterable<RangeAnnotationData>? _verticalRangeAnnotations;
  final Iterable<ExtraLineData>? extraHorizontalLines;
  final Iterable<ExtraLineData>? extraVerticalLines;
  final bool rotate;
  final double reservedSizeX;
  final double reservedSizeY;

  ChartView(
      {required this.chartDataList,
      required this.title,
      double? maxX,
      double? minX,
      double minIntervalX = 1,
      this.formatterX,
      required this.formatterAxisX,
      required this.formatterColorAxisX,
      this.axisNameWidgetX,
      double? maxY,
      double? minY,
      double minIntervalY = 1,
      this.formatterY,
      required this.formatterAxisY,
      required this.formatterColorAxisY,
      this.axisNameWidgetY,
      this.extraHorizontalLines,
      this.extraVerticalLines,
      Iterable<RangeAnnotationData>? horizontalRangeAnnotations,
      Iterable<RangeAnnotationData>? verticalRangeAnnotations,
      this.reservedSizeX = 45,
      this.reservedSizeY = 40,
      this.rotate = false,
      super.key})
      : _verticalRangeAnnotations = verticalRangeAnnotations,
        _horizontalRangeAnnotations = horizontalRangeAnnotations {
    // set intervalX maxX minX
    maxX ??= chartDataList.isNotEmpty
        ? chartDataList.map((e) => e.x).max.toDouble()
        : 0;
    minX ??= chartDataList.isNotEmpty
        ? chartDataList.map((e) => e.x).min.toDouble()
        : 0;
    intervalX = interval(minX, maxX, minInterval: minIntervalX);
    this.minX = ChartView.floorToInterval(minX, intervalX);
    this.maxX = ChartView.ceilToInterval(maxX, intervalX);
    // set intervalY maxY minY
    var iterableY = chartDataList.map((e) => e.y).nonNulls;
    if (iterableY.isNotEmpty) {
      maxY ??= iterableY.max.toDouble();
      minY ??= iterableY.min.toDouble();
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
  FlTitlesData get titlesData => FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: rotate ? yAxisTitles() : const AxisTitles(),
        bottomTitles: xAxisTitles(),
        leftTitles: rotate ? const AxisTitles() : yAxisTitles(),
      );

  @protected
  AxisTitles xAxisTitles() => AxisTitles(
        axisNameWidget:
            RotatedBox(quarterTurns: rotate ? 2 : 0, child: axisNameWidgetX),
        sideTitles: SideTitles(
            showTitles: true,
            interval: runtimeType == BarChartView
                ? double.maxFinite // that means no X intervals in bar char
                : intervalX.toDouble(),
            reservedSize: reservedSizeX,
            maxIncluded: runtimeType == BarChartView ? false : true,
            minIncluded: runtimeType == BarChartView ? false : true,
            getTitlesWidget: (value, meta) => bottomTitleWidgets(value, meta)),
      );

  @protected
  AxisTitles yAxisTitles() => AxisTitles(
        axisNameWidget: axisNameWidgetY,
        drawBelowEverything: true,
        sideTitles: SideTitles(
            showTitles: true,
            reservedSize: reservedSizeY,
            maxIncluded: false,
            minIncluded: false,
            interval: intervalY.toDouble(),
            getTitlesWidget: (value, TitleMeta meta) =>
                leftTitleWidgets(value, meta)),
      );

  @protected
  Widget leftTitleWidgets(double value, TitleMeta meta) => RotatedBox(
        quarterTurns: rotate ? 3 : 0,
        child: SideTitleWidget(
          meta: meta,
          child: Padding(
            padding:
                EdgeInsets.only(right: rotate ? 0 : 4.0, top: rotate ? 4.0 : 0),
            child: Text(
              formatterAxisY(value),
              style: TextStyle(color: formatterColorAxisY(value)),
            ),
          ),
        ),
      );

  @protected
  Widget bottomTitleWidgets(double value, TitleMeta meta) => SideTitleWidget(
      meta: meta,
      space: 3,
      child: Padding(
        padding: const EdgeInsets.only(right: 0, left: 5),
        child: RotatedBox(
          quarterTurns: rotate ? 0 : 3,
          child: Text(
            formatterAxisX(value),
            style: ThemeViewModel.instance()
                .theme
                .textTheme
                .bodySmall!
                .copyWith(color: formatterColorAxisX(value)),
          ),
        ),
      ));

  @protected
  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
              color: ThemeViewModel.instance()
                  .theme
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              width: 1),
          left: BorderSide(
              color: ThemeViewModel.instance()
                  .theme
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              width: 1),
          right: BorderSide(
              color: ThemeViewModel.instance()
                  .theme
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0),
              width: 1),
          top: BorderSide(
              color: ThemeViewModel.instance()
                  .theme
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0),
              width: 1),
        ),
      );

  @protected
  List<HorizontalLine> get horizontalLines => [
        ..._horizontalRangeAnnotations?.map(
              (e) => HorizontalLine(
                  y: e.min.toDouble(),
                  color: e.color.withValues(alpha: 0.4),
                  label: HorizontalLineLabel(
                      style: TextStyle(
                          color: e.color, fontWeight: FontWeight.bold),
                      alignment: Alignment.lerp(
                          Alignment.centerLeft, Alignment.topLeft, 0.5)!,
                      show: true,
                      labelResolver: (_) => e.label)),
            ) ??
            [],
        ...extraHorizontalLines
                ?.map(
                  (e) => HorizontalLine(
                      y: e.value.toDouble(),
                      color: e.color.withValues(alpha: 0.4),
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.bottomRight,
                        labelResolver: (_) => e.label,
                      )),
                )
                .toList() ??
            []
      ];

  @protected
  List<VerticalLine> get verticalLines => [
        // draw a line at the start of range
        ..._verticalRangeAnnotations?.map(
              (e) => VerticalLine(
                  x: e.min.toDouble(),
                  color: e.color.withValues(alpha: 0.4),
                  label: VerticalLineLabel(
                      style: TextStyle(
                          color: e.color, fontWeight: FontWeight.bold),
                      alignment: Alignment.topRight,
                      show: true,
                      labelResolver: (_) => e.label)),
            ) ??
            [],
        // draw a line at the end of range
        ..._verticalRangeAnnotations?.map(
              (e) => VerticalLine(
                  x: e.max.toDouble(),
                  color: e.color.withValues(alpha: 0.4),
                  label: VerticalLineLabel(
                      style: TextStyle(
                          color:
                              ThemeViewModel.instance().colorScheme.onSurface,
                          fontWeight: FontWeight.bold),
                      alignment: Alignment.topRight,
                      show: true,
                      labelResolver: (_) => '')),
            ) ??
            [],
        // draw a extra vertical line
        ...extraVerticalLines
                ?.map(
                  (e) => VerticalLine(
                      x: e.value.toDouble(),
                      color: e.color,
                      label: VerticalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        labelResolver: (_) => e.label,
                      )),
                )
                .toList() ??
            []
      ];

  @protected
  List<VerticalRangeAnnotation> get verticalRangeAnnotations =>
      _verticalRangeAnnotations
          ?.map(
            (e) => VerticalRangeAnnotation(
                x1: max(e.min.toDouble(), minX.toDouble()),
                x2: min(e.max.toDouble(), maxX.toDouble()),
                color: e.color.withValues(alpha: 0.4)),
          )
          .toList() ??
      [];

  @protected
  List<HorizontalRangeAnnotation> get horizontalRangeAnnotations =>
      _horizontalRangeAnnotations
          ?.map(
            (e) => HorizontalRangeAnnotation(
                y1: max(e.min.toDouble(), minY.toDouble()),
                y2: min(e.max.toDouble(), maxY.toDouble()),
                color: e.color.withValues(alpha: 0.4)),
          )
          .toList() ??
      [];

  @protected
  double interval(num minValue, num maxValue,
          {double minInterval = 5, int occurences = 10}) =>
      (max(
          ((maxValue - minValue) /
                  occurences // the interval to have <occurrences> in axies
                  /
                  minInterval) *
              minInterval,
          minInterval) * 10).round() / 10; // if inverval is less than multiplier, use multiplier

  @protected
  static int roundToInterval(num value, num interval) =>
      interval != 0 ? ((value / interval).round() * interval).toInt() : 0;

  @protected
  static double ceilToInterval(num value, num interval) =>
      interval != 0 ? ((value / interval).ceil() * interval).ceilToDouble() : 0;

  @protected
  static double floorToInterval(num value, num interval) =>
      interval != 0 ? ((value / interval).floor() * interval).floorToDouble() : 0;
}
