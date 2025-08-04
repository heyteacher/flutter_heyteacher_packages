import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'chart_view.dart';

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

class BarChartView extends ChartView {
  final bool horizontal;
  final double reservedSizeX;
  final double reservedSizeY;

  BarChartView({
    required super.chartDataList,
    required super.title,
    this.reservedSizeX = 36,
    this.reservedSizeY = 60,
    this.horizontal = false,
    super.maxX,
    super.minX,
    super.minIntervalX,
    required super.formatterX,
    required super.formatterAxisX,
    required super.formatterColorAxisX,
    super.maxY,
    super.minY,
    super.minIntervalY,
    required super.formatterY,
    required super.formatterAxisY,
    required super.formatterColorAxisY,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: title,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: switch (chartDataList.length) {
                    0 => 6,
                    1 => 3,
                    2 => 2.5,
                    3 => 2,
                    4 => 1.4,
                    _ => 8 / chartDataList.length
                  },
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceBetween,
                      rotationQuarterTurns: horizontal ? 1 : 0,
                      borderData: FlBorderData(
                        show: false,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        leftTitles:
                            horizontal ? _xAxisTitles() : _yAxisTitles(),
                        bottomTitles: _xAxisTitles(),
                        rightTitles:
                            horizontal ? _yAxisTitles() : const AxisTitles(),
                        topTitles: const AxisTitles(),
                      ),
                      gridData: FlGridData(
                        show: true,
                        horizontalInterval: intervalY.toDouble(),
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: chartDataList.indexed.map((e) {
                        final int index = e.$1;
                        final BarChartDataItem data = e.$2 as BarChartDataItem;
                        return BarChartGroupData(x: index, barRods: [
                          BarChartRodData(
                            fromY: data.fromY.toDouble(),
                            toY: data.y.toDouble(),
                            color: data.yColor,
                            borderRadius: BorderRadius.zero,
                            width: 25,
                          ),
                        ], showingTooltipIndicators: [
                          0
                        ]);
                      }).toList(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        handleBuiltInTouches: false,
                        touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => Colors.transparent,
                            tooltipMargin: 13,
                            getTooltipItem: (
                              BarChartGroupData group,
                              int groupIndex,
                              BarChartRodData rod,
                              int rodIndex,
                            ) =>
                                BarTooltipItem(
                                  textAlign: TextAlign.center,
                                  formatterY(
                                      chartDataList.elementAt(groupIndex)),
                                  TextStyle(
                                    color: rod.color,
                                    height: 0.9,
                                  ),
                                )),
                      ),
                      maxY: maxY.toDouble(),
                      minY: minY.toDouble(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  AxisTitles _xAxisTitles() => AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: double.maxFinite, // that means no X intervals in bar char
          reservedSize: reservedSizeX,
          maxIncluded: false,
          minIncluded: false,
          getTitlesWidget: (value, meta) => SideTitleWidget(
            meta: meta,
            child: Text(
              formatterAxisX(value.toInt()),
              style: TextStyle(color: formatterColorAxisX(value)),
            ),
          ),
        ),
      );

  AxisTitles _yAxisTitles() => AxisTitles(
        drawBelowEverything: true,
        sideTitles: SideTitles(
            showTitles: true,
            reservedSize: reservedSizeY,
            maxIncluded: false,
            minIncluded: true,
            interval: intervalY.toDouble(),
            getTitlesWidget: (value, TitleMeta meta) => RotatedBox(
                  quarterTurns: horizontal ? 3 : 0,
                  child: SideTitleWidget(
                    meta: meta,
                    child: Padding(
                      padding: EdgeInsets.only(
                          right: horizontal ? 0 : 4.0,
                          top: horizontal ? 4.0 : 0),
                      child: Text(
                        formatterAxisY(value),
                        style: TextStyle(color: formatterColorAxisY(value)),
                      ),
                    ),
                  ),
                )),
      );
}
