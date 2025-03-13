import 'package:intl/intl.dart' as intl;

import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FlutterHeyteacherUtilsLocalizationsEn extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get userNotAutenticated => 'User not autenticated';

  @override
  String get notAuthenticated => 'Not Authenticated';

  @override
  String get errorOnRetrieveData => 'Error on retrieve Data';

  @override
  String get timeoutOnRetrieveData => 'Timeout on retieve data';

  @override
  String get bleAntPlus => 'Ble Ant+ ';

  @override
  String get bleAntPlusDevices => 'Bluetooth Low Emission Ant+ Devices';

  @override
  String get age => 'age';

  @override
  String get restBpm => 'rest bpm';

  @override
  String get gender => 'gender';

  @override
  String genderValue(String gender) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'Male',
        'female': 'Female',
        'other': 'Other',
      },
    );
    return '$_temp0';
  }

  @override
  String trainingZoneValue(String trainingZone) {
    String _temp0 = intl.Intl.selectLogic(
      trainingZone,
      {
        'z0': 'Z0 Rest',
        'z1': 'Z1 Warm Up',
        'z2': 'Z2 Fat Burn',
        'z3': 'Z3 Aerobic',
        'z4': 'Z4 Anaerobic',
        'z5': 'Z5 V02 Max',
        'z6': 'Z6 Death',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get trainingZone => 'Training Zone';

  @override
  String get bpm => 'BPM';

  @override
  String get maxRpm => 'Max RPM';

  @override
  String get minBpm => 'Min Bpm';

  @override
  String get rpm => 'RPM';

  @override
  String get maxBpm => 'Max BPM';

  @override
  String bleTypeDevice(String bleType) {
    String _temp0 = intl.Intl.selectLogic(
      bleType,
      {
        'cadence': 'Cadence Device',
        'heartRate': 'Heart Rate Device',
        'cyclingPower': 'Power Meter',
        'other': 'Unknown',
      },
    );
    return '$_temp0';
  }

  @override
  String get bluetoothAdapterStateIs => 'Bluetooth adapter state is ';

  @override
  String bluetoothAdapterState(String bluetoothAdapterState) {
    String _temp0 = intl.Intl.selectLogic(
      bluetoothAdapterState,
      {
        'unavailable': 'Unavailable',
        'unauthorized': 'Unauthorized',
        'turningOn': 'Turning On',
        'on': 'On',
        'turningOff': 'Turning Off',
        'off': 'Off',
        'other': 'Unknow',
      },
    );
    return '$_temp0';
  }

  @override
  String deviceIsNotBleTypesDevice(Object bleTypes) {
    return 'device is not $bleTypes device';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get areYouSureToConfirmTheAction => 'Are you sure to confirm the action?';

  @override
  String get encryptionPassphraseIsEmptySetIt => 'Encryption Passphrase is empty, set it';

  @override
  String get missingEncryptionSecretKeyImportIt => 'Missing Encryption Secret Key, import it';

  @override
  String get errorOnEncryptionCheckPassphrase => 'Error on encryption, check the Encryption Passphrase';

  @override
  String get errorOnDecryptionCheckPassphrase => 'Error on decryption, check the Encryption Passphrase';

  @override
  String get subscriptions => 'Subscriptions';

  @override
  String get yourPlan => 'Your plan';

  @override
  String get noPlanPurchased => 'No plan purchased';

  @override
  String get noActivePlan => 'No active plan';

  @override
  String get withoutRenew => 'Without renew';

  @override
  String get autoRenew => 'Auto renew';

  @override
  String get offer => 'Offer';

  @override
  String expiryDateTime(DateTime date, DateTime time) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'Expiry Time: $dateString $timeString';
  }

  @override
  String periodDuration(String periodDuration) {
    String _temp0 = intl.Intl.selectLogic(
      periodDuration,
      {
        'weekly': 'Weekly',
        'every2Weeks': 'Every 2 weeks',
        'every3Weeks': 'Every 3 weeks',
        'every4Weeks': 'Every 4 weeks',
        'monthly': 'Monthly',
        'every2Months': 'Every 2 month',
        'every3Months': 'Quarterly',
        'every4Months': 'Every 4 months',
        'every6Months': 'Half yearly',
        'every8Months': 'Every 8 months',
        'yearly': 'Yearly',
        'other': 'Unknow',
      },
    );
    return '$_temp0';
  }

  @override
  String subscriptionPurchaseState(String subscriptionPurchaseState) {
    String _temp0 = intl.Intl.selectLogic(
      subscriptionPurchaseState,
      {
        'pending': 'Pending',
        'active': 'Active',
        'paused': 'Paused',
        'inGracePeriod': 'In grace period',
        'onHold': 'On hold',
        'canceled': 'Cancelled',
        'expired': 'Expired',
        'pendingPurchaseCanceled': 'Pending purchase cancelled',
        'other': 'Unspecified',
      },
    );
    return '$_temp0';
  }

  @override
  String get manage => 'Manage';
}
