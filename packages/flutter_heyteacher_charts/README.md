# flutter_heyteacher_charts

A high-level Flutter charting library built on top of [fl_chart](https://pub.dev/packages/fl_chart). This package provides simplified "View" components specifically designed for the [Flutter HeyTeacher ecosystem](https://codeberg.org/heyteacher/flutter_heyteacher_packages), offering consistent styling, theme integration, and easy-to-use APIs for common data visualizations.

## Features

* **Line Charts**: Support for multiple data series, curved or stepped lines, area fills, and range annotations.
* **Bar Charts**: Configurable bar groups, support for horizontal/vertical orientation, and optimized for small screens.
* **Scatter Charts**: Simple scatter plots for individual data points.
* **Candlestick Charts**: Specialized charts for financial or interval-based data (High, Low, Open, Close).
* **Theme Integration**: Built-in support for `ThemeViewModel` from `flutter_heyteacher_views`.
* **Rich Annotations**: Easily add horizontal and vertical range highlights or extra reference lines.

## Getting started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_charts:
```

## Usage

### Line Chart

The `LineChartView` is ideal for temporal or continuous data.

```dart
LineChartView(
  title: const Text('Performance Over Time'),
  chartDataLists: [
    [
      ChartDataItem(x: 0, y: 10),
      ChartDataItem(x: 1, y: 15),
      ChartDataItem(x: 2, y: 12),
    ],
  ],
  formatterAxisX: (x) => '$x min',
  formatterColorAxisX: (x) => Colors.orange,
  formatterAxisY: (index, y) => '$y',
  formatterColorAxisY: (y) => Colors.blue,
  formatterColorLine: (index, y) => Colors.blue,
)
```

### Bar Chart

Use `BarChartView` for categorical comparisons or interval data.

```dart
BarChartView(
  title: const Text('Weekly Distribution'),
  smallScreen: true,
  barChartDataList: [
    BarChartDataItem(x: 0, y: 5, yColor: Colors.red),
    BarChartDataItem(x: 1, y: 12, yColor: Colors.green),
    BarChartDataItem(x: 2, y: 8, fromY: 2, yColor: Colors.blue), // Floating bar
  ],
  formatterAxisX: (x) => 'Day $x',
  formatterColorAxisX: (x) => Colors.grey,
  formatterAxisY: (index, y) => '$y units',
  formatterColorAxisY: (y) => Colors.black,
  formatterY: (index, item) => '${item.y}',
)
```

### Scatter Chart

Perfect for visualizing clusters or quadrant analysis.

```dart
ScatterChartView(
  title: const Text('Quadrant Analysis'),
  scatterChartDataList: [
    ChartDataItem(x: 1.2, y: 4.5, yColor: Colors.purple),
    ChartDataItem(x: 3.4, y: 2.1, yColor: Colors.orange),
  ],
  formatterAxisX: (x) => x.toStringAsFixed(1),
  formatterColorAxisX: (x) => Colors.green,
  formatterAxisY: (index, y) => y.toString(),
  formatterColorAxisY: (y) => Colors.yellow,
)
```

### Candlestick Chart

Useful for displaying price movements or ranges.

```dart
CandlestickChartView(
  title: const Text('Range Data'),
  candlestickChartDataList: [[
    CandlestickDataItem(
      x: 1,
      yPrec: 10, // Open
      y: 15,     // Close
      yHigh: 20, // High
      yLow: 5,   // Low
    ),
  ]],
  formatterAxisX: (x) => 'Slot $x',
  formatterColorAxisX: (x) => Colors.red,
  formatterAxisY: (index, y) => '$y',
  formatterColorAxisY: (y) => Colors.green,
)
```

## Additional Documentation

For more complex implementations, including range annotations and custom tooltips, refer to the TrackDetailScreen implementation in the bike tracking app, which utilizes almost every chart type provided by this package.

For a live demonstration of all features, run the provided example app.
