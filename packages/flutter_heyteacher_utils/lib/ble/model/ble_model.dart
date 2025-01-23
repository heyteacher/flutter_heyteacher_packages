import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model_factory.dart';
import 'package:flutter_heyteacher_utils/ble/store/ble_user_store.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/store.dart';
import 'package:logging/logging.dart';
import 'package:flutter_heyteacher_utils/ble/ble_device_helper.dart';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';

abstract class BleModel {
  static final Logger _log = Logger("BleModel");

  BleType bleType;

  @protected
  static BleUserData? userData;

  BluetoothDevice? _device;

  StreamSubscription<bool>? _isDisconnectingStreamSubscription;

  bool get notConnected => !connected;

  bool get connected => _device?.isConnected ?? false;

  String? get deviceName => _device?.platformName.trim() != ""
      ? _device?.platformName
      : userData?.devices?[bleType]?.name;

  String? get deviceId =>
      _device?.remoteId.str ?? userData?.devices?[bleType]?.id;

  @protected
  final StreamController<num?> streamController = StreamController<num?>.broadcast();

  Stream<num?> get stream => streamController.stream;

  final StreamController<({String? id, String? name, bool connected})>
      _deviceStatusStreamController = StreamController<
          ({String? id, String? name, bool connected})>.broadcast();

  Stream<({String? id, String? name, bool connected})> get deviceStatusStream =>
      _deviceStatusStreamController.stream;

  @protected
  BleModel(this.bleType);

  // abstract
  @protected
  void onInit();

  // abstract
  @protected
  void onData(List<int> event);

  void dispose() {
    _log.fine("dispose: ${bleType.name}");
    close();
  }

  void close() {
    _log.fine(
        "close:  ${bleType.name} cancel subscriptions and close stream controllers");
    disconnect(isToStore: false);
    // _logStreamSubscription?.cancel();
    // _logStreamSubscription = null;
    // _isScanningSubscription?.cancel();
    // _isScanningSubscription = null;
    _isDisconnectingStreamSubscription?.cancel();
    _isDisconnectingStreamSubscription = null;
    // _bleAdaptreStreamSubscription?.cancel();
    // _bleAdaptreStreamSubscription = null;
    // _scanResultsSubscription?.cancel();
    // _scanResultsSubscription = null;
  }

  Future<void> init([VoidCallback? callback]) async {
    BleModelFactory.initBle(callback);
    try {
      userData ??= Auth.instance().autenticated
          ? await BleUserStore.instance().get(Auth.instance().uid!)
          : null;
    } on DocumentNotFoundException {
      _log.fine("user data not found in store");
    }
    ({String? id, String? name})? userDevice =
        userData?.devices?[bleType];
    _log.fine("init: ${bleType.name} remote user devices $userDevice");

    if (userDevice?.id?.trim() != "") {
      _deviceStatusStreamController.sink.add((
        id: userDevice?.id,
        name: userDevice?.name,
        connected: _device?.isConnected ?? false
      ));
      callback?.call();
      if (userDevice != null) {
        _log.fine("init: ${bleType.name} try auto connection to device");
        _device = BluetoothDevice.fromId(userDevice.id!);
        if (_device!.isDisconnected) {
          _log.fine("init:  ${bleType.name} connect(autoConnect: true)");
          connect(device: _device!, autoConnect: true, callback: callback);
        }
      }
    }
    callback?.call();
  }

  Future<void> connect(
      {required BluetoothDevice device,
      bool autoConnect = false,
      VoidCallback? callback}) async {
    try {
      _log.fine(
          "connect: ${bleType.name} ${device.remoteId.str} connecting...");
      device.connectAndUpdateStream(autoConnect: autoConnect);
      // autoconnect
      if (autoConnect) {
        _log.fine(
            "connect: ${bleType.name} ${device.remoteId.str} autoConnect true, wait device...");
        await device.connectionState
            .where((bluetoothConnectionState) =>
                bluetoothConnectionState == BluetoothConnectionState.connected)
            .first;
        // manual connecting, stop scan whe connecting and reset results
      } else {
        BleModelFactory.scanResults = [];
        BleModelFactory.stopScan(callback);
      }
      StreamSubscription<bool> isConnectingStreamSubscription =
          device.isConnecting.listen((connecting) async {
        _log.fine(
            "connect: ${bleType.name} ${device.remoteId.str} connecting $connecting");
        if (!connecting) {
          _log.fine(
              "connect: ${bleType.name} ${device.remoteId.str} connected");
          _connectDevice(device, callback: callback);
        }
      });
      device.cancelWhenDisconnected(isConnectingStreamSubscription);
    } catch (e, s) {
      _log.fine(
          "connect: ${bleType.name} device not found ${_device?.remoteId.str}",
          e,
          s);
    }
  }

  void reconnect({VoidCallback? callback}) {
    if (_device == null) {
      throw Exception("${bleType.name} try to connect to a null device");
    }
    _log.fine(
        "reconnect:  ${bleType.name} ${_device!.remoteId.str} try to reconnect");
    connect(device: _device!, autoConnect: true, callback: callback);
  }

  void disconnect({isToStore = false, VoidCallback? callback}) async {
    if (_device == null || _device!.isDisconnected) {
      _log.fine(
          "disconnect: ${bleType.name} ${_device?.remoteId.str} already disconnected ");
      return;
    }
    _log.fine("disconnect: $deviceId disconnecting...");
    _device?.disconnectAndUpdateStream();
    _isDisconnectingStreamSubscription ??= _device!.isDisconnecting.listen(
      (disconnecting) {
        _log.fine(
            "connect: ${bleType.name} $deviceId connecting $disconnecting");
        if (!disconnecting) {
          _log.fine("disconnect: ${bleType.name} $deviceId disconnected");
          // stop listening an update user store
          //_characteristic.setNotifyValue(false);
          // notify disconnection
          _deviceStatusStreamController.sink
              .add((name: "", id: null, connected: false));
          // reset last stream value
          streamController.sink.add(null);

          // persist disconnection
          _device = null;
          if (isToStore) _store();
          callback?.call();
        }
      },
    );
  }

  bool _serviceAllowed(BluetoothService service) =>
      BleModelFactory.serviceAllowedByType(bleType, service);

  bool _characteristicAllowed(BluetoothCharacteristic characteristic) =>
      BleModelFactory.characteristicAllowedByType(bleType, characteristic);

  void _store() {
    if (Auth.instance().autenticated) {
      BleUserData userData =
          BleUserData.fromDevices(devices: {bleType: _device});
      _log.fine(
          "_store:  ${bleType.name} persist device ${userData.devices![bleType]}");
      BleUserStore.instance().update(userData, fields: ["devices"]);
    }
  }

  Future<void> _connectDevice(BluetoothDevice device,
      {VoidCallback? callback}) async {
    _log.fine(
        "_connectDevice: ${bleType.name} connecting ${device.remoteId.str}");
    Iterable<BluetoothService>? services = await device.discoverServices();
    services =
        services.where((BluetoothService service) => _serviceAllowed(service));
    // no allowed service, disconnect device
    if (services.isEmpty) {
      _log.fine(
          "_connectDevice: ${bleType.name} no service allowed, disconnect ${device.remoteId.str}");
      device.disconnect();
    } else {
      // allowed services found, check caratteristics
      for (BluetoothService service in services) {
        BluetoothCharacteristic? characteristic = service.characteristics
            .where((characteristic) => _characteristicAllowed(characteristic))
            .firstOrNull;
        // no allowed characteristic, disconnect device
        if (characteristic == null) {
          _log.fine(
              "_connectDevice: ${bleType.name} no characteristic allowed, disconnect ${device.remoteId.str}");
          device.disconnect();
          // heart rate caratteristic found, listen it
        } else {
          // notify listener device connection
          _deviceStatusStreamController.sink.add((
            id: userData?.devices?[bleType]?.id ?? device.remoteId.str,
            name: userData?.devices?[bleType]?.name ?? device.platformName,
            connected: true
          ));
          _device = device;
          BleModelFactory.stopScan();
          BleModelFactory.scanResults = [];
          _store();
          _log.fine(
              "_connectDevice: ${bleType.name} start stream device ${device.remoteId.str} service ${service.uuid} characteristic ${characteristic.uuid}");
          StreamSubscription<List<int>> characteristicStreanSubscription =
              characteristic.lastValueStream.listen((List<int> event) {
            onData(event);
          });
          device.cancelWhenDisconnected(characteristicStreanSubscription);
          characteristic.setNotifyValue(true);
          // invoke callbask
          onInit();
        }
      }
    }
    callback?.call();
  }
}
