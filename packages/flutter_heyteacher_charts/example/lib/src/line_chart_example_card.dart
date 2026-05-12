import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/flutter_heyteacher_charts.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;

/// The Line Chart Card example
class ExampleLineChart extends StatelessWidget {
  /// Creates the Line Chart Card example.
  const ExampleLineChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: ThemeViewModel.instance.themeStream,
    builder: (context, asyncSnapshot) => LineChartView(
      title: const Text('Line Chart'),
      minIntervalX: 1,
      minIntervalY: 1,
      axisNameWidgetX: const Text('Abscissa'),
      formatterAxisX: (x) => '$x',
      formatterColorAxisX: (x) => ThemeViewModel.instance.redColor,
      axisNameWidgetY: const Text('Ordinate'),
      formatterAxisY: (index, y) => '$y',
      formatterColorAxisY: (x) => ThemeViewModel.instance.greenColor,
      formatterColorLine: (index, y) => switch (index) {
        0 => ThemeViewModel.instance.blueColor,
        1 => ThemeViewModel.instance.yellowColor,
        _ => Colors.black,
      },
      chartDataLists: const [
        [
          ChartDataItem(x: 0, y: 0),
          ChartDataItem(x: 1, y: 1),
          ChartDataItem(x: 2, y: 2),
          ChartDataItem(x: 3, y: 3),
          ChartDataItem(x: 4, y: 4),
          ChartDataItem(x: 5, y: 5),
        ],
        [
          ChartDataItem(x: 0, y: 0),
          ChartDataItem(x: 1, y: 1),
          ChartDataItem(x: 2, y: 4),
          ChartDataItem(x: 3, y: 9),
          ChartDataItem(x: 4, y: 16),
          ChartDataItem(x: 5, y: 25),
        ],
      ],
    ),
  );
}
