import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_heyteacher_utils/e2ee.dart';
import 'package:flutter_heyteacher_utils/store.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BleUserData extends UserData {
  Map<BleType, ({String? id, String? name})>? devices;

  E2EEValue? _biometricsE2EE;

  Future<void> setBiometrics(Biometrics newBiometrics) async => _biometricsE2EE =
          await E2EE.instance.encrypt(jsonEncode(newBiometrics));

  Future<Biometrics?> getBiometrics() async =>  _biometricsE2EE != null
          ? Biometrics.fromJson(
              await E2EE.instance.decrypt(_biometricsE2EE!))
          : null;

  // intensity% = (bpm -restBpm / ( (female: 226| male: 200) - age - restBpm)) * 100
  num? intensity(num? bpm, {required Biometrics? biometrics}) => bpm != null &&
          biometrics != null
      ? ((bpm - biometrics.restBpm) /
              (biometrics.gender.heartRateCoeff -
                  ((DateTime.now()).difference(biometrics.birthDate).inDays /
                          365)
                      .floor() -
                  biometrics.restBpm) *
              100)
          .round()
      : null;

  Iterable<({HRTrainingZone hrTrainingZone, num min, num max})>?
      hrTrainingZones(
              {required DateTime dateTime, required Biometrics? biometrics}) =>
          biometrics != null
              ? HRTrainingZone.values.map((hrTrainingZone) => hrTrainingZone
                  .targetBpm(biometrics: biometrics, dateTime: dateTime)!)
              : null;

  BleUserData._({this.devices, E2EEValue? biometricsE2EE}) : _biometricsE2EE = biometricsE2EE, super();

  BleUserData.fromDevices({Map<BleType, BluetoothDevice?>? devices})
      : this._(
            devices: devices?.map((bleType, device) => MapEntry(bleType, (
                  id: device?.remoteId.str ?? "",
                  name: device?.platformName ?? ""
                ))));

  factory BleUserData.fromFirestore(Map<String, dynamic> map) {
    return BleUserData._(devices: {
      for (BleType bleType in BleType.values)
        bleType: (
          id: map[bleType.firestoreFieldId],
          name: map[bleType.firestoreFieldName],
        ),
    }, biometricsE2EE: map["biometrics"] != null? E2EEValue.fromMap(map["biometrics"]): null);
  }

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) => {
        ...super.toFirestore(fields),
        if (fields?.contains("biometrics") ?? true)
          "biometrics": _biometricsE2EE?.toJson(),
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
      "biometrics: is set ${_biometricsE2EE != null}";
}

enum BleType {
  heartRate(
      icon: FontAwesomeIcons.heartPulse,
      color: Colors.redAccent,
      firestoreFieldId: "heartRateDeviceId",
      firestoreFieldName: "heartRateDeviceName",
      uuidService: "180d",
      uuidCharacteristic: "2a37"),
  cyclingPower(
      icon: Icons.electric_bolt,
      color: Colors.yellowAccent,
      firestoreFieldId: "cyclingPowerDeviceId",
      firestoreFieldName: "cyclingPowerDeviceName",
      uuidService: "1818",
      uuidCharacteristic: "2a63"),
  cadence(
      icon: Icons.change_circle,
      color:Colors.blueAccent,
      firestoreFieldId: "cadenceDeviceId",
      firestoreFieldName: "cadenceDeviceName",
      uuidService: "1816",
      uuidCharacteristic: "2a5b");

  const BleType(
      {required this.icon,
      required this.color,
      required this.firestoreFieldId,
      required this.firestoreFieldName,
      required this.uuidService,
      required this.uuidCharacteristic});
  final IconData icon;
  final Color color;
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

enum HRTrainingZone {
  z0(minIntensity: 0, maxIntensity: 50, color: Colors.white70),
  z1(minIntensity: 50, maxIntensity: 60, color: Colors.cyan),
  z2(minIntensity: 60, maxIntensity: 70, color: Colors.green),
  z3(minIntensity: 70, maxIntensity: 80, color: Colors.yellow),
  z4(minIntensity: 80, maxIntensity: 90, color: Colors.orange),
  z5(minIntensity: 90, maxIntensity: 100, color: Colors.red),
  z6(minIntensity: 100, maxIntensity: 1000, color: Colors.purple);

  final int minIntensity;
  final int maxIntensity;
  final Color color;
  const HRTrainingZone(
      {required this.minIntensity,
      required this.maxIntensity,
      required this.color});

  static HRTrainingZone? fromName(String? name) =>
      HRTrainingZone.values.where((zone) => zone.name == name).firstOrNull;

  static HRTrainingZone? fromBpm(
          {required num? bpm,
          required Biometrics? biometrics,
          required DateTime dateTime}) =>
      biometrics != null && bpm != null && bpm <= (biometrics.restBpm)
          ? HRTrainingZone.z0 // bpm is less then rest PBM, return z0
          : HRTrainingZone.values
              .where((zone) => _between(bpm,
                  zone.targetBpm(biometrics: biometrics, dateTime: dateTime)))
              .firstOrNull;

  ({HRTrainingZone hrTrainingZone, int min, int max})? targetBpm(
          {required Biometrics? biometrics, required DateTime dateTime}) =>
      biometrics != null
          ? (
              hrTrainingZone: this,
              min: _targetBpm(
                      biometrics: biometrics,
                      intensity: minIntensity,
                      dateTime: dateTime) ??
                  0,
              max: _targetBpm(
                      biometrics: biometrics,
                      intensity: maxIntensity,
                      dateTime: dateTime) ??
                  0
            )
          : null;

  // targetBpm = [((female: 226| male: 220) - age - restBpm) x intensity% \ 100] + restBpm
  int? _targetBpm(
          {required Biometrics? biometrics,
          required int? intensity,
          DateTime? dateTime}) =>
      biometrics != null && intensity != null && dateTime != null
          ? (((biometrics.gender.heartRateCoeff -
                          (dateTime.difference(biometrics.birthDate).inDays /
                                  365)
                              .floor() -
                          biometrics.restBpm) *
                      intensity /
                      100) +
                  biometrics.restBpm)
              .round()
          : null;

  @override
  toString() => ContextHelper.context != null
      ? FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)
              ?.trainingZoneValue(name) ??
          name
      : name;

  static bool _between(num? bpm,
          ({HRTrainingZone hrTrainingZone, num? max, num? min})? targetBpm) =>
      (bpm ?? 0) >= (targetBpm?.min ?? 0) && (bpm ?? 0) < (targetBpm?.max ?? 0);
}

class Biometrics {
  int restBpm;
  DateTime birthDate;
  Gender gender;

  Biometrics(
      {required this.gender, required this.birthDate, required this.restBpm});

  factory Biometrics.fromJson(String json) => Biometrics._fromMap(jsonDecode(json)); 

  factory Biometrics._fromMap(Map<String, dynamic> map) => Biometrics(
      restBpm: map["restBpm"] ?? 0,
      birthDate: DateTime.fromMillisecondsSinceEpoch(map["birthDate"] ?? 0),
      gender: Gender.values
              .where((gender) => gender.name == map["gender"])
              .firstOrNull ??
          Gender.other);

  Map<String, dynamic> toJson() => {
        "restBpm": restBpm,
        "birthDate": birthDate.millisecondsSinceEpoch,
        "gender": gender.name
      };
}

class CrankRevolutionRecordData {
  DateTime timestamp;
  int counter;
  CrankRevolutionRecordData({required this.timestamp, required this.counter});
}
