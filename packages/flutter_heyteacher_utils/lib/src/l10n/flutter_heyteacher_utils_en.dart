// ignore: unused_import
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
  String get id => 'Id: ';

  @override
  String get version => 'Version: ';

  @override
  String get support => 'Support';

  @override
  String get askSupportFor => 'Ask support for: ';
}
