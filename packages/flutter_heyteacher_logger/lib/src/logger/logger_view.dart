/// Provides UI components and a model for viewing and managing application
/// logs.
///
/// Key features include:
/// - [LoggerScreen]: A dedicated screen to display and filter log messages.
/// - [LoggingRouter]: Defines the routing for the logger UI.
/// - [LoggerViewModel]: Handles log capture, configuration (including level
///   setting via Firebase Remote Config), in-memory storage, and forwarding of
///   structured logs to Firebase Analytics.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/locale.dart';
import 'package:flutter_heyteacher_logger/logger.dart';
import 'package:flutter_heyteacher_logger/src/logger/logger_data.dart';
import 'package:flutter_heyteacher_platform/platform.dart';
import 'package:flutter_heyteacher_views/views.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Defines the routing for the logger screen.
class LoggingRouter {
  /// The path for the logger screen.
  static const String path = 'logging';

  /// Builds a [GoRoute] for the logger screen.
  static GoRoute builder() => GoRoute(
    path: path,
    builder: (context, state) => const LoggerScreen(),
  );
}

/// A card that provides navigation to the [LoggerScreen].
///
/// This widget is conditionally visible, appearing only when the application
/// is in debug mode (`kDebugMode` is true) or after a specific tap gesture
/// has been registered (listened via
/// `InfoDevicePackageViewModel.tapCounterReachedStream`). This makes it a
/// useful tool for developers and testers without cluttering the release UI.
class LoggerCard extends StatelessWidget {
  /// Creates a [LoggerCard].
  /// Requires a [_pathPrefix] to construct the navigation route.
  const LoggerCard(this._pathPrefix, {super.key});

  /// The prefix for the route path to the logger screen.
  final String _pathPrefix;

  @override
  StreamBuilder<bool> build(BuildContext context) => StreamBuilder<bool>(
    stream: InfoDevicePackageViewModel.instance.tapCounterReachedStream,
    builder: (_, tapCounterReachedSnapshot) => Visibility(
      visible: kDebugMode || (tapCounterReachedSnapshot.data ?? false),
      child: Card(
        child: ListTile(
          key: const ValueKey('lt_fhu_logger'),
          leading: const Icon(Icons.list),
          title: Text(
            FlutterHeyteacherLoggerLocalizations.of(context)!.logging,
          ),
          onTap: () {
            // Navigates to the logger screen using GoRouter.
            GoRouter.of(context).go('$_pathPrefix/${LoggingRouter.path}');
          },
          trailing: const Icon(Icons.keyboard_arrow_right),
        ),
      ),
    ),
  );
}

/// A screen that displays a paginated and filterable list of log messages.
///
/// This screen allows users to view logs, filter them by level and textcontent,
/// and refresh the view. It uses a [PagingSliverAnimatedState] to
/// efficiently handle large numbers of log entries.
class LoggerScreen extends StatefulWidget {
  /// Creates a [LoggerScreen].
  const LoggerScreen({super.key});

  @override
  /// Creates the mutable state for this widget.
  State<LoggerScreen> createState() => _LoggerScreenState();
}

class _LoggerScreenState
    extends PagingSliverAnimatedState<LogEntry, LoggerScreen> {
  /// The currently selected [Level] to filter logs by. If null, no filter is
  /// applied.
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  int get crossAxisCount => 1;

  @override
  double get mainAxisExtent => 85;

  @override
  Widget buildData(
    int index, {
    Animation<double>? animation,
    bool removing = false,
  }) => index < (dataList?.length ?? 0)
      ? LogEntryCard(logEntry: dataList!.elementAt(index))
      : const SizedBox.shrink();

  @override
  Future<Iterable<LogEntry>?> initData() async =>
      LoggerViewModel.instance.logs(descending: true, limit: pageSize);

  @override
  ScrollController get scrollController => _scrollController;

  @override
  Stream<Iterable<LogEntry>> stream({required int limit}) => LoggerViewModel
      .instance
      .logs(
        notSavedLogEntry: LoggerViewModel.instance.notSavedLogEntries,
        descending: true,
        limit: limit,
      )
      .asStream();

  @override
  @protected
  Stream<void> get updateStream => LoggerViewModel.instance.updateStream;

  /// Builds the UI for the logger screen.
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(FlutterHeyteacherLoggerLocalizations.of(context)!.logging),
    ),
    body: SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [_buildFilterDropdown(), super.build(context)],
      ),
    ),
  );

  /// Builds the dropdown menu for filtering log levels.
  Widget _buildFilterDropdown() => PinnedHeaderSliver(
    child: Container(
      padding: const EdgeInsets.only(bottom: 4),
      color: ThemeViewModel.instance.colorScheme.onPrimary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            spacing: 2,
            children: [
              Expanded(
                child: TextField(
                  style: Theme.of(context).textTheme.labelSmall,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints.tight(
                      const Size.fromHeight(40),
                    ),
                    labelText: FlutterHeyteacherLoggerLocalizations.of(
                      context,
                    )!.search,
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                  ),
                  onChanged: LoggerViewModel.instance.updateFilterText,
                ),
              ),
              DropdownMenu<Level?>(
                enableSearch: false,
                inputDecorationTheme: InputDecorationTheme(
                  isDense: true,
                  contentPadding: const EdgeInsets.only(left: 20),
                  constraints: BoxConstraints.tight(const Size.fromHeight(40)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                label: Text(
                  'Log Level',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                textStyle: Theme.of(context).textTheme.labelSmall,
                trailingIcon: const Icon(Icons.filter_list),
                // Updates the _filterLevel and rebuilds the UI when a new
                // level is selected.
                onSelected: LoggerViewModel.instance.updateFilterLevel,
                dropdownMenuEntries:
                    [
                          null,
                          Level.SHOUT,
                          Level.SEVERE,
                          Level.WARNING,
                          Level.CONFIG,
                          Level.INFO,
                          Level.FINE,
                          Level.FINER,
                          Level.FINEST,
                        ]
                        .map<DropdownMenuEntry<Level?>>(
                          (level) => DropdownMenuEntry<Level?>(
                            value: level,
                            label: level?.name ?? '',
                          ),
                        )
                        .toList(),
              ),
              // add refresh button to reload logs
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: LoggerViewModel.instance.refresh,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

/// A card widget that displays a single [LogEntry].
///
/// The card's background color changes based on the log level to provide a
/// quick visual cue (e.g., red for errors, orange for warnings). It shows the
/// timestamp, level, logger name, and message. If an error and stack trace are
/// present, it displays an info icon that reveals them in a dialog when tapped.
class LogEntryCard extends StatelessWidget {
  /// Creates a [LogEntryCard] to display the given [logEntry].
  const LogEntryCard({required LogEntry logEntry, super.key})
    : _logEntry = logEntry;

  final LogEntry _logEntry;
  @override
  Widget build(BuildContext context) => Card(
    color: _backgroundColor(_logEntry.level),
    child: ListTile(
      leading: _buildLeading(),
      title: Text(_logEntry.loggerName),
      subtitle: Text(_logEntry.message),
      trailing: _logEntry.error != null ? _buildTrailing(context) : null,
    ),
  );

  IconButton? _buildTrailing(BuildContext context) => IconButton(
    icon: const Icon(Icons.info),
    onPressed: () => showConfirmCancelDialog<void>(
      backgroundColor: _backgroundColor(_logEntry.level),
      context: context,
      content: ListTile(
        title: Text(_logEntry.error ?? ''),
        subtitle: Text(_logEntry.stackTrace ?? ''),
      ),
    ),
  );

  Column _buildLeading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(FormatterHelper.timeWithSecondsFormat(_logEntry.time)),
        Text(
          _logEntry.level.name,
        ),
      ],
    );
  }

  /// Determines the background color for a log entry based on its [Level].
  static Color? _backgroundColor(Level level) => switch (level) {
    Level.SHOUT => ThemeViewModel.instance.themeBackgroundColor(
      ThemeViewModel.instance.redColor,
    ),
    Level.SEVERE => ThemeViewModel.instance.themeBackgroundColor(
      ThemeViewModel.instance.redColor,
    ),
    Level.WARNING => ThemeViewModel.instance.themeBackgroundColor(
      ThemeViewModel.instance.orangeColor,
    ),
    Level.CONFIG => ThemeViewModel.instance.themeBackgroundColor(
      ThemeViewModel.instance.orangeColor,
    ),
    Level.CONFIG => ThemeViewModel.instance.themeBackgroundColor(
      ThemeViewModel.instance.yellowColor,
    ),
    Level.INFO => ThemeViewModel.instance.themeBackgroundColor(
      ThemeViewModel.instance.greenColor,
    ),
    _ => ThemeViewModel.instance.themeBackgroundColor(
      ThemeViewModel.instance.blueColor,
    ),
  };
}

/// A card widget that provides a dropdown menu to set the application's
/// logging level.
///
/// It displays the current logging level and allows the user to select a new
/// one, which is then persisted via [LoggerViewModel].
class LoggingLevelDropDownMenuCard extends StatefulWidget {
  /// Creates a [LoggingLevelDropDownMenuCard].
  const LoggingLevelDropDownMenuCard({
    required void Function() onChanged,
    super.key,
  }) : _onChanged = onChanged;
  final VoidCallback _onChanged;

  @override
  State<LoggingLevelDropDownMenuCard> createState() =>
      _LoggingLevelDropDownMenuCardState();
}

class _LoggingLevelDropDownMenuCardState
    extends State<LoggingLevelDropDownMenuCard> {
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
  Widget build(BuildContext context) => Card(
    child: ListTile(
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
    ),
  );

  void _onSelected(Level? level, {int? index}) {
    unawaited(LoggerViewModel.instance.setLevel(level, index: index));
    widget._onChanged();
  }
}

/// A card widget with a [Switch] to enable or disable the storage of logs
/// to the device's file system.
///
/// The user's preference is persisted in [SharedPreferences].
class EnableLogsStorageChoiceCard extends StatefulWidget {
  /// Creates an [EnableLogsStorageChoiceCard].
  const EnableLogsStorageChoiceCard({super.key});

  @override
  State<EnableLogsStorageChoiceCard> createState() =>
      _EnableLogsStorageChoiceCardState();
}

class _EnableLogsStorageChoiceCardState
    extends State<EnableLogsStorageChoiceCard> {
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
      : Card(
          child: ListTile(
            leading: const Icon(Icons.speaker_phone),
            title: Text(
              FlutterHeyteacherLoggerLocalizations.of(
                context,
              )!.enableLogsStorage,
            ),
            subtitle: Text(
              FlutterHeyteacherLocaleLocalizations.of(context)!.defaultValue(
                LoggerViewModel.instance.defaultEnableLogsStorage,
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
          ),
        );
}
