import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/chart/view/chart_view.dart';
import 'package:flutter_heyteacher_utils/theme.dart';

class BarChartView extends ChartView {
  final bool horizontal;

  BarChartView(
      {required super.chartDataList,
      super.maxX,
      super.minX,
      super.minIntervalX,
      required super.formatterX,
      super.maxY,
      super.minY,
      super.minIntervalY,
      required super.formatterY,
      super.key,
      this.horizontal = false,
 });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 25),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                rotationQuarterTurns: horizontal ? 1 : 0,
                borderData: FlBorderData(
                  show: false,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: horizontal? AxisTitles(): _valueAxisTitles(),
                  bottomTitles: _titleAxisTitles() ,
                  rightTitles: horizontal? _valueAxisTitles():AxisTitles(),
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
                  final ChartData data = e.$2;
                  return BarChartGroupData(x: index, barRods: [
                    BarChartRodData(
                      toY: data.y.toDouble(),
                      color: data.color,
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
                    tooltipMargin: 0,
                    getTooltipItem: (
                      BarChartGroupData group,
                      int groupIndex,
                      BarChartRodData rod,
                      int rodIndex,
                    ) {
                      return BarTooltipItem(
                        formatterY(chartDataList.elementAt(groupIndex).y),
                        TextStyle(
                          color: rod.color,
                        ),
                      );
                    },
                  ),
                ),
                maxY: maxY.toDouble(),
                minY: minY.toDouble(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AxisTitles _titleAxisTitles() {
    return AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          formatterX(chartDataList.elementAt(index).x),
                          style: TextStyle(color: chartDataList.elementAt(index).color),
                        ),
                      );
                    },
                  ),
                );
  }

  AxisTitles _valueAxisTitles() {
    return AxisTitles(
                  drawBelowEverything: true,
                  sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      interval: intervalY.toDouble(),
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        return RotatedBox(
                          quarterTurns: horizontal? 3: 0,
                          child: SideTitleWidget(
                            meta: meta,
                            child: Text(
                              formatterY(index),
                              style: TextStyle(
                                  color:
                                      ThemeHepler.instance().orangeTextColor),
                            ),
                          ),
                        );
                      }),
                );
  }
}
