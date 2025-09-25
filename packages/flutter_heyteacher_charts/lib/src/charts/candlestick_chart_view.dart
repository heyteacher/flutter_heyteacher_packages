import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_data.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_view.dart';
import 'package:flutter_heyteacher_utils/theme.dart';

class CandlestickChartView extends ChartView {
  final List<TextSpan>? Function(int index)? getTooltipItems;

  CandlestickChartView(
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
      super.rightTitlesLikeLeft,
      required super.formatterAxisY,
      required super.formatterColorAxisY,
      super.reservedSizeY,
      super.maxY,
      super.minY,
      super.minIntervalY,
      super.axisNameWidgetY,
      super.horizontalRangeAnnotations,
      super.verticalRangeAnnotations,
      super.aspectRatio,
      this.getTooltipItems});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          title,
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: CandlestickChart(
                _candleStickChartData,
              ),
            ),
          ),
        ],
      );

  CandlestickChartData get _candleStickChartData => CandlestickChartData(
        candlestickSpots: _candlestickSpots,
        gridData: const FlGridData(
          show: false,
        ),
        rangeAnnotations: RangeAnnotations(
            verticalRangeAnnotations: verticalRangeAnnotations,
            horizontalRangeAnnotations: horizontalRangeAnnotations),
        minY: _minY,
        maxY: _maxY,
        titlesData: titlesData,
        borderData: borderData,
        candlestickTouchData: CandlestickTouchData(
            touchTooltipData: CandlestickTouchTooltipData(
                getTooltipItems: _getTooltipItems,
                fitInsideHorizontally: true,
                fitInsideVertically: true)),
        touchedPointIndicator: AxisSpotIndicator(
          painter: AxisLinesIndicatorPainter(
            verticalLineProvider: (x) => VerticalLine(
              x: x,
              color: ThemeViewModel.instance.colorScheme.onSurface,
              strokeWidth: 1,
            ),
            horizontalLineProvider: (y) => HorizontalLine(
              y: y,
              label: HorizontalLineLabel(
                  show: true,
                  style: TextStyle(
                    color: ThemeViewModel.instance.yellowColor,
                  ),
                  labelResolver: (hLine) => hLine.y.toInt().toString(),
                  alignment: Alignment.topLeft),
              color: ThemeViewModel.instance.colorScheme.onSurface,
              strokeWidth: 1,
            ),
          ),
        ),
      );

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

  double get _maxY {
    final maxYValue =
        chartDataList.map((e) => (e as CandlestickDataItem).maxY).max.floor();
    final interval = intervalY.floor();
    final ret =
        (maxYValue + (interval - (maxYValue % interval))).floorToDouble();
    return ret;
  }

  double get _minY {
    final minYValue =
        chartDataList.map((e) => (e as CandlestickDataItem).minY).min.floor();
    final interval = intervalY.floor();
    final ret =
        (minYValue - (interval - (minYValue % intervalY))).floorToDouble();
    return ret;
  }

  CandlestickTooltipItem? _getTooltipItems(FlCandlestickPainter painter,
          CandlestickSpot touchedSpot, int spotIndex) =>
      getTooltipItems == null
          ? null
          : CandlestickTooltipItem('', children: getTooltipItems!(spotIndex));
}
