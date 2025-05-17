/// Provides utilities for managing background tasks using `android_alarm_manager_plus`.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:logging/logging.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys used for storing Android Alarm Manager related settings in
/// SharedPreferences.
enum AlarmManagerSharedPreferencesKeys {
  /// Indicates whether the alarm manager needs to be initialized.
  toBeInitialized,

  /// The interval in minutes for the Android Alarm Manager.
  androidAlarmManagerIntervalInMinutes,
}

/// Keys used for fetching Android Alarm Manager related configurations from
/// Firebase Remote Config.
enum AlarmManagerRemoteConfigKeys {
  /// The interval in minutes for the Android Alarm Manager, fetched from
  /// Remote Config.
  intervalInMinutes,

  /// The distance filter in meters, potentially used by the alarm callback,
  /// fetched from Remote Config.
  distanceFilterInMeters,
}

/// Defines preset intervals for the Android Alarm Manager.
enum AlarmManagerIntervalKeys {
  /// 1 minute interval.
  oneMinute(1),

  /// 2 minutes interval.
  twoMinutes(2),

  /// 5 minutes interval.
  fiveMinutes(5),

  /// 10 minutes interval.
  tenMinutes(10),

  /// 15 minutes interval.
  fifteenMinutes(15),

  /// 30 minutes interval.
  thirtyMinutes(30);

  /// The duration of the interval in minutes.
  final int minutes;

  /// Creates an [AlarmManagerIntervalKeys] with the given [minutes].
  const AlarmManagerIntervalKeys(this.minutes);
}

/// A StatefulWidget that provides a ListTile with a DropdownMenu
/// to select and persist the interval for the Android Alarm Manager.
class AlarmManagerIntervalListTile extends StatefulWidget {
  final AndroidAlarmManagerModel _androidAlarmManagerModel;
  final String label;

  const AlarmManagerIntervalListTile(this._androidAlarmManagerModel,
      {required this.label, super.key});

  @override
  State<AlarmManagerIntervalListTile> createState() =>
      _AlarmManagerIntervalListTileState();
}

class _AlarmManagerIntervalListTileState
    extends State<AlarmManagerIntervalListTile> {
  /// Builds the ListTile widget with a DropdownMenu for selecting the alarm interval.
  /// When a new interval is selected, it's saved to SharedPreferences and the
  /// [AndroidAlarmManagerModel] is re-initialized.
  @override
  Widget build(context) => ListTile(
      leading: const Icon(Icons.alarm),
      title: Text(widget.label),
      subtitle: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: FutureBuilder<int?>(
          future: SharedPreferencesAsync().getInt(
              AlarmManagerSharedPreferencesKeys
                  .androidAlarmManagerIntervalInMinutes.name),
          builder: (_, futureSnapshot) =>
              Wrap(alignment: WrapAlignment.center, spacing: 2, children: [
            ...AlarmManagerIntervalKeys.values.map(
                (alarmManagerIntervalInMinutes) => ChoiceChip(
                    selected: alarmManagerIntervalInMinutes.minutes ==
                        (futureSnapshot.data ??
                            (!kDebugMode &&
                                    RemoteConfigModel.instance.getInt(
                                            AlarmManagerRemoteConfigKeys
                                                .intervalInMinutes.name) >
                                        0
                                ? RemoteConfigModel.instance.getInt(
                                    AlarmManagerRemoteConfigKeys
                                        .intervalInMinutes.name)
                                : 1)),
                    label:
                        Text(alarmManagerIntervalInMinutes.minutes.toString()),
                    showCheckmark: false,
                    onSelected: (bool selected) => setState(() {
                          selected
                              ? SharedPreferencesAsync()
                                  .setInt(
                                      AlarmManagerSharedPreferencesKeys
                                          .androidAlarmManagerIntervalInMinutes
                                          .name,
                                      alarmManagerIntervalInMinutes.minutes)
                                  .then((_) => widget._androidAlarmManagerModel
                                      .initialize())
                              : null;
                        }))),
          ]),
        ),
      ));
}

/// Abstract class defining the contract for an Android Alarm Manager model.
/// Implementations of this class are responsible for providing an entry point
/// callback and initializing the alarm.
abstract class AndroidAlarmManagerModel {
  /// The callback function to be executed when the alarm triggers.
  /// This function must be a top-level or static function.
  VoidCallback get entryPointCallback;

  @protected
  String get alarmLockSharedPreferencesKey => '${runtimeType}Lock';

  final _log = Logger('AndroidAlarmManagerModel');
  static const int _alarmID = 0;
  final _sharedPreferences = SharedPreferencesAsync();

  /// Initializes the Android Alarm Manager.
  ///
  /// This function is called when the app is started
  /// to initialize the Android Alarm Manager.
  /// It initializes the Android Alarm Manager and sets up a periodic alarm
  /// for execute [entryPointCallback].
  /// The alarm is set to run every
  /// [AlarmManagerRemoteConfigKeys.intervalInMinutes] minutes.
  /// The alarm is set to run in the background even if the app is not running.
  /// The alarm is set to run even if the device is in doze mode.
  ///
  /// Parameters:
  /// - [allowWhileIdle]: Whether the alarm should be allowed to run when the
  ///   device is in Doze mode. Defaults to `true`.
  /// - [wakeup]: Whether the alarm should wake up the device.
  ///   Defaults to `true`.
  /// - [rescheduleOnReboot]: Whether the alarm should be rescheduled after a
  ///   device reboot. Defaults to `true`.
  /// - [exact]: Whether the alarm should be exact. If `false`, the alarm might
  ///   be delayed by the OS. Defaults to `true`.
  Future<void> initialize(
      {bool allowWhileIdle = true,
      bool wakeup = true,
      bool rescheduleOnReboot = true,
      bool exact = true}) async {
    await AndroidAlarmManager.initialize();

    final cancelled = await AndroidAlarmManager.cancel(_alarmID);
    _log.info('AndroidAlarmManager periodic cancelled: $cancelled');

    _log.info('initialize sharedPreferences toBeInitialized to true and '
        '$alarmLockSharedPreferencesKey to false');
    await _sharedPreferences.setBool(
        AlarmManagerSharedPreferencesKeys.toBeInitialized.name, true);
    _sharedPreferences.setBool(alarmLockSharedPreferencesKey, false);
    // setup alarm android manager interval in minutes
    var androidAlarmManagerIntervalInMinutes = await _sharedPreferences.getInt(
            AlarmManagerSharedPreferencesKeys
                .androidAlarmManagerIntervalInMinutes.name) ??
        RemoteConfigModel.instance
            .getDouble(AlarmManagerRemoteConfigKeys.intervalInMinutes.name)
            .toInt();
    androidAlarmManagerIntervalInMinutes =
        androidAlarmManagerIntervalInMinutes > 0
            ? androidAlarmManagerIntervalInMinutes
            : AlarmManagerIntervalKeys.thirtyMinutes.minutes;
    // start the periodic alarm
    final started = await AndroidAlarmManager.periodic(
        Duration(minutes: androidAlarmManagerIntervalInMinutes),
        _alarmID,
        entryPointCallback,
        allowWhileIdle: allowWhileIdle,
        exact: exact,
        rescheduleOnReboot: rescheduleOnReboot,
        wakeup: wakeup);
    _log.info('AndroidAlarmManager periodic started: $started '
        'checkCarBluetoothAlarmID $_alarmID '
        'androidAlarmManagerIntervalInMinutes $androidAlarmManagerIntervalInMinutes '
        'allowWhileIdle $allowWhileIdle '
        'exact $exact '
        'wakeup $wakeup');
  }
}
