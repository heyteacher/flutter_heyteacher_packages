import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:logging/logging.dart';
import '../ble_device_helper.dart';

abstract class BleModel {
  final Logger _log = Logger("BleModel");

  List<ScanResult> scanResults = [];

  @protected
  bool inProgess = false;

  @protected
  StreamSubscription<List<ScanResult>>? _scanResultsSubscription;

  Stream<BluetoothAdapterState>? _adapterStateStream;

  BluetoothAdapterState? bluetoothAdapterState;

  @protected
  Future<void> retrieveUserDevices([VoidCallback? callback]);

  init([VoidCallback? callback]) async {
    if (await FlutterBluePlus.isSupported == false) {
      _log.fine("init: Bluetooth not supported by this device");
      return;
    }
    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    if (_adapterStateStream == null) {
      _log.fine("init: listen ble adapter state");
      _adapterStateStream ??= FlutterBluePlus.adapterState;
      _adapterStateStream!.listen(
          (BluetoothAdapterState bluetoothAdapterState) =>
              this.bluetoothAdapterState = bluetoothAdapterState);
      callback?.call();
    }

    retrieveUserDevices(callback);
    _log.fine("init: listen scan results");
    _scanResultsSubscription ??= FlutterBluePlus.scanResults.listen((results) {
      scanResults = results;
      callback?.call();
    });
  }

  void dispose() {
    _log.fine("dispose");
    close();
  }

  void turnOn([VoidCallback? callback]) async {
    try {
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
        callback?.call();
      }
    } catch (e, s) {
      _log.severe("turnOn: error", e, s);
    }
  }

  void close() {
    _log.fine("close: cancel subscriptions and close stream controllers");
    closeDevices();

    _scanResultsSubscription?.cancel();
    _scanResultsSubscription = null;
  }

  @protected
  void closeDevices();

  Future startScan([VoidCallback? callback]) async {
    _log.fine("startScan");
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    callback?.call();
    // invoke callback when stop stanning
    FlutterBluePlus.isScanning
        .listen((bool isScanning) => !isScanning ? callback?.call() : null);
  }

  Future stopScan([VoidCallback? callback]) async {
    _log.fine("stopScan");
    await FlutterBluePlus.stopScan();
    callback?.call();
  }

  void disconnect(BluetoothDevice? device,
      {isToUpdateUserDevices = false, VoidCallback? callback}) async {
    if (device == null || device.isDisconnected) {
      _log.fine("disconnect: already disconnected ${device?.remoteId.str}");
      return;
    }
    // stop listening an update user store
    disconnectDevice(device, isToUpdateUserDevices);
    _log.fine("disconnect: ${device.remoteId.str}");
    device.disconnectAndUpdateStream();
    device.isDisconnecting.listen(
      (isDisconnecting) {
        inProgess = isDisconnecting;
        callback?.call();
      },
    );
  }

  @protected
  void disconnectDevice(BluetoothDevice device, bool isToUpdateUserDevices);

  Future<void> connect(BluetoothDevice device, {bool autoConnect =false, VoidCallback? callback}) async {
    try {
      _log.fine("connect: ${device.remoteId.str} connecting...");
      await device.connectAndUpdateStream();

      device.isConnecting.listen((connecting) {
        inProgess = connecting;
        if (!connecting) {
         _log.fine("connect: ${device.remoteId.str} connected!");
          connectDevice(device, callback);
        }
      });
    } catch (e, s) {
      _log.fine("connect: device not found ${device.remoteId.str}", e, s);
    }
  }

  @protected
  stopListening(BluetoothCharacteristic? characteristic,
      StreamController<Map<String, dynamic>> streamController,
      {isToUpdateUserDevices = false}) {
    characteristic?.setNotifyValue(false);
    streamController.sink.add({"name": "", "id": null, "connected": false});
    if (isToUpdateUserDevices) updateUserDevices();
  }

  void connectDevice(BluetoothDevice device, [VoidCallback? callback]) async {
    _log.fine("connectDevice: connecting ${device.remoteId.str}");
    Iterable<BluetoothService> services = await device.discoverServices();
    _log.fine("services discovered ${services.map((e) => e.uuid.str)}");
    services =
        services.where((BluetoothService service) => serviceAllowed(service));
    // no allowed service, disconnect device
    if (services.isEmpty) {
      _log.fine(
          "connectDevice: no service allowed, disconnect ${device.remoteId.str}");
      device.disconnect();
    } else {
      // allowed services found, check caratteristics
      for (BluetoothService service in services) {
        BluetoothCharacteristic? characteristic = service.characteristics
            .where((characteristic) => characteristicAllowed(characteristic))
            .firstOrNull;
        // no allowed characteristic, disconnect device
        if (characteristic == null) {
          _log.fine(
              "connectDevice: no characteristic allowed, disconnect ${device.remoteId.str}");
          device.disconnect();
          // heart rate caratteristic found, listen it
        } else {
          startListeningDevices(characteristic, device);
        }
      }
    }
    updateUserDevices();
    inProgess = false;
    callback?.call();
  }

  @protected
  startListening(BluetoothCharacteristic characteristic,
      StreamController<Map<String, dynamic>> streamController,
      {required String? userDeviceName,
      required String? userDeviceId,
      required BluetoothDevice device,
      required void Function(dynamic event) onData}) {
    _log.fine(
        "startListening: start stream device ${device.remoteId.str} characteristic ${characteristic.uuid}");
    characteristic.setNotifyValue(true);
    characteristic.lastValueStream.listen(onData);
    streamController.sink.add({
      "name": userDeviceName ?? device.platformName,
      "id": userDeviceId ?? device.remoteId.str,
      "connected": true
    });
  }

  void startListeningDevices(
      BluetoothCharacteristic characteristic, BluetoothDevice device);

  void updateUserDevices();

  bool serviceAllowed(BluetoothService service);

  bool characteristicAllowed(BluetoothCharacteristic characteristic);
}
