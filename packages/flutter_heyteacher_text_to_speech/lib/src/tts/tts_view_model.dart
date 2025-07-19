import 'dart:async';

import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class TTSViewModel {
  static final _log = Logger('TtsModel');

  late FlutterTts _textToSpeech;

  String? _previousTextSpeaked;

  StreamSubscription? _onUserUpdateStreamSubscription,
      _stateChangesStreamSubscription;

  static TTSViewModel? _instance;
  static TTSViewModel get instance => _instance ??= TTSViewModel._();
  TTSViewModel._() {
    _textToSpeech = FlutterTts();
    _textToSpeech.awaitSpeakCompletion(false);
    // get locale language 
    final languageCode =
        LocaleViewModel.instance.locale?.languageCode ?? Intl.getCurrentLocale();
    _changeLanguage(languageCode);
    // listen locale languale change  
    _stateChangesStreamSubscription = LocaleViewModel.instance.localeStream
        .listen((locale) => _changeLanguage(locale.languageCode));
  }

  dispose() {
    _stateChangesStreamSubscription?.cancel();
    _onUserUpdateStreamSubscription?.cancel();
  }

  Future<void> speak(String text) async {
    _log.finest('<speak>: text \'$text\'');
    if (_previousTextSpeaked == text) {
    _log.finest('(speak): ignore text equals to previous text \'$text\'');
      return;
    }
    _previousTextSpeaked = text;
    _log.finest('(speak): text \'$text\'');
    _textToSpeech.speak(text);
  }

  void _changeLanguage(String? languageCode) async =>
      await _textToSpeech.setLanguage(languageCode ?? Intl.getCurrentLocale());
}
