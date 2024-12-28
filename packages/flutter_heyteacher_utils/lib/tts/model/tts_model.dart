import 'dart:ui';


import '../../localization/model/localization_model.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

class TtsModel {
  static final _log = Logger("TTSModel");

  late FlutterTts _textToSpeech;

  static TtsModel? _instance;
  static TtsModel get instance => _instance ??= TtsModel._();
  TtsModel._() {
    _log.fine("costructor");
    _textToSpeech = FlutterTts();
    _setAwaitOptions();
    _textToSpeech.setSpeechRate(1);
    LocalizationModel.instance.localeStream.listen(_changeLanguage);
  }

  Future<void> speak(String text) async {
    _log.fine("speak: text");
    _textToSpeech.speak(text);
  }

  Future<void> _setAwaitOptions() async {
    _textToSpeech.awaitSpeakCompletion(true);
  }

  void _changeLanguage(Locale? locale) {
    _textToSpeech.setLanguage(locale?.languageCode ?? Intl.getCurrentLocale());
  }
}
