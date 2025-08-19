import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_data.dart';
import 'chart_view.dart';

class BarChartView extends ChartView {
  BarChartView({
    required super.chartDataList,
    required super.title,
    super.reservedSizeX,
    super.reservedSizeY,
    super.rotate,
    super.maxX,
    super.minX,
    super.minIntervalX,
    required super.formatterX,
    required super.formatterAxisX,
    required super.formatterColorAxisX,
    super.axisNameWidgetX,
    super.maxY,
    super.minY,
    super.minIntervalY,
    required super.formatterY,
    required super.formatterAxisY,
    required super.formatterColorAxisY,
    super.axisNameWidgetY,
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
            padding: const EdgeInsets.only(right: 20, bottom: 20),
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
                      rotationQuarterTurns: rotate ? 1 : 0,
                      borderData: FlBorderData(
                        show: false,
                      ),
                      titlesData: titlesData,
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
}
