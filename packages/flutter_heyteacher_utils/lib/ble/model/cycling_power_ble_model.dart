import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model.dart';
import 'package:logging/logging.dart';

class CyclingPowerBleModel extends BleModel {
  static final Logger _log = Logger("CyclingPowerBleModel");

  static CyclingPowerBleModel? _instance;
  static CyclingPowerBleModel get instance => _instance ??= CyclingPowerBleModel._();
  CyclingPowerBleModel._() : super(BleType.cyclingPower);

 
  @override
  void onInit() {
  }

  @override
  void onData(List<int> event) {
    _log.info("onData:  event $event");
    if (event.length < 2) {
      return;}
    int watt = event[1];
    streamController.sink.add(watt);
  }
}
