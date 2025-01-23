import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'flutter_heyteacher_utils_en.dart';
import 'flutter_heyteacher_utils_it.dart';

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
  FlutterHeyteacherUtilsLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FlutterHeyteacherUtilsLocalizations? of(BuildContext context) {
    return Localizations.of<FlutterHeyteacherUtilsLocalizations>(context, FlutterHeyteacherUtilsLocalizations);
  }

  static const LocalizationsDelegate<FlutterHeyteacherUtilsLocalizations> delegate = _FlutterHeyteacherUtilsLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @userNotAutenticated.
  ///
  /// In en, this message translates to:
  /// **'User not autenticated'**
  String get userNotAutenticated;

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
  /// **'Timeout on retieve data'**
  String get timeoutOnRetrieveData;

  /// No description provided for @bleAntPlus.
  ///
  /// In en, this message translates to:
  /// **'Ble Ant+ '**
  String get bleAntPlus;

  /// No description provided for @bleAntPlusDevices.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth Low Emission Ant+ Devices'**
  String get bleAntPlusDevices;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'age'**
  String get age;

  /// No description provided for @restBpm.
  ///
  /// In en, this message translates to:
  /// **'rest bpm'**
  String get restBpm;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'gender'**
  String get gender;

  /// No description provided for @genderValue.
  ///
  /// In en, this message translates to:
  /// **'{gender, select, male{Male} female{Female} other{Other}}'**
  String genderValue(String gender);

  /// No description provided for @trainingZoneValue.
  ///
  /// In en, this message translates to:
  /// **'{trainingZone, select, z0{Z0 Rest} z1{Z1 Warm Up} z2{Z2 Fat Burn} z3{Z3 Aerobic} z4{Z4 Anaerobic} z5{Z5 V02 Max} z6{Z6 Death}  other{}}'**
  String trainingZoneValue(String trainingZone);

  /// No description provided for @trainingZone.
  ///
  /// In en, this message translates to:
  /// **'Training Zone'**
  String get trainingZone;

  /// No description provided for @bpm.
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get bpm;

  /// No description provided for @maxRpm.
  ///
  /// In en, this message translates to:
  /// **'Max RPM'**
  String get maxRpm;

  /// No description provided for @minBpm.
  ///
  /// In en, this message translates to:
  /// **'Min Bpm'**
  String get minBpm;

  /// No description provided for @rpm.
  ///
  /// In en, this message translates to:
  /// **'RPM'**
  String get rpm;

  /// No description provided for @maxBpm.
  ///
  /// In en, this message translates to:
  /// **'Max BPM'**
  String get maxBpm;

  /// No description provided for @bleTypeDevice.
  ///
  /// In en, this message translates to:
  /// **'{bleType, select, cadence{Cadence Device} heartRate{Heart Rate Device} other{Unknow}}'**
  String bleTypeDevice(String bleType);

  /// No description provided for @bluetoothAdapterStateIs.
  ///
  /// In en, this message translates to:
  /// **'Bluetooth adapter state is '**
  String get bluetoothAdapterStateIs;

  /// No description provided for @bluetoothAdapterState.
  ///
  /// In en, this message translates to:
  /// **'{bluetoothAdapterState, select, unavailable{Unavailable} unauthorized{Unauthorized} turningOn{Turning On} on{On} turningOff{Turning Off} off{Off} other{Unknow}}'**
  String bluetoothAdapterState(String bluetoothAdapterState);

  /// No description provided for @deviceIsNotBleTypesDevice.
  ///
  /// In en, this message translates to:
  /// **'device is not {bleTypes} device'**
  String deviceIsNotBleTypesDevice(Object bleTypes);
}

class _FlutterHeyteacherUtilsLocalizationsDelegate extends LocalizationsDelegate<FlutterHeyteacherUtilsLocalizations> {
  const _FlutterHeyteacherUtilsLocalizationsDelegate();

  @override
  Future<FlutterHeyteacherUtilsLocalizations> load(Locale locale) {
    return SynchronousFuture<FlutterHeyteacherUtilsLocalizations>(lookupFlutterHeyteacherUtilsLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_FlutterHeyteacherUtilsLocalizationsDelegate old) => false;
}

FlutterHeyteacherUtilsLocalizations lookupFlutterHeyteacherUtilsLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return FlutterHeyteacherUtilsLocalizationsEn();
    case 'it': return FlutterHeyteacherUtilsLocalizationsIt();
  }

  throw FlutterError(
    'FlutterHeyteacherUtilsLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
