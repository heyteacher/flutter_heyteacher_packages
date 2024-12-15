import '../../formats.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
//import 'package:logging/logging.dart';

class LineChartView extends StatefulWidget {
  //static final _log = Logger("LineChartView");

  final Iterable<FlSpot>? chartSpots;
  late final double minX;
  late final double maxX;
  late final double minY;
  late final double maxY;
  final ThemeData theme;

  late final int intervalX;
  late final int intervalY;

  final String title;

  LineChartView(
      {super.key,
      required this.title,
      required this.chartSpots,
      required minX,
      required maxX,
      required num minY,
      required num maxY,
      required this.theme}) {
    intervalX = _interval(minX, maxX);
    intervalY = _interval(minY, maxY);

    this.minX = _LineChartViewState._roundToInterval(minX, intervalX);
    this.maxX = _LineChartViewState._roundToInterval(maxX, intervalX);
    this.minY =
        _LineChartViewState._roundToInterval(minY, intervalY) - intervalY;
    this.maxY =
        _LineChartViewState._roundToInterval(maxY, intervalY) + intervalY;
  }

  int _interval(num min, num max, {int offset = 10}) {
    int interval = ((max - min) / offset / offset).round() * offset;
    return interval == 0 ? offset : interval;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return "$title: "
        "minX $minX, "
        "maxX $maxX, "
        "minY $minY, "
        "maxY $maxY, "
        "intervalX $intervalX, "
        "intervalY $intervalY";
  }

  @override
  State<LineChartView> createState() => _LineChartViewState();
}

class _LineChartViewState extends State<LineChartView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.title, style: widget.theme.textTheme.titleLarge),
        AspectRatio(
          aspectRatio: 1.5,
          child: Padding(
            padding: const EdgeInsets.all(5.0),
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
        gridData: const FlGridData(show: false),
        titlesData: _titlesData,
        borderData: _borderData,
        lineBarsData: [
          _lineChartBarData,
        ],
        minX: widget.minX,
        maxX: widget.maxX,
        minY: widget.minY,
        maxY: widget.maxY,
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

  Widget _leftTitleWidgets(double value, TitleMeta meta) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Text(_roundToInterval(value, widget.intervalY).toInt().toString(),
          style: widget.theme.textTheme.bodySmall!
              .copyWith(color: widget.theme.colorScheme.onTertiary),
          textAlign: TextAlign.right),
    );
  }

  Widget _bottomTitleWidgets(double value, TitleMeta meta) {
    return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 5,
        child: Padding(
          padding: const EdgeInsets.only(right: 10, left: 5),
          child: RotatedBox(
            quarterTurns: 3,
            child: Text(
              formatDuration(
                  _roundToInterval(value, widget.intervalX) * 60 * 1000),
              style: widget.theme.textTheme.bodySmall!
                  .copyWith(color: widget.theme.colorScheme.onSecondary),
            ),
          ),
        ));
  }

  FlBorderData get _borderData => FlBorderData(
        show: true,
        border: Border(
          bottom: BorderSide(
              color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
              width: 1),
          left: BorderSide(
              color: widget.theme.colorScheme.onSurface.withValues(alpha: 0.5),
              width: 1),
          right: BorderSide(
              color: widget.theme.colorScheme.onSurface.withValues(alpha: 0),
              width: 1),
          top: BorderSide(
              color: widget.theme.colorScheme.onSurface.withValues(alpha: 0),
              width: 1),
        ),
      );

  LineChartBarData get _lineChartBarData => LineChartBarData(
      isCurved: true,
      //curveSmoothness: 0,
      color: widget.theme.colorScheme.onTertiary /*.withOpacity(0.5)*/,
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: widget.chartSpots != null ? widget.chartSpots!.toList() : []);

  static double _roundToInterval(num value, num interval) =>
      interval != 0 ? ((value / interval).round() * interval).toDouble() : 0;
}
