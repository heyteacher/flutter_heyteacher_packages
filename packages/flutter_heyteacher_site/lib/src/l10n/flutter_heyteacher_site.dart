import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'flutter_heyteacher_site_de.dart';
import 'flutter_heyteacher_site_en.dart';
import 'flutter_heyteacher_site_es.dart';
import 'flutter_heyteacher_site_fr.dart';
import 'flutter_heyteacher_site_it.dart';
import 'flutter_heyteacher_site_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FlutterHeyteacherSiteLocalizations
/// returned by `FlutterHeyteacherSiteLocalizations.of(context)`.
///
/// Applications need to include `FlutterHeyteacherSiteLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/flutter_heyteacher_site.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FlutterHeyteacherSiteLocalizations.localizationsDelegates,
///   supportedLocales: FlutterHeyteacherSiteLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the FlutterHeyteacherSiteLocalizations.supportedLocales
/// property.
abstract class FlutterHeyteacherSiteLocalizations {
  FlutterHeyteacherSiteLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FlutterHeyteacherSiteLocalizations? of(BuildContext context) {
    return Localizations.of<FlutterHeyteacherSiteLocalizations>(
      context,
      FlutterHeyteacherSiteLocalizations,
    );
  }

  static const LocalizationsDelegate<FlutterHeyteacherSiteLocalizations>
  delegate = _FlutterHeyteacherSiteLocalizationsDelegate();

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

  /// No description provided for @cookieSettings.
  ///
  /// In en, this message translates to:
  /// **'Cookie Settings'**
  String get cookieSettings;

  /// No description provided for @cookieMessage.
  ///
  /// In en, this message translates to:
  /// **'This website collects cookies to deliver better user experience.\nFor more information, visit our Cookies Policy.'**
  String get cookieMessage;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get decline;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;
}

class _FlutterHeyteacherSiteLocalizationsDelegate
    extends LocalizationsDelegate<FlutterHeyteacherSiteLocalizations> {
  const _FlutterHeyteacherSiteLocalizationsDelegate();

  @override
  Future<FlutterHeyteacherSiteLocalizations> load(Locale locale) {
    return SynchronousFuture<FlutterHeyteacherSiteLocalizations>(
      lookupFlutterHeyteacherSiteLocalizations(locale),
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
  bool shouldReload(_FlutterHeyteacherSiteLocalizationsDelegate old) => false;
}

FlutterHeyteacherSiteLocalizations lookupFlutterHeyteacherSiteLocalizations(
  Locale locale,
) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return FlutterHeyteacherSiteLocalizationsDe();
    case 'en':
      return FlutterHeyteacherSiteLocalizationsEn();
    case 'es':
      return FlutterHeyteacherSiteLocalizationsEs();
    case 'fr':
      return FlutterHeyteacherSiteLocalizationsFr();
    case 'it':
      return FlutterHeyteacherSiteLocalizationsIt();
    case 'pt':
      return FlutterHeyteacherSiteLocalizationsPt();
  }

  throw FlutterError(
    'FlutterHeyteacherSiteLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
