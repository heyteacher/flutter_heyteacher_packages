import 'dart:async';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:logging/logging.dart';

class BackgroundService {
  static final _log = Logger("BackgroundService");

  static final List<Stream> _streams = [];
  static final List<void Function(dynamic)> _onDataFunctions = [];
  static final List<StreamSubscription?> _subscriptions = [];

  static Future<void> configure() async {
    _log.fine("configure");
    final service = FlutterBackgroundService();
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: _onStart,
        isForegroundMode: true,
        autoStartOnBoot: false,
      ),
    );
  }

  static void addListener(
      {required Stream stream, required void Function(dynamic) onData}) {
    _streams.add(stream);
    _onDataFunctions.add(onData);
  }

  static void start() {
    _log.fine("start");
    final service = FlutterBackgroundService();
    service.startService();
  }

  static void stop() {
    _log.fine("stop");
    final service = FlutterBackgroundService();
    service.invoke("stop");
    for (var i = 0; i < _subscriptions.length; i++) {
      _subscriptions[i]?.cancel();
    }
  }

  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    _log.fine("_onStart");
    for (var i = 0; i < _streams.length; i++) {
      _log.fine("_onStart: start listening ${_onDataFunctions[i]}");
      _subscriptions[i]?.cancel();
      //_subscriptions[i] = _streams[i].listen(_onDataFunctions[i]);
    _subscriptions[i] = _streams[i].listen((data) => _log.fine("listen($data)"));
    }
  }
}
