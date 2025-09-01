import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_view.dart';

class ScatterChartView extends ChartView {
  static const Color color = Colors.grey;
  static const radius = 4.0;

  ScatterChartView({
    super.key,
    required super.title,
    required super.chartDataLists,
    required super.formatterAxisX,
    required super.formatterColorAxisX,
    super.reservedSizeX,
    super.maxX,
    super.minX,
    super.minIntervalX,
    super.axisNameWidgetX,
    required super.formatterAxisY,
    required super.formatterColorAxisY,
    super.reservedSizeY,
    super.maxY,
    super.minY,
    super.minIntervalY,
    super.axisNameWidgetY,
    super.aspectRatio
  });

  @override
  Widget build(BuildContext context) => Column(children: [
        title,
        AspectRatio(
          aspectRatio: aspectRatio,
          child: ScatterChart(
            ScatterChartData(
              scatterSpots: chartDataList
                  .map((e) => ScatterSpot(
                        e.x.toDouble(),
                        e.y.toDouble(),
                        dotPainter: FlDotCirclePainter(
                            color: e.yColor ?? color, radius: radius),
                      ))
                  .toList(),
              minX: minX.toDouble(),
              maxX: maxX.toDouble(),
              minY: minY.toDouble(),
              maxY: maxY.toDouble(),
              gridData: const FlGridData(
                show: false,
              ),
              titlesData: titlesData,
              borderData: borderData,
              scatterTouchData: ScatterTouchData(
                enabled: false,
              ),
            ),
          ),
        )
      ]);
}
