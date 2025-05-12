library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/l10n/flutter_heyteacher_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The [Locale] list tile widget.
///
/// This widget is used to select the locale supported by the app.
class LocaleListTile extends StatefulWidget {
  const LocaleListTile({super.key});

  @override
  State<LocaleListTile> createState() => _LocaleListTileState();
}

class _LocaleListTileState extends State<LocaleListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const Icon(Icons.language),
        key: ValueKey("lt_fhu_locale"),
        title: Wrap(
          alignment: WrapAlignment.spaceEvenly,
          spacing: 2,
          children: [
            ...FlutterHeyteacherUtilsLocalizations.supportedLocales
                .map<Widget>((locale) => ChoiceChip(
                      label: Text(locale.languageCode),
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
        ));
  }
}

/// The [Locale] model class is used to manage the app's supporded locale.
///
/// The locale is saved in the [SharedPreferencesAsync] on key `fhu_locale`.
/// Locale changes are yield on [localeStream].
class LocaleModel {
  Locale? _locale;

  static const _sharedPreferencesLocaleKey = 'fhuLocale';

  static LocaleModel? _instance;
  static LocaleModel get instance => _instance ??= LocaleModel._();

  /// Private constructor to prevent instantiation
  /// of the class from outside.
  /// This constructor loads the saved locale from [SharedPreferencesAsync]
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

  final StreamController<Locale> _localeStreamController =
      StreamController<Locale>.broadcast();

  /// stream yield [Locale] changes
  Stream<Locale> get localeStream => _localeStreamController.stream;

  /// get the current [Locale]
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
