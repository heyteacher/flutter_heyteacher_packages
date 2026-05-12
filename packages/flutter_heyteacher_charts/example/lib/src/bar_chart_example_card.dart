import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_charts/flutter_heyteacher_charts.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;

/// The Bar Chart Card example
class ExampleBarChart extends StatelessWidget {
  /// Creates the Bar Chart Card example.
  const ExampleBarChart({
    super.key,
  });

  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: ThemeViewModel.instance.themeStream,
    builder: (context, asyncSnapshot) => BarChartView(
      title: const Text('Bar Chart'),
      axisNameWidgetX: const Text('Abscissa'),
      axisNameWidgetY: const Text('Ordinate'),
      smallScreen: true,
      formatterAxisX: (x) => '$x',
      formatterColorAxisX: (x) => ThemeViewModel.instance.redColor,
      minIntervalY: 1,
      formatterY: (index, charDataItem) =>
          '${(charDataItem as BarChartDataItem).y}-${charDataItem.fromY}',
      formatterAxisY: (index, y) => '$y',
      formatterColorAxisY: (x) => ThemeViewModel.instance.greenColor,
      barChartDataList: [
        BarChartDataItem(
          x: 0,
          y: 0,
          yColor: ThemeViewModel.instance.amberColor,
        ),
        BarChartDataItem(
          x: 1,
          y: 1,
          yColor: ThemeViewModel.instance.blueColor,
        ),
        BarChartDataItem(
          x: 2,
          y: 4,
          yColor: ThemeViewModel.instance.cyanColor,
        ),
        BarChartDataItem(
          x: 3,
          y: 9,
          yColor: ThemeViewModel.instance.deepOrangeColor,
        ),
        BarChartDataItem(
          x: 4,
          y: 16,
          fromY: 8,
          yColor: ThemeViewModel.instance.deepPurpleColor,
        ),
        BarChartDataItem(
          x: 5,
          y: 25,
          fromY: 12,
          yColor: ThemeViewModel.instance.greenColor,
        ),
      ],
    ),
  );
}
