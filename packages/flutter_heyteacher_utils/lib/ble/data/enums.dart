import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

enum BleType {
  heartRate(
      icon: FontAwesomeIcons.heartPulse,
      firestoreFieldId: "heartRateDeviceId",
      firestoreFieldName: "heartRateDeviceName"),
  cadence(
      icon: Icons.change_circle,
      firestoreFieldId: "cadenceDeviceId",
      firestoreFieldName: "cadenceDeviceName");

  const BleType(
      {required this.icon,
      required this.firestoreFieldId,
      required this.firestoreFieldName});
  final IconData icon;
  final String firestoreFieldId;
  final String firestoreFieldName;
}

enum BleField { id, name }
