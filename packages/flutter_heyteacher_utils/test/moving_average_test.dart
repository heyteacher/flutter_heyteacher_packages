import 'package:flutter_heyteacher_utils/src/moving_average.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MovingAverage', () {
    final data = [10.0, 12.0, 11.0, 15.0, 14.0, 16.0];

    group('simple', () {
      test('calculates simple moving average correctly with period 3', () {
        const period = 3;
        final result = MovingAverage.simple(data, period).toList();

        // The first value is always the original value.
        expect(result[0], data[0]);

        // Subsequent values are calculated based on the original data.
        // ma[1] = (10+12)/2 = 11
        expect(result[1], closeTo(11.0, 0.001));
        // ma[2] = (10+12+11)/3 = 11
        expect(result[2], closeTo(11.0, 0.001));
        // ma[3] = (12+11+15)/3 = 12.666
        expect(result[3], closeTo(12.666, 0.001));
        // ma[4] = (11+15+14)/3 = 13.333
        expect(result[4], closeTo(13.333, 0.001));
        // ma[5] = (15+14+16)/3 = 15
        expect(result[5], closeTo(15.0, 0.001));
      });

      test('handles period larger than data length at start', () {
        const period = 5;
        final result = MovingAverage.simple(data, period).toList();

        expect(result[0], data[0]);
        // ma[1] = (10+12)/2
        expect(result[1], closeTo(11.0, 0.001));
        // ma[2] = (10+12+11)/3
        expect(result[2], closeTo(11.0, 0.001));
        // ma[3] = (10+12+11+15)/4
        expect(result[3], closeTo(12.0, 0.001));
        // ma[4] = (10+12+11+15+14)/5
        expect(result[4], closeTo(12.4, 0.001));
        // ma[5] = (12+11+15+14+16)/5
        expect(result[5], closeTo(13.6, 0.001));
      });
    });

    group('exponential', () {
      test('calculates exponential moving average correctly with period 3', () {
        const period = 3;
        final result = MovingAverage.exponential(data, period).toList();

        // alpha = 2 / (3 + 1) = 0.5
        // The first value is always the original value.
        expect(result[0], data[0]);

        // Subsequent values are calculated based on the *previous EMA value*.
        // ema[1] = 0.5 * 12 + 0.5 * 10 = 11
        expect(result[1], closeTo(11.0, 0.001));
        // ema[2] = 0.5 * 11 + 0.5 * 11 = 11
        expect(result[2], closeTo(11, 0.001));
        // ema[3] = 0.5 * 15 + 0.5 * 11 = 13
        expect(result[3], closeTo(13.0, 0.001));
        // ema[4] = 0.5 * 14 + 0.5 * 13 = 13.5
        expect(result[4], closeTo(13.5, 0.001));
        // ema[5] = 0.5 * 16 + 0.5 * 13.5 = 14.75
        expect(result[5], closeTo(14.75, 0.001));
      });
    });

    group('weighted', () {
      test('calculates weighted moving average correctly with period 3', () {
        const period = 3;
        final result = MovingAverage.weighted(data, period).toList();

        // The first value is always the original value.
        expect(result[0], data[0]);

        // Subsequent values are calculated based on the original data.
        // wma[1] = (12*2 + 10*1) / (2+1) = 34/3 = 11.333
        expect(result[1], closeTo(11.333, 0.001));
        // wma[2] = (11*3 + 12*2 + 10*1) / (3+2+1) = 67/6 = 11.166
        expect(result[2], closeTo(11.166, 0.001));
        // wma[3] = (15*3 + 11*2 + 12*1) / (3+2+1) = 79/6 = 13.166
        expect(result[3], closeTo(13.166, 0.001));
        // wma[4] = (14*3 + 15*2 + 11*1) / (3+2+1) = 83/6 = 13.833
        expect(result[4], closeTo(13.833, 0.001));
        // wma[5] = (16*3 + 14*2 + 15*1) / (3+2+1) = 91/6 = 15.166
        expect(result[5], closeTo(15.166, 0.001));
      });
    });

    group('error handling', () {
      test('throws ArgumentError for period <= 0', () {
        expect(() => MovingAverage.simple(data, 0),
            throwsA(isA<ArgumentError>()));
        expect(() => MovingAverage.simple(data, -1),
            throwsA(isA<ArgumentError>()));
        expect(() => MovingAverage.exponential(data, 0),
            throwsA(isA<ArgumentError>()));
        expect(() => MovingAverage.weighted(data, 0),
            throwsA(isA<ArgumentError>()));
      });

      test('throws ArgumentError for data length < period', () {
        final shortData = [1.0, 2.0];
        const period = 3;

        expect(() => MovingAverage.simple(shortData, period),
            throwsA(isA<ArgumentError>()));
        expect(() => MovingAverage.exponential(shortData, period),
            throwsA(isA<ArgumentError>()));
        expect(() => MovingAverage.weighted(shortData, period),
            throwsA(isA<ArgumentError>()));
      });

      test('does not throw for data length == period', () {
        final sameLengthData = [1.0, 2.0, 3.0];
        const period = 3;

        expect(() => MovingAverage.simple(sameLengthData, period),
            returnsNormally);
      });
    });
  });
}
