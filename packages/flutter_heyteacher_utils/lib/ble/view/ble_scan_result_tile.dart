import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEScanResultTile extends StatefulWidget {
  const BLEScanResultTile(
      {super.key, required this.result, required this.onConnect});

  final ScanResult result;
  final VoidCallback onConnect;

  @override
  State<BLEScanResultTile> createState() => _BLEScanResultTileState();
}

class _BLEScanResultTileState extends State<BLEScanResultTile> {
  BluetoothConnectionState _connectionState =
      BluetoothConnectionState.disconnected;

  late StreamSubscription<BluetoothConnectionState>
      _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription =
        widget.result.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get _connected => _connectionState == BluetoothConnectionState.connected;

  bool get _disconnected => !_connected;

  Widget _buildTitle(BuildContext context) {
    return Text(
      widget.result.device.platformName.isNotEmpty
          ? widget.result.device.platformName
          : widget.result.device.advName.isNotEmpty
              ? widget.result.device.advName
              : widget.result.device.remoteId.str,
      overflow: TextOverflow.ellipsis,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(_connected ? Icons.bluetooth_connected : Icons.bluetooth,       
            color: _connected
                ? Theme.of(context).iconTheme.color
                : Theme.of(context).disabledColor),
        title: _buildTitle(context),
        subtitle: Text(widget.result.device.remoteId.str),
        trailing: _disconnected
            ? Icon(Icons.link)
            : SizedBox.shrink(),
        onTap: !_connected ? widget.onConnect : null,
      ),
    );
  }
}
