import 'package:flutter_heyteacher_utils/ble/data/enums.dart';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/user_store.dart';

enum Gender {
  male(heartRateCoeff: 220),
  female(heartRateCoeff: 226);

  final int heartRateCoeff;
  const Gender({required this.heartRateCoeff});
}

enum HeartRateTrainingZone {
  z1(minIntensity: 50, maxIntensity: 60),
  z2(minIntensity: 60, maxIntensity: 70),
  z3(minIntensity: 70, maxIntensity: 80),
  z4(minIntensity: 80, maxIntensity: 90),
  z5(minIntensity: 90, maxIntensity: 100);

  final int minIntensity, maxIntensity;
  const HeartRateTrainingZone(
      {required this.minIntensity, required this.maxIntensity});

  (HeartRateTrainingZone heartRateTrainingZone, int? min, int? max) targetBpm(
          {required Gender? gender,
          required int? age,
          required int? restBpm}) =>
      (
        this,
        _targetBpm(
            gender: gender,
            age: age,
            restBpm: restBpm,
            intensity: minIntensity),
        _targetBpm(
            gender: gender, age: age, restBpm: restBpm, intensity: maxIntensity)
      );

  // TargetHR = [(220 - Age - RestHR) x %Intensity] + RestHR
  int? _targetBpm(
          {required Gender? gender,
          required int? age,
          required int? restBpm,
          required int? intensity}) =>
      gender != null || age != null || restBpm != null || intensity != null
          ? (((gender!.heartRateCoeff - age! - restBpm!) * intensity!) + restBpm).round()
          : null;
}

class BleUserData extends UserData {
  Map<BleType, Map<BleField, String?>>? devices;

  int? restBpm;
  int? age;
  Gender? gender;

  // %Intensity = (HR - RestHR / (220 - Age - RestHR)) * 100
  int? intensity(int bpm) => gender != null && age != null && restBpm != null
      ? ((bpm - restBpm!) / (gender!.heartRateCoeff - age! - restBpm!) * 100)
          .round()
      : null;

  Iterable<(HeartRateTrainingZone heartRateTrainingZone, num? min, num? max)>
      get heartRateTrainingZones => HeartRateTrainingZone.values.map(
          (heartRateTrainingZone) => heartRateTrainingZone.targetBpm(
              gender: gender!, age: age!, restBpm: restBpm!));

  @override
  String get id => Auth.instance().uid ?? "guest";

  BleUserData._({this.devices, this.restBpm, this.age, this.gender})
      : super(null);

  BleUserData.fromDevices(
      {Map<BleType, BluetoothDevice?>? devices,
      Gender? gender,
      int? age,
      int? restBpm})
      : this._(
            devices: devices?.map((bleType, device) => MapEntry(bleType, {
                  BleField.id: device?.remoteId.str ?? "",
                  BleField.name: device?.platformName ?? ""
                })));

  BleUserData.fromHeartRate({Gender? gender, int? age, int? restBpm})
      : this._(gender: gender, age: age, restBpm: restBpm);

  factory BleUserData.fromFirestore(Map<String, dynamic> map) {
    return BleUserData._(
        devices: {
          for (BleType bleType in BleType.values)
            bleType: {
              BleField.id: map[bleType.firestoreFieldId],
              BleField.name: map[bleType.firestoreFieldName],
            },
        },
        restBpm: map["restBpm"],
        age: map["age"],
        gender: Gender.values
            .where((gender) => gender.name == map["gender"])
            .firstOrNull);
  }

  @override
  Map<String, dynamic> toFirestore({List<String>? fields}) => {
        ...super.toFirestore(),
        if (fields?.contains("restBpm") ?? true) "restBpm": restBpm,
        if (fields?.contains("age") ?? true) "age": age,
        if (fields?.contains("gender") ?? true) "gender": gender?.name,

        // set firestoreFieldId for each ble types
        for (BleType bleType in BleType.values)
          // update only if not null, empty string for reset
          if (devices?[bleType]?[BleField.id] != null)
            bleType.firestoreFieldId: devices![bleType]![BleField.id],

        // set firestoreFieldName  for each ble types
        // if id in not null or empty, dont update name if is empty
        // id not null and name empty occurs when ble device is restore on app restart
        // so, in this way is preserved the stored name during scan and connect
        for (BleType bleType in BleType.values)
          if (devices?[bleType]?[BleField.id] == "" ||
              (devices?[bleType]?[BleField.name] != null &&
                  devices?[bleType]?[BleField.name]?.trim() != ""))
            bleType.firestoreFieldName: devices?[bleType]?[BleField.name],
      };

  @override
  String toString() => "${super.toString()}, "
      "bleDevices: ${devices?.map((key, value) => MapEntry(key.name, "${value[BleField.name]} (${value[BleField.id]})"))}";
}
