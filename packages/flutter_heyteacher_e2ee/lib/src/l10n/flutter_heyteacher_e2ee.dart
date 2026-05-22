import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'flutter_heyteacher_e2ee_de.dart';
import 'flutter_heyteacher_e2ee_en.dart';
import 'flutter_heyteacher_e2ee_es.dart';
import 'flutter_heyteacher_e2ee_fr.dart';
import 'flutter_heyteacher_e2ee_it.dart';
import 'flutter_heyteacher_e2ee_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FlutterHeyteacherE2EELocalizations
/// returned by `FlutterHeyteacherE2EELocalizations.of(context)`.
///
/// Applications need to include `FlutterHeyteacherE2EELocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/flutter_heyteacher_e2ee.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FlutterHeyteacherE2EELocalizations.localizationsDelegates,
///   supportedLocales: FlutterHeyteacherE2EELocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the FlutterHeyteacherE2EELocalizations.supportedLocales
/// property.
abstract class FlutterHeyteacherE2EELocalizations {
  FlutterHeyteacherE2EELocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FlutterHeyteacherE2EELocalizations? of(BuildContext context) {
    return Localizations.of<FlutterHeyteacherE2EELocalizations>(
      context,
      FlutterHeyteacherE2EELocalizations,
    );
  }

  static const LocalizationsDelegate<FlutterHeyteacherE2EELocalizations>
  delegate = _FlutterHeyteacherE2EELocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
  ];

  /// No description provided for @encryptionPassphraseIsEmptySetIt.
  ///
  /// In en, this message translates to:
  /// **'Encryption Passphrase is empty, set it'**
  String get encryptionPassphraseIsEmptySetIt;

  /// No description provided for @missingEncryptionSecretKeyImportIt.
  ///
  /// In en, this message translates to:
  /// **'Missing Encryption Key, import it'**
  String get missingEncryptionSecretKeyImportIt;

  /// No description provided for @errorOnEncryptionCheckPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Error on encryption, check the Encryption Passphrase'**
  String get errorOnEncryptionCheckPassphrase;

  /// No description provided for @errorOnDecryptionCheckPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Error on decryption, check the Encryption Passphrase'**
  String get errorOnDecryptionCheckPassphrase;

  /// No description provided for @areYouSureToChangeEncryptionPassphrase.
  ///
  /// In en, this message translates to:
  /// **'If you change the Encryption Passphrase, you will not be able to access data encrypted with the old passphrase.\n\nAre you sure you want to change the Encryption Passphrase?'**
  String get areYouSureToChangeEncryptionPassphrase;

  /// No description provided for @areYouSureToImportEncryptionSecretKey.
  ///
  /// In en, this message translates to:
  /// **'If you import an Encryption Key, the old key will be overridden and data encrypted with the old key will be lost.\n\nAre you sure you want to import the Encryption Key?'**
  String get areYouSureToImportEncryptionSecretKey;

  /// No description provided for @encryptionSecretKeyImported.
  ///
  /// In en, this message translates to:
  /// **'Encryption Key imported'**
  String get encryptionSecretKeyImported;

  /// No description provided for @encryptionPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get encryptionPassphrase;

  /// No description provided for @encryptionSecretKey.
  ///
  /// In en, this message translates to:
  /// **'Encryption Key'**
  String get encryptionSecretKey;

  /// No description provided for @scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code with another device or store it in a secure place.\nThe QR code is encrypted with the Encryption Passphrase.\nYou must set the same Encryption Passphrase on the new device.'**
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase;

  /// No description provided for @missingMasterSecretKeyJwk.
  ///
  /// In en, this message translates to:
  /// **'Missing Master Secret Key JWK, E2EE not initialized'**
  String get missingMasterSecretKeyJwk;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;
}

class _FlutterHeyteacherE2EELocalizationsDelegate
    extends LocalizationsDelegate<FlutterHeyteacherE2EELocalizations> {
  const _FlutterHeyteacherE2EELocalizationsDelegate();

  @override
  Future<FlutterHeyteacherE2EELocalizations> load(Locale locale) {
    return SynchronousFuture<FlutterHeyteacherE2EELocalizations>(
      lookupFlutterHeyteacherE2EELocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_FlutterHeyteacherE2EELocalizationsDelegate old) => false;
}

FlutterHeyteacherE2EELocalizations lookupFlutterHeyteacherE2EELocalizations(
  Locale locale,
) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return FlutterHeyteacherE2EELocalizationsDe();
    case 'en':
      return FlutterHeyteacherE2EELocalizationsEn();
    case 'es':
      return FlutterHeyteacherE2EELocalizationsEs();
    case 'fr':
      return FlutterHeyteacherE2EELocalizationsFr();
    case 'it':
      return FlutterHeyteacherE2EELocalizationsIt();
    case 'pt':
      return FlutterHeyteacherE2EELocalizationsPt();
  }

  throw FlutterError(
    'FlutterHeyteacherE2EELocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
