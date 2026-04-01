import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_data.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_view.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// A chart widget that displays data as one or more lines.
///
/// It extends [ChartView] to handle common chart functionalities like axes,
/// titles, and data formatting. It supports multiple line series, curved or
/// stepped lines, and filling the area between or below lines.
class LineChartView extends ChartView {
  /// Creates a [LineChartView].
  LineChartView({
    required super.chartDataLists,
    required super.formatterAxisX,
    required super.formatterColorAxisX,
    required super.formatterAxisY,
    required super.formatterColorLine,
    required super.formatterColorAxisY,
    super.key,
    super.title,
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
    super.formatterAxisYAlt,
    super.formatterColorAxisYAlt,
    super.reservedSizeYAlt,
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
    super.rightTitlesLikeLeft,
  });

  @override
  Widget build(BuildContext context) => Column(
        children: [
          title,
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: LineChart(
                _lineChartData,
              ),
            ),
          ),
        ],
      );

  LineChartData get _lineChartData => LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (lineBarSpots) => lineBarSpots
                .map(
                  (lineBarSpot) => LineTooltipItem(
                    formatterY?.call(
                          lineBarSpot.barIndex,
                          ChartDataItem(
                            x: lineBarSpot.x,
                            y: lineBarSpot.y,
                          ),
                        ) ??
                        FormatterHelper.doubleFormat(lineBarSpot.y),
                    TextStyle(
                      color: formatterColorLine?.call(
                        lineBarSpot.barIndex,
                        lineBarSpot.y,
                      ),
                    ),
                  ),
                )
                .toList(),
            getTooltipColor: (touchedSpot) =>
                ThemeViewModel.instance.colorScheme.surface,
          ),
        ),
        rangeAnnotations: RangeAnnotations(
          verticalRangeAnnotations: verticalRangeAnnotations,
          horizontalRangeAnnotations: horizontalRangeAnnotations,
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: horizontalLines,
          verticalLines: verticalLines,
        ),
        gridData: const FlGridData(show: false),
        titlesData: titlesData,
        borderData: borderData,
        lineBarsData: chartDataLists.mapIndexed(_lineChartBarData).toList(),
        minX: minX,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        betweenBarsData: betweenBarsData,
      );

  LineChartBarData _lineChartBarData(int index, _) => LineChartBarData(
        isCurved: isCurved(index),
        isStepLineChart: isStepLineChart(index),
        color:
            formatterColorLine?.call(index, chartDataList.first.y.toDouble()),
        barWidth: 1,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: belowBarData(index),
        aboveBarData: aboveBarData(index),
        spots: chartDataLists
            .elementAt(index)
            .map(
              (e) => FlSpot(
                min(maxX, max(minX, e.x.toDouble())),
                min(maxY, max(minY, e.y.toDouble())),
              ),
            )
            .toList(),
      );
}
