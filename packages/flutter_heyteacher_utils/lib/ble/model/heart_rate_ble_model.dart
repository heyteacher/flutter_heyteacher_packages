import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model.dart';
import 'package:flutter_heyteacher_utils/ble/store/ble_user_store.dart';

class HeartRateBleModel extends BleModel {
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
        streamController.sink.add(bpm);
      }
    }
  }

  ({int age, Gender gender, int restBpm})? get biometrics =>
      BleModel.userData?.biometrics;

  Iterable<({HRTrainingZone hrTrainingZone, num? max, num? min})>?
      get hrTrainingZones => BleModel.userData?.hrTrainingZones;

  static num? intensity(num? bpm) => BleModel.userData?.intensity(bpm);

  void updateBiometrics({({int age, Gender gender, int restBpm})? biometrics}) {
    if (BleModel.userData != null) {
      BleModel.userData!.biometrics = biometrics;
      BleUserStore.instance()
          .update(BleModel.userData!, fields: ["biometrics"]);
    }
  }
}
