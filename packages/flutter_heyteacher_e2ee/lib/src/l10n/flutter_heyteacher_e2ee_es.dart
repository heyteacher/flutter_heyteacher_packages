// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_e2ee.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class FlutterHeyteacherE2EELocalizationsEs
    extends FlutterHeyteacherE2EELocalizations {
  FlutterHeyteacherE2EELocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'La frase de contraseña está vacía, configúrela';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Falta la Clave Criptográfica, impórtela';

  @override
  String errorOnEncryptionCheckPassphrase(String error) {
    return 'Error en el cifrado: $error';
  }

  @override
  String errorOnDecryptionCheckPassphrase(String error) {
    return 'Error en el descifrado: $error';
  }

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'Si cambia la frase de contraseña, no podrá acceder a los datos cifrados con la frase de contraseña antigua.\n\n¿Está seguro de que desea cambiar la frase de contraseña?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Si importa una Clave Criptográfica, la clave antigua se sobrescribirá y los datos cifrados con la clave antigua se perderán.\n\n¿Está seguro de que desea importar la Clave Criptográfica?';

  @override
  String get encryptionSecretKeyImported => 'Clave Criptográfica importada';

  @override
  String get encryptionPassphrase => 'Contraseña';

  @override
  String get encryptionSecretKey => 'Clave Criptográfica';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Escanee el código QR con otro dispositivo o guárdelo en un lugar seguro.\nEl código QR está cifrado con la frase de contraseña.\nDebe establecer la misma frase de contraseña en el nuevo dispositivo.';

  @override
  String get missingMasterSecretKeyJwk =>
      'Falta la clave secreta maestra JWK, E2EE no inicializado';

  @override
  String get show => 'Mostrar';

  @override
  String get scan => 'Escanear';

  @override
  String get edit => 'Editar';

  @override
  String get generate => 'Generar';

  @override
  String get secretkeyGenerated => 'Clave secreta generada';

  @override
  String get areYouSureToChangeSecretKey =>
      'Si cambia la Clave Criptográfica, no podrá acceder a los datos cifrados con la clave antigua.\n\n¿Está seguro de que desea cambiar la Clave Criptográfica?';

  @override
  String get actionNotPermittedInDebugMode =>
      'Acción no permitida en modo de depuración';
}
