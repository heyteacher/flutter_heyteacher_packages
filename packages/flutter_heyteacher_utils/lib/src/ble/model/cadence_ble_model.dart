import 'package:flutter_heyteacher_utils/src/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/src/ble/model/ble_model.dart';
import 'package:logging/logging.dart';

class CadenceBleModel extends BleModel {
  static final Logger _log = Logger("CadenceBleModel");

  static CadenceBleModel? _instance;
  static CadenceBleModel get instance => _instance ??= CadenceBleModel._();
  CadenceBleModel._() : super(BleType.cadence);

  // crank revolutions data used to calculate cadence
  static const int _crankRevolutionBuffer = 256;
  int _lastCrankRevolutionsCounter = 0;
  int _crankRevolutionsCycles = 0;
  List<CrankRevolutionRecordData> _crankRevolutionRecords = [];

  @override
  void onInit() {
    _lastCrankRevolutionsCounter = 0;
    _crankRevolutionsCycles = 0;
    _crankRevolutionRecords = [];
  }

  @override
  void onData(List<int> event) {
    DateTime crankRevolutionsTimestamp = DateTime.now();
    // invalid record
    if (event.length < 2) return;
    int crankRevolutionsCounter = event[1];
    // calculate the absolute value
    crankRevolutionsCounter +=
        (_crankRevolutionsCycles * _crankRevolutionBuffer);
    // increment cycles
    if (crankRevolutionsCounter < _lastCrankRevolutionsCounter) {
      _crankRevolutionsCycles++;
      crankRevolutionsCounter += _crankRevolutionBuffer;
    }
    _lastCrankRevolutionsCounter = crankRevolutionsCounter;
    // add record
    _crankRevolutionRecords.add(CrankRevolutionRecordData(
        timestamp: crankRevolutionsTimestamp,
        counter: crankRevolutionsCounter));
    // keep only last minute record
    _crankRevolutionRecords = _crankRevolutionRecords
        .where((element) =>
            DateTime.now().difference(element.timestamp).inSeconds < 10)
        .toList();
    // skip first five records
    if (_crankRevolutionRecords.length < 5) {
      streamController.sink.add(null);
      _log.fine(
          "onData: only ${_crankRevolutionRecords.length} recorded, waiting at least 5 records ");
      return;
    }
    // calculate RPM
    int rpm = (((_crankRevolutionRecords.last.counter -
                    _crankRevolutionRecords.first.counter) /
                _crankRevolutionRecords.last.timestamp
                    .difference(_crankRevolutionRecords.first.timestamp)
                    .inMicroseconds) *
            60000000)
        .round();
    // _log.fine("rpm $rpm"
    // " crankRevolutionsCounter $crankRevolutionsCounter "
    // "_crankRevolutionsCycles $_crankRevolutionsCycles "
    // "_crankRevolutionRecords.length ${_crankRevolutionRecords.length}"
    //    );
    streamController.sink.add(rpm);
  }
}
