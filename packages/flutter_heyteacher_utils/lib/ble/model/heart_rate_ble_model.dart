import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model.dart';
import 'package:flutter_heyteacher_utils/ble/data/enums.dart';
//import 'package:logging/logging.dart';

class HeartRateBleModel extends BleModel {
  //Logger _log = Logger("HeartRateBleModel");

  @override
  void onInit() async {}

  static HeartRateBleModel? _instance;
  static HeartRateBleModel get instance => _instance ??= HeartRateBleModel._();
  HeartRateBleModel._() : super(BleType.heartRate);

  @override
  void onData(List<int> event) {
    if (event.length >= 2) {
      if (event[1] > 0) {
        int bpm = event[1];
        int? intensityValue = intensity(bpm);
        streamController.sink.add((
          value: bpm,
          formatted: bpm.toString(),
          subValue: intensityValue,
          subFormatted: intensityValue != null ? "$intensity%" : "",
          color: HeartRateTrainingZone.intensityColor(intensityValue)
        ));
      }
      // _log.fine("bpm ${event[1]}");
    }
  }
}
