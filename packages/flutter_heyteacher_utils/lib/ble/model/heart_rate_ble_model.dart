import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:logging/logging.dart';

class HeartRateBleModel extends BleModel {
  final Logger _log = Logger("HeartRateBleModel");

  HeartRateTrainingZone? lastHeartRateTrainingZone;

  @override
  void onInit() async {}

  static HeartRateBleModel? _instance;
  static HeartRateBleModel get instance => _instance ??= HeartRateBleModel._();
  HeartRateBleModel._() : super(BleType.heartRate);

  @override
  void onData(List<int> event) {
    if (event.length >= 2) {
      if (event[1] > 0) {
        final int bpm = event[1];
        final int? intensityValue = intensity(bpm);
        final HeartRateTrainingZone? heartRateTrainingZone =
            HeartRateTrainingZone.fromIntensity(intensityValue);
        final String zone = heartRateTrainingZone != null
            ? " ${heartRateTrainingZone.name.toUpperCase()}"
            : "";
        streamController.sink.add((
          value: bpm,
          formatted: bpm.toString(),
          subValue: intensityValue,
          subFormatted: intensityValue != null ? "$intensityValue%$zone" : "",
          color: heartRateTrainingZone?.color
        ));
        // new heartRateTrainingZone
        if (heartRateTrainingZone != null &&
            lastHeartRateTrainingZone != heartRateTrainingZone) {
          _log.fine("heartRateTrainingZone "
              "$lastHeartRateTrainingZone -> $heartRateTrainingZone, "
              "bpm $bpm, "
              "intensity $intensityValue");
          // change the background
          if (heartRateTrainingZone != HeartRateTrainingZone.z0) {
            ThemeHepler.instance()
                .update(surface: _surfaceColor(heartRateTrainingZone.color));
          } else {
            ThemeHepler.instance().setDefault();
          }
          lastHeartRateTrainingZone = heartRateTrainingZone;
        }
      }
    }
  }

  ({Color light, Color dark}) _surfaceColor(Color color) => (
        light: Color.lerp(color, Colors.white, 0.7)!,
        dark: Color.lerp(color, Colors.black, 0.7)!
      );
}
