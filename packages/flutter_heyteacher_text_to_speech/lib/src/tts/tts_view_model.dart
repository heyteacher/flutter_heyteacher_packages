import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart';
import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';
import 'package:flutter_heyteacher_text_to_speech/src/tts/tts_data.dart';
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
  TTSViewModel._({
    required bool defaultEnabled,
    required int thresholdInSeconds,
    FlutterTts? ttsForTesting,
  })  : _defaultEnabled = defaultEnabled,
        _thresholdInSeconds = thresholdInSeconds {
    _textToSpeech = ttsForTesting ?? FlutterTts();
    if (PlatformHelper.isMobile || PlatformHelper.isWeb) {
      unawaited(_textToSpeech.awaitSpeakCompletion(false));
      // get locale language
      unawaited(_changeLanguage(LocaleViewModel.instance.locale.languageCode));
      // listen locale languale change
      _stateChangesStreamSubscription = LocaleViewModel.instance.localeStream
          .listen((locale) => _changeLanguage(locale.languageCode));
    }
  }
  static final _logger = Logger('TTSViewModel');

  late FlutterTts _textToSpeech;
  final SharedPreferencesAsync _sharedPreferencesAsync =
      SharedPreferencesAsync();

  final bool _defaultEnabled;
  final int _thresholdInSeconds;
  String? _lastTextSpoken;
  DateTime? _lastTryDateTime;

  /// if TTS is enabled by default
  bool get defaultEnabled => _defaultEnabled;

  /// if threshold in seconds is enabled by default
  int get thresholdInSeconds => _thresholdInSeconds;

  StreamSubscription<Locale>? _stateChangesStreamSubscription;

  static TTSViewModel? _instance;

  /// The singleton instance of [TTSViewModel].
  ///
  /// Set the [defaultEnabled] (default: true) and the [thresholdInSeconds]
  /// (default: 5)
  // ignore: prefer_constructors_over_static_methods
  static TTSViewModel instance({
    bool defaultEnabled = true,
    int thresholdInSeconds = 5,
  }) {
    _instance ??= TTSViewModel._(
      defaultEnabled: defaultEnabled,
      thresholdInSeconds: thresholdInSeconds,
    );
    return _instance!;
  }

  /// Disposes of the resources used by the view model.
  ///
  /// This should be called when the view model is no longer needed to prevent
  /// memory leaks.
  void dispose() {
    unawaited(_stateChangesStreamSubscription?.cancel());
  }

  /// Resets the view model to its initial state.
  Future<void> reset() async {
    _instance = TTSViewModel._(
      defaultEnabled: true,
      thresholdInSeconds: _thresholdInSeconds,
    );
    await _sharedPreferencesAsync
        .remove(TTSPreferencesKeys.htuTtsEnableTTS.name);
    _lastTextSpoken = null;
    _lastTryDateTime = null;
  }

  /// Checks if Text-To-Speech is enabled.
  ///
  /// It first checks the user's preference in [SharedPreferencesAsync].
  Future<bool> get enabled async =>
      (await _sharedPreferencesAsync.getBool(
        TTSPreferencesKeys.htuTtsEnableTTS.name,
      )) ??
      _defaultEnabled;

  /// Set Text-To-Speech is enabled in the user's preference
  /// in [SharedPreferencesAsync].
  Future<void> setEnabled({required bool enabled}) async =>
      _sharedPreferencesAsync.setBool(
        TTSPreferencesKeys.htuTtsEnableTTS.name,
        enabled,
      );

  /// Speaks the given [text] using the TTS engine.
  ///
  /// This method includes several checks:
  /// - It will not speak if TTS is disabled.
  /// - It will not speak if the [text] is the same as the previously spoken
  ///   text.
  /// - If [checkTTSThreshold] is `true`, it will not speak if the time since
  ///   the last speech is less than the threshold defined in remote config
  ///   (`ttsThresholdInSeconds`).
  ///
  /// Returns `true` if [text] is successfully spoken.
  /// Returns `false` if [checkTTSThreshold] is true and try to speak a text
  /// in threshold seconds after previous text.
  Future<bool> speak(String text, {required bool checkTTSThreshold}) async {
    _logger.finest("<speak>: text '$text'");
    if (!await enabled) {
      _logger.finer("(speak): TTS disabled, ignored text '$text'");
      return false;
    }
    if (_lastTextSpoken == text) {
      _logger.finer("(speak): ignore text equals to last '$text'");
      // set the last try date time when the text is delayed
      _lastTryDateTime = clock.now();
      return false;
    }
    // speak in threshold
    if (checkTTSThreshold &&
        _lastTryDateTime != null &&
        clock.now().difference(_lastTryDateTime!) <
            Duration(seconds: _thresholdInSeconds)) {
      final tryDateTime = clock.now();
      // await thresholdInSeconds
      await Future<void>.delayed(
        Duration(seconds: _thresholdInSeconds),
      );
      // if previous text remain equal or no new text has been spoken
      // meantime, ignore text
      if (_lastTextSpoken == text || tryDateTime.isBefore(_lastTryDateTime!)) {
        _logger.finer("(speak): ignore text '$text' too close to previous "
            "speaked at '$_lastTryDateTime' "
            'thresholdInSeconds $_thresholdInSeconds');
        // set the last try date time when the text is delayed
        _lastTryDateTime = tryDateTime;
        return false;
      } else {
        _logger.finer("(speak): text '$text' delayed");
      }
    }
    _lastTextSpoken = text;
    _lastTryDateTime = clock.now();
    _logger.finer("(speak): text '$text'");
    if (!PlatformHelper.isFlutterTest) {
      unawaited(_textToSpeech.speak(text));
    }
    return true;
  }

  Future<void> _changeLanguage(String? languageCode) async =>
      !PlatformHelper.isFlutterTest
          ? _textToSpeech.setLanguage(languageCode ?? Intl.getCurrentLocale())
          : null;
}
