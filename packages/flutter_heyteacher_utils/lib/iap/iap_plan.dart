import 'package:flutter/material.dart';

class IAPPlan {
  String title;
  String offerConditionText;
  List<String> features;
  Widget leading;
  Color color;

  IAPPlan(
      {
      required this.title,
      required this.leading,
      required this.offerConditionText,
      required this.features,
      required this.color});
}
