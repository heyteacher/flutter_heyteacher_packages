import 'dart:async';

import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_heyteacher_store/flutter_heyteacher_store.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class TtsModel {
  static final _log = Logger("TtsModel");

  late FlutterTts _textToSpeech;

  StreamSubscription? _onUserUpdateStreamSubscription,
      _stateChangesStreamSubscription;

  static TtsModel? _instance;
  static TtsModel get instance => _instance ??= TtsModel._();
  TtsModel._() {
    _log.fine("costructor");
    _textToSpeech = FlutterTts();
    _textToSpeech.awaitSpeakCompletion(true);
    // on authentication user
    _stateChangesStreamSubscription?.cancel();
    _stateChangesStreamSubscription = Auth.instance().stateChangesStream.listen(
        (_) async => _changeLanguage(Auth.instance().autenticated
            ? (await UserStore.instance().getOrNull(Auth.instance().uid))
                ?.locale
                ?.languageCode
            : null));
    // on change unpdate user profile
    _onUserUpdateStreamSubscription?.cancel();
    _onUserUpdateStreamSubscription = UserStore.instance()
        .onUserUpdated
        .listen((user) => _changeLanguage(user.locale?.languageCode));
  }

  dispose() {
    _stateChangesStreamSubscription?.cancel();
    _onUserUpdateStreamSubscription?.cancel();
  }

  Future<void> speak(String text, {double speechRate = 1}) async {
    _log.fine("speak({speechRate:$speechRate}): $text");
    await _textToSpeech.setSpeechRate(speechRate);
    _textToSpeech.speak(text);
  }

  void _changeLanguage(String? languageCode) async =>
      await _textToSpeech.setLanguage(languageCode ?? Intl.getCurrentLocale());
}
