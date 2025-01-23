import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model.dart';
import 'package:flutter_heyteacher_utils/ble/store/ble_user_store.dart';
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
        streamController.sink.add(bpm);
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
                .update(surface: ThemeHepler.instance().backgroundColor(heartRateTrainingZone.color));
          } else {
            ThemeHepler.instance().setDefault();
          }
          lastHeartRateTrainingZone = heartRateTrainingZone;
        }
      }
    }
  }

 
  ({int? age, Gender? gender, int? restBpm})? get biometrics =>
      BleModel.userData?.biometrics;

  Iterable<({HeartRateTrainingZone heartRateTrainingZone, num? max, num? min})>?
      get heartRateTrainingZones => BleModel.userData?.heartRateTrainingZones;

  static int? intensity(int bpm) => BleModel.userData?.intensity(bpm);

  void updateBiometrics(
      {({int? age, Gender? gender, int? restBpm})? biometrics}) {
    if (BleModel.userData != null) {
      BleModel.userData!.biometrics = biometrics;
      BleUserStore.instance().update(BleModel.userData!, fields: ["biometrics"]);
    }
  } 
}
