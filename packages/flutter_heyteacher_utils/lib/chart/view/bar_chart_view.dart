import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/chart/view/chart_view.dart';

// ignore: must_be_immutable
class BarChartView extends ChartView {
  final bool horizontal;


  BarChartView({
    required super.chartDataList,
    required super.title,
    this.horizontal = false,
    super.maxX,
    super.minX,
    super.minIntervalX,
    required super.formatterX,
    required super.colorX,
    super.maxY,
    super.minY,
    super.minIntervalY,
    required super.formatterY,
    required super.colorY,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title),
        Padding(
          padding: const EdgeInsets.only(right: 25),
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: switch (chartDataList.length) {
                  0 => 6,
                  1 => 3,
                  2 => 3,
                  3 => 2,
                  _ => 1.3,
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
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
                            horizontal ? const AxisTitles() : _valueAxisTitles(interval: intervalY, color:colorY, formatter: formatterY),
                        bottomTitles: _titleAxisTitles(),
                        rightTitles:
                            horizontal ? _valueAxisTitles(interval: intervalY, color:colorY, formatter: formatterY) : const AxisTitles(),
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
                          tooltipMargin: 0,
                          getTooltipItem: (
                            BarChartGroupData group,
                            int groupIndex,
                            BarChartRodData rod,
                            int rodIndex,
                          ) {
                            return BarTooltipItem(
                              formatterY(chartDataList.elementAt(groupIndex)),
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
              ),
            ],
          ),
        ),
      ],
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
              formatterX(chartDataList.elementAt(index)),
              style: TextStyle(color: chartDataList.elementAt(index).yColor),
            ),
          );
        },
      ),
    );
  }

  AxisTitles _valueAxisTitles({required num? interval, required Color? color, required String Function(ChartData)? formatter}) {
    return interval != null && color != null && formatter != null? AxisTitles(
      drawBelowEverything: true,
      sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 60,
          maxIncluded: false,
          minIncluded: true,
          interval: interval.toDouble(),
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            return RotatedBox(
              quarterTurns: horizontal ? 3 : 0,
              child: SideTitleWidget(
                meta: meta,
                child: Text(
                  formatterY(ChartData(x: 0, y: index)),
                  style:
                      TextStyle(color: color),
                ),
              ),
            );
          }),
    ): const AxisTitles();
  }
}
