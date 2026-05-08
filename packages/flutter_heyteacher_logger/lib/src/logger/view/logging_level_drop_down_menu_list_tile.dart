import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart'
    show FlutterHeyteacherLocaleLocalizations;
import 'package:flutter_heyteacher_logger/flutter_heyteacher_logger.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show GenericsDropDownMenu;
import 'package:logging/logging.dart' show Level;

/// A list tile widget that provides a dropdown menu to set the application's
/// logging level.
///
/// It displays the current logging level and allows the user to select a new
/// one, which is then persisted via [LoggerViewModel].
class LoggingLevelDropDownMenuListTile extends StatefulWidget {
  /// Creates a [LoggingLevelDropDownMenuListTile].
  const LoggingLevelDropDownMenuListTile({
    required void Function() onChanged,
    super.key,
  }) : _onChanged = onChanged;
  final VoidCallback _onChanged;

  @override
  State<LoggingLevelDropDownMenuListTile> createState() =>
      _LoggingLevelDropDownMenuListTileState();
}

class _LoggingLevelDropDownMenuListTileState
    extends State<LoggingLevelDropDownMenuListTile> {
  Level? _level;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  Future<void> _init(_) async {
    _level = await LoggerViewModel.instance.level;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.list),
    title: Text(
      FlutterHeyteacherLoggerLocalizations.of(context)!.loggingLevel,
    ),
    subtitle: Text(
      FlutterHeyteacherLocaleLocalizations.of(context)!.defaultValue(
        LoggerViewModel.instance.defaultLevel.name,
      ),
    ),
    trailing: GenericsDropDownMenu<Level>(
      label: FlutterHeyteacherLoggerLocalizations.of(context)!.loggingLevel,
      width: 120,
      isDense: true,
      onSelected: _onSelected,
      values: Level.LEVELS
          .map((level) => (label: level.name, value: level, icon: null))
          .toList(),
      initialSelection: _level,
    ),
  );

  void _onSelected(Level? level, {int? index}) {
    unawaited(LoggerViewModel.instance.setLevel(level, index: index));
    widget._onChanged();
  }
}
