import 'dart:math';

import 'package:collection/collection.dart';

import 'chart_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartView extends ChartView {
  LineChartView(
      {super.key,
      super.title,
      required super.chartDataLists,

      required super.formatterAxisX,
      required super.formatterColorAxisX,
      super.reservedSizeX,
      super.maxX,
      super.minX,
      super.minIntervalX,
      super.axisNameWidgetX,

      required super.formatterAxisY,
      required super.formatterColorLine,
      required super.formatterColorAxisY,
      super.reservedSizeY,
      super.maxY,
      super.minY,
      super.minIntervalY,
      super.axisNameWidgetY,

      super.formatterAxisYAlt,
      super.formatterColorAxisYAlt,
      super.reservedSizeYAlt,
      super.maxYAlt,
      super.minYAlt,
      super.minIntervalYAlt,
      super.axisNameWidgetYAlt,

      super.extraHorizontalLines,
      super.extraVerticalLines,
      super.horizontalRangeAnnotations,
      super.verticalRangeAnnotations,
      super.betweenBarsDataList,
      super.aboveBarDataList,
      super.belowBarDataList,
      super.aspectRatio,
      super.isCurvedList,
      super.isStepLineChartList,
      super.rightTitlesLikeLeft});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          title,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: aspectRatio,
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
        lineBarsData: chartDataLists.mapIndexed(_lineChartBarData).toList(),
        minX: minX.toDouble(),
        maxX: maxX.toDouble(),
        minY: minY.toDouble(),
        maxY: maxY.toDouble(),
        betweenBarsData: betweenBarsData,
      );

  LineChartBarData _lineChartBarData(int index, _) => LineChartBarData(
      isCurved: isCurved(index),
      isStepLineChart: isStepLineChart(index),
      color: formatterColorLine?.call(index, chartDataList.first.y.toDouble()),
      barWidth: 1,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: belowBarData(index),
      aboveBarData: aboveBarData(index),
      spots: chartDataLists
          .elementAt(index)
          .map(
            (e) => FlSpot(min(maxX, max(minX, e.x.toDouble())),
                min(maxY, max(minY, e.y.toDouble()))),
          )
          .toList());
}
