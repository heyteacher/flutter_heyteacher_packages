import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_text_to_speech/src/l10n/flutter_heyteacher_text_to_speech.dart';
import 'package:flutter_heyteacher_text_to_speech/src/tts/tts_data.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A card widget with a switch to enable or disable Text-To-Speech (TTS).
///
/// This widget displays a `ListTile` with a title, a subtitle showing the
/// default TTS setting from remote config, and a trailing `Switch` to let the
/// user override the setting. The user's preference is persisted in
/// [SharedPreferences].
class EnableTTSChoiceCard extends StatefulWidget {
  /// Creates an [EnableTTSChoiceCard] widget.
  const EnableTTSChoiceCard({super.key});

  @override
  State<EnableTTSChoiceCard> createState() => _EnableTTSChoiceCardState();
}

class _EnableTTSChoiceCardState extends State<EnableTTSChoiceCard> {
  bool? _enableTTS;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  Future<void> _init(Duration _) async {
    _enableTTS = await SharedPreferencesAsync().getBool(
      TTSPreferencesKeys.htuTtsEnableTTS.name,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.speaker_phone),
          title: Text(
            FlutterHeyteacherTextToSpeechLocalizations.of(context)!
                .enableTextToSpeech,
          ),
          subtitle: Text(
            FlutterHeyteacherUtilsLocalizations.of(context)!.defaultValue(
              RemoteConfigViewModel.instance.getBool(
                TTSRemoteConfigKeys.ttsEnable.name,
              ),
            ),
          ),
          trailing: Switch(
            // This bool value toggles the switch.
            value: _enableTTS ??
                RemoteConfigViewModel.instance.getBool(
                  TTSRemoteConfigKeys.ttsEnable.name,
                ),
            onChanged: (bool value) {
              setState(() => _enableTTS = value);
              unawaited(
                SharedPreferencesAsync().setBool(
                  TTSPreferencesKeys.htuTtsEnableTTS.name,
                  value,
                ),
              );
            },
          ),
        ),
      );
}
