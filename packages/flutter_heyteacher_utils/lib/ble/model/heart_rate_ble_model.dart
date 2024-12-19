import 'package:flutter_heyteacher_utils/ble/model/ble_model.dart';
import 'package:flutter_heyteacher_utils/ble/data/enums.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model_factory.dart';
//import 'package:logging/logging.dart';

class HeartRateBleModel extends BleModel {
  //Logger _log = Logger("HeartRateBleModel");
  
  @override
  void onInit() {}

  static HeartRateBleModel? _instance;
  static HeartRateBleModel get instance => _instance ??= HeartRateBleModel._();
  HeartRateBleModel._() : super(BleType.heartRate);

  @override
  void onData(List<int> event) {
    if (event.length >= 2) {
      if (event[2] > 0) {
        streamController.sink.add({BleModelFactory.streamKey: event[1].toString()});
      }
      // _log.fine("bpm ${event[1]}");
    }
  }
}