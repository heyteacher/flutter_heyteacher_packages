import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_heyteacher_utils/chart/view/chart_view.dart';

class BarChartView extends ChartView {
  final List<BarData> dataList;
  
  late final num  _minY;
  late final num  _maxY;
  late final int _intervalY;
 

  BarChartView(this.dataList, {super.key}) {
     int maxY = dataList.map((e) => e.value).max.toInt();
     int minY = dataList.map((e) => e.value).min.toInt();
    _intervalY = interval(minY,maxY);
    _minY = ChartView.floorToInterval(minY, _intervalY);
    _maxY = ChartView.ceilToInterval(maxY, _intervalY) + _intervalY;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceBetween,
                rotationQuarterTurns: 1,
                borderData: FlBorderData(
                  show: true,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: const AxisTitles(
                    drawBelowEverything: true,
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 25,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      interval: _intervalY.toDouble(),
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
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                gridData: FlGridData(
                  show: true,
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
                      toY: data.value,
                      color: data.color,
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
                        dataList[groupIndex].text,
                        TextStyle(
                          color: rod.color,
                        ),
                      );
                    },
                  ),
                ),
                maxY: _maxY.toDouble(),
                minY: _minY.toDouble(),
            
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BarData {
  const BarData(this.title, this.color, this.value, this.text);
  final String title;
  final Color color;
  final double value;
  final String text;
}
