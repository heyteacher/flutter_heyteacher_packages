import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'flutter_heyteacher_auth_de.dart';
import 'flutter_heyteacher_auth_en.dart';
import 'flutter_heyteacher_auth_es.dart';
import 'flutter_heyteacher_auth_fr.dart';
import 'flutter_heyteacher_auth_it.dart';
import 'flutter_heyteacher_auth_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FlutterHeyteacherAuthLocalizations
/// returned by `FlutterHeyteacherAuthLocalizations.of(context)`.
///
/// Applications need to include `FlutterHeyteacherAuthLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/flutter_heyteacher_auth.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FlutterHeyteacherAuthLocalizations.localizationsDelegates,
///   supportedLocales: FlutterHeyteacherAuthLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the FlutterHeyteacherAuthLocalizations.supportedLocales
/// property.
abstract class FlutterHeyteacherAuthLocalizations {
  FlutterHeyteacherAuthLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FlutterHeyteacherAuthLocalizations? of(BuildContext context) {
    return Localizations.of<FlutterHeyteacherAuthLocalizations>(
      context,
      FlutterHeyteacherAuthLocalizations,
    );
  }

  static const LocalizationsDelegate<FlutterHeyteacherAuthLocalizations>
  delegate = _FlutterHeyteacherAuthLocalizationsDelegate();

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

  /// No description provided for @deleteUserData.
  ///
  /// In en, this message translates to:
  /// **'Deletion User Data'**
  String get deleteUserData;
}

class _FlutterHeyteacherAuthLocalizationsDelegate
    extends LocalizationsDelegate<FlutterHeyteacherAuthLocalizations> {
  const _FlutterHeyteacherAuthLocalizationsDelegate();

  @override
  Future<FlutterHeyteacherAuthLocalizations> load(Locale locale) {
    return SynchronousFuture<FlutterHeyteacherAuthLocalizations>(
      lookupFlutterHeyteacherAuthLocalizations(locale),
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
  bool shouldReload(_FlutterHeyteacherAuthLocalizationsDelegate old) => false;
}

FlutterHeyteacherAuthLocalizations lookupFlutterHeyteacherAuthLocalizations(
  Locale locale,
) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return FlutterHeyteacherAuthLocalizationsDe();
    case 'en':
      return FlutterHeyteacherAuthLocalizationsEn();
    case 'es':
      return FlutterHeyteacherAuthLocalizationsEs();
    case 'fr':
      return FlutterHeyteacherAuthLocalizationsFr();
    case 'it':
      return FlutterHeyteacherAuthLocalizationsIt();
    case 'pt':
      return FlutterHeyteacherAuthLocalizationsPt();
  }

  throw FlutterError(
    'FlutterHeyteacherAuthLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
