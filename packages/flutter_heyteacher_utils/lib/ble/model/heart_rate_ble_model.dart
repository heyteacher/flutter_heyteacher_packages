import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model.dart';
import 'package:flutter_heyteacher_utils/ble/store/ble_user_store.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:logging/logging.dart';

class HeartRateBleModel extends BleModel {
  final Logger _log = Logger("HeartRateBleModel");

  HRTrainingZone? lastHeartRateTrainingZone;

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
        final HRTrainingZone? hrTrainingZone =
            HRTrainingZone.fromBpm(bpm,BleModel.userData?.biometrics);
        streamController.sink.add(bpm);
        // new hrTrainingZone
        if (hrTrainingZone != null &&
            lastHeartRateTrainingZone != hrTrainingZone) {
          _log.fine("hrTrainingZone "
              "$lastHeartRateTrainingZone -> $hrTrainingZone, "
              "bpm $bpm ");
          // change the background
          if (hrTrainingZone != HRTrainingZone.z0) {
            ThemeHepler.instance()
                .update(surface: ThemeHepler.instance().backgroundColor(hrTrainingZone.color));
          } else {
            ThemeHepler.instance().setDefault();
          }
          lastHeartRateTrainingZone = hrTrainingZone;
        }
      }
    }
  }

 
  ({int age, Gender gender, int restBpm})? get biometrics =>
      BleModel.userData?.biometrics;

  Iterable<({HRTrainingZone hrTrainingZone, num? max, num? min})>?
      get hrTrainingZones => BleModel.userData?.hrTrainingZones;

  static num? intensity(num? bpm) => BleModel.userData?.intensity(bpm);

  void updateBiometrics(
      {({int age, Gender gender, int restBpm})? biometrics}) {
    if (BleModel.userData != null) {
      BleModel.userData!.biometrics = biometrics;
      BleUserStore.instance().update(BleModel.userData!, fields: ["biometrics"]);
    }
  } 
}
