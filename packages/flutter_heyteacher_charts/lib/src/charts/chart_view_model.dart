

import 'package:collection/collection.dart';
import 'package:flutter_heyteacher_charts/flutter_heyteacher_charts.dart';

class ChartViewModel {
  
  static double minX(Iterable<ChartDataItem> spots) {
    Iterable<double> xSeries = spots.map((e) => e.x.toDouble());
    return switch (xSeries.length) {
      0 => 0,
      1 => xSeries.first,
      _ => xSeries.min
    };
  }

  static double maxX(Iterable<ChartDataItem> spots) {
    Iterable<double> xSeries = spots.map((e) => e.x.toDouble());
    return switch (xSeries.length) {
      0 => 0,
      1 => xSeries.first,
      _ => xSeries.max
    };
  }

  static double minY(Iterable<ChartDataItem> spots) {
    Iterable<double> ySeries = spots.map((e) => e.y.toDouble());
    return switch (ySeries.length) {
      0 => 0,
      1 => ySeries.first,
      _ => ySeries.min
    };
  }

  static double maxY(Iterable<ChartDataItem> spots) {
    Iterable<double> ySeries = spots.map((e) => e.y.toDouble());
    return switch (ySeries.length) {
      0 => 0,
      1 => ySeries.first,
      _ => ySeries.max
    };
  }
}