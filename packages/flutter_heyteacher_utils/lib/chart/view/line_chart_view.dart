import 'dart:math';
import 'package:flutter_heyteacher_utils/theme.dart';
import '../../formats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
//import 'package:logging/logging.dart';

class LineChartView extends StatefulWidget {
  //static final _log = Logger("LineChartView");

  final Iterable<({double x, double y})>? chartSpots;
  final Iterable<({num y, Color color})>? extraHorizontalLines;
  final Iterable<({num x, Color color})>? extraVerticalLines;
  final Iterable<({num minY, num maxY, Color color})>?
      horizontalRangeAnnotations;
  final Iterable<({num minX, num maxX, Color color})>? verticalRangeAnnotations;

  late final num  minX;
  late final num  maxX;
  late final num  minY;
  late final num  maxY;
  late final int intervalX;
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
    intervalX = _interval(minX, maxX);
    intervalY = _interval(minY, maxY);
    this.minX = _floorToInterval(minX, intervalX);
    this.maxX = _ceilToInterval(maxX, intervalX);
    this.minY = _floorToInterval(minY, intervalY);
    this.maxY = _ceilToInterval(maxY, intervalY);
  }

  int _interval(num minValue, num maxValue, {int multiplier = 5, int occurences = 10}) =>
      max((
        (maxValue - minValue) / occurences // the interval to have <occurrences> in axies 
        / multiplier).round() * multiplier,  // round the value to multiplier
        multiplier); // if inverval is less than multiplier, use multiplier

  static int _roundToInterval(num value, num interval) =>
      interval != 0 ? ((value/ interval).round() * interval).toInt() : 0;

  static int _ceilToInterval(num value, num interval) =>
      interval != 0 ? ((value/ interval).ceil() * interval).toInt() : 0;

  static int _floorToInterval(num value, num interval) =>
      interval != 0 ? ((value/ interval).floor() * interval).toInt() : 0;

  @override
  State<LineChartView> createState() => _LineChartViewState();
}

class _LineChartViewState extends State<LineChartView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.title,
            style: ThemeHepler.instance().theme.textTheme.titleLarge),
        AspectRatio(
          aspectRatio: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: LineChart(
              _lineChartData,
              //duration: const Duration(milliseconds: 250),
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
        minX: widget.minX.toDouble(),
        maxX: widget.maxX.toDouble(),
        minY: widget.minY.toDouble(),
        maxY: widget.maxY.toDouble(),
      );

  FlTitlesData get _titlesData => FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: widget.intervalX.toDouble(),
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
            interval: widget.intervalY.toDouble(),
            reservedSize: 30,
          ),
        ),
      );

  Widget _leftTitleWidgets(double value, TitleMeta meta) => Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Text(
            LineChartView._roundToInterval(value, widget.intervalY)
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
                LineChartView._roundToInterval(value, widget.intervalX) *
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
      spots: widget.chartSpots != null ? widget.chartSpots!.map((e) => FlSpot(e.x, e.y),).toList() : []);

  List<HorizontalLine> get _horizontalLines =>
      widget.extraHorizontalLines
          ?.map(
            (e) => HorizontalLine(y: e.y.toDouble(), color: e.color),
          )
          .toList() ??
      [];

  List<VerticalLine> get _verticalLines =>
      widget.extraVerticalLines
          ?.map(
            (e) => VerticalLine(x: e.x.toDouble(), color: e.color),
          )
          .toList() ??
      [];

  List<VerticalRangeAnnotation> get _verticalRangeAnnotations =>
      widget.verticalRangeAnnotations
          ?.map(
            (e) => VerticalRangeAnnotation(
                x1: max(e.minX.toDouble(), widget.minX.toDouble()),
                x2: min(e.maxX.toDouble(), widget.maxX.toDouble()),
                color: e.color),
          )
          .toList() ??
      [];

  List<HorizontalRangeAnnotation> get _horizontalRangeAnnotations =>
      widget.horizontalRangeAnnotations
          ?.map(
            (e) => HorizontalRangeAnnotation(
                y1: max(e.minY.toDouble(), widget.minY.toDouble()),
                y2: min(e.maxY.toDouble(), widget.maxY.toDouble()),
                color: e.color),
          )
          .toList() ??
      [];
}
