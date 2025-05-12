import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/l10n/flutter_heyteacher_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleModel {
  Locale? _locale;

  static LocaleModel? _instance;
  static LocaleModel get instance => _instance ??= LocaleModel._();

  LocaleModel._() {
    SharedPreferencesAsync().getString('locale').then((localeName) {
      _locale = FlutterHeyteacherUtilsLocalizations.supportedLocales
          .firstWhere((locale) => locale.languageCode == localeName);
      if (_locale == null) {
        _localeStreamController.sink.add(_locale!);
      }
    });
  }

  final StreamController<Locale> _localeStreamController =
      StreamController<Locale>.broadcast();

  /// stream yield [Locale] changes
  Stream<Locale> get localeStream => _localeStreamController.stream;

  set locale(Locale? newLocale) {
    _locale = newLocale;
    if (newLocale != null) {
      SharedPreferencesAsync().setString('locale', newLocale.languageCode);
      _localeStreamController.sink.add(newLocale);
    } else {
      SharedPreferencesAsync().remove('locale');
    }
  }

  Locale? get locale => _locale;
}

class LocaleListTile extends StatefulWidget {
  const LocaleListTile({super.key});

  @override
  State<LocaleListTile> createState() => _LocaleListTileState();
}

class _LocaleListTileState extends State<LocaleListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        key: ValueKey("lt_locale"),
        title: SegmentedButton<Locale>(
            segments: <ButtonSegment<Locale>>[
              for (Locale locale
                  in FlutterHeyteacherUtilsLocalizations.supportedLocales)
                ButtonSegment<Locale>(
                  value: locale,
                  label: Text(locale.languageCode),
                )
            ],
            selected: <Locale>{
              LocaleModel.instance.locale ?? Localizations.localeOf(context)
            },
            onSelectionChanged: (Set<Locale> newSelection) async {
              setState(() {
              LocaleModel.instance.locale = newSelection.first;
              });
            }));
  }
}
