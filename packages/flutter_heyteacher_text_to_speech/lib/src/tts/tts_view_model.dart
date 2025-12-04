import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_heyteacher_text_to_speech/src/tts/tts_data.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A view model that manages Text-To-Speech (TTS) functionality.
///
/// This class is a singleton that handles initializing the TTS engine,
/// setting the language based on the app's locale, and providing a method
/// to speak text with throttling and duplicate-text prevention.
class TTSViewModel {
  TTSViewModel._() {
    _textToSpeech = FlutterTts();
    unawaited(_textToSpeech.awaitSpeakCompletion(false));
    // get locale language
    unawaited(_changeLanguage(LocaleViewModel.instance.locale.languageCode));
    // listen locale languale change
    _stateChangesStreamSubscription = LocaleViewModel.instance.localeStream
        .listen((locale) => _changeLanguage(locale.languageCode));
  }
  static final _logger = Logger('TTSViewModel');

  late FlutterTts _textToSpeech;

  String? _previousTextSpeaked;

  StreamSubscription<Locale>?  _stateChangesStreamSubscription;

  static TTSViewModel? _instance;

  DateTime? _previousTextSpeakedDateTime;

  /// The singleton instance of [TTSViewModel].
  // ignore: prefer_constructors_over_static_methods
  static TTSViewModel get instance => _instance ??= TTSViewModel._();

  /// Disposes of the resources used by the view model.
  ///
  /// This should be called when the view model is no longer needed to prevent
  /// memory leaks.
  void dispose() {
    unawaited(_stateChangesStreamSubscription?.cancel());
  }

  /// Checks if Text-To-Speech is enabled.
  ///
  /// It first checks the user's preference in [SharedPreferencesAsync]. If not
  /// set, it falls back to the value from [RemoteConfigViewModel].
  Future<bool> get enabled async =>
      (await SharedPreferencesAsync().getBool(
        TTSPreferencesKeys.htuTtsEnableTTS.name,
      )) ??
      RemoteConfigViewModel.instance.getBool('enableTTS');

  /// Speaks the given [text] using the TTS engine.
  ///
  /// This method includes several checks:
  /// - It will not speak if TTS is disabled.
  /// - It will not speak if the [text] is the same as the previously spoken 
  ///   text.
  /// - If [checkTTSThreshold] is `true`, it will not speak if the time since
  ///   the last speech is less than the threshold defined in remote config
  ///   (`ttsThresholdInSeconds`).
  Future<void> speak(String text, {required bool checkTTSThreshold}) async {
    _logger.finer("<speak>: text '$text'");
    if (!await enabled) {
      _logger.finer("(speak): TTS disabled, ignored text '$text'");
      return;
    }
    if (_previousTextSpeaked == text) {
      _logger.finer("(speak): ignore text equals to previous text '$text'");
      return;
    }
    final ttsThresholdInSeconds = RemoteConfigViewModel.instance
        .getInt(TTSRemoteConfigKeys.ttsThresholdInSeconds.name);
    if (checkTTSThreshold &&
        _previousTextSpeakedDateTime != null &&
        clock.now().difference(_previousTextSpeakedDateTime!) <
            Duration(seconds: ttsThresholdInSeconds)) {
      _logger.finer("(speak): ignore text '$text' too close to previous "
          "speaked at '$_previousTextSpeakedDateTime' "
          'ttsThresholdInSeconds $ttsThresholdInSeconds');
      return;
    }
    _previousTextSpeaked = text;
    _previousTextSpeakedDateTime = clock.now();
    _logger.finer("(speak): text '$text'");
    unawaited(_textToSpeech.speak(text));
  }

  Future<void> _changeLanguage(String? languageCode) async =>
      _textToSpeech.setLanguage(languageCode ?? Intl.getCurrentLocale());
}
