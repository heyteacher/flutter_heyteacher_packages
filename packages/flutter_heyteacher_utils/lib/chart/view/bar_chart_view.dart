import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_heyteacher_utils/chart/view/chart_view.dart';
import 'package:flutter_heyteacher_utils/theme.dart';

class BarData {
  const BarData(this.title, this.color, this.value);
  final String title;
  final Color color;
  final num value;
}

class BarChartView extends ChartView {
  final List<BarData> dataList;
  final String Function(num value) formatterY;
  final bool horizontal;

  late final num _maxY;
  late final int _intervalY;

  BarChartView(
      {required this.dataList,
      required this.formatterY,
      this.horizontal = false,
      super.key}) {
    num maxY = dataList.map((e) => e.value).max;
    num minY = dataList.map((e) => e.value).min;
    _intervalY = interval(minY, maxY, multiplier: 1);
    _maxY = ChartView.ceilToInterval(maxY, _intervalY) +  _intervalY;
  }

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
                  horizontalInterval: _intervalY.toDouble(),
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.withValues(alpha: 0.2),
                    strokeWidth: 1,
                  ),
                ),
                barGroups: dataList.asMap().entries.map((e) {
                  final index = e.key;
                  final data = e.value;
                  return BarChartGroupData(x: index, barRods: [
                    BarChartRodData(
                      toY: data.value.toDouble(),
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
                        formatterY(dataList[groupIndex].value),
                        TextStyle(
                          color: rod.color,
                        ),
                      );
                    },
                  ),
                ),
                maxY: _maxY.toDouble(),
                minY: 0,
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
                          dataList[index].title,
                          style: TextStyle(color: dataList[index].color),
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
                      interval: _intervalY.toDouble(),
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
