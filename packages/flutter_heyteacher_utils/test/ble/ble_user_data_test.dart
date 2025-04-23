import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/ble/data/ble_user_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final biometrics = Biometrics(
    birthDate: clock.now().subtract(Duration(days: 366 * 20)),
    gender: Gender.male,
    restBpm: 60
  );

  setUp(() async {
    WidgetsFlutterBinding.ensureInitialized();
  });

  group('HRTrainingZone fromBpm group:', () {
    test('should return correct HR training zone', () async {
      expect(
          HRTrainingZone.fromBpm(
              bpm: 50,
              biometrics: biometrics,
              dateTime: clock.now()),
          HRTrainingZone.z0,
          reason: "less then restBpm doesn't return z0");
      expect(
          HRTrainingZone.fromBpm(
              bpm: 65,
              biometrics: biometrics,
              dateTime: clock.now()),
          HRTrainingZone.z0,
          reason: "greather then restBpm doesn't return z0");
      expect(
          HRTrainingZone.fromBpm(
              bpm: 200,
              biometrics: biometrics,
              dateTime: clock.now()),
          HRTrainingZone.z6,
          reason: "doesn't return z6");
      expect(
          HRTrainingZone.fromBpm(
              bpm: 199,
              biometrics: biometrics,
              dateTime: clock.now()),
          HRTrainingZone.z5,
          reason: "doesn't return z5");
    });
    test('null bpm return null', () async {
      expect(
          HRTrainingZone.fromBpm(
              bpm: null,
              biometrics: biometrics,
              dateTime: clock.now()),
          null,
          reason: "null, doesn't return null");
    });
  });

  group('HRTrainingZone fromName group:', () {
    test('should return correct HR training zone', () async {
      expect(HRTrainingZone.fromName("z0"), HRTrainingZone.z0,
          reason: "name 'z0' doesn't return z0");
      expect(HRTrainingZone.fromName("z3"), HRTrainingZone.z3,
          reason: "name 'z3' doesn't return z3");
    });
    test('null zone name return null', () async {
      expect(HRTrainingZone.fromName(null), null,
          reason: "null, doesn't return null");
    });
  });

  group('HRTrainingZone targetBpm group:', () {
    test('should return correct target bpm', () async {
      final targetBpm = HRTrainingZone.z4.targetBpm(
          biometrics: biometrics, dateTime: clock.now());
      expect(targetBpm?.min, 172,
          reason: "biometrics $biometrics z4 min isn't 147");
      expect(targetBpm?.max, 186,
          reason: "biometrics $biometrics z4 max isn't 158");
    });
    test('null biometrics should return null', () async {
      final targetBpm = HRTrainingZone.z4
          .targetBpm(biometrics: null, dateTime: clock.now());
      expect(targetBpm, null, reason: "biometrics null, doesn't return null");
    });
  });
}
