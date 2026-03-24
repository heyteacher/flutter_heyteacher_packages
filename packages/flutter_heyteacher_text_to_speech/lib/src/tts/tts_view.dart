import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart'
    show FlutterHeyteacherLocaleLocalizations;
import 'package:flutter_heyteacher_text_to_speech/src/l10n/flutter_heyteacher_text_to_speech.dart';
import 'package:flutter_heyteacher_text_to_speech/src/tts/tts_view_model.dart';
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
    _enableTTS = await TTSViewModel.instance().enabled;
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
            FlutterHeyteacherLocaleLocalizations.of(context)!.defaultValue(
              TTSViewModel.defaultEnabled,
            ),
          ),
          trailing: Switch(
            // This bool value toggles the switch.
            value: _enableTTS ?? TTSViewModel.defaultEnabled,
            onChanged: (value) {
              setState(() => _enableTTS = value);
              unawaited(TTSViewModel.instance().setEnabled(enabled: value));
            },
          ),
        ),
      );
}
