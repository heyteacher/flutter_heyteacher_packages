import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_data.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_view.dart';
import 'package:flutter_heyteacher_utils/theme.dart';

class CandlestickChartView extends ChartView {
  CandlestickChartView(
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        title,
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
          child: AspectRatio(
            aspectRatio: 1,
            child: CandlestickChart(
              CandlestickChartData(
                candlestickSpots: _candlestickSpots,
                gridData: const FlGridData(
                  show: false,
                ),
                rangeAnnotations: RangeAnnotations(
                    verticalRangeAnnotations: verticalRangeAnnotations,
                    horizontalRangeAnnotations: horizontalRangeAnnotations),
                minY: _minY(),
                maxY: _maxY(),
                titlesData: titlesData,
                borderData: borderData,
                touchedPointIndicator: AxisSpotIndicator(
                  painter: AxisLinesIndicatorPainter(
                    verticalLineProvider: (x) {
                      final data = chartDataList.elementAt(x.toInt())
                          as CandlestickDataItem;
                      return VerticalLine(
                        x: x,
                        color: (data.isUp
                                ? ThemeViewModel.instance().greenColor
                                : ThemeViewModel.instance().redColor)
                            .withValues(alpha: 0.5),
                        strokeWidth: 1,
                      );
                    },
                    horizontalLineProvider: (y) => HorizontalLine(
                      y: y,
                      label: HorizontalLineLabel(
                          show: true,
                          style: TextStyle(
                            color: ThemeViewModel.instance().yellowColor,
                          ),
                          labelResolver: (hLine) => hLine.y.toInt().toString(),
                          alignment: Alignment.topLeft),
                      color: ThemeViewModel.instance().yellowColor.withValues(
                            alpha: 0.8,
                          ),
                      strokeWidth: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _maxY() {
    final maxYValue =
        chartDataList.map((e) => (e as CandlestickDataItem).maxY).max.floor();
    final interval = intervalY.floor();
    final ret =
        (maxYValue + (interval - (maxYValue % interval))).floorToDouble();
    return ret;
  }

  double _minY() {
    final minYValue =
        chartDataList.map((e) => (e as CandlestickDataItem).minY).min.floor();
    final interval = intervalY.floor();
    final ret =
        (minYValue - (interval - (minYValue % intervalY))).floorToDouble();
    return ret;
  }

  List<CandlestickSpot> get _candlestickSpots => chartDataList
      .toList()
      .asMap()
      .entries
      .map((entry) => CandlestickSpot(
            x: entry.key.toDouble(),
            open: (entry.value as CandlestickDataItem).yPrec.toDouble(),
            high: (entry.value as CandlestickDataItem).yHigh.toDouble(),
            low: (entry.value as CandlestickDataItem).yLow.toDouble(),
            close: entry.value.y.toDouble(),
          ))
      .toList();
}
