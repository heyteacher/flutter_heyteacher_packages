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

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart';
import 'package:flutter_heyteacher_logger/flutter_heyteacher_logger.dart';
import 'package:flutter_heyteacher_logger/src/logger/data/logger_data.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

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
      ? _LogEntryListTile(logEntry: dataList!.elementAt(index))
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
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
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

/// A list tile widget that displays a single [LogEntry].
///
/// The list tile's background color changes based on the log level to provide a
/// quick visual cue (e.g., red for errors, orange for warnings). It shows the
/// timestamp, level, logger name, and message. If an error and stack trace are
/// present, it displays an info icon that reveals them in a dialog when tapped.
class _LogEntryListTile extends StatelessWidget {
  /// Creates a [_LogEntryListTile] to display the given [logEntry].
  const _LogEntryListTile({required LogEntry logEntry}) : _logEntry = logEntry;

  final LogEntry _logEntry;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: _backgroundColor(_logEntry.level),
    child: Column(
      children: [
        ListTile(
          leading: _buildLeading(),
          title: Text(_logEntry.loggerName),
          subtitle: Text(_logEntry.message),
          trailing: _logEntry.error != null ? _buildTrailing(context) : null,
        ),
        const Divider(height: 1, color: Colors.white24),
      ],
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
  static Color _backgroundColor(Level level) =>
      switch (level) {
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
      } ??
      ThemeViewModel.instance.blueColor;
}
