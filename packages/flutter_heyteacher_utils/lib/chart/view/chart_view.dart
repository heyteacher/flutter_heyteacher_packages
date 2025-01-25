import 'dart:math';
import 'package:flutter/material.dart';

abstract class ChartView extends StatelessWidget {
  const ChartView({super.key});

  @protected
  int interval(num minValue, num maxValue, {int multiplier = 5, int occurences = 10}) =>
      max((
        (maxValue - minValue) / occurences // the interval to have <occurrences> in axies 
        / multiplier).round() * multiplier,  // round the value to multiplier
        multiplier); // if inverval is less than multiplier, use multiplier

  @protected
  static int roundToInterval(num value, num interval) =>
      interval != 0 ? ((value/ interval).round() * interval).toInt() : 0;

  @protected
  static int ceilToInterval(num value, num interval) =>
      interval != 0 ? ((value/ interval).ceil() * interval).toInt() : 0;

  @protected
  static int floorToInterval(num value, num interval) =>
      interval != 0 ? ((value/ interval).floor() * interval).toInt() : 0;

}
