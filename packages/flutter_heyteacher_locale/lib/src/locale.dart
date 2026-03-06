import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_firebase/firebase.dart';
import 'package:flutter_heyteacher_locale/locale.dart';
import 'package:flutter_heyteacher_text_to_speech/flutter_heyteacher_text_to_speech.dart';
import 'package:flutter_heyteacher_views/views.dart' show ThemeViewModel;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A  [Card] wrap of [ListTile] a [LocaleWrap] with TTS speak test.
class LocaleCard extends StatelessWidget {
  /// Creates a [LocaleCard].
  const LocaleCard({
    Future<void> Function(BuildContext)? onTextToSpeechPressed,
    super.key,
  }) : _onTextToSpeechPressed = onTextToSpeechPressed;

  final Future<void> Function(BuildContext context)? _onTextToSpeechPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        key: const ValueKey('lt_fhu_locale'),
        leading: const Icon(Icons.language),
        trailing: IconButton(
          alignment: Alignment.topRight,
          icon: const Icon(Icons.volume_up),
          onPressed: () =>
              _onTextToSpeechPressed?.call(context) ??
              unawaited(
                TTSViewModel.instance.speak(
                  'Hello World, this is a test. Language is '
                  '${LocaleViewModel.instance.locale.languageCode}, '
                  'country is ${LocaleViewModel.instance.locale.languageCode}',
                  checkTTSThreshold: false,
                ),
              ),
        ),
        title: const LocaleWrap(),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: StreamBuilder(
            stream: LocaleViewModel.instance.localeStream,
            builder: (_, _) => RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: '',
                children: [
                  TextSpan(
                    text: FormatterHelper.dateTimeFormat(
                      DateTime(2020, 6, 30, 22),
                    ),
                    style: TextStyle(
                      color: ThemeViewModel.instance.orangeColor,
                    ),
                  ),
                  const TextSpan(text: '  '),
                  TextSpan(
                    text: FormatterHelper.doubleFormat(12.34),
                    style: TextStyle(color: ThemeViewModel.instance.blueColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A [Wrap] widget that allows users to select the application's [Locale].
///
/// This widget is used to select the locale supported by the app.
class LocaleWrap extends StatefulWidget {
  /// Creates a [LocaleWrap].
  const LocaleWrap({super.key});

  @override
  State<LocaleWrap> createState() => LocaleWrapState<LocaleWrap>();
}

/// The locale Card State
class LocaleWrapState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 4,
    runSpacing: 4,
    alignment: WrapAlignment.spaceEvenly,
    children: LocaleViewModel.instance.supportedLocales
        .map<Widget>(
          (locale) => ChoiceChip(
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 4),
            side: BorderSide.none,
            showCheckmark: false,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            label: Image(
              height: 16,
              width: 16,
              image: AssetImage(
                'assets/locale/${locale.countryCode}.png',
                package: 'flutter_heyteacher_locale',
              ),
            ),
            selected: locale == LocaleViewModel.instance.locale,
            onSelected: (selected) {
              setState(
                () =>
                    LocaleViewModel.instance.locale = selected ? locale : null,
              );
            },
          ),
        )
        .toList(),
  );
}

/// Manages the application's selected [Locale] for localization.
///
/// This class follows a singleton pattern, accessible via
/// `LocaleViewModel.instance`.
///
/// Key functionalities:
/// - Persists the selected [Locale] (by its language code) using
///   [SharedPreferences]
///   (via `SharedPreferencesAsync`).
/// - Exposes a [localeStream] to notify listeners of locale changes.
/// - Allows setting and getting the current application locale.
///
/// The locale is stored under the key `SharedPreferencesKeys.fhuLocale.name`
/// in shared preferences.
/// If no locale is explicitly set or loaded, it defaults to the system's
/// locale or the first supported locale.
class LocaleViewModel {
  /// Private constructor for the singleton.
  /// Initializes the model by attempting to load the persisted locale from
  /// `SharedPreferencesAsync`.
  LocaleViewModel._();

  Iterable<Locale> _supportedLocales = [
    _availableLocales['US']!,
  ];

  /// Returns the supported locales for the app.
  ///
  /// The supported locale are set calling [initLocale].
  Iterable<Locale> get supportedLocales => _supportedLocales;

  /// the supported locales for the app
  static const Map<String, Locale> _availableLocales = {
    'AR': Locale.fromSubtags(languageCode: 'es', countryCode: 'AR'),
    'BR': Locale.fromSubtags(languageCode: 'pt', countryCode: 'BR'),
    'CA': Locale.fromSubtags(languageCode: 'en', countryCode: 'CA'),
    'DE': Locale.fromSubtags(languageCode: 'de', countryCode: 'DE'),
    'ES': Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
    'FR': Locale.fromSubtags(languageCode: 'fr', countryCode: 'FR'),
    'GB': Locale.fromSubtags(languageCode: 'en', countryCode: 'GB'),
    'IT': Locale.fromSubtags(languageCode: 'it', countryCode: 'IT'),
    'PT': Locale.fromSubtags(languageCode: 'pt', countryCode: 'PT'),
    'US': Locale.fromSubtags(languageCode: 'en', countryCode: 'US'),
  };

  static final Locale _defaultLocale =
      LocaleViewModel._availableLocales[PlatformDispatcher
          .instance
          .locale
          .countryCode] ??
      _availableLocales['US']!;

  static LocaleViewModel? _instance;

  /// Provides the singleton instance of [LocaleViewModel].
  // ignore: prefer_constructors_over_static_methods
  static LocaleViewModel get instance => _instance ??= LocaleViewModel._();

  Locale _locale = _defaultLocale;

  /// Gets the current application [Locale].
  ///
  /// This might be `null` initially or if the persisted locale is invalid,
  /// in which case the application might fall back to
  /// `Localizations.localeOf(context)`.
  Locale get locale => _locale;

  /// Sets the [Locale] and saves it to SharedPreferences.
  ///
  /// If [newLocale] is null, set the [_defaultLocale].
  /// Finally, yields [newLocale] to the [localeStream]
  set locale(Locale? newLocale) {
    _locale = newLocale ?? _defaultLocale;
    assert(_locale.countryCode != null, 'country code cannot be null');
    unawaited(
      SharedPreferencesAsync().setString(
        FlutterHeyteacherUtilsSharedPreferencesKeys.fhuCountryCode.name,
        _locale.countryCode!,
      ),
    );
    _localeStreamController.sink.add(_locale);
  }

  /// A stream controller to broadcast locale changes.
  final StreamController<Locale> _localeStreamController =
      StreamController<Locale>.broadcast();

  /// A stream that emits the new [Locale] whenever it changes.
  ///
  /// Widgets can listen to this stream to rebuild when the application's locale
  /// is updated.
  Stream<Locale> get localeStream => _localeStreamController.stream.distinct();

  /// Initializes supported locales and current locale.
  /// 
  /// set the supported locales from [supportedCountries] and set current 
  /// locale loading from [SharedPreferences]
  Future<void> initLocale({
    Iterable<String> supportedCountries = const ['US'],
  }) async {
    _supportedLocales = supportedCountries.map(
      (country) => _localeFromCountryCode(
        countryCode: country,
      ),
    );
    _locale = _localeFromCountryCode(
      countryCode: await SharedPreferencesAsync().getString(
        FlutterHeyteacherUtilsSharedPreferencesKeys.fhuCountryCode.name,
      ),
    );
    await initializeDateFormatting();
    _localeStreamController.sink.add(_locale);
  }

  Locale _localeFromCountryCode({
    required String? countryCode,
  }) => countryCode == null
      ? _defaultLocale
      : _availableLocales[countryCode] ?? _defaultLocale;
}
