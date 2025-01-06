import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

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

enum BleField { id, name }
