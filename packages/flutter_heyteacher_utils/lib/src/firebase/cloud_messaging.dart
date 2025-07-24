/// Provides utilities for managing background tasks using
/// `Firebase Cloud Messaging`.
library;

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keys used for storing Firebase Cloud Messaging related settings in
/// SharedPreferences.
enum FCMSharedPreferencesKeys {
  /// Indicates whether the alarm manager needs to be initialized.
  toBeInitialized,
}

/// Keys used for fetching Firebase Cloud Messaging related configurations from
/// Firebase Remote Config.
enum FCMRemoteConfigKeys {
  /// The distance filter in meters, potentially used by the alarm callback,
  /// fetched from Remote Config.
  distanceFilterInMeters,

  /// the interval in minutes to check car bluetooth status.
  intervalInMinutes,

  /// the Firebase Cloud Messaging topic name
  fcmTopicName,
}

/// Defines preset intervals for the Firebase Cloud Messaging.
enum IntervalKeys {
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

  /// Creates an [IntervalKeys] with the given [minutes].
  const IntervalKeys(this.minutes);
}

/// Abstract class defining the contract for an Firebase Cloud Messaging model.
/// Implementations of this class are responsible for providing an entry point
/// callback and initializing the alarm.
abstract class FirebaseCloudMessagingViewModel {
  /// The callback function to be executed when the alarm triggers.
  /// This function must be a top-level or static function.
  BackgroundMessageHandler entryPointCallback;

  FirebaseCloudMessagingViewModel({required this.entryPointCallback});

  @protected
  String get lockSharedPreferencesKey => '${runtimeType}Lock';

  final _logger = Logger('FirebaseCloudMessagingViewModel');
  final _sharedPreferences = SharedPreferencesAsync();

  static int get remoteConfigIntervalInMinutes => kDebugMode
      ? 1
      : RemoteConfigViewModel.instance
                  .getInt(FCMRemoteConfigKeys.intervalInMinutes.name) >
              0
          ? RemoteConfigViewModel.instance
              .getInt(FCMRemoteConfigKeys.intervalInMinutes.name)
          : IntervalKeys.fiveMinutes.minutes;

  /// Initializes the Firebase Cloud Messaging.
  ///
  /// This function is called when the app is started
  /// to initialize the Firebase Cloud Messaging.
  /// It initializes the Firebase Cloud Messaging and sets up a periodic alarm
  /// for execute [entryPointCallback] every
  /// [FCMRemoteConfigKeys.intervalInMinutes] minutes.
  /// The callback is set to run in the background even if the app is not running.
  /// The callback is set to run even if the device is in doze mode.
  Future<void> initialize() async {
    _logger.finest('<initialize>:');
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    _logger.info(
      '(initialize): User granted permission: ${settings.authorizationStatus}',
    );
    final topic = RemoteConfigViewModel.instance
        .getString(FCMRemoteConfigKeys.fcmTopicName.name);
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    _logger.info('(initialize): listen topic $topic');
    FirebaseMessaging.onBackgroundMessage(entryPointCallback);
    _logger
        .info('(initialize): set sharedPreferences toBeInitialized to true and '
            '$lockSharedPreferencesKey to false');
    await _sharedPreferences.setBool(
        FCMSharedPreferencesKeys.toBeInitialized.name, true);
    _sharedPreferences.setBool(lockSharedPreferencesKey, false);
  }
}
