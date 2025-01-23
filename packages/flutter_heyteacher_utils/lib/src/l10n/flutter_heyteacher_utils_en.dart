import 'package:intl/intl.dart' as intl;

import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FlutterHeyteacherUtilsLocalizationsEn extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get userNotAutenticated => 'User not autenticated';

  @override
  String get notAuthenticated => 'Not Authenticated';

  @override
  String get errorOnRetrieveData => 'Error on retrieve Data';

  @override
  String get timeoutOnRetrieveData => 'Timeout on retieve data';

  @override
  String get bleAntPlus => 'Ble Ant+ ';

  @override
  String get bleAntPlusDevices => 'Bluetooth Low Emission Ant+ Devices';

  @override
  String get age => 'age';

  @override
  String get restBpm => 'rest bpm';

  @override
  String get gender => 'gender';

  @override
  String genderValue(String gender) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'Male',
        'female': 'Female',
        'other': 'Other',
      },
    );
    return '$_temp0';
  }

  @override
  String trainingZoneValue(String trainingZone) {
    String _temp0 = intl.Intl.selectLogic(
      trainingZone,
      {
        'z0': 'Z0 Rest',
        'z1': 'Z1 Warm Up',
        'z2': 'Z2 Fat Burn',
        'z3': 'Z3 Aerobic',
        'z4': 'Z4 Anaerobic',
        'z5': 'Z5 V02 Max',
        'z6': 'Z6 Death',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get trainingZone => 'Training Zone';

  @override
  String get bpm => 'BPM';

  @override
  String get maxRpm => 'Max RPM';

  @override
  String get minBpm => 'Min Bpm';

  @override
  String get rpm => 'RPM';

  @override
  String get maxBpm => 'Max BPM';

  @override
  String bleTypeDevice(String bleType) {
    String _temp0 = intl.Intl.selectLogic(
      bleType,
      {
        'cadence': 'Cadence Device',
        'heartRate': 'Heart Rate Device',
        'other': 'Unknow',
      },
    );
    return '$_temp0';
  }

  @override
  String get bluetoothAdapterStateIs => 'Bluetooth adapter state is ';

  @override
  String bluetoothAdapterState(String bluetoothAdapterState) {
    String _temp0 = intl.Intl.selectLogic(
      bluetoothAdapterState,
      {
        'unavailable': 'Unavailable',
        'unauthorized': 'Unauthorized',
        'turningOn': 'Turning On',
        'on': 'On',
        'turningOff': 'Turning Off',
        'off': 'Off',
        'other': 'Unknow',
      },
    );
    return '$_temp0';
  }

  @override
  String deviceIsNotBleTypesDevice(Object bleTypes) {
    return 'device is not $bleTypes device';
  }
}
