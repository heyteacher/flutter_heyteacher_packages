import 'dart:io';

import 'package:flutter/foundation.dart';

final class PlatformHelper {

  static final bool isMobile =
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static final bool isNotMobile =
      kIsWeb || (!Platform.isAndroid && !Platform.isIOS);

  static final bool isWeb = kIsWeb;

  // static class, avoid costructor
  PlatformHelper._();
}
