import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'flutter_heyteacher_logger_de.dart';
import 'flutter_heyteacher_logger_en.dart';
import 'flutter_heyteacher_logger_es.dart';
import 'flutter_heyteacher_logger_fr.dart';
import 'flutter_heyteacher_logger_it.dart';
import 'flutter_heyteacher_logger_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FlutterHeyteacherLoggerLocalizations
/// returned by `FlutterHeyteacherLoggerLocalizations.of(context)`.
///
/// Applications need to include `FlutterHeyteacherLoggerLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/flutter_heyteacher_logger.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FlutterHeyteacherLoggerLocalizations.localizationsDelegates,
///   supportedLocales: FlutterHeyteacherLoggerLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the FlutterHeyteacherLoggerLocalizations.supportedLocales
/// property.
abstract class FlutterHeyteacherLoggerLocalizations {
  FlutterHeyteacherLoggerLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FlutterHeyteacherLoggerLocalizations? of(BuildContext context) {
    return Localizations.of<FlutterHeyteacherLoggerLocalizations>(
      context,
      FlutterHeyteacherLoggerLocalizations,
    );
  }

  static const LocalizationsDelegate<FlutterHeyteacherLoggerLocalizations>
  delegate = _FlutterHeyteacherLoggerLocalizationsDelegate();

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

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @enableLogsStorage.
  ///
  /// In en, this message translates to:
  /// **'Enable Logs Storage'**
  String get enableLogsStorage;
}

class _FlutterHeyteacherLoggerLocalizationsDelegate
    extends LocalizationsDelegate<FlutterHeyteacherLoggerLocalizations> {
  const _FlutterHeyteacherLoggerLocalizationsDelegate();

  @override
  Future<FlutterHeyteacherLoggerLocalizations> load(Locale locale) {
    return SynchronousFuture<FlutterHeyteacherLoggerLocalizations>(
      lookupFlutterHeyteacherLoggerLocalizations(locale),
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
  bool shouldReload(_FlutterHeyteacherLoggerLocalizationsDelegate old) => false;
}

FlutterHeyteacherLoggerLocalizations lookupFlutterHeyteacherLoggerLocalizations(
  Locale locale,
) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return FlutterHeyteacherLoggerLocalizationsDe();
    case 'en':
      return FlutterHeyteacherLoggerLocalizationsEn();
    case 'es':
      return FlutterHeyteacherLoggerLocalizationsEs();
    case 'fr':
      return FlutterHeyteacherLoggerLocalizationsFr();
    case 'it':
      return FlutterHeyteacherLoggerLocalizationsIt();
    case 'pt':
      return FlutterHeyteacherLoggerLocalizationsPt();
  }

  throw FlutterError(
    'FlutterHeyteacherLoggerLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
