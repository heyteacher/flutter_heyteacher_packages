// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class FlutterHeyteacherUtilsLocalizationsPt extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get userNotAutenticated => 'Usuário não autenticado';

  @override
  String get notAuthenticated => 'Não Autenticado';

  @override
  String get errorOnRetrieveData => 'Erro ao recuperar dados';

  @override
  String get timeoutOnRetrieveData => 'Tempo esgotado ao recuperar dados';

  @override
  String get confirm => 'Confirmar';

  @override
  String get areYouSureToConfirmTheAction => 'Tem certeza que deseja confirmar a ação?';

  @override
  String get encryptionPassphraseIsEmptySetIt => 'A frase secreta de criptografia está vazia, defina-a';

  @override
  String get missingEncryptionSecretKeyImportIt => 'Chave secreta de criptografia ausente, importe-a';

  @override
  String get errorOnEncryptionCheckPassphrase => 'Erro na criptografia, verifique a frase secreta de criptografia';

  @override
  String get errorOnDecryptionCheckPassphrase => 'Erro na descriptografia, verifique a frase secreta de criptografia';

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
}
