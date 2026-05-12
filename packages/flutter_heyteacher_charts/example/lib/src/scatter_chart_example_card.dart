import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/flutter_heyteacher_charts.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;

/// The Bar Chart Card example
class ExampleScatterChart extends StatelessWidget {
  /// Creates the Bar Chart Card example.
  const ExampleScatterChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: ThemeViewModel.instance.themeStream,
    builder: (context, asyncSnapshot) => ScatterChartView(
      title: const Text('Scatter Chart'),
      axisNameWidgetX: const Text('Abscissa'),
      axisNameWidgetY: const Text('Ordinate'),
      formatterAxisX: (x) => '$x',
      formatterColorAxisX: (x) => ThemeViewModel.instance.redColor,
      minIntervalY: 1,
      formatterAxisY: (index, y) => '$y',
      formatterColorAxisY: (x) => ThemeViewModel.instance.greenColor,
      scatterChartDataList: [
        ChartDataItem(
          x: 1,
          y: 1,
          yColor: ThemeViewModel.instance.amberColor,
        ),
        ChartDataItem(
          x: 1,
          y: 10,
          yColor: ThemeViewModel.instance.blueColor,
        ),
        ChartDataItem(
          x: 2,
          y: 12,
          yColor: ThemeViewModel.instance.cyanColor,
        ),
        ChartDataItem(
          x: 3,
          y: 10,
          yColor: ThemeViewModel.instance.deepOrangeColor,
        ),
        ChartDataItem(
          x: 4,
          y: 16,
          yColor: ThemeViewModel.instance.deepPurpleColor,
        ),
        ChartDataItem(
          x: 4,
          y: 2,
          yColor: ThemeViewModel.instance.greenColor,
        ),
      ],
    ),
  );
}
