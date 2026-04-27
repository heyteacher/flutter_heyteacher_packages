import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart'
    show FlutterHeyteacherLocaleLocalizations;
import 'package:flutter_heyteacher_text_to_speech/src/l10n/flutter_heyteacher_text_to_speech.dart';
import 'package:flutter_heyteacher_text_to_speech/src/tts/tts_view_model.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show GenericsDropDownMenu;
import 'package:shared_preferences/shared_preferences.dart';

/// A card widget with a switch to enable or disable Text-To-Speech (TTS).
///
/// This widget displays a `ListTile` with a title, a subtitle showing the
/// default TTS setting from remote config, and a trailing `Switch` to let the
/// user override the setting. The user's preference is persisted in
/// [SharedPreferences].
class TTSEnableChoiceCard extends StatefulWidget {
  /// Creates an [TTSEnableChoiceCard] widget.
  const TTSEnableChoiceCard({super.key});

  @override
  State<TTSEnableChoiceCard> createState() => _TTSEnableChoiceCardState();
}

class _TTSEnableChoiceCardState extends State<TTSEnableChoiceCard> {
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
              FlutterHeyteacherLocaleLocalizations.of(context)!.booleanValue(
                TTSViewModel.instance().defaultEnabled.toString(),
              ),
            ),
          ),
          trailing: Switch(
            // This bool value toggles the switch.
            value: _enableTTS ?? TTSViewModel.instance().defaultEnabled,
            onChanged: (value) {
              setState(() => _enableTTS = value);
              unawaited(TTSViewModel.instance().setEnabled(enabled: value));
            },
          ),
        ),
      );
}

/// A card widget that provides a dropdown menu to set the threshold in seconds.
class TTSThresholdInSecondsCard extends StatefulWidget {
  /// Creates a [TTSThresholdInSecondsCard].
  const TTSThresholdInSecondsCard({
    super.key,
  });

  @override
  State<TTSThresholdInSecondsCard> createState() =>
      _TTSThresholdInSecondsCardState();
}

class _TTSThresholdInSecondsCardState extends State<TTSThresholdInSecondsCard> {
  int? _thresholdInSeconds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  Future<void> _init([dynamic _]) async {
    _thresholdInSeconds = await TTSViewModel.instance().thresholdInSeconds;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: const Icon(Icons.list),
          title: Text(
            FlutterHeyteacherTextToSpeechLocalizations.of(context)!
                .thresholdInSeconds,
          ),
          subtitle: Text(
            FlutterHeyteacherLocaleLocalizations.of(context)!.defaultValue(
              5,
            ),
          ),
          trailing: GenericsDropDownMenu<int>(
            label: FlutterHeyteacherTextToSpeechLocalizations.of(context)!
                .thresholdInSeconds,
            width: 120,
            isDense: true,
            onSelected: _onSelected,
            values: [1, 2, 5, 10, 20, 50]
                .map(
                  (thresholdInSeconds) => (
                    label: thresholdInSeconds.toString(),
                    value: thresholdInSeconds,
                    icon: null
                  ),
                )
                .toList(),
            initialSelection: _thresholdInSeconds,
          ),
        ),
      );

  void _onSelected(int? level, {int? index}) {
    unawaited(
      TTSViewModel.instance().setThresholdInSeconds(thresholdInSeconds: level!),
    );
  }
}
