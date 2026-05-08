import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart'
    show FlutterHeyteacherLocaleLocalizations;
import 'package:flutter_heyteacher_logger/flutter_heyteacher_logger.dart'
    show LoggerViewModel;
import 'package:flutter_heyteacher_logger/src/l10n/flutter_heyteacher_logger.dart'
    show FlutterHeyteacherLoggerLocalizations;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ProgressIndicatorWidget;
import 'package:shared_preferences/shared_preferences.dart';

/// A card widget with a [Switch] to enable or disable the storage of logs
/// to the device's file system.
///
/// The user's preference is persisted in [SharedPreferences].
class EnableLogsStorageChoiceListTile extends StatefulWidget {
  /// Creates an [EnableLogsStorageChoiceListTile].
  const EnableLogsStorageChoiceListTile({super.key});

  @override
  State<EnableLogsStorageChoiceListTile> createState() =>
      _EnableLogsStorageChoiceListTileState();
}

class _EnableLogsStorageChoiceListTileState
    extends State<EnableLogsStorageChoiceListTile> {
  bool? _enableLogsStorage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  Future<void> _init(_) async {
    _enableLogsStorage = await LoggerViewModel.instance.enableLogsStorage;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => _enableLogsStorage == null
      ? const ProgressIndicatorWidget()
      : ListTile(
          leading: const Icon(Icons.speaker_phone),
          title: Text(
            FlutterHeyteacherLoggerLocalizations.of(
              context,
            )!.enableLogsStorage,
          ),
          subtitle: Text(
            FlutterHeyteacherLocaleLocalizations.of(context)!.defaultValue(
              FlutterHeyteacherLocaleLocalizations.of(context)!.booleanValue(
                LoggerViewModel.instance.defaultEnableLogsStorage.toString(),
              ),
            ),
          ),
          trailing: Switch(
            // This bool value toggles the switch.
            value: _enableLogsStorage!,
            onChanged: (value) {
              setState(() => _enableLogsStorage = value);
              unawaited(
                LoggerViewModel.instance.setEnableLogsStorage(
                  enableLogsStorage: value,
                ),
              );
            },
          ),
        );
}
