// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class FlutterHeyteacherUtilsLocalizationsPt
    extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get account => 'Conta';

  @override
  String get userNotAuthenticated => 'Usuário não autenticado';

  @override
  String get notAuthenticated => 'Não Autenticado';

  @override
  String get errorOnRetrieveData => 'Erro ao recuperar dados';

  @override
  String get timeoutOnRetrieveData => 'Tempo esgotado ao recuperar dados';

  @override
  String get confirm => 'Confirmar';

  @override
  String get areYouSureToConfirmTheAction =>
      'Tem certeza que deseja confirmar a ação?';

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'A frase secreta de criptografia está vazia, defina-a';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Chave secreta de criptografia ausente, importe-a';

  @override
  String get errorOnEncryptionCheckPassphrase =>
      'Erro na criptografia, verifique a frase secreta de criptografia';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Erro na descriptografia, verifique a frase secreta de criptografia';

  @override
  String get id => 'Id: ';

  @override
  String get version => 'Versão: ';

  @override
  String get askSupport => 'Pedir suporte';

  @override
  String get askSupportFor => 'Pedir suporte para: ';

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
      'Tem certeza que deseja alterar a frase secreta de criptografia?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Tem certeza que deseja importar a chave secreta de criptografia?';

  @override
  String get encryptionSecretKeyImported =>
      'Chave secreta de criptografia importada';

  @override
  String get encryptionPassphrase => 'Frase secreta de criptografia';

  @override
  String get encryptionSecretKey => 'Chave secreta de criptografia';

  @override
  String get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Escaneie o código QR com outro dispositivo ou armazene em um local seguro. Lembre-se de usar a mesma frase secreta.';

  @override
  String get errorWorkflowTaskAlreadyInitialized =>
      'Tarefa de fluxo de trabalho já inicializada';

  @override
  String get errorWorkflowNotInitialized => 'Workflow não inicializado';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Conteúdo indisponível offline.\n\nPor favor, tente novamente quando estiver conectado à internet.';

  @override
  String get deleteUserData => 'Excluir dados do usuário';

  @override
  String get doYouConfirmDeletionUserData =>
      'Você confirma a exclusão dos dados do usuário?';

  @override
  String get task => 'Tarefa';

  @override
  String get description => 'Descrição';

  @override
  String get tasks => 'Tarefas';
}
