import 'package:intl/intl.dart' as intl;

import 'flutter_heyteacher_utils.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class FlutterHeyteacherUtilsLocalizationsIt extends FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get userNotAutenticated => 'Utente non autenticato';

  @override
  String get notAuthenticated => 'Non Autenticato';

  @override
  String get errorOnRetrieveData => 'errore durante il caricamento dei dati';

  @override
  String get timeoutOnRetrieveData => 'Timeout durante in caricamento dei dati';

  @override
  String get bleAntPlus => 'Ble Ant+ ';

  @override
  String get bleAntPlusDevices => 'Dispositivi Bluetooth Low Emission Ant+';

  @override
  String get age => 'età';

  @override
  String get restBpm => 'bpm riposo';

  @override
  String get gender => 'genere';

  @override
  String genderValue(String gender) {
    String _temp0 = intl.Intl.selectLogic(
      gender,
      {
        'male': 'Uomo',
        'female': 'Donna',
        'other': 'Altro',
      },
    );
    return '$_temp0';
  }

  @override
  String trainingZoneValue(String trainingZone) {
    String _temp0 = intl.Intl.selectLogic(
      trainingZone,
      {
        'z0': 'Z0 Riposo',
        'z1': 'Z1 Riscaldamento',
        'z2': 'Z2 Brucia Grassi',
        'z3': 'Z3 Aerobico',
        'z4': 'Z4 Anaerobico',
        'z5': 'Z5 V02 Max',
        'z6': 'Z6 Morte',
        'other': '',
      },
    );
    return '$_temp0';
  }

  @override
  String get trainingZone => 'Zone Allenamento';

  @override
  String get bpm => 'BPM';

  @override
  String get maxRpm => 'Max RPM';

  @override
  String get minBpm => 'Min BPM';

  @override
  String get rpm => 'RPM';

  @override
  String get maxBpm => 'Max BPM';

  @override
  String bleTypeDevice(String bleType) {
    String _temp0 = intl.Intl.selectLogic(
      bleType,
      {
        'cadence': 'Contapedalate',
        'heartRate': 'Cardiofrequenzimetro',
        'cyclingPower': 'Misuratore Potenza',
        'other': 'Sconosciuto',
      },
    );
    return '$_temp0';
  }

  @override
  String get bluetoothAdapterStateIs => 'Lo stato del Bluetooth è ';

  @override
  String bluetoothAdapterState(String bluetoothAdapterState) {
    String _temp0 = intl.Intl.selectLogic(
      bluetoothAdapterState,
      {
        'unknown': 'Sconosciuto',
        'unavailable': 'Non Disponibile',
        'unauthorized': 'Non Autorizzato',
        'turningOn': 'In Accensione',
        'on': 'Attivo',
        'turningOff': 'In Spegnimento',
        'off': 'Spento',
        'other': 'Sconosciuto',
      },
    );
    return '$_temp0';
  }

  @override
  String deviceIsNotBleTypesDevice(Object bleTypes) {
    return 'il device non è un $bleTypes device';
  }

  @override
  String get confirm => 'Conferma';

  @override
  String get areYouSureToConfirmTheAction => 'Sei sicuro di confermare l\'azione?';

  @override
  String get encryptionPassphraseIsEmptySetIt => 'La Password di Criptazione non è valorizzata, impostala';

  @override
  String get missingEncryptionSecretKeyImportIt => 'La Chiave Secreta di Criptazione no n presente, importala';

  @override
  String get errorOnEncryptionCheckPassphrase => 'Errore durante la criptazione, controlla la Password di Criptazione';

  @override
  String get errorOnDecryptionCheckPassphrase => 'Errore durante la decriptazione, controlla la Password di Criptazione';

  @override
  String get subscriptions => 'Abbonamenti';

  @override
  String get yourPlan => 'Il tuo piano';

  @override
  String get noPlan => 'Nessun piano';

  @override
  String get noActivePlan => 'Nessun piano attivo';

  @override
  String get withoutRenew => 'Senza rinnovo';

  @override
  String get autoRenew => 'Rinnovo automatico';

  @override
  String get offer => 'Offerta';

  @override
  String expiryDateTime(DateTime date, DateTime time) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'Scadenza: $dateString $timeString';
  }

  @override
  String periodDuration(String periodDuration) {
    String _temp0 = intl.Intl.selectLogic(
      periodDuration,
      {
        'weekly': 'Settimanale',
        'every2Weeks': 'Bisettimanale',
        'every3Weeks': 'Ogni 3 settimane',
        'every4Weeks': 'Ogni 4 settimane',
        'monthly': 'Mensile',
        'every2Months': 'Bimensile',
        'every3Months': 'Trimestrale',
        'every4Months': 'Quadrimestrale',
        'every6Months': 'Semestrale',
        'every8Months': 'Ogni 8 mesi',
        'yearly': 'Annuale',
        'other': 'Sconosciuto',
      },
    );
    return '$_temp0';
  }

  @override
  String subscriptionPurchaseState(String subscriptionPurchaseState) {
    String _temp0 = intl.Intl.selectLogic(
      subscriptionPurchaseState,
      {
        'pending': 'In attesa',
        'active': 'Attivo',
        'paused': 'In pausa',
        'inGracePeriod': 'Proroga',
        'onHold': 'In sospeso',
        'canceled': 'Cancellato',
        'expired': 'Scaduto',
        'pendingPurchaseCanceled': 'Acquisto pendente cancellato',
        'other': 'Non specificato',
      },
    );
    return '$_temp0';
  }
}
