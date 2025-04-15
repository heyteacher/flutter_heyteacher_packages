import 'ble_utils.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

final Map<DeviceIdentifier, StreamControllerReemit<bool>>
    _connectingStreamControllers = {};
final Map<DeviceIdentifier, StreamControllerReemit<bool>>
    _disconnectingStreamControllers = {};

/// connect & disconnect + update stream
extension BluetoothDeviceHelper on BluetoothDevice {
  // convenience
  StreamControllerReemit<bool> get _connectingStream {
    _connectingStreamControllers[remoteId] ??=
        StreamControllerReemit(initialValue: false);
    return _connectingStreamControllers[remoteId]!;
  }

  // convenience
  StreamControllerReemit<bool> get _disconnectingStream {
    _disconnectingStreamControllers[remoteId] ??=
        StreamControllerReemit(initialValue: false);
    return _disconnectingStreamControllers[remoteId]!;
  }

  // get stream
  Stream<bool> get isConnecting {
    return _connectingStream.stream;
  }

  // get stream
  Stream<bool> get isDisconnecting {
    return _disconnectingStream.stream;
  }

  // connect & update stream
  Future<void> connectAndUpdateStream({autoConnect = false}) async {
    _connectingStream.add(true);
    try {
      await connect(autoConnect: autoConnect, mtu: null);
    } finally {
      _connectingStream.add(false);
    }
  }

  // disconnect & update stream
  Future<void> disconnectAndUpdateStream({bool queue = true}) async {
    _disconnectingStream.add(true);
    try {
      await disconnect(queue: queue);
    } finally {
      _disconnectingStream.add(false);
    }
  }
}
