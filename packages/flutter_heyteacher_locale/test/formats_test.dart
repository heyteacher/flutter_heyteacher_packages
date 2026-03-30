import 'package:flutter/widgets.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('Formatters', () {
    test('FormatterHelper.intFormatter has correct pattern', () {
      // NumberFormat patterns are a bit different, check formatting
      expect(FormatterHelper.intFormat(123), '123');
      expect(FormatterHelper.intFormat(0), '0');
      expect(FormatterHelper.intFormat(-5), '-5');
      expect(FormatterHelper.intFormat(123456789), '123,456,789');
    });

    test('FormatterHelper.doubleFormatter has correct pattern', () {
      // Check formatting with one decimal place
      expect(FormatterHelper.doubleFormat(123.456), '123.5'); // Rounds
      expect(FormatterHelper.doubleFormat(123.4), '123.4');
      expect(FormatterHelper.doubleFormat(0.0), '0.0');
      expect(FormatterHelper.doubleFormat(-5.67), '-5.7'); // Rounds
      expect(FormatterHelper.doubleFormat(10), '10.0');
      expect(FormatterHelper.doubleFormat(123456789.09), '123,456,789.1');
    });
  });

  group('Parsers', () {
    test('FormatterHelper.machineDateTimeParse has correct pattern', () {
      expect(
        FormatterHelper.machineDateTimeParse('20241231_235959'),
        DateTime(2024, 12, 31, 23, 59, 59),
      );
    });
    test('FormatterHelper.intParse has correct pattern', () {
      expect(FormatterHelper.intParse('2024'), 2024);
      expect(FormatterHelper.intParse('2,024'), 2024);
    });
  });

  group('FormatterHelper.formatDurationTts', () {
    test('returns empty string for null input', () async {
      expect(
        await FormatterHelper.formatDurationTts(null),
        '',
      );
    });

    test('formats zero duration correctly', () async {
      expect(
        await FormatterHelper.formatDurationTts(Duration.zero),
        '0 minutes 0 seconds',
      );
      expect(
        await FormatterHelper.formatDurationTts(
          Duration.zero,
          speakSeconds: false,
        ),
        '0 minutes',
      );
    });

    test('formats duration less than an hour correctly', () async {
      const duration = Duration(minutes: 30, seconds: 30);
      expect(
        await FormatterHelper.formatDurationTts(duration),
        '30 minutes 30 seconds',
      );
      expect(
        await FormatterHelper.formatDurationTts(
          duration,
          speakSeconds: false,
        ),
        '30 minutes',
      );
    });

    test('formats duration with exactly one hour correctly', () async {
      const duration = Duration(hours: 1);
      expect(
        await FormatterHelper.formatDurationTts(
          duration,
        ),
        '1 hour 0 minutes 0 seconds',
      );
      expect(
        await FormatterHelper.formatDurationTts(
          duration,
          speakHours: false,
        ),
        '60 minutes 0 seconds',
      );
      expect(
        await FormatterHelper.formatDurationTts(
          duration,
          speakSeconds: false,
        ),
        '1 hour 0 minutes',
      );
      expect(
        await FormatterHelper.formatDurationTts(
          duration,
          speakSeconds: false,
          speakHours: false,
        ),
        '60 minutes',
      );
    });

    test('formats duration with hours and minutes correctly', () async {
      const duration = Duration(hours: 1, minutes: 30, seconds: 30);
      expect(
        await FormatterHelper.formatDurationTts(
          duration,
        ),
        '1 hour 30 minutes 30 seconds',
      );
      expect(
        await FormatterHelper.formatDurationTts(
          duration,
          speakSeconds: false,
        ),
        '1 hour 30 minutes',
      );
      expect(
        await FormatterHelper.formatDurationTts(
          duration,
          speakHours: false,
        ),
        '90 minutes 30 seconds',
      );
      expect(
        await FormatterHelper.formatDurationTts(
          duration,
          speakHours: false,
          speakSeconds: false,
        ),
        '90 minutes',
      );
    });

    test(
      'formats duration with multiple hours and minutes correctly',
      () async {
        const duration = Duration(hours: 2, minutes: 15, seconds: 15);
        expect(
          await FormatterHelper.formatDurationTts(duration),
          '2 hours 15 minutes 15 seconds',
        );
      },
    );

    test('formats duration with only minutes correctly', () async {
      const duration = Duration(minutes: 5);
      expect(
        await FormatterHelper.formatDurationTts(
          duration,
          speakSeconds: false,
        ),
        '5 minutes',
      );
    });
  });

  group('FormatterHelper.formatDuration', () {
    test('returns empty string for null input', () {
      expect(FormatterHelper.formatDuration(null), '');
      expect(FormatterHelper.formatDuration(null, showSeconds: true), '');
      expect(FormatterHelper.formatDuration(null, showHoursIfZero: false), '');
      expect(
        FormatterHelper.formatDuration(
          null,
          showSeconds: true,
          showHoursIfZero: false,
        ),
        '',
      );
    });

    // --- Default options (showSeconds: false, showHoursIfZero: true) ---
    test('formats zero duration (default)', () {
      expect(FormatterHelper.formatDuration(0), '00:00');
    });

    test('formats less than a minute (default)', () {
      const thirtySecondsMs = 30 * 1000;
      expect(
        FormatterHelper.formatDuration(thirtySecondsMs),
        '00:00',
      ); // Seconds ignored
    });

    test('formats exactly one minute (default)', () {
      const oneMinuteMs = 60 * 1000;
      expect(FormatterHelper.formatDuration(oneMinuteMs), '00:01');
    });

    test('formats less than an hour (default)', () {
      const thirtyMinutesMs = 30 * 60 * 1000;
      const thirtyMinTenSecMs = (30 * 60 + 10) * 1000;
      expect(FormatterHelper.formatDuration(thirtyMinutesMs), '00:30');
      expect(
        FormatterHelper.formatDuration(thirtyMinTenSecMs),
        '00:30',
      ); // Seconds ignored
    });

    test('formats exactly one hour (default)', () {
      const oneHourMs = 60 * 60 * 1000;
      expect(FormatterHelper.formatDuration(oneHourMs), '01:00');
    });

    test('formats more than an hour (default)', () {
      const oneHourThirtyMinutesMs = (60 + 30) * 60 * 1000;
      const twoHoursFiveMinTenSecMs = (2 * 60 * 60 + 5 * 60 + 10) * 1000;
      expect(FormatterHelper.formatDuration(oneHourThirtyMinutesMs), '01:30');
      expect(
        FormatterHelper.formatDuration(twoHoursFiveMinTenSecMs),
        '02:05',
      ); // Seconds ignored
    });

    // --- showSeconds: true, showHoursIfZero: true ---
    test('formats zero duration (show seconds)', () {
      expect(FormatterHelper.formatDuration(0, showSeconds: true), '00:00:00');
    });

    test('formats less than a minute (show seconds)', () {
      const thirtySecondsMs = 30 * 1000;
      const fiveSecondsMs = 5 * 1000;
      expect(
        FormatterHelper.formatDuration(thirtySecondsMs, showSeconds: true),
        '00:00:30',
      );
      expect(
        FormatterHelper.formatDuration(fiveSecondsMs, showSeconds: true),
        '00:00:05',
      );
    });

    test('formats less than an hour (show seconds)', () {
      const thirtyMinTenSecMs = (30 * 60 + 10) * 1000;
      expect(
        FormatterHelper.formatDuration(thirtyMinTenSecMs, showSeconds: true),
        '00:30:10',
      );
    });

    test('formats exactly one hour (show seconds)', () {
      const oneHourMs = 60 * 60 * 1000;
      expect(
        FormatterHelper.formatDuration(oneHourMs, showSeconds: true),
        '01:00:00',
      );
    });

    test('formats more than an hour (show seconds)', () {
      const twoHoursFiveMinTenSecMs = (2 * 60 * 60 + 5 * 60 + 10) * 1000;
      expect(
        FormatterHelper.formatDuration(
          twoHoursFiveMinTenSecMs,
          showSeconds: true,
        ),
        '02:05:10',
      );
    });

    // --- showSeconds: false, showHoursIfZero: false ---
    test('formats zero duration (hide zero hours)', () {
      expect(FormatterHelper.formatDuration(0, showHoursIfZero: false), '00');
    });

    test('formats less than a minute (hide zero hours)', () {
      const thirtySecondsMs = 30 * 1000;
      expect(
        FormatterHelper.formatDuration(thirtySecondsMs, showHoursIfZero: false),
        '00',
      ); // Seconds ignored
    });

    test('formats less than an hour (hide zero hours)', () {
      const thirtyMinutesMs = 30 * 60 * 1000;
      const thirtyMinTenSecMs = (30 * 60 + 10) * 1000;
      expect(
        FormatterHelper.formatDuration(thirtyMinutesMs, showHoursIfZero: false),
        '30',
      );
      expect(
        FormatterHelper.formatDuration(
          thirtyMinTenSecMs,
          showHoursIfZero: false,
        ),
        '30',
      ); // Seconds ignored
    });

    test('formats exactly one hour (hide zero hours)', () {
      const oneHourMs = 60 * 60 * 1000;
      expect(
        FormatterHelper.formatDuration(oneHourMs, showHoursIfZero: false),
        '01:00',
      ); // Hours shown because > 0
    });

    test('formats more than an hour (hide zero hours)', () {
      const oneHourThirtyMinutesMs = (60 + 30) * 60 * 1000;
      expect(
        FormatterHelper.formatDuration(
          oneHourThirtyMinutesMs,
          showHoursIfZero: false,
        ),
        '01:30',
      );
    });

    // --- showSeconds: true, showHoursIfZero: false ---
    test('formats zero duration (show seconds, hide zero hours)', () {
      expect(
        FormatterHelper.formatDuration(
          0,
          showSeconds: true,
          showHoursIfZero: false,
        ),
        '00:00',
      );
    });

    test('formats less than a minute (show seconds, hide zero hours)', () {
      const thirtySecondsMs = 30 * 1000;
      expect(
        FormatterHelper.formatDuration(
          thirtySecondsMs,
          showSeconds: true,
          showHoursIfZero: false,
        ),
        '00:30',
      );
    });

    test('formats less than an hour (show seconds, hide zero hours)', () {
      const thirtyMinTenSecMs = (30 * 60 + 10) * 1000;
      expect(
        FormatterHelper.formatDuration(
          thirtyMinTenSecMs,
          showSeconds: true,
          showHoursIfZero: false,
        ),
        '30:10',
      );
    });

    test('formats exactly one hour (show seconds, hide zero hours)', () {
      const oneHourMs = 60 * 60 * 1000;
      expect(
        FormatterHelper.formatDuration(
          oneHourMs,
          showSeconds: true,
          showHoursIfZero: false,
        ),
        '01:00:00',
      ); // Hours shown because > 0
    });

    test('formats more than an hour (show seconds, hide zero hours)', () {
      const twoHoursFiveMinTenSecMs = (2 * 60 * 60 + 5 * 60 + 10) * 1000;
      expect(
        FormatterHelper.formatDuration(
          twoHoursFiveMinTenSecMs,
          showSeconds: true,
          showHoursIfZero: false,
        ),
        '02:05:10',
      );
    });

    test('formats large duration correctly', () {
      const largeDurationMs = (25 * 60 * 60 + 45 * 60 + 15) * 1000; // 25:45:15
      expect(FormatterHelper.formatDuration(largeDurationMs), '25:45');
      expect(
        FormatterHelper.formatDuration(largeDurationMs, showSeconds: true),
        '25:45:15',
      );
      expect(
        FormatterHelper.formatDuration(largeDurationMs, showHoursIfZero: false),
        '25:45',
      );
      expect(
        FormatterHelper.formatDuration(
          largeDurationMs,
          showSeconds: true,
          showHoursIfZero: false,
        ),
        '25:45:15',
      );
    });
  });
}
