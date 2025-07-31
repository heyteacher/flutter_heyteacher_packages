import 'dart:math';
import 'chart_view.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartView extends ChartView {
  final Iterable<ExtraLineData>? extraHorizontalLines;
  final Iterable<ExtraLineData>? extraVerticalLines;
  final Iterable<RangeAnnotationData>? horizontalRangeAnnotations;
  final Iterable<RangeAnnotationData>? verticalRangeAnnotations;

  LineChartView(
      {super.key,
      required super.title,
      required super.chartDataList,
      super.maxX,
      super.minX,
      super.minIntervalX,
      required super.formatterX,
      super.formatterAxisX,
      required super.colorX,
      super.maxY,
      super.minY,
      super.minIntervalY,
      required super.colorY,
      required super.formatterY,
      super.formatterAxisY,
      this.extraHorizontalLines,
      this.extraVerticalLines,
      this.horizontalRangeAnnotations,
      this.verticalRangeAnnotations});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              _lineChartData,
            ),
          ),
        )
      ],
    );
  }

  LineChartData get _lineChartData => LineChartData(
        lineTouchData: const LineTouchData(
          enabled: false,
        ),
        rangeAnnotations: RangeAnnotations(
            verticalRangeAnnotations: _verticalRangeAnnotations,
            horizontalRangeAnnotations: _horizontalRangeAnnotations),
        extraLinesData: ExtraLinesData(
            horizontalLines: _horizontalLines, verticalLines: _verticalLines),
        gridData: const FlGridData(show: false),
        titlesData: _titlesData,
        borderData: _borderData,
        lineBarsData: [
          _lineChartBarData,
        ],
        minX: minX.toDouble(),
        maxX: maxX.toDouble(),
        minY: minY.toDouble(),
        maxY: maxY.toDouble(),
      );

  FlTitlesData get _titlesData => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            interval: intervalX.toDouble(),
            getTitlesWidget: _bottomTitleWidgets,
          ),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            getTitlesWidget: _leftTitleWidgets,
            showTitles: true,
            interval: intervalY.toDouble(),
            reservedSize: 30,
          ),
        ),
      );

  Widget _leftTitleWidgets(double value, TitleMeta meta) => Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Text(formatterAxisY(ChartDataItem(x: 0, y: value)),
            style: ThemeViewModel.instance().theme.textTheme.bodySmall!
            .copyWith(color: colorY)
            ,
            textAlign: TextAlign.right),
      );

  Widget _bottomTitleWidgets(double value, TitleMeta meta) => SideTitleWidget(
      meta: meta,
      space: 3,
      child: Padding(
        padding: const EdgeInsets.only(right: 0, left: 5),
        child: RotatedBox(
          quarterTurns: 3,
          child: Text(
            formatterAxisX(ChartDataItem(x: value, y: 0)),
            style: ThemeViewModel.instance()
                .theme
                .textTheme
                .bodySmall!
                .copyWith(color: colorX),
          ),
        ),
      ));

  FlBorderData get _borderData => FlBorderData(
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

  LineChartBarData get _lineChartBarData => LineChartBarData(
      isCurved: true,
      //curveSmoothness: 0,
      color: colorY,
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: chartDataList
          .map(
            (e) => FlSpot(e.x.toDouble(), e.y.toDouble()),
          )
          .toList());

  List<HorizontalLine> get _horizontalLines => [
        ...horizontalRangeAnnotations?.map(
              (e) => HorizontalLine(
                  y: e.min.toDouble(),
                  color: e.color.withValues(alpha: 0.4),
                  label: HorizontalLineLabel(
                      style: TextStyle(color: e.color, fontWeight: FontWeight.bold),
                        alignment: Alignment.lerp(Alignment.centerLeft, Alignment.topLeft, 0.5)!,
                      show: true, labelResolver: (_) => e.label)),
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

  List<VerticalLine> get _verticalLines => [
        // draw a line at the start of range
        ...verticalRangeAnnotations?.map(
              (e) => VerticalLine(
                  x: e.min.toDouble(),
                  color: e.color.withValues(alpha: 0.4),
                  label: VerticalLineLabel(
                      style: TextStyle(color: e.color, fontWeight: FontWeight.bold),
                      alignment: Alignment.topRight,
                      show: true,
                      labelResolver: (_) => e.label)),
            ) ??
            [],
        // draw a line at the end of range
        ...verticalRangeAnnotations?.map(
              (e) => VerticalLine(
                  x: e.max.toDouble(),
                  color: e.color.withValues(alpha: 0.4),
                  label: VerticalLineLabel(
                      style: TextStyle(color: ThemeViewModel.instance().colorScheme.onSurface, fontWeight: FontWeight.bold),
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

  List<VerticalRangeAnnotation> get _verticalRangeAnnotations =>
      verticalRangeAnnotations
          ?.map(
            (e) => VerticalRangeAnnotation(
                x1: max(e.min.toDouble(), minX.toDouble()),
                x2: min(e.max.toDouble(), maxX.toDouble()),
                color: e.color.withValues(alpha: 0.4)),
          )
          .toList() ??
      [];

  List<HorizontalRangeAnnotation> get _horizontalRangeAnnotations =>
      horizontalRangeAnnotations
          ?.map(
            (e) => HorizontalRangeAnnotation(
                y1: max(e.min.toDouble(), minY.toDouble()),
                y2: min(e.max.toDouble(), maxY.toDouble()),
                color: e.color.withValues(alpha: 0.4)),
          )
          .toList() ??
      [];
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
