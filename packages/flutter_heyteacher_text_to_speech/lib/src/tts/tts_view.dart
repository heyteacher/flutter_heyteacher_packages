import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_text_to_speech/src/l10n/flutter_heyteacher_text_to_speech.dart';
import 'package:flutter_heyteacher_text_to_speech/src/tts/tts_data.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnableTTSDropDownMenuCard extends StatefulWidget {
  const EnableTTSDropDownMenuCard({super.key});

  @override
  State<EnableTTSDropDownMenuCard> createState() =>
      _EnableTTSDropDownMenuCardState();
}

class _EnableTTSDropDownMenuCardState extends State<EnableTTSDropDownMenuCard> {
  bool _enableTTS = RemoteConfigViewModel.instance.getBool(
    TTSRemoteConfigKeys.ttsEnable.name,
  );

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.speaker_phone),
          title: Text(FlutterHeyteacherTextToSpeechLocalizations.of(context)!
              .enableTextToSpeech),
          subtitle: Text(
            FlutterHeyteacherUtilsLocalizations.of(context)!.defaultValue(
              RemoteConfigViewModel.instance.getBool(
                TTSRemoteConfigKeys.ttsEnable.name,
              ),
            ),
          ),
          trailing: FutureBuilder(
            future: SharedPreferencesAsync().getBool(
              TTSPreferencesKeys.htuTtsEnableTTS.name,
            ),
            builder: (context, asyncSnapshot) => Switch(
              // This bool value toggles the switch.
              value: asyncSnapshot.data ?? _enableTTS,
              onChanged: (bool value) {
                setState(() => _enableTTS = value);
                SharedPreferencesAsync().setBool(
                  TTSPreferencesKeys.htuTtsEnableTTS.name,
                  value,
                );
              },
            ),
          ),
        ),
      );
}
