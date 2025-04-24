import 'package:clock/clock.dart';
import 'package:flutter_heyteacher_utils/date_helpers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateHelpers Extension Tests', () {
    // Define a fixed point in time for consistent testing
    final fixedNow = DateTime(2023, 10, 27, 10, 30, 0); // October 27th, 2023

    test('isToday returns true for the same day', () {
      // Use withClock to control the time returned by clock.now()
      withClock(Clock.fixed(fixedNow), () {
        final today = DateTime(2023, 10, 27, 15, 0, 0);
        expect(today.isToday, isTrue);
      });
    });

    test('isToday returns false for a different day', () {
      withClock(Clock.fixed(fixedNow), () {
        final yesterday = DateTime(2023, 10, 26, 23, 59, 59);
        final tomorrow = DateTime(2023, 10, 28, 0, 0, 1);
        final differentMonth = DateTime(2023, 11, 27);
        final differentYear = DateTime(2024, 10, 27);

        expect(yesterday.isToday, isFalse);
        expect(tomorrow.isToday, isFalse);
        expect(differentMonth.isToday, isFalse);
        expect(differentYear.isToday, isFalse);
      });
    });

    test('isYesterday returns true for the previous day', () {
      withClock(Clock.fixed(fixedNow), () {
        final yesterday = DateTime(2023, 10, 26, 12, 0, 0);
        expect(yesterday.isYesterday, isTrue);
      });
    });

     test('isYesterday returns true across month boundary', () {
      final firstOfMonth = DateTime(2023, 11, 1, 10, 0, 0);
      withClock(Clock.fixed(firstOfMonth), () {
        final lastOfPreviousMonth = DateTime(2023, 10, 31, 12, 0, 0);
        expect(lastOfPreviousMonth.isYesterday, isTrue);
      });
    });

     test('isYesterday returns true across year boundary', () {
      final firstOfYear = DateTime(2024, 1, 1, 10, 0, 0);
      withClock(Clock.fixed(firstOfYear), () {
        final lastOfPreviousYear = DateTime(2023, 12, 31, 12, 0, 0);
        expect(lastOfPreviousYear.isYesterday, isTrue);
      });
    });

    test('isYesterday returns false for the same or future day', () {
      withClock(Clock.fixed(fixedNow), () {
        final today = DateTime(2023, 10, 27, 0, 0, 1);
        final tomorrow = DateTime(2023, 10, 28, 15, 0, 0);
        final twoDaysAgo = DateTime(2023, 10, 25);

        expect(today.isYesterday, isFalse);
        expect(tomorrow.isYesterday, isFalse);
        expect(twoDaysAgo.isYesterday, isFalse); // isYesterday only checks the *immediately* preceding day
      });
    });

    test('isTomorrow returns true for the next day', () {
      withClock(Clock.fixed(fixedNow), () {
        final tomorrow = DateTime(2023, 10, 28, 8, 0, 0);
        expect(tomorrow.isTomorrow, isTrue);
      });
    });

    test('isTomorrow returns true across month boundary', () {
      final lastOfMonth = DateTime(2023, 10, 31, 10, 0, 0);
       withClock(Clock.fixed(lastOfMonth), () {
        final firstOfNextMonth = DateTime(2023, 11, 1, 8, 0, 0);
        expect(firstOfNextMonth.isTomorrow, isTrue);
      });
    });

     test('isTomorrow returns true across year boundary', () {
      final lastOfYear = DateTime(2023, 12, 31, 10, 0, 0);
       withClock(Clock.fixed(lastOfYear), () {
        final firstOfNextYear = DateTime(2024, 1, 1, 8, 0, 0);
        expect(firstOfNextYear.isTomorrow, isTrue);
      });
    });

    test('isTomorrow returns false for the same or past day', () {
      withClock(Clock.fixed(fixedNow), () {
        final today = DateTime(2023, 10, 27, 23, 59, 59);
        final yesterday = DateTime(2023, 10, 26, 15, 0, 0);
        final twoDaysLater = DateTime(2023, 10, 29);

        expect(today.isTomorrow, isFalse);
        expect(yesterday.isTomorrow, isFalse);
        expect(twoDaysLater.isTomorrow, isFalse); // isTomorrow only checks the *immediately* succeeding day
      });
    });

    test('relativeDay returns correct enum values', () {
      withClock(Clock.fixed(fixedNow), () {
        final today = DateTime(2023, 10, 27, 1, 1, 1);
        final yesterday = DateTime(2023, 10, 26, 5, 5, 5);
        final tomorrow = DateTime(2023, 10, 28, 9, 9, 9);
        final twoDaysAgo = DateTime(2023, 10, 25);
        final twoDaysLater = DateTime(2023, 10, 29);
        final differentMonth = DateTime(2023, 11, 27);
        final differentYear = DateTime(2024, 10, 27);

        expect(today.relativeDay, RelativeDay.today);
        expect(yesterday.relativeDay, RelativeDay.yesterday);
        expect(tomorrow.relativeDay, RelativeDay.tomorrow);
        expect(twoDaysAgo.relativeDay, RelativeDay.unknow);
        expect(twoDaysLater.relativeDay, RelativeDay.unknow);
        expect(differentMonth.relativeDay, RelativeDay.unknow);
        expect(differentYear.relativeDay, RelativeDay.unknow);
      });
    });
  });
}
