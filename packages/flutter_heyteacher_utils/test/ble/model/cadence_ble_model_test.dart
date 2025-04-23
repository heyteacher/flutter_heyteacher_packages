import 'package:fake_async/fake_async.dart';
import 'package:flutter_heyteacher_utils/src/ble/model/cadence_ble_model.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  // Disable logging for cleaner test output
  Logger.root.level = Level.OFF;

  group('CadenceBleModel Tests', () {
    late CadenceBleModel model;

    setUp(() {
      // Reset the singleton instance before each test
      // This is a bit tricky with singletons. A common pattern is to provide
      // a reset method for testing or use dependency injection.
      // For this specific case, we can re-assign the private static instance
      // via a helper or just re-initialize its state. Let's re-initialize state.
      model = CadenceBleModel.instance;
      model.onInit(); // Ensure clean state for each test
    });

    test('Singleton instance returns the same object', () {
      final instance1 = CadenceBleModel.instance;
      final instance2 = CadenceBleModel.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('onInit resets internal state', () {
      fakeAsync((async) {
        List<num?> emittedValues = <num?>[];
        model.stream.listen(emittedValues.add);

        // Simulate some data processing
        model.onData([0, 10]);
        async.elapse(const Duration(seconds: 1));
        model.onData([0, 20]);
        async.elapse(const Duration(seconds: 1));
        model.onData([0, 30]);
        async.elapse(const Duration(seconds: 1));
        model.onData([0, 40]);
        async.elapse(const Duration(seconds: 1));
        model.onData([0, 50]); // Should emit RPM now
        async.elapse(const Duration(seconds: 1));

        // Expect *some* non-null value after 5 records
        expect(emittedValues.length, 5);
        expect(emittedValues.last, isNotNull); // Check that RPM is calculated

        // Now reset
        model.onInit();

        // Add data again, it should require 5 records again before emitting RPM
         emittedValues.clear();

        model.onData([0, 60]); // 1st record after reset
        async.elapse(const Duration(milliseconds: 500));
        model.onData([0, 65]); // 2nd
        async.elapse(const Duration(milliseconds: 500));
        model.onData([0, 70]); // 3rd
        async.elapse(const Duration(milliseconds: 500));
        model.onData([0, 75]); // 4th
        async.elapse(const Duration(milliseconds: 500));

        // Before 5th record
        expect(emittedValues, equals([null, null, null, null]));

        model.onData([0, 80]); // 5th
        async.elapse(const Duration(milliseconds: 500));

        // After 5th record, should emit calculated RPM
        expect(emittedValues.length, 5);
        expect(emittedValues.last, isNotNull); // Check that RPM is calculated
      });
    });

    test('onData handles invalid (short) event list', () {
      final emittedValues = <num?>[];
      model.stream.listen(emittedValues.add);

      model.onData([]); // Invalid
      model.onData([1]); // Invalid

      // No valid data processed, should not emit anything (or null if forced)
      // The model emits null when records < 5, but these invalid calls shouldn't add records
      expect(emittedValues, isEmpty); // Or check internal state if possible/needed
    });

    test('Requires 5 records before emitting RPM', () {
      fakeAsync((async) {
        final emittedValues = <num?>[];
        model.stream.listen(emittedValues.add);

        // Add 4 records
        for (int i = 1; i <= 4; i++) {
          model.onData([0, i * 10]);
          async.elapse(const Duration(seconds: 1));
        }

        // Should have emitted null 4 times
        expect(emittedValues, equals([null, null, null, null]));

        // Add 5th record
        model.onData([0, 50]);
        async.elapse(const Duration(seconds: 1));

        // Should emit calculated RPM now
        expect(emittedValues.length, 5);
        expect(emittedValues.last, isNotNull);
        expect(emittedValues.last, isPositive); // Basic sanity check
      });
    });

    test('Calculates RPM correctly (stable rate, no rollover)', () {
      fakeAsync((async) {
        final expectedRpms = <num?>[];
        model.stream.listen(expectedRpms.add);

        // Add 5 records, 1 revolution per second (60 RPM)
        // Record 1: time=0s, count=10
        model.onData([0, 10]);
        async.elapse(const Duration(seconds: 1));
        // Record 2: time=1s, count=11
        model.onData([0, 11]);
        async.elapse(const Duration(seconds: 1));
        // Record 3: time=2s, count=12
        model.onData([0, 12]);
        async.elapse(const Duration(seconds: 1));
        // Record 4: time=3s, count=13
        model.onData([0, 13]);
        async.elapse(const Duration(seconds: 1));
        // Record 5: time=4s, count=14 -> first calculation
        model.onData([0, 14]);
        async.elapse(const Duration(seconds: 1));

        // Calculation: (14 - 10) / 4 seconds = 4 rev / 4 s = 1 rev/s = 60 RPM
        expect(expectedRpms, equals([null, null, null, null, 60]));

        // Record 6: time=5s, count=15
        model.onData([0, 15]);
        async.elapse(const Duration(seconds: 1));

        // Calculation: (15 - 11) / 4 seconds = 4 rev / 4 s = 1 rev/s = 60 RPM
        expect(expectedRpms.last, equals(60));

        // Record 7: time=6s, count=16
        model.onData([0, 16]);
        async.elapse(const Duration(seconds: 1));
        // Calculation: (16 - 12) / 4 seconds = 4 rev / 4 s = 1 rev/s = 60 RPM
        expect(expectedRpms.last, equals(60));
      });
    });

    test('Calculates RPM correctly with counter rollover', () {
      fakeAsync((async) {
        final expectedRpms = <num?>[];
        model.stream.listen(expectedRpms.add);

        // Simulate rollover (256 buffer)
        // Assume 1 rev per second (60 RPM)
        // Record 1: time=0s, count=250
        model.onData([0, 250]);
        async.elapse(const Duration(seconds: 1));
        // Record 2: time=1s, count=252
        model.onData([0, 252]);
        async.elapse(const Duration(seconds: 1));
        // Record 3: time=2s, count=254
        model.onData([0, 254]);
        async.elapse(const Duration(seconds: 1));
        // Record 4: time=3s, count=0 (rollover, absolute = 256)
        model.onData([0, 0]);
        async.elapse(const Duration(seconds: 1));
        // Record 5: time=4s, count=2 (absolute = 258) -> first calculation
        model.onData([0, 2]);
        async.elapse(const Duration(seconds: 1));

        // Calculation: (abs(2) - abs(250)) / 4 seconds = (258 - 250) / 4s = 8 rev / 4s = 2 rev/s = 120 RPM
        // Let's adjust the input for 60 RPM for simplicity: 1 rev per second
        // R1: 254 @ 0s
        // R2: 255 @ 1s
        // R3: 0   @ 2s (abs 256)
        // R4: 1   @ 3s (abs 257)
        // R5: 2   @ 4s (abs 258) -> first calc

        model.onInit(); // Reset for clarity
        expectedRpms.clear();

        model.onData([0, 254]); // t=0
        async.elapse(const Duration(seconds: 1));
        model.onData([0, 255]); // t=1
        async.elapse(const Duration(seconds: 1));
        model.onData([0, 0]);   // t=2, abs=256
        async.elapse(const Duration(seconds: 1));
        model.onData([0, 1]);   // t=3, abs=257
        async.elapse(const Duration(seconds: 1));
        model.onData([0, 2]);   // t=4, abs=258
        async.elapse(const Duration(seconds: 1));

        // Calculation: (abs(2) - abs(254)) / 4 seconds = (258 - 254) / 4s = 4 rev / 4s = 1 rev/s = 60 RPM
        expect(expectedRpms, equals([null, null, null, null, 60]));

        // Record 6: time=5s, count=3 (abs=259)
        model.onData([0, 3]);   // t=5, abs=259
        async.elapse(const Duration(seconds: 1));
        // Calculation: (abs(3) - abs(255)) / 4 seconds = (259 - 255) / 4s = 4 rev / 4s = 1 rev/s = 60 RPM
        expect(expectedRpms.last, equals(60));

      });
    });

     test('Handles zero RPM (no change in counter)', () {
      fakeAsync((async) {
        final expectedRpms = <num?>[];
        model.stream.listen(expectedRpms.add);

        // Add 5 records with the same counter
        for(int i=0; i<5; ++i) {
          model.onData([0, 100]);
          async.elapse(const Duration(seconds: 1));
        }

        // Calculation: (100 - 100) / 4 seconds = 0 rev / 4s = 0 RPM
        expect(expectedRpms, equals([null, null, null, null, 0]));

        // Add another record, still same counter
        model.onData([0, 100]);
        async.elapse(const Duration(seconds: 1));
         // Calculation: (100 - 100) / 4 seconds = 0 rev / 4s = 0 RPM
        expect(expectedRpms.last, equals(0));

      });
    });


    test('Prunes records older than 10 seconds', () {
      fakeAsync((async) {
        final expectedRpms = <num?>[];
        model.stream.listen(expectedRpms.add);

        // Add 5 records quickly (e.g., 100ms apart)
        for (int i = 1; i <= 5; i++) {
          model.onData([0, i]); // Counts 1, 2, 3, 4, 5
          async.elapse(const Duration(milliseconds: 100));
        }
        // Time elapsed = 500ms. First record at t=0, last at t=400ms
        // Calculation: (5-1) / 0.4s = 4 / 0.4 = 10 rev/s = 600 RPM
        expect(expectedRpms, equals([null, null, null, null, 600]));

        // Wait for more than 10 seconds
        async.elapse(const Duration(seconds: 11));
        // All previous records should now be considered old

        // Add 5 new records
        // Start time is now ~11.5s
        for (int i = 1; i <= 5; i++) {
          model.onData([0, 10 + i]); // Counts 11, 12, 13, 14, 15
          async.elapse(const Duration(milliseconds: 100));
        }
        // Time elapsed since first *new* record = 400ms
        // Calculation should use only new records: (15-11) / 0.4s = 4 / 0.4 = 10 rev/s = 600 RPM
        // The stream emits nulls again because the old records were pruned,
        // and we need 5 *new* records.
         expect(expectedRpms, equals([
           null, null, null, null, 600, // From first batch
           null, null, null, null, 600  // From second batch after pruning
         ]));

      });
    });
  });
}
