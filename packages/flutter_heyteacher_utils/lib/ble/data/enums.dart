import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

enum BleType {
  heartRate(
      icon: FontAwesomeIcons.heartPulse,
      firestoreFieldId: "heart_rate_device_id",
      firestoreFieldName: "heart_rate_device_name"),
  cadence(
      icon: Icons.change_circle,
      firestoreFieldId: "cadence_device_id",
      firestoreFieldName: "cadence_device_name");

  const BleType(
      {required this.icon,
      required this.firestoreFieldId,
      required this.firestoreFieldName});
  final IconData icon;
  final String firestoreFieldId;
  final String firestoreFieldName;
}

enum BleField { id, name }
