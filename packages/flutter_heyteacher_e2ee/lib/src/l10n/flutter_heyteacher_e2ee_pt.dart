// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flutter_heyteacher_e2ee.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class FlutterHeyteacherE2EELocalizationsPt
    extends FlutterHeyteacherE2EELocalizations {
  FlutterHeyteacherE2EELocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get encryptionPassphraseIsEmptySetIt =>
      'A Frase Criptográfica está vazia, defina-a';

  @override
  String get missingEncryptionSecretKeyImportIt =>
      'Chave Criptográfica ausente, importe-a';

  @override
  String errorOnEncryptionCheckPassphrase(String error) {
    return 'Erro na criptografia: $error';
  }

  @override
  String errorOnDecryptionCheckPassphrase(String error) {
    return 'Erro na descriptografia: $error';
  }

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'Se você alterar a Frase Criptográfica, não poderá acessar os dados criptografados com a frase secreta antiga.\n\nTem certeza de que deseja alterar a Frase Criptográfica?';

  @override
  String get areYouSureToImportEncryptionSecretKey =>
      'Se você importar uma chave Criptográfica, a chave antiga será substituída e os dados criptografados com a chave antiga serão perdidos.\n\nTem certeza de que deseja importar a chave Criptográfica?';

  @override
  String get encryptionSecretKeyImported => 'Chave Criptográfica importada';

  @override
  String get encryptionPassphrase => 'Senha';

  @override
  String get encryptionSecretKey => 'Chave Criptográfica';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      'Digitalize o código QR com outro dispositivo ou armazene-o em um local seguro.\nO código QR é criptografado com a Frase Criptográfica.\nVocê deve definir a mesma Frase Criptográfica no novo dispositivo.';

  @override
  String get missingMasterSecretKeyJwk =>
      'Chave secreta mestre JWK ausente, E2EE não inicializado';

  @override
  String get show => 'Mostrar';

  @override
  String get scan => 'Escanear';

  @override
  String get edit => 'Editar';

  @override
  String get generate => 'Gerar';

  @override
  String get secretkeyGenerated => 'Chave secreta gerada';

  @override
  String get areYouSureToChangeSecretKey =>
      'Se você alterar a Chave Criptográfica, não poderá acessar os dados criptografados com a chave antiga.\n\nTem certeza de que deseja alterar a Chave Criptográfica?';

  @override
  String get actionNotPermittedInDebugMode =>
      'Ação não permitida no modo de depuração';
}
