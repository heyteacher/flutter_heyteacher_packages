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
  String get errorOnEncryptionCheckPassphrase =>
      'Erro na criptografia, verifique a Frase Criptográfica';

  @override
  String get errorOnDecryptionCheckPassphrase =>
      'Erro na descriptografia, verifique a Frase Criptográfica';

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
}
