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
  String get notAuthenticated => 'Não autenticado';

  @override
  String get errorOnRetrieveData => 'Erro ao recuperar dados';

  @override
  String get timeoutOnRetrieveData => 'Tempo limite ao recuperar dados';

  @override
  String get confirm => 'Confirmar';

  @override
  String get areYouSureToConfirmTheAction =>
      'Tem certeza de que deseja confirmar a ação?';

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
  String get id => 'ID: ';

  @override
  String get version => 'Versão: ';

  @override
  String get askSupport => 'Pedir suporte';

  @override
  String get askSupportFor => 'Pedir suporte para: ';

  @override
  String get logging => 'Registro';

  @override
  String get loggingLevel => 'Nível de registro';

  @override
  String nMinutes(num minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutos',
      one: 'um minuto',
    );
    return '$_temp0';
  }

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'Se você alterar a frase secreta de criptografia, não poderá acessar os dados criptografados com a frase secreta antiga.\n\nTem certeza de que deseja alterar a frase secreta de criptografia?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Se você importar uma chave secreta de criptografia, a chave antiga será substituída e os dados criptografados com a chave antiga serão perdidos.\n\nTem certeza de que deseja importar a chave secreta de criptografia?';

  @override
  String get encryptionSecretKeyImported =>
      'Chave secreta de criptografia importada';

  @override
  String get encryptionPassphrase => 'Frase secreta de criptografia';

  @override
  String get encryptionSecretKey => 'Chave secreta de criptografia';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Digitalize o código QR com outro dispositivo ou armazene-o em um local seguro.\nO código QR é criptografado com a frase secreta de criptografia.\nVocê deve definir a mesma frase secreta de criptografia no novo dispositivo.';

  @override
  String get errorWorkflowTaskAlreadyInitialized =>
      'Tarefa de fluxo de trabalho já inicializada';

  @override
  String get errorWorkflowNotInitialized =>
      'Fluxo de trabalho não inicializado';

  @override
  String get contentUnavailableOfflineRetryWhenOnline =>
      'Conteúdo indisponível offline.\n\nTente novamente quando o dispositivo estiver conectado à internet.';

  @override
  String get deleteUserData => 'Agendar exclusão de dados do usuário';

  @override
  String doYouConfirmDeletionUserData(Object expireDateTime) {
    return 'Você confirma a exclusão dos seus dados de usuário?\nCuidado! Esta ação não pode ser desfeita até depois de $expireDateTime.';
  }

  @override
  String get restoreUserData => 'Restaurar dados do usuário';

  @override
  String doYouConfirmRestoringUserData(Object expireDateTime) {
    return 'Você agendou a exclusão dos seus dados de usuário para $expireDateTime.\nVocê confirma o cancelamento da exclusão agendada?';
  }

  @override
  String get task => 'Tarefa';

  @override
  String get description => 'Descrição';

  @override
  String get tasks => 'Tarefas';

  @override
  String get skip => 'Pular';

  @override
  String get deviceOfflineAskSupportWhenOnline =>
      'Dispositivo offline. Peça suporte quando o dispositivo estiver conectado à internet.';

  @override
  String defaultValue(Object defaultValue) {
    return 'Padrão: $defaultValue';
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
  String get search => 'Pesquisar';

  @override
  String get enableLogsStorage => 'Habilitar armazenamento de logs';
}
