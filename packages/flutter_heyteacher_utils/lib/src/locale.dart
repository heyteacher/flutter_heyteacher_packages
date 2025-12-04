import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_text_to_speech/flutter_heyteacher_text_to_speech.dart';
import 'package:flutter_heyteacher_utils/src/firebase/remote_config.dart';
import 'package:flutter_heyteacher_utils/src/l10n/flutter_heyteacher_utils.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A [ListTile] widget that allows users to select the application's [Locale].
///
/// This widget is used to select the locale supported by the app.
class LocaleCard extends StatefulWidget {
  /// Creates a [LocaleCard].
  const LocaleCard({super.key});

  @override
  State<LocaleCard> createState() => LocaleCardState<LocaleCard>();
}

/// The locale Card State
class LocaleCardState<T extends StatefulWidget> extends State<T> {
  /// A callback executed when the text-to-speech button is pressed.
  @protected
  Future<void> onTextToSpeechPressed() => TTSViewModel.instance.speak(
    'Hello World, this is a test. Current locale is '
    '${LocaleViewModel.instance.locale.languageCode}',
    checkTTSThreshold: false,
  );

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      key: const ValueKey('lt_fhu_locale'),
      leading: const Icon(Icons.language),
      trailing: IconButton(
        alignment: Alignment.topRight,
        icon: const Icon(Icons.volume_up),
        onPressed: onTextToSpeechPressed,
      ),
      title: Center(
        child: GenericsDropDownMenu<String>(
          enableFilter: false,
          label: FlutterHeyteacherUtilsLocalizations.of(context)!.localeName,
          initialSelection: LocaleViewModel.instance.locale.languageCode,
          onSelected: (languageCode, {index}) {
            LocaleViewModel.instance.setLocaleFromLanguageCode(languageCode);
            setState(() {});
          },
          values: [
            ...FlutterHeyteacherUtilsLocalizations.supportedLocales.map(
              (locale) => (
                label: locale.languageCode,
                value: locale.languageCode,
              ),
            ),
          ],
        ),
      ),
    ),
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
  LocaleViewModel._() {
    // Load the saved locale from SharedPreferences
    unawaited(_initLocale());
  }

  static final Locale _defaultLocale = FlutterHeyteacherUtilsLocalizations
      .supportedLocales
      .singleWhereOrNull(
        (locale) => locale.languageCode.startsWith(
          Intl.getCurrentLocale().substring(0, 2),
        ),
      ) ?? FlutterHeyteacherUtilsLocalizations
      .supportedLocales
      .singleWhereOrNull(
        (locale) => locale.languageCode.startsWith(
          'en',
        )) ?? FlutterHeyteacherUtilsLocalizations.supportedLocales.first;

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
  /// If [languageCode] is null, remove the saved locale from SharedPreferences
  /// and set the locale to null. If [languageCode] is not null, yield the new
  /// locale to the stream
  void setLocaleFromLanguageCode(String? languageCode) {
    _locale = _localeFromLanguageCode(languageCode);
    unawaited(
      SharedPreferencesAsync().setString(
        SharedPreferencesKeys.fhuLocale.name,
        _locale.languageCode,
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

  Locale _localeFromLanguageCode([String? languageCode]) => languageCode == null
      ? _defaultLocale
      : FlutterHeyteacherUtilsLocalizations.supportedLocales
                .where(
                  (locale) =>
                      locale.languageCode.toLowerCase() ==
                      languageCode.toLowerCase(),
                )
                .firstOrNull ??
            _defaultLocale;

  Future<void> _initLocale() async {
    final languageCode = await SharedPreferencesAsync().getString(
      SharedPreferencesKeys.fhuLocale.name,
    );
    _locale = _localeFromLanguageCode(languageCode);
    _localeStreamController.sink.add(_locale);
  }
}
