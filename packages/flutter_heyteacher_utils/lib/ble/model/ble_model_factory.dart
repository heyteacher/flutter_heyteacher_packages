import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model.dart';
import 'package:flutter_heyteacher_utils/ble/model/cadence_ble_model.dart';
import 'package:flutter_heyteacher_utils/ble/model/cycling_power_ble_model.dart';
import 'package:flutter_heyteacher_utils/ble/model/heart_rate_ble_model.dart';
import 'package:flutter_heyteacher_utils/ble/ble_device_helper.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class BleModelFactory {
  static final Logger _log = Logger("BleModel");

  static const String streamKey = "value";

  static List<ScanResult> scanResults = [];

  static StreamSubscription<List<ScanResult>>? _scanResultsSubscription;

  static StreamSubscription<bool>? _isScanningSubscription;

  static StreamSubscription<String>? _logStreamSubscription;

  static BleType? scanningBleType;

  static final Map<BleType, BluetoothDevice?> _connectingDevices = {};

  // block instantiation
  BleModelFactory._();

  static BleModel instance({required BleType bleType}) {
    switch (bleType) {
      case BleType.cadence:
        return CadenceBleModel.instance;
      case BleType.heartRate:
        return HeartRateBleModel.instance;
      case BleType.cyclingPower:
        return CyclingPowerBleModel.instance;
    }
  }

  static Iterable<BleModel> get bleModels => BleType.values
      .map((bleType) => BleModelFactory.instance(bleType: bleType));

  static Future<BleType?> detectBleType(BluetoothDevice? device) async {
    await device?.connectAndUpdateStream();
    await device?.discoverServices();
    return BleType.values
        .where((bleType) =>
            device?.servicesList.any((service) =>
                (serviceAllowedByType(bleType, service)) &&
                (service.characteristics.any((characteristic) =>
                    characteristicAllowedByType(bleType, characteristic)))) ??
            false)
        .firstOrNull;
  }

  static Future<void> connect({required BluetoothDevice device}) async {
    BleType? bleType = await detectBleType(device);
    if (bleType != null) {
      instance(bleType: bleType).connect(device: device);
    } else {
      throw Exception(
          "ble type not detected between ${BleType.values.map((bleType) => bleType.name)}");
    }
  }

  static Future<void> turnOn({VoidCallback? callback}) async {
    _log.fine("turnOn: if android try to turn on Ble");
    try {
      if (Platform.isAndroid &&
          FlutterBluePlus.adapterStateNow != BluetoothAdapterState.on) {
        _log.fine("turnOn: android bluetooth isn't on, turn on");
        await FlutterBluePlus.turnOn();
        callback?.call();
      }
    } catch (e, s) {
      _log.severe("turnOn: error", e, s);
    }
  }

  static Future startScan(
      {required BleType bleType, VoidCallback? callback}) async {
    _log.fine("startScan");
    scanningBleType = bleType;
    await FlutterBluePlus.startScan(
        timeout: Duration(
            seconds:
                FirebaseRemoteConfig.instance.getInt("bleScanTimeoutSeconds")),
        withServices: [_serviceGuid(bleType)]);
    // invoke callback when stop scanning
    _isScanningSubscription ??=
        FlutterBluePlus.isScanning.listen((bool isScanning) {
      if (!isScanning) {
        scanningBleType = null;
        callback?.call();
      }
    });
    _log.fine("startScan: listen scan results");
    _scanResultsSubscription?.cancel();
    _connectingDevices[bleType] = null;
    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) async {
      scanResults = results;
      // found one device and no device of bleType is already connecting, autoconnect
      if (scanResults.length == 1 && _connectingDevices[bleType] == null) {
        _log.fine(
            "found one ${scanningBleType!.name} device, connect to ${scanResults.first.device.remoteId.str}");
        _connectingDevices[bleType] = results.first.device;
        await BleModelFactory.instance(bleType: scanningBleType!).connect(
            device: results.first.device,
            autoConnect: true,
            callback: callback);
      } else if (results.length > 1) {
        _log.fine(
            "scanningBleType $scanningBleType found ${scanResults.length} devices");
        callback?.call();
      }
    });
    callback?.call();
  }

  static Future stopScan([VoidCallback? callback]) async {
    _log.fine("stopScan");
    scanningBleType = null;
    await FlutterBluePlus.stopScan();
    callback?.call();
  }

  static Future<void> initBle([VoidCallback? callback]) async {
    // if your terminal doesn't support color you'll see annoying logs like `\x1B[1;35m`
    FlutterBluePlus.setLogLevel(LogLevel.error, color: false);
    _logStreamSubscription ??=
        FlutterBluePlus.logs.listen((message) => _log.severe("fbp: $message"));
    // check if bluetooth is supported
    if (await FlutterBluePlus.isSupported == false) {
      _log.fine("initBle: Bluetooth not supported by this device");
      return;
    }
  }

  static Guid _serviceGuid(BleType bleType) => Guid(bleType.uuidService);

  static bool serviceAllowedByType(BleType type, BluetoothService service) {
    return service.uuid == _serviceGuid(type);
  }

  static Guid _characteristicGuid(BleType bleType) =>
      Guid(bleType.uuidCharacteristic);

  static bool characteristicAllowedByType(
          BleType bleType, BluetoothCharacteristic characteristic) =>
      characteristic.uuid == _characteristicGuid(bleType);
}
