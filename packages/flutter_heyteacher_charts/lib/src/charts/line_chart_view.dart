import 'chart_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartView extends ChartView {

  LineChartView(
      {super.key,
      required super.title,
      required super.chartDataList,
      required super.formatterX,
      required super.formatterAxisX,
      required super.formatterColorAxisX,
      super.reservedSizeX,
      super.maxX,
      super.minX,
      super.minIntervalX,
      super.axisNameWidgetX,
      required super.formatterY,
      required super.formatterAxisY,
      required super.formatterColorAxisY,
      super.reservedSizeY,
      super.maxY,
      super.minY,
      super.minIntervalY,
      super.axisNameWidgetY,
      super.extraHorizontalLines,
      super.extraVerticalLines,
      super.horizontalRangeAnnotations,
      super.verticalRangeAnnotations});

  @override
  Widget build(BuildContext context) => Column(
      children: [
        title,
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AspectRatio(
            aspectRatio: 1.5,
            child: LineChart(
              _lineChartData,
            ),
          ),
        )
      ],
    );
  

  LineChartData get _lineChartData => LineChartData(
        lineTouchData: const LineTouchData(
          enabled: false,
        ),
        rangeAnnotations: RangeAnnotations(
            verticalRangeAnnotations: verticalRangeAnnotations,
            horizontalRangeAnnotations: horizontalRangeAnnotations),
        extraLinesData: ExtraLinesData(
            horizontalLines: horizontalLines, verticalLines: verticalLines),
        gridData: const FlGridData(show: false),
        titlesData: titlesData,
        borderData: borderData,
        lineBarsData: [
          _lineChartBarData,
        ],
        minX: minX.toDouble(),
        maxX: maxX.toDouble(),
        minY: minY.toDouble(),
        maxY: maxY.toDouble(),
      );

  LineChartBarData get _lineChartBarData => LineChartBarData(
      isCurved: true,
      //curveSmoothness: 0,
      color: formatterColorAxisY(chartDataList.first.y.toDouble()),
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      spots: chartDataList
          .map(
            (e) => FlSpot(e.x.toDouble(), e.y.toDouble()),
          )
          .toList());
}
