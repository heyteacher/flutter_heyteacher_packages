import 'dart:io';

import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model.dart';
import 'package:flutter_heyteacher_utils/ble/model/ble_model_factory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_heyteacher_utils/ble/model/heart_rate_ble_model.dart';
import 'package:flutter_heyteacher_utils/formats.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:logging/logging.dart';
import 'package:flutter_heyteacher_utils/ble/view/ble_scan_result_tile.dart';

class BLEScreen extends StatelessWidget {
  const BLEScreen({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<BluetoothAdapterState>(
      stream: FlutterBluePlus.adapterState,
      initialData: FlutterBluePlus.adapterStateNow,
      builder: (context, snapshot) => switch (snapshot.data) {
            BluetoothAdapterState.on => BleOnView(),
            _ => BleStatusView(snapshot.data)
          });
}

class BleOnView extends StatefulWidget {
  const BleOnView({super.key});

  @override
  State<BleOnView> createState() => _BleOnViewState();
}

class _BleOnViewState extends State<BleOnView> {
  final Logger _log = Logger("BleOnView");

  void _refresh() => mounted ? setState(() {}) : null;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 100.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      for (BleType bleType in BleType.values)
                        if (bleType == BleType.heartRate)
                          Card(
                            child: HeartRateDeviceConnectedListTile(
                              heartRateBleModel:
                                  BleModelFactory.instance(bleType: bleType)
                                      as HeartRateBleModel,
                            ),
                          )
                        else
                          Card(
                            child: BleDeviceConnectedListTile(
                              bleModel: BleModelFactory.instance(bleType: bleType),
                            ),
                          ),
                      ..._buildScanResultTiles(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (BleType bleType in BleType.values)
                StreamBuilder<({bool connected, String? id, String? name})>(
                    stream: BleModelFactory.instance(bleType: bleType)
                        .deviceStatusStream,
                    builder: (context, snapshot) {
                      return !(snapshot.data?.connected ?? false)
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 80,
                                width: 80,
                                child: _buildStartStopScanButton(context,
                                    bleType: bleType,
                                    deviceStatusData: snapshot.data),
                              ),
                            )
                          : SizedBox.shrink();
                    }),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
        // bottomNavigationBar: BottomAppBar(
        //   shape: const CircularNotchedRectangle(),
        //   child: Container(height: 80.0),
        // ),
      );

  Widget _buildStartStopScanButton(BuildContext context,
          {required BleType bleType,
          ({bool connected, String? id, String? name})? deviceStatusData}) =>
      bleType != BleModelFactory.scanningBleType
          // inkWell manage onTap over the child
          ? FloatingActionButton(
              // heroTag must be set unique in app for each FloatingActionButton to avoid warning introduce by go_router
              heroTag: "bleStartScan${bleType.name}HT",
              // when is scanning for another ble type or already set, disable button
              onPressed: BleModelFactory.scanningBleType == null &&
                      !(deviceStatusData?.connected ?? false)
                  ? () => BleModelFactory.startScan(
                      bleType: bleType, callback: _refresh)
                  : null,
              // when is scanning for another ble type, disable button disable
              backgroundColor: BleModelFactory.scanningBleType == null &&
                      !(deviceStatusData?.connected ?? false)
                  ? bleType.color
                  : bleType.color.withValues(alpha: 0.5),
              child: Icon(
                bleType.icon,
                size: 80,
              ),
            )
          : InkWell(
              child: ProgressIndicatorView(),
              onTap: () => BleModelFactory.stopScan(_refresh));

  List<Widget> _buildScanResultTiles(BuildContext context) =>
      BleModelFactory.scanResults
          .where((e) => e.advertisementData.connectable)
          .map((ScanResult scanResult) => BLEScanResultTile(
              result: scanResult,
              onConnect: () async {
                try {
                  await BleModelFactory.connect(device: scanResult.device);
                } catch (e, s) {
                  _log.severe("_buildScanResultTiles: unknow error", e, s);
                  if (context.mounted) {
                    showSnackBar(context: context, message: e.toString());
                  }
                }
              }))
          .toList();
}

class BleStatusView extends StatelessWidget {
  final BluetoothAdapterState? bluetoothAdapterState;
  BleStatusView(this.bluetoothAdapterState, {super.key}) {
    // try to turn on device bluetooth
    if (bluetoothAdapterState == BluetoothAdapterState.off) {
      BleModelFactory.turnOn();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                switch (bluetoothAdapterState) {
                  BluetoothAdapterState.on => Icons.bluetooth,
                  BluetoothAdapterState.turningOn => Icons.bluetooth,
                  _ => Icons.bluetooth_disabled
                },
                size: 200.0,
                color: switch (bluetoothAdapterState) {
                  BluetoothAdapterState.on =>
                    ThemeHepler.instance().blueTextColor,
                  BluetoothAdapterState.turningOn =>
                    ThemeHepler.instance().blueTextColor,
                  _ => Theme.of(context).colorScheme.onError
                },
              ),
              Text(
                style: TextStyle(
                    fontSize: Theme.of(context).textTheme.bodyLarge!.fontSize),
                "${FlutterHeyteacherUtilsLocalizations.of(context)!.bluetoothAdapterStateIs} "
                "${FlutterHeyteacherUtilsLocalizations.of(context)!.bluetoothAdapterState(bluetoothAdapterState?.name ?? BluetoothAdapterState.unknown.name)}",
              ),
              if (Platform.isAndroid &&
                  bluetoothAdapterState == BluetoothAdapterState.off)
                Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Switch(
                        value: false,
                        onChanged: (bool value) => BleModelFactory.turnOn())),
            ],
          ),
        ),
      );
}

class HeartRateDeviceConnectedListTile extends StatefulWidget {
  final HeartRateBleModel heartRateBleModel;
  const HeartRateDeviceConnectedListTile(
      {super.key, required this.heartRateBleModel});

  @override
  State<HeartRateDeviceConnectedListTile> createState() =>
      _HeartRateDeviceConnectedListTileState();
}

class _HeartRateDeviceConnectedListTileState
    extends State<HeartRateDeviceConnectedListTile> {
  Gender? gender;
  DateTime? birthDate;
  int? restBpm;
  Iterable<({HRTrainingZone hrTrainingZone, num? min, num? max})>?
      _hrTrainingZones;

  @override
  void initState() {
    super.initState();
    widget.heartRateBleModel.init(_initBiometrics);
  }

  void _initBiometrics() async {
    Biometrics? biometrics = BleModel.biometrics;
    gender = biometrics?.gender;
    birthDate = biometrics?.birthDate;
    restBpm = biometrics?.restBpm;
    _hrTrainingZones = widget.heartRateBleModel.hrTrainingZones;
    if (mounted) setState(() {});
  }

  void _updateBiometrics([VoidCallback? preUpdateCallback]) {
    if (preUpdateCallback != null) preUpdateCallback();
    // update biometrics only when all 3 parameters are not null
    if (gender != null && birthDate != null && restBpm != null) {
      widget.heartRateBleModel.updateBiometrics(
          newBiometrics: Biometrics(
              gender: gender!, birthDate: birthDate!, restBpm: restBpm!));

      _hrTrainingZones = widget.heartRateBleModel.hrTrainingZones;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          BleDeviceConnectedListTile(bleModel: widget.heartRateBleModel),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Row(
              spacing: 2.0,
              children: [
                GenericsDropDownMenu<Gender>(
                    label:
                        FlutterHeyteacherUtilsLocalizations.of(context)!.gender,
                    onSelected: (value) =>
                        _updateBiometrics(() => gender = value),
                    values: Gender.values
                        .map((gender) => (
                              value: gender,
                              label: FlutterHeyteacherUtilsLocalizations.of(
                                      context)!
                                  .genderValue(gender.name)
                            ))
                        .toList(),
                    initialSelection: gender),
                Expanded(
                  child: TextField(
                      onTap: () async {
                        final newBirthDate = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1935),
                            lastDate: DateTime(2015),
                            currentDate: birthDate ?? DateTime(1975));
                        if (newBirthDate != null) {
                          _updateBiometrics(() => birthDate = newBirthDate);
                        }
                      },
                      style: Theme.of(context).textTheme.labelSmall,
                      readOnly: true,
                      decoration: InputDecoration(
                          isDense: true,
                          constraints:
                              BoxConstraints.tight(const Size.fromHeight(35)),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.onSurface),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          labelStyle: Theme.of(context).textTheme.labelSmall,
                          labelText: birthDate != null ? "Birth Date" : ""),
                      controller: TextEditingController(
                          text: birthDate != null
                              ? dateFormatter.format(birthDate!)
                              : "Birth Date")),
                ),
                GenericsDropDownMenu<int>(
                    label: FlutterHeyteacherUtilsLocalizations.of(context)!
                        .restBpm,
                    onSelected: (value) =>
                        _updateBiometrics(() => restBpm = value),
                    values: [
                      for (int i = 40; i <= 100; i++)
                        (value: i, label: i.toString())
                    ],
                    initialSelection: restBpm),
              ],
            ),
          ),
          if (_hrTrainingZones != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              child: Row(children: [
                Expanded(
                    child: Text(
                        style: TextStyle(fontWeight: FontWeight.bold),
                        FlutterHeyteacherUtilsLocalizations.of(context)!
                            .trainingZone)),
                Expanded(
                    child: Center(
                        child: Text(
                            style: TextStyle(fontWeight: FontWeight.bold),
                            FlutterHeyteacherUtilsLocalizations.of(context)!
                                .minBpm))),
                Expanded(
                    child: Center(
                        child: Text(
                            style: TextStyle(fontWeight: FontWeight.bold),
                            FlutterHeyteacherUtilsLocalizations.of(context)!
                                .maxBpm))),
              ]),
            ),
          for (({HRTrainingZone hrTrainingZone, num? min, num? max}) zone
              in _hrTrainingZones ?? [])
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                          style: TextStyle(color: zone.hrTrainingZone.color),
                          FlutterHeyteacherUtilsLocalizations.of(context)!
                              .trainingZoneValue(zone.hrTrainingZone.name))),
                  Expanded(
                      child: Center(
                          child: Text(
                              style:
                                  TextStyle(color: zone.hrTrainingZone.color),
                              "${zone.hrTrainingZone.minIntensity}%: ${zone.min}"))),
                  Expanded(
                      child: Center(
                          child: Text(
                              style:
                                  TextStyle(color: zone.hrTrainingZone.color),
                              zone.hrTrainingZone != HRTrainingZone.z6
                                  ? "${zone.hrTrainingZone.maxIntensity}%: ${zone.max}"
                                  : ""))),
                ],
              ),
            )
        ],
      );
}

class GenericsDropDownMenu<T> extends StatelessWidget {
  final String label;
  final void Function(T? value) onSelected;
  final List<({T value, String label})> values;
  final T? initialSelection;

  const GenericsDropDownMenu({
    required this.label,
    required this.onSelected,
    required this.values,
    this.initialSelection,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DropdownMenu<T?>(
        enableSearch: false,
        label: Text(label, style: Theme.of(context).textTheme.labelSmall),
        textStyle: Theme.of(context).textTheme.labelSmall,
        initialSelection: initialSelection,
        trailingIcon: const Icon(Icons.filter_list),
        onSelected: onSelected,
        dropdownMenuEntries: [
          DropdownMenuEntry<T?>(value: null, label: ""),
          ...values.map((record) =>
              DropdownMenuEntry<T?>(value: record.value, label: record.label))
        ],
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          constraints: BoxConstraints.tight(const Size.fromHeight(35)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class BleDeviceConnectedListTile extends StatefulWidget {
  final BleModel bleModel;
  final bool disableDisconnect;
  const BleDeviceConnectedListTile(
      {super.key, required this.bleModel, this.disableDisconnect = false});

  @override
  State<BleDeviceConnectedListTile> createState() =>
      _BleDeviceConnectedListTileState();
}

class _BleDeviceConnectedListTileState
    extends State<BleDeviceConnectedListTile> {
  void _refresh() => mounted ? setState(() {}) : null;

  @override
  void initState() {
    super.initState();
    widget.bleModel.init(_refresh);
  }

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<({String? id, String? name, bool connected})>(
          stream: widget.bleModel.deviceStatusStream,
          initialData: (
            id: widget.bleModel.deviceId ?? "",
            name: widget.bleModel.deviceName ?? "",
            connected: widget.bleModel.connected
          ),
          builder: (context, deviceStatusSnapshot) => ListTile(
              leading: _buildLeading(
                  context: context,
                  deviceStatusData: deviceStatusSnapshot.data),
              title: _buildTitle(
                  context: context,
                  deviceStatusData: deviceStatusSnapshot.data),
              subtitle:
                  _buildSubtitle(deviceStatusData: deviceStatusSnapshot.data),
              trailing: _buildTrailing(
                  context: context,
                  deviceStatusData: deviceStatusSnapshot.data)));

  FaIcon _buildLeading(
          {required BuildContext context,
          required ({
            bool connected,
            String? id,
            String? name
          })? deviceStatusData}) =>
      FaIcon(widget.bleModel.bleType.icon,
          color: deviceStatusData?.connected ?? false
              ? widget.bleModel.bleType.color
              : widget.bleModel.bleType.color.withValues(alpha: 0.5));

  Text _buildTitle(
          {required BuildContext context,
          required ({
            bool connected,
            String? id,
            String? name
          })? deviceStatusData}) =>
      Text(
        deviceStatusData?.name ??
            FlutterHeyteacherUtilsLocalizations.of(context)!
                .bleTypeDevice(widget.bleModel.bleType.name),
        style: TextStyle(
            color: deviceStatusData?.connected ?? false
                ? Theme.of(context).iconTheme.color
                : Theme.of(context).disabledColor),
        overflow: TextOverflow.ellipsis,
      );

  Widget _buildSubtitle(
          {required ({
            bool connected,
            String? id,
            String? name
          })? deviceStatusData}) =>
      StreamBuilder<Object?>(
          stream: widget.bleModel.stream,
          builder: (context, snapshot) => Text(
                "${snapshot.data ?? deviceStatusData?.id ?? ""}",
                style: TextStyle(
                    color: deviceStatusData?.connected ?? false
                        ? Theme.of(context).iconTheme.color
                        : Theme.of(context).disabledColor),
              ));

  Widget _buildTrailing(
          {required BuildContext context,
          required ({
            bool connected,
            String? id,
            String? name
          })? deviceStatusData}) =>
      (deviceStatusData?.connected ?? false)
          ? !widget.disableDisconnect
              ? IconButton(
                  icon: Icon(Icons.link_off),
                  color: Theme.of(context).colorScheme.onError,
                  onPressed: () {
                    widget.bleModel
                        .disconnect(isToStore: true, callback: _refresh);
                  })
              : IconButton(
                  icon: Icon(Icons.link),
                  color: ThemeHepler.instance().greenTextColor,
                  onPressed: () => {})
          : IconButton(
              icon: Icon(Icons.link),
              color: Theme.of(context).iconTheme.color,
              onPressed: (deviceStatusData?.id?.isNotEmpty ??
                      false) // device i set but disconnected, try to reconnect
                  ? () => widget.bleModel.reconnect(callback: _refresh)
                  // device isn't set, disable reconnect button
                  : null);
}
