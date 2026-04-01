import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/flutter_heyteacher_charts.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;

/// The Bar Chart Card example
class CandlestickChartExampleCard extends StatelessWidget {
  /// Creates the Bar Chart Card example.
  const CandlestickChartExampleCard({
    super.key,
  });

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: ThemeViewModel.instance.themeStream,
    builder: (context, asyncSnapshot) {
      return Card(
        child: CandlestickChartView(
          title: const Text('Candlestick Chart'),
          axisNameWidgetX: const Text('Abscissa'),
          axisNameWidgetY: const Text('Ordinate'),
          formatterAxisX: (x) => '$x',
          formatterColorAxisX: (x) => ThemeViewModel.instance.redColor,
          minX: 0,
          maxX: 5,
          minIntervalY: 1,
          minIntervalX: 1,
          formatterAxisY: (index, y) => '$y',
          formatterColorAxisY: (y) => ThemeViewModel.instance.greenColor,
          candlestickChartDataList: [
            [
              CandlestickDataItem(
                x: 1,
                y: 4,
                yHigh: 5,
                yPrec: 2,
                yLow: 1,
              ),
              CandlestickDataItem(
                x: 2,
                y: 9,
                yHigh: 10,
                yPrec: 8,
                yLow: 7,
              ),
              CandlestickDataItem(
                x: 3,
                y: 16,
                yHigh: 20,
                yPrec: 10,
                yLow: 6,
              ),
              CandlestickDataItem(
                x: 4,
                y: 25,
                yHigh: 30,
                yPrec: 14,
                yLow: 8,
              ),
            ],
          ],
        ),
      );
    },
  );
}
