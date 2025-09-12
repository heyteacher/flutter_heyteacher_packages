import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'flutter_heyteacher_utils_de.dart';
import 'flutter_heyteacher_utils_en.dart';
import 'flutter_heyteacher_utils_es.dart';
import 'flutter_heyteacher_utils_fr.dart';
import 'flutter_heyteacher_utils_it.dart';
import 'flutter_heyteacher_utils_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FlutterHeyteacherUtilsLocalizations
/// returned by `FlutterHeyteacherUtilsLocalizations.of(context)`.
///
/// Applications need to include `FlutterHeyteacherUtilsLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/flutter_heyteacher_utils.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FlutterHeyteacherUtilsLocalizations.localizationsDelegates,
///   supportedLocales: FlutterHeyteacherUtilsLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the FlutterHeyteacherUtilsLocalizations.supportedLocales
/// property.
abstract class FlutterHeyteacherUtilsLocalizations {
  FlutterHeyteacherUtilsLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FlutterHeyteacherUtilsLocalizations? of(BuildContext context) {
    return Localizations.of<FlutterHeyteacherUtilsLocalizations>(
      context,
      FlutterHeyteacherUtilsLocalizations,
    );
  }

  static const LocalizationsDelegate<FlutterHeyteacherUtilsLocalizations>
  delegate = _FlutterHeyteacherUtilsLocalizationsDelegate();

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

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @userNotAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'User not authenticated'**
  String get userNotAuthenticated;

  /// No description provided for @notAuthenticated.
  ///
  /// In en, this message translates to:
  /// **'Not Authenticated'**
  String get notAuthenticated;

  /// No description provided for @errorOnRetrieveData.
  ///
  /// In en, this message translates to:
  /// **'Error on retrieve Data'**
  String get errorOnRetrieveData;

  /// No description provided for @timeoutOnRetrieveData.
  ///
  /// In en, this message translates to:
  /// **'Timeout on retrieve data'**
  String get timeoutOnRetrieveData;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @areYouSureToConfirmTheAction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure to confirm the action?'**
  String get areYouSureToConfirmTheAction;

  /// No description provided for @encryptionPassphraseIsEmptySetIt.
  ///
  /// In en, this message translates to:
  /// **'Encryption Passphrase is empty, set it'**
  String get encryptionPassphraseIsEmptySetIt;

  /// No description provided for @missingEncryptionSecretKeyImportIt.
  ///
  /// In en, this message translates to:
  /// **'Missing Encryption Secret Key, import it'**
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

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'Id: '**
  String get id;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version: '**
  String get version;

  /// No description provided for @askSupport.
  ///
  /// In en, this message translates to:
  /// **'Ask Support'**
  String get askSupport;

  /// No description provided for @askSupportFor.
  ///
  /// In en, this message translates to:
  /// **'Ask support for: '**
  String get askSupportFor;

  /// No description provided for @logging.
  ///
  /// In en, this message translates to:
  /// **'Logging'**
  String get logging;

  /// No description provided for @loggingLevel.
  ///
  /// In en, this message translates to:
  /// **'Logging Level'**
  String get loggingLevel;

  /// No description provided for @nMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes, plural, =1{one minute} other{{minutes} minutes}}'**
  String nMinutes(num minutes);

  /// No description provided for @areYouSureToChangeEncryptionPassphrase.
  ///
  /// In en, this message translates to:
  /// **'If you change the Encryption Passphrase, you will not be able to access data encrypted with the old passphrase.\n\nAre you sure you want to change the Encryption Passphrase?'**
  String get areYouSureToChangeEncryptionPassphrase;

  /// No description provided for @areYouSureToImportEncryptionSecretKey.
  ///
  /// In en, this message translates to:
  /// **'If you import an Encryption Secret Key, the old key will be overridden and data encrypted with the old key will be lost.\n\nAre you sure you want to import the Encryption Secret Key?'**
  String get areYouSureToImportEncryptionSecretKey;

  /// No description provided for @encryptionSecretKeyImported.
  ///
  /// In en, this message translates to:
  /// **'Encryption Secret Key imported'**
  String get encryptionSecretKeyImported;

  /// No description provided for @encryptionPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Encryption Passphrase'**
  String get encryptionPassphrase;

  /// No description provided for @encryptionSecretKey.
  ///
  /// In en, this message translates to:
  /// **'Encryption Secret Key'**
  String get encryptionSecretKey;

  /// No description provided for @scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code with another device or store it in a secure place.\nThe QR code is encrypted with the Encryption Passphrase.\nYou must set the same Encryption Passphrase on the new device.'**
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase;

  /// No description provided for @errorWorkflowTaskAlreadyInitialized.
  ///
  /// In en, this message translates to:
  /// **'Workflow task already initialized'**
  String get errorWorkflowTaskAlreadyInitialized;

  /// No description provided for @errorWorkflowNotInitialized.
  ///
  /// In en, this message translates to:
  /// **'Workflow not initialized'**
  String get errorWorkflowNotInitialized;

  /// No description provided for @contentUnavailableOfflineRetryWhenOnline.
  ///
  /// In en, this message translates to:
  /// **'Content unavailable offline.\n\nRetry when the device is connected to the internet.'**
  String get contentUnavailableOfflineRetryWhenOnline;

  /// No description provided for @deleteUserData.
  ///
  /// In en, this message translates to:
  /// **'Delete User Data'**
  String get deleteUserData;

  /// No description provided for @doYouConfirmDeletionUserData.
  ///
  /// In en, this message translates to:
  /// **'Do you confirm the deletion of your user data?\nBe careful! This action cannot be undone.'**
  String get doYouConfirmDeletionUserData;

  /// No description provided for @task.
  ///
  /// In en, this message translates to:
  /// **'Task'**
  String get task;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @deviceOfflineAskSupportWhenOnline.
  ///
  /// In en, this message translates to:
  /// **'Device offline. Ask support when the device is connected to the internet.'**
  String get deviceOfflineAskSupportWhenOnline;

  /// No description provided for @defaultValue.
  ///
  /// In en, this message translates to:
  /// **'Default: {defaultValue}'**
  String defaultValue(Object defaultValue);

  /// No description provided for @nSeconds.
  ///
  /// In en, this message translates to:
  /// **'{nSeconds, plural, =0{0 sec} =1{1 sec} other{{nSeconds} secs}}'**
  String nSeconds(num nSeconds);

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;
}

class _FlutterHeyteacherUtilsLocalizationsDelegate
    extends LocalizationsDelegate<FlutterHeyteacherUtilsLocalizations> {
  const _FlutterHeyteacherUtilsLocalizationsDelegate();

  @override
  Future<FlutterHeyteacherUtilsLocalizations> load(Locale locale) {
    return SynchronousFuture<FlutterHeyteacherUtilsLocalizations>(
      lookupFlutterHeyteacherUtilsLocalizations(locale),
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
  bool shouldReload(_FlutterHeyteacherUtilsLocalizationsDelegate old) => false;
}

FlutterHeyteacherUtilsLocalizations lookupFlutterHeyteacherUtilsLocalizations(
  Locale locale,
) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return FlutterHeyteacherUtilsLocalizationsDe();
    case 'en':
      return FlutterHeyteacherUtilsLocalizationsEn();
    case 'es':
      return FlutterHeyteacherUtilsLocalizationsEs();
    case 'fr':
      return FlutterHeyteacherUtilsLocalizationsFr();
    case 'it':
      return FlutterHeyteacherUtilsLocalizationsIt();
    case 'pt':
      return FlutterHeyteacherUtilsLocalizationsPt();
  }

  throw FlutterError(
    'FlutterHeyteacherUtilsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
