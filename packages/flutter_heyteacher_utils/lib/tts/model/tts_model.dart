import 'dart:async';

import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/user_store.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class TtsModel {
  static final _log = Logger("TTSModel");

  late FlutterTts _textToSpeech;

  StreamSubscription? _streamSubscription;

  static TtsModel? _instance;
  static TtsModel get instance => _instance ??= TtsModel._();
  TtsModel._() {
    _log.fine("costructor");
    _textToSpeech = FlutterTts();
    _setAwaitOptions();
    _streamSubscription?.cancel();
    Auth.instance().stateChangesStream.listen((user) async => _changeLanguage(
        user != null ? await UserStore.instance().getOrNull(user.uid) : null));
    _streamSubscription =
        UserStore.instance().onUserUpdated.listen(_changeLanguage);
  }

  dispose() {
    _streamSubscription?.cancel();
  }

  Future<void> speak(String text, {double speechRate=0}) async {
    _log.fine("speak({speechRate:$speechRate}): $text");
    await _textToSpeech.setSpeechRate(speechRate);
    _textToSpeech.speak(text);
  }

  Future<void> _setAwaitOptions() async {
    _textToSpeech.awaitSpeakCompletion(true);
  }

  void _changeLanguage(UserData? userData) {
    _textToSpeech
        .setLanguage(userData?.locale?.languageCode ?? Intl.getCurrentLocale());
  }
}
