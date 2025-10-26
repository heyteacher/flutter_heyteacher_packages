import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_view.dart';

/// A chart widget that displays data as a scatter plot of individual points.
///
/// It extends [ChartView] to handle common chart functionalities like axes,
/// titles, and data formatting.
class ScatterChartView extends ChartView {

  /// Creates a [ScatterChartView].
  ScatterChartView(
      {required super.title,
      required super.chartDataLists,
      required super.formatterAxisX,
      required super.formatterColorAxisX,
      required super.formatterAxisY,
      required super.formatterColorAxisY,
      super.key,
      super.reservedSizeX,
      super.maxX,
      super.minX,
      super.minIntervalX,
      super.axisNameWidgetX,
      super.reservedSizeY,
      super.maxY,
      super.minY,
      super.minIntervalY,
      super.axisNameWidgetY,
      super.aspectRatio,});
  /// The default color for the scatter plot points if not otherwise specified.
  static const Color color = Colors.grey;
  /// The default radius for the scatter plot points.
  static const radius = 4.0;

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
                            color: e.yColor ?? color, radius: radius,),
                      ),)
                  .toList(),
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
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
        ),
      ],);
}
