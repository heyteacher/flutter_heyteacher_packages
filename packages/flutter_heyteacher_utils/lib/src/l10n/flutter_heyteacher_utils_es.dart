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
  String get notAuthenticated => 'No Autenticado';

  @override
  String get errorOnRetrieveData => 'Error al recuperar datos';

  @override
  String get timeoutOnRetrieveData =>
      'Tiempo de espera agotado al recuperar datos';

  @override
  String get confirm => 'Confirmar';

  @override
  String get areYouSureToConfirmTheAction =>
      '¿Estás seguro de confirmar la acción?';

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'La frase de contraseña de cifrado está vacía, configúrala';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Falta la clave secreta de cifrado, impórtala';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Error en el cifrado, verifica la frase de contraseña de cifrado';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Error en el descifrado, verifica la frase de contraseña de cifrado';

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
  String get areYouSureToChangeEncryptionPassphrase =>
      '¿Estás seguro de cambiar la frase de contraseña de cifrado?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      '¿Estás seguro de importar la clave secreta de cifrado?';

  @override
  String get encryptionSecretKeyImported =>
      'Clave secreta de cifrado importada';

  @override
  String get encryptionPassphrase => 'Frase de contraseña de cifrado';

  @override
  String get encryptionSecretKey => 'Clave secreta de cifrado';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Escanea el código QR con otro dispositivo o guárdalo en un lugar seguro. Recuerda usar la misma frase de contraseña.';

  @override
  String get errorWorkflowTaskAlreadyInitialized =>
      'La tarea del flujo de trabajo ya ha sido inicializada';

  @override
  String get errorWorkflowNotInitialized => 'Workflow no inicializado';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Contenido no disponible sin conexión.\n\nPor favor, inténtalo de nuevo cuando estés conectado a Internet.';

  @override
  String get deleteUserData => 'Eliminar datos de usuario';

  @override
  String get doYouConfirmDeletionUserData =>
      '¿Confirma la eliminación de los datos de usuario?';

  @override
  String get task => 'Tarea';

  @override
  String get description => 'Descripción';

  @override
  String get tasks => 'Tareas';

  @override
  String get skip => 'Saltar';

  @override
  String get deviceOfflineAskSupportWhenOnline =>
      'Dispositivo sin conexión. Pida soporte cuando el dispositivo esté conectado a internet.';
}
