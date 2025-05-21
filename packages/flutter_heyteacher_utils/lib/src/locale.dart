import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_text_to_speech/flutter_heyteacher_text_to_speech.dart';
import 'package:flutter_heyteacher_utils/src/l10n/flutter_heyteacher_utils.dart'; // Assuming SharedPreferencesAsync is defined here or re-exported
import 'package:shared_preferences/shared_preferences.dart';

/// A [ListTile] widget that allows users to select the application's [Locale].
///
/// This widget is used to select the locale supported by the app.
class LocaleCard extends StatefulWidget {
  const LocaleCard({super.key});

  @override
  State<LocaleCard> createState() => LocaleCardState<LocaleCard>();
}

class LocaleCardState<T extends StatefulWidget> extends State<T> {
  @protected
  onTextToSpeechPressed() => TtsModel.instance.speak(
      'Hello World, this is a test. Current locale is ${LocaleModel.instance.locale?.languageCode}');

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
            key: const ValueKey('lt_fhu_locale'),
            leading: const Icon(Icons.language),
            trailing: IconButton(
                alignment: Alignment.topRight,
                icon: const Icon(Icons.volume_up),
                onPressed: onTextToSpeechPressed),
            title: Wrap(
              alignment: WrapAlignment.center,
              spacing: 2,
              children: [
                ...FlutterHeyteacherUtilsLocalizations.supportedLocales
                    .map<Widget>((locale) => ChoiceChip(
                          label: Text(locale.languageCode.toUpperCase()),
                          showCheckmark: false,
                          selected: locale ==
                              (LocaleModel.instance.locale ??
                                  Localizations.localeOf(context)),
                          onSelected: (bool selected) {
                            setState(() {
                              LocaleModel.instance.locale =
                                  selected ? locale : null;
                            });
                          },
                        )),
              ],
            )),
      );
}

/// Manages the application's selected [Locale] for localization.
///
/// This class follows a singleton pattern, accessible via `LocaleModel.instance`.
///
/// Key functionalities:
/// - Persists the selected [Locale] (by its language code) using [SharedPreferences]
///   (via a hypothetical `SharedPreferencesAsync`).
/// - Exposes a [localeStream] to notify listeners of locale changes.
/// - Allows setting and getting the current application locale.
///
/// The locale is stored under the key `_sharedPreferencesLocaleKey` in shared preferences.
/// If no locale is explicitly set or loaded, it defaults to the system's locale or the first supported locale.
class LocaleModel {
  Locale? _locale;

  /// The key used to store the selected locale's language code in [SharedPreferences].
  static const _sharedPreferencesLocaleKey = 'fhuLocale';

  static LocaleModel? _instance;

  /// Provides the singleton instance of [LocaleModel].
  static LocaleModel get instance => _instance ??= LocaleModel._();

  /// Private constructor for the singleton.
  /// Initializes the model by attempting to load the persisted locale from [SharedPreferencesAsync].
  LocaleModel._() {
    // Load the saved locale from SharedPreferences
    SharedPreferencesAsync()
        .getString(_sharedPreferencesLocaleKey)
        .then((localeName) {
      _locale = FlutterHeyteacherUtilsLocalizations.supportedLocales
          .where((locale) => locale.languageCode == localeName)
          .firstOrNull;
      if (_locale != null) {
        _localeStreamController.sink.add(_locale!);
      }
    });
  }

  /// A stream controller to broadcast locale changes.
  final StreamController<Locale> _localeStreamController =
      StreamController<Locale>.broadcast();

  /// A stream that emits the new [Locale] whenever it changes.
  ///
  /// Widgets can listen to this stream to rebuild when the application's locale is updated.
  Stream<Locale> get localeStream => _localeStreamController.stream;

  /// Gets the current application [Locale].
  ///
  /// This might be `null` initially or if the persisted locale is invalid,
  /// in which case the application might fall back to `Localizations.localeOf(context)`.
  Locale? get locale => _locale;

  /// set the [Locale] and save it to SharedPreferences.
  ///
  /// If [newLocale] is null, remove the saved locale from SharedPreferences
  /// and set the locale to null. If [newLocale] is not null, yield the new
  /// locale to the stream
  set locale(Locale? newLocale) {
    _locale = newLocale;
    if (newLocale != null) {
      SharedPreferencesAsync()
          .setString(_sharedPreferencesLocaleKey, newLocale.languageCode);
      _localeStreamController.sink.add(newLocale);
    } else {
      SharedPreferencesAsync().remove(_sharedPreferencesLocaleKey);
    }
  }
}
