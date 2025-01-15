// somewhere else in your project
import 'package:flutter/material.dart';

class ContextHelper {
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static BuildContext? get context =>
      scaffoldMessengerKey.currentContext!;

  ContextHelper._();
}
