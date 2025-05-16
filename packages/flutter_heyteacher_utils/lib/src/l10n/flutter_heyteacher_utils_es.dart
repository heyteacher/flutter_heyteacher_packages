// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class FlutterHeyteacherUtilsLocalizationsEs extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsEs([String locale = 'es']) : super(locale);

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
}
