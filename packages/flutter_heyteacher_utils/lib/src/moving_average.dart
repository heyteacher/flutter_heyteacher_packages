/// A library for calculating different types of moving averages on a series of data.
///
/// This utility provides static methods to compute:
/// - Simple Moving Average (SMA)
/// - Exponential Moving Average (EMA)
/// - Weighted Moving Average (WMA)
///
/// These are common tools in data analysis and technical analysis of financial markets.
library;

import 'dart:math';

/// A type definition for a function that calculates a single moving average value.
typedef MovingAverageFunction =
    double Function({
      required int index,
      required Iterable<double> data,
      required int period,
    });

/// A utility class that provides static methods for calculating various
/// types of moving averages.
class MovingAverage {
  /// Exponential Moving Average of [data] using [period].
  ///
  /// ```EWAt = α * rt + (1 - α) * EMAt-1```
  /// Where:
  /// - `α`: (alpha) is the smoothing factor, `2 / ([period] + 1)`, A higher α
  ///   gives more weight to the current observation (rt) and makes the EWMA
  ///   more responsive to recent changes.
  /// - `rt`: is the actual value of the time series at time t.
  /// - `EMAt-1`: is the exponentially weighted moving average from the previous time period (t-1).
  static Iterable<double> exponential(Iterable<double> data, int period) =>
      _ma(data, period, _exponentialFunction, modifyInputDataList: true);

  static double _exponentialFunction({
    required int index,
    required Iterable<double> data,
    required int period,
  }) {
    final double alpha = 2 / (period + 1);
    return (alpha * data.elementAt(index)) +
        ((1 - alpha) * data.elementAt(index - 1));
  }

  /// Simple Moving Average of [data] using [period].
  ///
  /// ```SMAt = ( rt + rt-1 + ... + rt-period+1 ) / period```
  /// Where:
  /// - `rt`: is the actual value of the time series at time t.
  /// - period: the windows where calculate the average
  static Iterable<double> simple(Iterable<double> data, int period) =>
      _ma(data, period, _simpleFunction);

  static double _simpleFunction({
    required int index,
    required Iterable<double> data,
    required int period,
  }) {
    double numerator = 0;
    final int windowSize = min(index + 1, period);
    for (int j = 0; j < windowSize; j++) {
      numerator += data.elementAt(index - j);
    }
    return numerator / windowSize;
  }

  /// Weighted Moving Average of [data] using [period].
  ///
  /// ```WMAt = (r1W1 + r2W2 + ... + rtWt) / (W1 + W2 + ... + Wt)```
  /// Where:
  /// - `rt`: is the actual value of the time series at time t.
  /// - `period`: the windows where calculate the average
  static Iterable<double> weighted(Iterable<double> data, int period) =>
      _ma(data, period, _weightedFunction);

  static double _weightedFunction({
    required int index,
    required Iterable<double> data,
    required int period,
  }) {
    double numerator = 0;
    double denominator = 0;
    final int windowSize = min(index + 1, period);
    for (int j = 0; j < windowSize; j++) {
      final double weight = (windowSize - j).toDouble();
      numerator += data.elementAt(index - j) * weight;
      denominator += weight;
    }
    return numerator / denominator;
  }

  /// Generic function to calculate a moving average.
  static Iterable<double> _ma(
    Iterable<double> data,
    int period,
    MovingAverageFunction movingAverageFunction, {
    bool modifyInputDataList = false,
  }) {
    if (period <= 0) {
      throw ArgumentError('moving average: period ($period) must be '
      'greater than 0.');
    }
    if (data.length < period) {
      throw ArgumentError('moving average: data length (${data.length}) '
      'must be greater or equal than period ($period).');
    }
    final List<double> ma = data.toList();
    for (int i = 1; i < data.length; i++) {
      ma[i] = movingAverageFunction(
        index: i,
        data: modifyInputDataList ? ma : data,
        period: period,
      );
    }
    return ma;
  }
}
