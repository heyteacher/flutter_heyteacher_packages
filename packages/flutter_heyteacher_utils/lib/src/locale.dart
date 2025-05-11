import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/l10n/flutter_heyteacher_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleModel {
  static LocaleModel? _instance;
  static LocaleModel get instance => _instance ??= LocaleModel._();
  LocaleModel._();

  final StreamController<Locale> _localeStreamController =
      StreamController<Locale>.broadcast();

  /// stream yield [Locale] changes
  Stream<Locale> get localeStream => _localeStreamController.stream;

  void setLocale(Locale locale) async {
    SharedPreferencesAsync().setString('locale', locale.languageCode);
    _localeStreamController.sink.add(locale);
  }
}

class LocaleListTile extends StatelessWidget {
  const LocaleListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        key: ValueKey("lt_locale"),
        leading: Icon(
          Icons.language,
          size: Theme.of(context).textTheme.displaySmall!.fontSize,
        ),
        title: SegmentedButton<Locale>(
            segments: <ButtonSegment<Locale>>[
              for (Locale locale in FlutterHeyteacherUtilsLocalizations.supportedLocales)
                ButtonSegment<Locale>(
                  value: locale,
                  label: Text(locale.languageCode.toUpperCase()),
                )
            ],
            selected: <Locale>{
              Localizations.localeOf(context)
            },
            onSelectionChanged: (Set<Locale> newSelection) async {
              LocaleModel.instance.setLocale(newSelection.first);
            }));
  }
}
