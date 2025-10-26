import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_data.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_view.dart';

/// A chart widget that displays data as a series of bars.
///
/// It extends [ChartView] to handle common chart functionalities like axes,
/// titles, and data formatting.
class BarChartView extends ChartView {
  /// Creates a [BarChartView].
  BarChartView({
    required super.chartDataLists,
    required super.title,
    required super.formatterAxisX,
    required super.formatterColorAxisX,
    required super.formatterY,
    required super.formatterAxisY,
    required super.formatterColorAxisY,
    super.reservedSizeX,
    super.reservedSizeY,
    super.rotate,
    super.maxX,
    super.minX,
    super.minIntervalX,
    super.axisNameWidgetX,
    super.maxY,
    super.minY,
    super.minIntervalY,
    super.axisNameWidgetY,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
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
                        horizontalInterval: intervalY,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      barGroups: chartDataList.indexed.map((e) {
                        final index = e.$1;
                        final data = e.$2 as BarChartDataItem;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              fromY: data.fromY.toDouble(),
                              toY: data.y.toDouble(),
                              color: data.yColor,
                              borderRadius: BorderRadius.zero,
                              width: 25,
                            ),
                          ],
                          showingTooltipIndicators: [
                            0,
                          ],
                        );
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
                            formatterY?.call(
                                  0,
                                  chartDataList.elementAt(groupIndex),
                                ) ??
                                '',
                            TextStyle(
                              color: rod.color,
                              height: 0.9,
                            ),
                          ),
                        ),
                      ),
                      maxY: maxY,
                      minY: minY,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}
