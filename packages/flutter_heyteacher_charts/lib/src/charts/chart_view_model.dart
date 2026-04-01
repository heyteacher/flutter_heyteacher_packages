import 'package:collection/collection.dart';
import 'package:flutter_heyteacher_charts/src/charts/chart_data.dart';

/// A view model providing utility functions for chart data calculations.
class ChartViewModel {
  
  /// Calculates the minimum x-value from a list of [ChartDataItem]s.
  /// Returns 0 if the list is empty.
  static double minX(Iterable<ChartDataItem> spots) {
    final xSeries = spots.map((e) => e.x.toDouble());
    return switch (xSeries.length) {
      0 => 0,
      1 => xSeries.first,
      _ => xSeries.min
    };
  }

  /// Calculates the maximum x-value from a list of [ChartDataItem]s.
  /// Returns 0 if the list is empty.
  static double maxX(Iterable<ChartDataItem> spots) {
    final xSeries = spots.map((e) => e.x.toDouble());
    return switch (xSeries.length) {
      0 => 0,
      1 => xSeries.first,
      _ => xSeries.max
    };
  }

  /// Calculates the minimum y-value from a list of [ChartDataItem]s.
  /// Returns 0 if the list is empty.
  static double minY(Iterable<ChartDataItem> spots) {
    final ySeries = spots.map((e) => e.y.toDouble());
    return switch (ySeries.length) {
      0 => 0,
      1 => ySeries.first,
      _ => ySeries.min
    };
  }

  /// Calculates the maximum y-value from a list of [ChartDataItem]s.
  /// Returns 0 if the list is empty.
  static double maxY(Iterable<ChartDataItem> spots) {
    final ySeries = spots.map((e) => e.y.toDouble());
    return switch (ySeries.length) {
      0 => 0,
      1 => ySeries.first,
      _ => ySeries.max
    };
  }
}
