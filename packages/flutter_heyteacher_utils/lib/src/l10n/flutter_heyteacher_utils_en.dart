// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class FlutterHeyteacherUtilsLocalizationsEn
    extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get account => 'Account';

  @override
  String get userNotAuthenticated => 'User not authenticated';

  @override
  String get notAuthenticated => 'Not Authenticated';

  @override
  String get errorOnRetrieveData => 'Error on retrieve Data';

  @override
  String get timeoutOnRetrieveData => 'Timeout on retrieve data';

  @override
  String get confirm => 'Confirm';

  @override
  String get areYouSureToConfirmTheAction =>
      'Are you sure to confirm the action?';

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'Encryption Passphrase is empty, set it';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Missing Encryption Key, import it';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Error on encryption, check the Encryption Passphrase';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Error on decryption, check the Encryption Passphrase';

  @override
  String get id => 'Id: ';

  @override
  String get version => 'Version: ';

  @override
  String get askSupport => 'Ask Support';

  @override
  String get askSupportFor => 'Ask support for: ';

  @override
  String get logging => 'Logging';

  @override
  String get loggingLevel => 'Logging Level';

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'If you change the Encryption Passphrase, you will not be able to access data encrypted with the old passphrase.\n\nAre you sure you want to change the Encryption Passphrase?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'If you import an Encryption Key, the old key will be overridden and data encrypted with the old key will be lost.\n\nAre you sure you want to import the Encryption Key?';

  @override
  String get encryptionSecretKeyImported => 'Encryption Key imported';

  @override
  String get encryptionPassphrase => 'Encryption Passphrase';

  @override
  String get encryptionSecretKey => 'Encryption Key';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Scan the QR code with another device or store it in a secure place.\nThe QR code is encrypted with the Encryption Passphrase.\nYou must set the same Encryption Passphrase on the new device.';

  @override
  String get errorWorkflowTaskAlreadyInitialized =>
      'Workflow task already initialized';

  @override
  String get errorWorkflowNotInitialized => 'Workflow not initialized';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Content unavailable offline.\n\nRetry when the device is connected to the internet.';

  @override
  String get deleteUserData => 'Schedule deletion User Data';

  @override
  String doYouConfirmDeletionUserData(Object expireDateTime) {
    return 'Do you confirm the deletion of your user data?\nBe careful! This action cannot be undone until after $expireDateTime.';
  }

  @override
  String get restoreUserData => 'Restore User Data';

  @override
  String doYouConfirmRestoringUserData(Object expireDateTime) {
    return 'You sheduled the deletion of your user data on $expireDateTime.\nDo you confirm to cancel the deletion scheduled?';
  }

  @override
  String get task => 'Task';

  @override
  String get description => 'Description';

  @override
  String get tasks => 'Tasks';

  @override
  String get skip => 'Skip';

  @override
  String get deviceOfflineAskSupportWhenOnline =>
      'Device offline. Ask support when the device is connected to the internet.';

  @override
  String defaultValue(Object defaultValue) {
    return 'Default: $defaultValue';
  }

  @override
  String nSeconds(num nSeconds) {
    String _temp0 = intl.Intl.pluralLogic(
      nSeconds,
      locale: localeName,
      other: '$nSeconds seconds',
      one: '1 second',
      zero: '0 seconds',
    );
    return '$_temp0';
  }

  @override
  String get search => 'Search';

  @override
  String get enableLogsStorage => 'Enable Logs Storage';

  @override
  String nMinutes(num minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutesString minutes',
      one: '1 minute',
      zero: '0 minutes',
    );
    return '$_temp0';
  }

  @override
  String nHours(num hours) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);

    String _temp0 = intl.Intl.pluralLogic(
      hours,
      locale: localeName,
      other: '$hoursString hours',
      one: '1 hour',
      zero: '0 hour',
    );
    return '$_temp0';
  }
}
