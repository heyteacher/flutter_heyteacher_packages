import 'dart:async';

import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class TtsModel {
  static final _log = Logger('TtsModel');

  late FlutterTts _textToSpeech;

  StreamSubscription? _onUserUpdateStreamSubscription,
      _stateChangesStreamSubscription;

  static TtsModel? _instance;
  static TtsModel get instance => _instance ??= TtsModel._();
  TtsModel._() {
    _textToSpeech = FlutterTts();
    _textToSpeech.awaitSpeakCompletion(true);
    // get locale language 
    final languageCode =
        LocaleModel.instance.locale?.languageCode ?? Intl.getCurrentLocale();
    _changeLanguage(languageCode);
    // listen locale languale change  
    _stateChangesStreamSubscription = LocaleModel.instance.localeStream
        .listen((locale) => _changeLanguage(locale.languageCode));
  }

  dispose() {
    _stateChangesStreamSubscription?.cancel();
    _onUserUpdateStreamSubscription?.cancel();
  }

  Future<void> speak(String text, {double speechRate = 1}) async {
    _log.info('speak({speechRate:$speechRate}): $text');
    await _textToSpeech.setSpeechRate(speechRate);
    _textToSpeech.speak(text);
  }

  void _changeLanguage(String? languageCode) async =>
      await _textToSpeech.setLanguage(languageCode ?? Intl.getCurrentLocale());
}
