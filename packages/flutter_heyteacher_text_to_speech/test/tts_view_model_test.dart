import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_heyteacher_logger/flutter_heyteacher_logger.dart'
    show LoggerViewModel;
import 'package:flutter_heyteacher_text_to_speech/src/tts/tts_view_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart'
    show InMemorySharedPreferencesAsync;
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart'
    show SharedPreferencesAsyncPlatform;

void main() {
  const thresholdInSeconds = 1;
  TestWidgetsFlutterBinding.ensureInitialized();
  LoggerViewModel.instance.initializeLogForTest(Level.FINER);
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  final ttsViewModel =
      TTSViewModel.instance(thresholdInSeconds: thresholdInSeconds);

  tearDown(() async {
    // reset
    await ttsViewModel.reset();
  });

  group('TTSViewModel instance', () {
    test('Singleton returns same instance', () {
      expect(TTSViewModel.instance(), ttsViewModel);
    });

    test('enabled reflects SharedPreferences and default value', () async {
      expect(await ttsViewModel.enabled, true); // default

      await ttsViewModel.setEnabled(enabled: false);
      expect(await ttsViewModel.enabled, false);

      await ttsViewModel.setEnabled(enabled: true);
      expect(await ttsViewModel.enabled, true);
    });
  });

  group('speak logic', () {
    test('does not speak if disabled', () async {
      unawaited(ttsViewModel.setEnabled(enabled: false));
      final result =
          await ttsViewModel.speak('hello', checkTTSThreshold: false);
      expect(result, false);
    });

    test('does not speak same text twice consecutively', () async {
      final firstResult =
          await ttsViewModel.speak('hello', checkTTSThreshold: false);
      expect(firstResult, true);
      final secondResult =
          await ttsViewModel.speak('hello', checkTTSThreshold: false);
      expect(secondResult, false);
    });

    test('speaks different text', () async {
      final firstResult =
          await ttsViewModel.speak('one', checkTTSThreshold: false);
      expect(firstResult, true);
      final secondResult =
          await ttsViewModel.speak('two', checkTTSThreshold: false);
      expect(secondResult, true);
    });
  });

  test('allows speech after threshold passed', () async {
    final startTime = DateTime(2024, 1, 1, 12);
    await withClock(Clock.fixed(startTime), () async {
      final firstResult =
          await ttsViewModel.speak('one', checkTTSThreshold: false);
      expect(firstResult, true);
    });
    // Advance time by thresholdInSeconds
    final secondResult = await withClock(
        Clock.fixed(startTime.add(const Duration(seconds: thresholdInSeconds))),
        () async {
      return ttsViewModel.speak('two', checkTTSThreshold: true);
    });
    expect(secondResult, true);
  });

  group('Throttling / Threshold logic', () {
    test('sequence in threshold: one (true) -> two (true)', () async {
      await withClock(Clock.fixed(DateTime(2024, 1, 1, 12)), () async {
        final firstResult =
            await ttsViewModel.speak('one', checkTTSThreshold: false);
        expect(firstResult, true);
        // Advance time only by 0.5 seconds (threshold is 1s)
        final result = await withClock(
            Clock.fixed(DateTime(2024, 1, 1, 12, 0, 0, 500)), () async {
          return ttsViewModel.speak('two', checkTTSThreshold: true);
        });
        expect(result, true);
      });
    });
    test(
        'sequence in threshold:  '
        'one (true) -> one (false) -> two (true)', () async {
      await withClock(Clock.fixed(DateTime(2024, 1, 1, 12)), () async {
        // first message is spoken
        final firstMessageSpoken =
            await ttsViewModel.speak('one', checkTTSThreshold: true);
        expect(firstMessageSpoken, true);
        // send second message and get future
        final secondMessageSpokenFuture =
            ttsViewModel.speak('one', checkTTSThreshold: true);
        // Advance time only by 0.5 seconds (with in threshold)
        // third message should not be spoken because is within threshold
        // and equal to first message (the last spoken)
        final thirdMessageSpoken = await withClock(
            Clock.fixed(DateTime(2024, 1, 1, 12, 0, 0, 500)), () async {
          return ttsViewModel.speak('two', checkTTSThreshold: true);
        });
        expect(thirdMessageSpoken, true);
        // wait for second message, is not spoken because is within threshold
        // and there was a try to spoken the first message after so
        // second message is to old to be spoken
        expect(await secondMessageSpokenFuture, false);
      });
    });

    test(
        'sequence in threshold:  '
        'one (true) -> two (false) -> one (false)', () async {
      await withClock(Clock.fixed(DateTime(2024, 1, 1, 12)), () async {
        // first message is spoken
        final firstMessageSpoken =
            await ttsViewModel.speak('one', checkTTSThreshold: true);
        expect(firstMessageSpoken, true);
        // send second message and get future
        final secondMessageSpokenFuture =
            ttsViewModel.speak('two', checkTTSThreshold: true);
        // Advance time only by 0.5 seconds (with in threshold)
        // third message should not be spoken because is within threshold
        // and equal to first message (the last spoken)
        final thirdMessageSpoken = await withClock(
            Clock.fixed(DateTime(2024, 1, 1, 12, 0, 0, 500)), () async {
          return ttsViewModel.speak('one', checkTTSThreshold: true);
        });
        expect(thirdMessageSpoken, false);
        // wait for second message, is not spoken because is within threshold
        // and there was a try to spoken the first message after so
        // second message is to old to be spoken
        expect(await secondMessageSpokenFuture, false);
      });
    });

    test(
        'sequence in threshold:  '
        'first (true) -> two (false) -> one (false) -> two (true)', () async {
      await withClock(Clock.fixed(DateTime(2024, 1, 1, 12)), () async {
        // first message is spoken
        final firstMessageSpoken =
            await ttsViewModel.speak('one', checkTTSThreshold: true);
        expect(firstMessageSpoken, true);
        // send second message and get future
        final secondMessageSpokenFuture =
            ttsViewModel.speak('two', checkTTSThreshold: true);
        // Advance time only by 0.5 seconds (with in threshold)
        // third message should not be spoken because is within threshold
        // and equal to first message (the last spoken)
        final thirdMessageSpoken = await withClock(
            Clock.fixed(DateTime(2024, 1, 1, 12, 0, 0, 500)), () async {
          return ttsViewModel.speak('one', checkTTSThreshold: true);
        });
        expect(thirdMessageSpoken, false);
        final fourthMessageSpoken =
            ttsViewModel.speak('two', checkTTSThreshold: true);
        // wait for second message, is not spoken because is within threshold
        // and there was a try to spoken the first message after so
        // second message is to old to be spoken
        expect(await secondMessageSpokenFuture, false);
        // fourth message should be spoken delayed
        expect(await fourthMessageSpoken, true);
      });
    });
  });
}
