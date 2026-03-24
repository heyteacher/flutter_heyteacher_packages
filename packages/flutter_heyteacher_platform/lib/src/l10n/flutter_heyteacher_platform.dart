import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'flutter_heyteacher_platform_de.dart';
import 'flutter_heyteacher_platform_en.dart';
import 'flutter_heyteacher_platform_es.dart';
import 'flutter_heyteacher_platform_fr.dart';
import 'flutter_heyteacher_platform_it.dart';
import 'flutter_heyteacher_platform_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of FlutterHeyteacherPlatformLocalizations
/// returned by `FlutterHeyteacherPlatformLocalizations.of(context)`.
///
/// Applications need to include `FlutterHeyteacherPlatformLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/flutter_heyteacher_platform.dart';
///
/// return MaterialApp(
///   localizationsDelegates: FlutterHeyteacherPlatformLocalizations.localizationsDelegates,
///   supportedLocales: FlutterHeyteacherPlatformLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the FlutterHeyteacherPlatformLocalizations.supportedLocales
/// property.
abstract class FlutterHeyteacherPlatformLocalizations {
  FlutterHeyteacherPlatformLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static FlutterHeyteacherPlatformLocalizations? of(BuildContext context) {
    return Localizations.of<FlutterHeyteacherPlatformLocalizations>(
      context,
      FlutterHeyteacherPlatformLocalizations,
    );
  }

  static const LocalizationsDelegate<FlutterHeyteacherPlatformLocalizations>
  delegate = _FlutterHeyteacherPlatformLocalizationsDelegate();

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

  /// No description provided for @deviceOfflineAskSupportWhenOnline.
  ///
  /// In en, this message translates to:
  /// **'Device offline. Ask support when the device is connected to the internet.'**
  String get deviceOfflineAskSupportWhenOnline;
}

class _FlutterHeyteacherPlatformLocalizationsDelegate
    extends LocalizationsDelegate<FlutterHeyteacherPlatformLocalizations> {
  const _FlutterHeyteacherPlatformLocalizationsDelegate();

  @override
  Future<FlutterHeyteacherPlatformLocalizations> load(Locale locale) {
    return SynchronousFuture<FlutterHeyteacherPlatformLocalizations>(
      lookupFlutterHeyteacherPlatformLocalizations(locale),
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
  bool shouldReload(_FlutterHeyteacherPlatformLocalizationsDelegate old) =>
      false;
}

FlutterHeyteacherPlatformLocalizations
lookupFlutterHeyteacherPlatformLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return FlutterHeyteacherPlatformLocalizationsDe();
    case 'en':
      return FlutterHeyteacherPlatformLocalizationsEn();
    case 'es':
      return FlutterHeyteacherPlatformLocalizationsEs();
    case 'fr':
      return FlutterHeyteacherPlatformLocalizationsFr();
    case 'it':
      return FlutterHeyteacherPlatformLocalizationsIt();
    case 'pt':
      return FlutterHeyteacherPlatformLocalizationsPt();
  }

  throw FlutterError(
    'FlutterHeyteacherPlatformLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
