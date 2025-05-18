// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class FlutterHeyteacherUtilsLocalizationsEs extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get account => 'Account';

  @override
  String get userNotAutenticated => 'Usuario no autenticado';

  @override
  String get notAuthenticated => 'No Autenticado';

  @override
  String get errorOnRetrieveData => 'Error al recuperar datos';

  @override
  String get timeoutOnRetrieveData => 'Tiempo de espera agotado al recuperar datos';

  @override
  String get confirm => 'Confirmar';

  @override
  String get areYouSureToConfirmTheAction => '¿Estás seguro de confirmar la acción?';

  @override
  String get encryptionPassphraseIsEmptySetIt => 'La frase de contraseña de cifrado está vacía, configúrala';

  @override
  String get missingEncryptionSecretKeyImportIt => 'Falta la clave secreta de cifrado, impórtala';

  @override
  String get errorOnEncryptionCheckPassphrase => 'Error en el cifrado, verifica la frase de contraseña de cifrado';

  @override
  String get errorOnDecryptionCheckPassphrase => 'Error en el descifrado, verifica la frase de contraseña de cifrado';

  @override
  String get id => 'Id: ';

  @override
  String get version => 'Versión: ';

  @override
  String get askSupport => 'Pedir soporte';

  @override
  String get askSupportFor => 'Pedir soporte para: ';

  @override
  String get logging => 'Registro';

  @override
  String nMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: '$minutes minuto',
    );
    return '$_temp0';
  }

  @override
  String get areYouSureToChangeEncryptionPassphrase => 'If you change Encryption Passphrase you\'ll not able to access data encrypted with this passphrase.\n\nAre you sure to change Encryption Passphrase';

  @override
  String get areYouSureToImportEncryptionSecretKey => 'If you import a Encryption Secret Key, old key is overidden and data encrypted with old key will be lost.\n\nAre you sure import Encryption Secret Key?';

  @override
  String get encryptionSecretKeyImported => 'Encryption Secret Key imported';

  @override
  String get encryptionPassphrase => 'Encryption Passphrase';

  @override
  String get encryptionSecretKey => 'Encryption Secret Key';

  @override
  String get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase => 'Scan QR code into another device or store in a secure place.\nThe QR code is encrypted with the Encryptrion Passphrase.\nYou must set the same Encryptrion Passphrase into the new device';
}
