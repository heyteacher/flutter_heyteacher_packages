import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_data.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_view.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// A chart widget that displays data as a series of candlesticks.
/// It extends [ChartView] to handle common chart functionalities.
class CandlestickChartView extends ChartView {
  /// Creates a [CandlestickChartView].
  CandlestickChartView({
    required Iterable<Iterable<CandlestickDataItem>> candlestickChartDataList,
    required super.formatterAxisX,
    required super.formatterColorAxisX,
    required super.formatterAxisY,
    required super.formatterColorAxisY,
    super.key,
    super.title,
    super.reservedSizeX,
    super.maxX,
    super.minX,
    super.minIntervalX,
    super.axisNameWidgetX,
    super.rightTitlesLikeLeft,
    super.reservedSizeY,
    super.maxY,
    super.minY,
    super.minIntervalY,
    super.axisNameWidgetY,
    super.horizontalRangeAnnotations,
    super.verticalRangeAnnotations,
    super.aspectRatio,
    List<TextSpan>? Function(int)? getTooltipItems,
  })  : _getTooltipItems = getTooltipItems,
        super(chartDataLists: candlestickChartDataList);

  /// A function that provides custom tooltip text spans for a given data point
  /// index. This allows for rich text formatting in the tooltips.
  final List<TextSpan>? Function(int index)? _getTooltipItems;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          title,
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
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
          horizontalRangeAnnotations: horizontalRangeAnnotations,
        ),
        minY: _minY,
        maxY: _maxY,
        minX: minX,
        maxX: maxX,
        titlesData: titlesData,
        borderData: borderData,
        candlestickTouchData: CandlestickTouchData(
          touchTooltipData: CandlestickTouchTooltipData(
            getTooltipItems: _getCandleStickTooltipItems,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
          ),
        ),
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
                  color: formatterColorAxisY(y),
                ),
                labelResolver: (hLine) => hLine.y.toInt().toString(),
              ),
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
      .map(
        (entry) => CandlestickSpot(
          x: entry.value.x.toDouble(),
          open: (entry.value as CandlestickDataItem).yPrec.toDouble(),
          high: (entry.value as CandlestickDataItem).yHigh.toDouble(),
          low: (entry.value as CandlestickDataItem).yLow.toDouble(),
          close: entry.value.y.toDouble(),
        ),
      )
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

  CandlestickTooltipItem? _getCandleStickTooltipItems(
    FlCandlestickPainter painter,
    CandlestickSpot touchedSpot,
    int spotIndex,
  ) =>
      _getTooltipItems == null
          ? null
          : CandlestickTooltipItem('', children: _getTooltipItems(spotIndex));
}
