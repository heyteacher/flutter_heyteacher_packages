import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model.dart';
import 'package:flutter_heyteacher_utils/ble/data/enums.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model_factory.dart';
import 'package:flutter_heyteacher_utils/ble/store/ble_user_store.dart';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
//import 'package:logging/logging.dart';

class HeartRateBleModel extends BleModel {
  //Logger _log = Logger("HeartRateBleModel");
  BleUserData? _bleUserData;

  @override
  void onInit() async {
    // initialize _bleUserData
    _bleUserData = await BleUserStore.instance().get(Auth.instance().uid!);
    // listen login and initialize _bleUserData 
    Auth.instance()
        .stateChangesStream
        .where((user) => user != null)
        .listen((user) async => _bleUserData = await BleUserStore.instance().get(user!.uid));
  }

  static HeartRateBleModel? _instance;
  static HeartRateBleModel get instance => _instance ??= HeartRateBleModel._();
  HeartRateBleModel._() : super(BleType.heartRate);

  @override
  void onData(List<int> event) {
    if (event.length >= 2) {
      if (event[2] > 0) {
        int bpm = event[1];
        int? intensity = _bleUserData?.intensity(bpm);
        streamController.sink.add({
          BleModelFactory.streamKey:
              "$bpm${intensity != null ? "\n$intensity%" : ""}"
        });
      }
      // _log.fine("bpm ${event[1]}");
    }
  }
}
