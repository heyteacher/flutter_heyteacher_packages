/// Provides utilities for managing background tasks using
/// `Firebase Cloud Messaging`.
library;

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/src/firebase/remote_config.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Creates an [IntervalKeys] with the given [minutes].
  const IntervalKeys(this.minutes);
 /// The duration of the interval in minutes.
  final int minutes;
}

 

/// Abstract class defining the contract for an Firebase Cloud Messaging model.
/// Implementations of this class are responsible for providing an entry point
/// callback and initializing the alarm.
abstract class FirebaseCloudMessagingViewModel {

  /// Creates an instance of [FirebaseCloudMessagingViewModel].
  FirebaseCloudMessagingViewModel({required this.entryPointCallback});
  /// The callback function to be executed when the alarm triggers.
  /// This function must be a top-level or static function.
  BackgroundMessageHandler entryPointCallback;

  /// the lock shared preferences key
  @protected
  String get lockSharedPreferencesKey => '${runtimeType}Lock';

  final _logger = Logger('FirebaseCloudMessagingViewModel');
  final _sharedPreferences = SharedPreferencesAsync();

  /// Gets the interval in minutes for the Firebase Cloud Messaging.
  static int get remoteConfigIntervalInMinutes => kDebugMode
      ? 1
      : RemoteConfigViewModel.instance
                  .getInt(FHURemoteConfigKeys.fmcIntervalInMinutes.name) >
              0
          ? RemoteConfigViewModel.instance
              .getInt(FHURemoteConfigKeys.fmcIntervalInMinutes.name)
          : IntervalKeys.fiveMinutes.minutes;

  /// Initializes the Firebase Cloud Messaging.
  ///
  /// This function is called when the app is started
  /// to initialize the Firebase Cloud Messaging.
  /// The callback is set to run in the background even if the app is not 
  /// running.
  /// The callback is set to run even if the device is in doze mode.
  Future<void> initialize() async {
    _logger.finer('<initialize>:');
    final settings =
        await FirebaseMessaging.instance.requestPermission(
      announcement: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
    );
    _logger.info(
      '(initialize): User granted permission ${settings.authorizationStatus}',
    );
    final topic = RemoteConfigViewModel.instance
        .getString(FHURemoteConfigKeys.fcmTopicName.name);
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    _logger.info('(initialize): listen topic $topic');
    FirebaseMessaging.onBackgroundMessage(entryPointCallback);
    _logger
        .info('(initialize): set sharedPreferences toBeInitialized to true and '
            '$lockSharedPreferencesKey to false');
    await _sharedPreferences.setBool(
        FlutterHeyteacherUtilsSharedPreferencesKeys.htuFmcToBeInitialized.name, true);
    unawaited(_sharedPreferences.setBool(lockSharedPreferencesKey, false));
  }
}
