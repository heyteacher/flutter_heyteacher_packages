import 'dart:math';
import 'package:flutter_heyteacher_utils/chart/view/chart_view.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import '../../formats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartView extends ChartView {
  //static final _log = Logger("LineChartView");

  final Iterable<({double x, double y})>? chartSpots;
  final Iterable<({num y, Color color})>? extraHorizontalLines;
  final Iterable<({num x, Color color})>? extraVerticalLines;
  final Iterable<({num minY, num maxY, Color color})>?
      horizontalRangeAnnotations;
  final Iterable<({num minX, num maxX, Color color})>? verticalRangeAnnotations;

  late final num  minX;
  late final num  maxX;
  late final int intervalX;
  late final num  minY;
  late final num  maxY;
  late final int intervalY;
  final String title;


  LineChartView(
      {super.key,
      required this.title,
      required this.chartSpots,
      required int minX,
      required int maxX,
      required int  minY,
      required int  maxY,
      this.extraHorizontalLines,
      this.extraVerticalLines,
      this.horizontalRangeAnnotations,
      this.verticalRangeAnnotations}) {
    intervalX = interval(minX, maxX);
    intervalY = interval(minY, maxY);
    this.minX = ChartView.floorToInterval(minX, intervalX);
    this.maxX = ChartView.ceilToInterval(maxX, intervalX);
    this.minY = ChartView.floorToInterval(minY, intervalY);
    this.maxY = ChartView.ceilToInterval(maxY + intervalY, intervalY);
  }

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
            reservedSize: 40,
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
        child: Text(
            ChartView.roundToInterval(value, intervalY)
                .toInt()
                .toString(),
            style: ThemeHepler.instance().theme.textTheme.bodySmall!
            //.copyWith(color: ThemeHepler.instance().greenTextColor)
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
            formatDuration(
                ChartView.roundToInterval(value, intervalX) *
                    60 *
                    1000),
            style: ThemeHepler.instance()
                .theme
                .textTheme
                .bodySmall!
                .copyWith(color: ThemeHepler.instance().orangeTextColor),
          ),
        ),
      ));

  FlBorderData get _borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
              color: ThemeHepler.instance()
                  .theme
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              width: 1),
          left: BorderSide(
              color: ThemeHepler.instance()
                  .theme
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.5),
              width: 1),
          right: BorderSide(
              color: ThemeHepler.instance()
                  .theme
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0),
              width: 1),
          top: BorderSide(
              color: ThemeHepler.instance()
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
      color: ThemeHepler.instance()
          .theme
          .colorScheme
          .onSurface /*.withOpacity(0.5)*/,
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: chartSpots != null ? chartSpots!.map((e) => FlSpot(e.x, e.y),).toList() : []);

  List<HorizontalLine> get _horizontalLines =>
      extraHorizontalLines
          ?.map(
            (e) => HorizontalLine(y: e.y.toDouble(), color: e.color),
          )
          .toList() ??
      [];

  List<VerticalLine> get _verticalLines =>
      extraVerticalLines
          ?.map(
            (e) => VerticalLine(x: e.x.toDouble(), color: e.color),
          )
          .toList() ??
      [];

  List<VerticalRangeAnnotation> get _verticalRangeAnnotations =>
      verticalRangeAnnotations
          ?.map(
            (e) => VerticalRangeAnnotation(
                x1: max(e.minX.toDouble(), minX.toDouble()),
                x2: min(e.maxX.toDouble(), maxX.toDouble()),
                color: e.color),
          )
          .toList() ??
      [];

  List<HorizontalRangeAnnotation> get _horizontalRangeAnnotations =>
      horizontalRangeAnnotations
          ?.map(
            (e) => HorizontalRangeAnnotation(
                y1: max(e.minY.toDouble(), minY.toDouble()),
                y2: min(e.maxY.toDouble(), maxY.toDouble()),
                color: e.color),
          )
          .toList() ??
      [];
}
