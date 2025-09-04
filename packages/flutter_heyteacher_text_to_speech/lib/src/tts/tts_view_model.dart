import 'dart:async';

import 'package:flutter_heyteacher_text_to_speech/src/tts/tts_data.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSViewModel {
  static final _logger = Logger('TTSViewModel');

  late FlutterTts _textToSpeech;

  String? _previousTextSpeaked;

  StreamSubscription? _onUserUpdateStreamSubscription,
      _stateChangesStreamSubscription;

  static TTSViewModel? _instance;

  DateTime? _previousTextSpeakedDateTime;

  static TTSViewModel get instance => _instance ??= TTSViewModel._();
  TTSViewModel._() {
    _textToSpeech = FlutterTts();
    _textToSpeech.awaitSpeakCompletion(false);
    // get locale language
    final languageCode = LocaleViewModel.instance.locale?.languageCode ??
        Intl.getCurrentLocale();
    _changeLanguage(languageCode);
    // listen locale languale change
    _stateChangesStreamSubscription = LocaleViewModel.instance.localeStream
        .listen((locale) => _changeLanguage(locale.languageCode));
  }

  dispose() {
    _stateChangesStreamSubscription?.cancel();
    _onUserUpdateStreamSubscription?.cancel();
  }

  Future<bool> get enabled async =>
      (await SharedPreferencesAsync().getBool(
        TTSPreferencesKeys.htuTtsEnableTTS.name,
      )) ??
      RemoteConfigViewModel.instance.getBool('enableTTS');

  Future<void> speak(String text, {required bool checkTTSThreshold}) async {
    _logger.finest('<speak>: text \'$text\'');
    if (!await enabled) {
      _logger.finest('(speak): TTS enabled, ignored text \'$text\'');
      return;
    }
    if (_previousTextSpeaked == text) {
      _logger.finest('(speak): ignore text equals to previous text \'$text\'');
      return;
    }
    final ttsThresholdInSeconds = RemoteConfigViewModel.instance
        .getInt(TTSRemoteConfigKeys.ttsThresholdInSeconds.name);
    if (checkTTSThreshold &&
        _previousTextSpeakedDateTime != null &&
        DateTime.now().difference(_previousTextSpeakedDateTime!) <
            Duration(seconds: ttsThresholdInSeconds)) {
      _logger.finest('(speak): ignore text \'$text\' too close to previous '
          'speaked at \'$_previousTextSpeakedDateTime\' '
          'ttsThresholdInSeconds $ttsThresholdInSeconds');
      return;
    }
    _previousTextSpeaked = text;
    _previousTextSpeakedDateTime = DateTime.now();
    _logger.finest('(speak): text \'$text\'');
    _textToSpeech.speak(text);
  }

  void _changeLanguage(String? languageCode) async =>
      await _textToSpeech.setLanguage(languageCode ?? Intl.getCurrentLocale());
}
