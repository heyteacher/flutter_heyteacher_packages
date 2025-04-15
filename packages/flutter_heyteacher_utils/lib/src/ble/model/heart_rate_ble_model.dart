import 'package:flutter_heyteacher_utils/src/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/src/ble/model/ble_model.dart';
import 'package:flutter_heyteacher_utils/src/ble/store/ble_user_store.dart';

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

  Iterable<({HRTrainingZone hrTrainingZone, num? max, num? min})>?
      get hrTrainingZones => BleModel.userData?.hrTrainingZones(
          dateTime: DateTime.now(), biometrics: BleModel.biometrics);

  static num? intensity(num? bpm) =>
      BleModel.userData?.intensity(bpm, biometrics: BleModel.biometrics);

  void updateBiometrics({required Biometrics newBiometrics}) async {
    BleModel.biometrics = newBiometrics;
    if (BleModel.userData != null) {
      await BleModel.userData!.setBiometrics(newBiometrics);
      BleUserStore.instance()
          .update(BleModel.userData!, fields: ["biometrics"]);
    }
  }
}
