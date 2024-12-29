import 'dart:async';
import 'dart:ui';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/user_store.dart';
import 'package:logging/logging.dart';

class LocalizationModel {
  final Logger _log = Logger("LocalizationModel");

  final StreamController<Locale?> _localeStreamController =
      StreamController<Locale?>.broadcast();
  Stream<Locale?> get localeStream => _localeStreamController.stream;

  static LocalizationModel? _instance;
  static LocalizationModel get instance => _instance ??= LocalizationModel._();
  LocalizationModel._();

  void init(List<Locale> supportedLocales) async {
    // check if autenticated
    if (Auth.instance().notAutenticated) return;
    // user language code found
    UserData user = await UserStore.instance.exists(Auth.instance().uid!)
        ? await UserStore.instance.get(Auth.instance().uid!)
        : UserData(null);
    if (user.localeLanguageCode != null) {
      // firestore user locale is supported
      if (supportedLocales
          .where(
              (Locale locale) => locale.languageCode == user.localeLanguageCode)
          .isNotEmpty) {
        //feed locale found
        _localeStreamController.sink.add(Locale(user.localeLanguageCode!));
        _log.fine(
            "initLocale: load locale '${user.localeLanguageCode!}' store in user collection");
      } else {
        _log.warning(
            "initLocale: locale '${user.localeLanguageCode!}' store in user not supported. Do nothing");
      }
    } else {
      _log.fine("initLocale: no locale stored in user collection");
    }
  }

  void onChangeLocale(Locale locale) {
    _localeStreamController.sink.add(locale);
    _log.fine("onChangeLocale: load locale '${locale.languageCode}'");
    if (Auth.instance().notAutenticated) return;
    _log.fine(
        "onChangeLocale: store locale '${locale.languageCode}' in user collection");
    UserStore.instance.update(UserData.fromLocalization(locale: locale));
  }
}
