import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/src/charts/bar_chart_view.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_data.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// An abstract base class for creating various chart widgets using the
/// `fl_chart` package.
///
/// This class handles the common logic for setting up chart axes, titles,
/// ranges, and formatting, allowing concrete implementations like
/// [BarChartView] or `LineChartView` to focus on rendering the specific chart
/// type.
abstract class ChartView extends StatelessWidget {
  /// Creates a [ChartView].
  ///
  /// This constructor initializes all the common properties for a chart and
  /// calculates the axis ranges and intervals based on the provided data and
  /// parameters.
  ChartView({
    required this.chartDataLists,
    required this.formatterAxisX,
    required this.formatterColorAxisX,
    required this.formatterAxisY,
    required this.formatterColorAxisY,
    super.key,
    this.aspectRatio = 1,
    this.title = const Text(''),
    this.rightTitlesLikeLeft = false,
    this.formatterColorLine,
    this.axisNameWidgetX,
    this.reservedSizeX = 45,
    double? maxX,
    double? minX,
    double minIntervalX = 5,
    this.formatterX,
    this.axisNameWidgetY,
    this.reservedSizeY = 45,
    double? maxY,
    double? minY,
    double minIntervalY = 5,
    this.formatterY,
    this.axisNameWidgetYAlt,
    this.reservedSizeYAlt = 45,
    this.formatterYAlt,
    this.formatterAxisYAlt,
    this.formatterColorAxisYAlt,
    this.intervalYAlt,
    this.extraHorizontalLines,
    this.extraVerticalLines,
    Iterable<RangeAnnotationData>? horizontalRangeAnnotations,
    Iterable<RangeAnnotationData>? verticalRangeAnnotations,
    this.rotate = false,
    this.betweenBarsDataList,
    this.aboveBarDataList,
    this.belowBarDataList,
    this.isCurvedList,
    this.isStepLineChartList,
  })  : _verticalRangeAnnotations = verticalRangeAnnotations,
        _horizontalRangeAnnotations = horizontalRangeAnnotations {
    // set intervalX maxX minX
    maxX ??= _maxX();
    minX ??= _minX();
    intervalX = interval(minX, maxX, minInterval: minIntervalX);
    this.minX = ChartView.floorToInterval(minX, intervalX);
    this.maxX = ChartView.ceilToInterval(maxX, intervalX);
    // set intervalY maxY minY
    final minMaxValues = _minMaxIntervalY(maxY, minY, minIntervalY);
    intervalY = minMaxValues.intervalY;
    minY ??= minMaxValues.minY;
    maxY ??= minMaxValues.maxY;
    this.minY = ChartView.floorToInterval(minY, intervalX);
    this.maxY = ChartView.ceilToInterval(maxY, intervalX);
  }

  /// A widget to display as the main title of the chart.
  final Widget title;

  /// A list of data series to be plotted on the chart. Each inner iterable
  /// represents a separate series.
  final Iterable<Iterable<ChartDataItem>> chartDataLists;

  /// The aspect ratio of the chart widget.
  final double aspectRatio;

  /// The reserved space on the bottom side for the X-axis labels.
  final double reservedSizeX;

  /// The minimum value for the X-axis. If not provided, it's calculated from
  /// the data.
  late final double minX;

  /// The maximum value for the X-axis. If not provided, it's calculated from
  /// the data.
  late final double maxX;

  /// The interval between ticks on the X-axis.
  late final double intervalX;

  /// A function to format the tooltip text for a given data point's X-value.
  final String Function(ChartDataItem)? formatterX;

  /// A function to format the label text for a given value on the X-axis.
  final String Function(double) formatterAxisX;

  /// A function to determine the color of a label on the X-axis.
  final Color Function(double) formatterColorAxisX;

  /// An optional widget to display as the name of the X-axis.
  final Widget? axisNameWidgetX;

  /// The reserved space on the right side for the alternative Y-axis labels.
  final double reservedSizeYAlt;

  /// The minimum value for the alternative (right) Y-axis.
  late final double? minYAlt;

  /// The maximum value for the alternative (right) Y-axis.
  late final double? maxYAlt;

  /// The interval between ticks on the alternative (right) Y-axis.
  late final double? intervalYAlt;

  /// A function to determine the color of a label on the alternative Y-axis.
  final Color Function(double)? formatterColorAxisYAlt;

  /// A function to format the tooltip text for a data point on the alternative
  /// Y-axis.
  final String Function(int, ChartDataItem)? formatterYAlt;

  /// A function to format the label text for a given value on the alternative
  /// Y-axis.
  final String Function(int, double)? formatterAxisYAlt;

  /// An optional widget to display as the name of the alternative Y-axis.
  final Widget? axisNameWidgetYAlt;

  /// The reserved space on the left side for the primary Y-axis labels.
  final double reservedSizeY;

  /// The minimum value for the primary (left) Y-axis.
  late final double minY;

  /// The maximum value for the primary (left) Y-axis.
  late final double maxY;

  /// The interval between ticks on the primary (left) Y-axis.
  late final double intervalY;

  /// A function to determine the color of a label on the primary Y-axis.
  final Color Function(double) formatterColorAxisY;

  /// A function to format the tooltip text for a data point on the primary
  /// Y-axis.
  final String Function(int, ChartDataItem)? formatterY;

  /// A function to format the label text for a given value on the primary
  /// Y-axis.
  final String Function(int, double) formatterAxisY;

  /// A function to determine the color of a line series in a line chart.
  final Color Function(int, double)? formatterColorLine;

  /// An optional widget to display as the name of the primary Y-axis.
  final Widget? axisNameWidgetY;

  /// If `true`, the right Y-axis will be configured with the same titles as the
  /// left Y-axis.
  final bool rightTitlesLikeLeft;
  final Iterable<RangeAnnotationData>? _horizontalRangeAnnotations;
  final Iterable<RangeAnnotationData>? _verticalRangeAnnotations;

  /// A list of extra horizontal lines to draw on the chart.
  final Iterable<ExtraLineData>? extraHorizontalLines;

  /// A list of extra vertical lines to draw on the chart.
  final Iterable<ExtraLineData>? extraVerticalLines;

  /// If `true`, the chart's axes are rotated by 90 degrees.
  final bool rotate;

  /// For line charts, a list of booleans indicating whether each line series
  /// should be curved.
  final Iterable<bool?>? isCurvedList;

  /// For line charts, a list of booleans indicating whether each line series
  /// should be a step chart.
  final Iterable<bool?>? isStepLineChartList;

  /// For line charts, defines the appearance of the area between two line
  /// series.
  final Iterable<
      ({
        int fromIndex,
        int toIndex,
        Color? color,
        Color? fromAboveColor,
        Color? fromBelowColor,
        Gradient? gradient
      })?>? betweenBarsDataList;

  /// For line charts, defines the appearance of the area above a line series,
  /// cut off at a specific Y-value.
  final Iterable<({double cutoff, Color color})?>? aboveBarDataList;

  /// For line charts, defines the appearance of the area below a line series,
  /// cut off at a specific Y-value.
  final Iterable<({double cutoff, Color color})?>? belowBarDataList;

  ({double intervalY, double maxY, double minY}) _minMaxIntervalY(
    double? maxY,
    double? minY,
    double minIntervalY,
  ) {
    double? intervalYValue;
    double? maxYValue;
    double? minYValue;
    for (final chartDataList in chartDataLists) {
      final iterableY = chartDataList.map((e) => e.y).nonNulls;
      if (iterableY.isNotEmpty) {
        final newMaxY = iterableY.max.toDouble();
        final maxYToUse = maxY == null || maxY < newMaxY ? newMaxY : maxY;
        final newMinY = iterableY.min.toDouble();
        final minYToUse = minY == null || minY > newMinY ? newMinY : minY;
        intervalYValue =
            interval(minYToUse, maxYToUse, minInterval: minIntervalY);
        minYValue = min(
          ChartView.floorToInterval(minYToUse, intervalYValue),
          minYValue ?? 0,
        );
        maxYValue = max(
          ChartView.ceilToInterval(maxYToUse, intervalYValue),
          maxYValue ?? 0,
        );
      } else {
        minYValue = 0;
        maxYValue = 0;
        intervalYValue = minIntervalY;
      }
    }
    return (
      intervalY: intervalYValue ?? 0,
      minY: minYValue ?? 0,
      maxY: maxYValue ?? 0
    );
  }

  double _minX() => chartDataLists.isNotEmpty
      ? chartDataLists
          .map(
            (chartDataList) => chartDataList.isNotEmpty
                ? chartDataList.map((e) => e.x).min.toDouble()
                : 0,
          )
          .min
          .toDouble()
      : 0;

  double _maxX() => chartDataLists.isNotEmpty
      ? chartDataLists
          .map(
            (chartDataList) => chartDataList.isNotEmpty
                ? chartDataList.map((e) => e.x).max.toDouble()
                : 0,
          )
          .max
          .toDouble()
      : 0;

  /// Gets the first data series from [chartDataLists].
  ///
  /// This is a convenience getter for charts that only handle a single series.
  @protected
  Iterable<ChartDataItem> get chartDataList => chartDataLists.first;

  /// Configures the titles (axes labels and names) for the chart.
  @protected
  FlTitlesData get titlesData => FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: formatterAxisYAlt != null
            ? yAltAxisTitles()
            : rightTitlesLikeLeft || rotate
                ? yAxisTitles()
                : const AxisTitles(),
        bottomTitles: xAxisTitles(),
        leftTitles: rotate ? const AxisTitles() : yAxisTitles(),
      );

  /// Configures the X-axis titles.
  @protected
  AxisTitles xAxisTitles() => AxisTitles(
        axisNameSize: 20,
        axisNameWidget:
            RotatedBox(quarterTurns: rotate ? 2 : 0, child: axisNameWidgetX),
        sideTitles: SideTitles(
          showTitles: true,
          interval: runtimeType == BarChartView
              ? double.maxFinite // that means no X intervals in bar char
              : intervalX,
          reservedSize: reservedSizeX,
          maxIncluded: !(runtimeType == BarChartView),
          minIncluded: !(runtimeType == BarChartView),
          getTitlesWidget: bottomTitleWidgets,
        ),
      );

  /// Configures the primary (left) Y-axis titles.
  @protected
  AxisTitles yAxisTitles() => AxisTitles(
        axisNameWidget: axisNameWidgetY,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: reservedSizeY,
          maxIncluded: false,
          minIncluded: false,
          interval: intervalY,
          getTitlesWidget: leftTitleWidgets,
        ),
      );

  /// Builds the widget for a single label on the left Y-axis.
  @protected
  Widget leftTitleWidgets(double value, TitleMeta meta) => RotatedBox(
        quarterTurns: rotate ? 3 : 0,
        child: SideTitleWidget(
          meta: meta,
          child: Padding(
            padding:
                EdgeInsets.only(right: rotate ? 0 : 4.0, top: rotate ? 4.0 : 0),
            child: Text(
              formatterAxisY(0, value),
              style: TextStyle(
                color: formatterColorAxisY(value),
                fontSize: 10,
              ),
            ),
          ),
        ),
      );

  /// Configures the alternative (right) Y-axis titles.
  @protected
  AxisTitles yAltAxisTitles() => AxisTitles(
        axisNameWidget: axisNameWidgetYAlt,
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: reservedSizeYAlt,
          maxIncluded: false,
          minIncluded: false,
          interval: intervalYAlt,
          getTitlesWidget: rightTitleWidgets,
        ),
      );

  /// Builds the widget for a single label on the right Y-axis.
  @protected
  Widget rightTitleWidgets(double value, TitleMeta meta) => RotatedBox(
        quarterTurns: rotate ? 3 : 0,
        child: SideTitleWidget(
          meta: meta,
          child: Padding(
            padding:
                EdgeInsets.only(right: rotate ? 0 : 4.0, top: rotate ? 4.0 : 0),
            child: Text(
              formatterAxisYAlt!(0, value),
              style: TextStyle(color: formatterColorAxisYAlt?.call(value)),
            ),
          ),
        ),
      );

  /// Builds the widget for a single label on the bottom X-axis.
  @protected
  Widget bottomTitleWidgets(double value, TitleMeta meta) => SideTitleWidget(
        meta: meta,
        space: 3,
        child: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: RotatedBox(
            quarterTurns: rotate ? 0 : 3,
            child: Text(
              formatterAxisX(value),
              style: TextStyle(color: formatterColorAxisX(value), fontSize: 10),
            ),
          ),
        ),
      );

  /// Configures the border of the chart drawing area.
  @protected
  FlBorderData get borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
            color: ThemeViewModel.instance.colorScheme.onSurface
                .withValues(alpha: 0.5),
          ),
          left: BorderSide(
            color: ThemeViewModel.instance.colorScheme.onSurface
                .withValues(alpha: 0.5),
          ),
          right: BorderSide(
            color: ThemeViewModel.instance.colorScheme.onSurface
                .withValues(alpha: rightTitlesLikeLeft ? 0.5 : 0),
          ),
          top: BorderSide(
            color: ThemeViewModel.instance.colorScheme.onSurface
                .withValues(alpha: 0),
          ),
        ),
      );

  /// Generates a list of [HorizontalLine]s from the provided annotation data.
  @protected
  List<HorizontalLine> get horizontalLines => [
        ..._horizontalRangeAnnotations?.map(
              (e) => HorizontalLine(
                y: e.min.toDouble(),
                color: e.color,
                label: HorizontalLineLabel(
                  style: TextStyle(
                    color: e.color,
                    fontWeight: FontWeight.bold,
                  ),
                  alignment: Alignment.lerp(
                    Alignment.centerLeft,
                    Alignment.topLeft,
                    0.5,
                  )!,
                  show: true,
                  labelResolver: (_) => e.label,
                ),
              ),
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
                    ),
                  ),
                )
                .toList() ??
            [],
      ];

  /// Generates a list of [VerticalLine]s from the provided annotation data.
  @protected
  List<VerticalLine> get verticalLines => [
        // draw a line at the start of range
        ..._verticalRangeAnnotations?.map(
              (e) => VerticalLine(
                x: e.min.toDouble(),
                color: e.color,
                label: VerticalLineLabel(
                  style: TextStyle(
                    color: e.color,
                    fontWeight: FontWeight.bold,
                  ),
                  alignment: Alignment.topLeft,
                  show: true,
                  labelResolver: (_) => e.label,
                ),
              ),
            ) ??
            [],
        // draw a line at the end of range
        ..._verticalRangeAnnotations?.map(
              (e) => VerticalLine(
                x: e.max.toDouble(),
                color: e.color,
                label: VerticalLineLabel(
                  style: TextStyle(
                    color: ThemeViewModel.instance.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  alignment: Alignment.topRight,
                  show: true,
                  labelResolver: (_) => '',
                ),
              ),
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
                    ),
                  ),
                )
                .toList() ??
            [],
      ];

  /// Generates a list of [VerticalRangeAnnotation]s to shade vertical regions
  /// of the chart.
  @protected
  List<VerticalRangeAnnotation> get verticalRangeAnnotations =>
      _verticalRangeAnnotations
          ?.map(
            (e) => VerticalRangeAnnotation(
              x1: max(e.min.toDouble(), minX),
              x2: min(e.max.toDouble(), maxX),
              color: e.color.withValues(alpha: 0.2),
            ),
          )
          .toList() ??
      [];

  /// Generates a list of [HorizontalRangeAnnotation]s to shade horizontal
  /// regions of the chart.
  @protected
  List<HorizontalRangeAnnotation> get horizontalRangeAnnotations =>
      _horizontalRangeAnnotations
          ?.map(
            (e) => HorizontalRangeAnnotation(
              y1: max(e.min.toDouble(), minY),
              y2: min(e.max.toDouble(), maxY),
              color: e.color.withValues(alpha: 0.2),
            ),
          )
          .toList() ??
      [];

  /// Calculates a suitable interval for an axis given a min/max value.
  @protected
  double interval(
    num minValue,
    num maxValue, {
    double minInterval = 5,
    int occurences = 10,
  }) =>
      (max(
                ((maxValue - minValue) /
                            // the interval to have <occurrences> in axies
                            occurences /
                            minInterval)
                        .round() *
                    minInterval,
                minInterval,
              ) *
              10)
          .round() /
      10; // if inverval is less than multiplier, use multiplier

  /// Generates a list of [BetweenBarsData] for filling areas between lines.
  @protected
  List<BetweenBarsData> get betweenBarsData =>
      betweenBarsDataList
          ?.map(
            (betweenBarsData) => betweenBarsData != null
                ? BetweenBarsData(
                    fromIndex: betweenBarsData.fromIndex,
                    toIndex: betweenBarsData.toIndex,
                    color: betweenBarsData.color,
                    //fromAboveColor: betweenBarsData.fromAboveColor,
                    //fromBelowColor: betweenBarsData.fromBelowColor,
                    gradient: betweenBarsData.gradient,
                  )
                : null,
          )
          .nonNulls
          .toList() ??
      const [];

  /// Creates [BarAreaData] for the area above a line.
  @protected
  BarAreaData aboveBarData(int index) {
    return (aboveBarDataList?.length ?? 0) > index &&
            aboveBarDataList!.elementAt(index) != null
        ? BarAreaData(
            show: true,
            color: aboveBarDataList!.elementAt(index)!.color,
            cutOffY: aboveBarDataList!.elementAt(index)!.cutoff,
            applyCutOffY: true,
          )
        : BarAreaData();
  }

  /// Creates [BarAreaData] for the area below a line.
  @protected
  BarAreaData belowBarData(int index) {
    return (belowBarDataList?.length ?? 0) > index &&
            belowBarDataList!.elementAt(index) != null
        ? BarAreaData(
            show: true,
            color: belowBarDataList!.elementAt(index)!.color,
            cutOffY: belowBarDataList!.elementAt(index)!.cutoff,
            applyCutOffY: true,
          )
        : BarAreaData();
  }

  /// Checks if the line at the given [index] should be curved.
  @protected
  bool isCurved(int index) =>
      (isCurvedList?.length ?? 0) <= index ||
      (isCurvedList?.elementAt(index) ?? true);

  /// Checks if the line at the given [index] should be a step line.
  @protected
  bool isStepLineChart(int index) =>
      (isStepLineChartList?.length ?? 0) > index &&
      (isStepLineChartList?.elementAt(index) ?? false);

  /// Rounds a [value] to the nearest [interval].
  @protected
  static int roundToInterval(num value, num interval) =>
      interval != 0 ? ((value / interval).round() * interval).toInt() : 0;

  /// Rounds a [value] up to the nearest [interval].
  @protected
  static double ceilToInterval(num value, num interval) =>
      interval != 0 ? ((value / interval).ceil() * interval).ceilToDouble() : 0;

  /// Rounds a [value] down to the nearest [interval].
  @protected
  static double floorToInterval(num value, num interval) => interval != 0
      ? ((value / interval).floor() * interval).floorToDouble()
      : 0;
}
