import 'dart:math';

import 'package:flutter/material.dart';

import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/user_store.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';


class BleUserData extends UserData {
  Map<BleType, ({String? id, String? name})>? devices;

  ({int? restBpm, int? age, Gender? gender})? biometrics;

  // intensity% = (bpm -restBpm / ( (female: 226| male: 200) - age - restBpm)) * 100
  int? intensity(int bpm) => biometrics?.gender != null &&
          biometrics?.age != null &&
          biometrics?.restBpm != null
      ? ((bpm - biometrics!.restBpm!) /
              (biometrics!.gender!.heartRateCoeff -
                  biometrics!.age! -
                  biometrics!.restBpm!) *
              100)
          .round()
      : null;

  Iterable<({HeartRateTrainingZone heartRateTrainingZone, num? min, num? max})>?
      get heartRateTrainingZones => biometrics?.gender != null &&
              biometrics?.age != null &&
              biometrics?.restBpm != null
          ? HeartRateTrainingZone.values.map((heartRateTrainingZone) =>
              heartRateTrainingZone.targetBpm(biometrics: biometrics))
          : null;

  @override
  String get id => Auth.instance().uid ?? "guest";

  BleUserData._({this.devices, this.biometrics}) : super();

  BleUserData.fromDevices({Map<BleType, BluetoothDevice?>? devices})
      : this._(
            devices: devices?.map((bleType, device) => MapEntry(bleType,( 
                  id: device?.remoteId.str ?? "",
                  name: device?.platformName ?? ""
                ))));

  BleUserData.fromHeartRate(
      ({Gender? gender, int? age, int? restBpm}) biometrics)
      : this._(biometrics: biometrics);

  factory BleUserData.fromFirestore(Map<String, dynamic> map) {
    return BleUserData._(devices: {
      for (BleType bleType in BleType.values)
        bleType: (
          id: map[bleType.firestoreFieldId],
          name: map[bleType.firestoreFieldName],
        ),
    }, biometrics: (
      restBpm: map["biometrics"]?["restBpm"],
      age: map["biometrics"]?["age"],
      gender: Gender.values
          .where((gender) => gender.name == map["biometrics"]?["gender"])
          .firstOrNull
    ));
  }

  @override
  Map<String, dynamic> toFirestore({List<String>? fields}) => {
        ...super.toFirestore(),
        if (fields?.contains("biometrics") ?? true)
          "biometrics": {
            "restBpm": biometrics?.restBpm,
            "age": biometrics?.age,
            "gender": biometrics?.gender?.name,
          },
        // set firestoreFieldId for each ble types
        for (BleType bleType in BleType.values)
          // update only if not null, empty string for reset
          if (devices?[bleType]?.id != null)
            bleType.firestoreFieldId: devices![bleType]!.id,

        // set firestoreFieldName  for each ble types
        // if id in not null or empty, dont update name if is empty
        // id not null and name empty occurs when ble device is restore on app restart
        // so, in this way is preserved the stored name during scan and connect
        for (BleType bleType in BleType.values)
          if (devices?[bleType]?.id == "" ||
              (devices?[bleType]?.name != null &&
                  devices?[bleType]?.name?.trim() != ""))
            bleType.firestoreFieldName: devices?[bleType]?.name,
      };

  @override
  String toString() => "${super.toString()}, "
      "devices: ${devices?.map((key, value) => MapEntry(key.name, "${value.name} (${value.id})"))}, "
      "biometrics: $biometrics";
}

enum BleType {
  heartRate(
      icon: FontAwesomeIcons.heartPulse,
      firestoreFieldId: "heartRateDeviceId",
      firestoreFieldName: "heartRateDeviceName",
      uuidService: "180d",
      uuidCharacteristic:"2a37"),
  cadence(
      icon: Icons.change_circle,
      firestoreFieldId: "cadenceDeviceId",
      firestoreFieldName: "cadenceDeviceName",
            uuidService: "1816",
      uuidCharacteristic:"2a5b");

  const BleType(
      {required this.icon,
      required this.firestoreFieldId,
      required this.firestoreFieldName,
      required this.uuidService,
      required this.uuidCharacteristic});
  final IconData icon;
  final String firestoreFieldId;
  final String firestoreFieldName;
  final String uuidService;
  final String uuidCharacteristic;
}

enum Gender {
  male(heartRateCoeff: 220),
  female(heartRateCoeff: 226),
  other(heartRateCoeff: 223);

  final int heartRateCoeff;
  const Gender({required this.heartRateCoeff});

  @override
  String toString() {
    return name;
  }
}

enum HeartRateTrainingZone {
  z0(minIntensity: 0, maxIntensity: 50, color: Colors.white70),
  z1(minIntensity: 50, maxIntensity: 60, color: Colors.cyanAccent),
  z2(minIntensity: 60, maxIntensity: 70, color: Colors.greenAccent),
  z3(minIntensity: 70, maxIntensity: 80, color: Colors.yellowAccent),
  z4(minIntensity: 80, maxIntensity: 90, color: Colors.orangeAccent),
  z5(minIntensity: 90, maxIntensity: 100, color: Colors.redAccent),
  z6(minIntensity: 100, maxIntensity: 1000, color: Colors.purpleAccent);

  final int minIntensity;
  final int maxIntensity;
  final Color color;
  const HeartRateTrainingZone(
      {required this.minIntensity,
      required this.maxIntensity,
      required this.color});

  static HeartRateTrainingZone? fromName(String? name) =>
      HeartRateTrainingZone.values
          .where((zone) =>
              zone.name == name)
          .firstOrNull;


  static HeartRateTrainingZone? fromIntensity(int? intensity) =>
      HeartRateTrainingZone.values
          .where((zone) =>
              (intensity ?? 0) >= zone.minIntensity &&
              (intensity ?? 0) < zone.maxIntensity)
          .firstOrNull;

  ({HeartRateTrainingZone heartRateTrainingZone, int? min, int? max}) targetBpm(
          {({Gender? gender, int? age, int? restBpm})? biometrics}) =>
      (
        heartRateTrainingZone: this,
        min: max( _targetBpm(biometrics: biometrics, intensity: minIntensity) ?? 0, biometrics?.restBpm ?? 0),
        max: _targetBpm(biometrics: biometrics, intensity: maxIntensity)
      );

  // targetBpm = [((female: 226| male: 200) - age - restBpm) x intensity% \ 100] + restBpm
  int? _targetBpm(
          {required ({Gender? gender, int? age, int? restBpm})? biometrics,
          required int? intensity}) =>
      biometrics?.gender != null &&
              biometrics?.age != null &&
              biometrics?.restBpm != null &&
              intensity != null
          ? (((biometrics!.gender!.heartRateCoeff -
                          biometrics.age! -
                          biometrics.restBpm!) *
                      intensity /
                      100) +
                  biometrics.restBpm!)
              .round()
          : null;

  @override
  toString() => name;
}

class CrankRevolutionRecordData {
  DateTime timestamp;
  int counter;
  CrankRevolutionRecordData({required this.timestamp, required this.counter});
}