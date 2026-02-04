// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class FlutterHeyteacherUtilsLocalizationsEs
    extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get account => 'Cuenta';

  @override
  String get userNotAuthenticated => 'Usuario no autenticado';

  @override
  String get notAuthenticated => 'No autenticado';

  @override
  String get errorOnRetrieveData => 'Error al recuperar datos';

  @override
  String get timeoutOnRetrieveData =>
      'Tiempo de espera agotado al recuperar datos';

  @override
  String get confirm => 'Confirmar';

  @override
  String get areYouSureToConfirmTheAction =>
      '¿Está seguro de confirmar la acción?';

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'La frase de contraseña está vacía, configúrela';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Falta la Clave Criptográfica, impórtela';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Error en el cifrado, verifique la frase de contraseña';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Error en el descifrado, verifique la frase de contraseña';

  @override
  String get id => 'ID: ';

  @override
  String get version => 'Versión: ';

  @override
  String get askSupport => 'Solicitar soporte';

  @override
  String get askSupportFor => 'Solicitar soporte para: ';

  @override
  String get logging => 'Registro';

  @override
  String get loggingLevel => 'Nivel de registro';

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'Si cambia la frase de contraseña, no podrá acceder a los datos cifrados con la frase de contraseña antigua.\n\n¿Está seguro de que desea cambiar la frase de contraseña?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Si importa una Clave Criptográfica, la clave antigua se sobrescribirá y los datos cifrados con la clave antigua se perderán.\n\n¿Está seguro de que desea importar la Clave Criptográfica?';

  @override
  String get encryptionSecretKeyImported => 'Clave Criptográfica importada';

  @override
  String get encryptionPassphrase => 'Frase de contraseña';

  @override
  String get encryptionSecretKey => 'Clave Criptográfica';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Escanee el código QR con otro dispositivo o guárdelo en un lugar seguro.\nEl código QR está cifrado con la frase de contraseña.\nDebe establecer la misma frase de contraseña en el nuevo dispositivo.';

  @override
  String get errorWorkflowTaskAlreadyInitialized =>
      'Tarea de flujo de trabajo ya inicializada';

  @override
  String get errorWorkflowNotInitialized => 'Flujo de trabajo no inicializado';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Contenido no disponible sin conexión.\n\nIntente de nuevo cuando el dispositivo esté conectado a internet.';

  @override
  String get deleteUserData => 'Programar eliminación de datos de usuario';

  @override
  String doYouConfirmDeletionUserData(Object expireDateTime) {
    return '¿Confirma la eliminación de sus datos de usuario?\n¡Tenga cuidado! Esta acción no se puede deshacer hasta después de $expireDateTime.';
  }

  @override
  String get restoreUserData => 'Restaurar datos de usuario';

  @override
  String doYouConfirmRestoringUserData(Object expireDateTime) {
    return 'Ha programado la eliminación de sus datos de usuario para $expireDateTime.\n¿Confirma que desea cancelar la eliminación programada?';
  }

  @override
  String get task => 'Tarea';

  @override
  String get description => 'Descripción';

  @override
  String get tasks => 'Tareas';

  @override
  String get skip => 'Omitir';

  @override
  String get deviceOfflineAskSupportWhenOnline =>
      'Dispositivo sin conexión. Solicite soporte cuando el dispositivo esté conectado a internet.';

  @override
  String defaultValue(Object defaultValue) {
    return 'Predeterminado: $defaultValue';
  }

  @override
  String nSeconds(num nSeconds) {
    String _temp0 = intl.Intl.pluralLogic(
      nSeconds,
      locale: localeName,
      other: '$nSeconds segs',
      one: '1 seg',
      zero: '0 seg',
    );
    return '$_temp0';
  }

  @override
  String get search => 'Buscar';

  @override
  String get enableLogsStorage => 'Habilitar almacenamiento de registros';

  @override
  String nMinutes(num minutes) {
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutesString minutos',
      one: '1 minuto',
      zero: '0 minutos',
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
      other: '$hoursString horas',
      one: '1 hora',
      zero: '0 horas',
    );
    return '$_temp0';
  }
}
