library;

/// Provides UI components and a model for viewing and managing application logs.
///
/// Key features include:
/// - [LoggerScreen]: A dedicated screen to display and filter log messages.
/// - [LoggerListTile]: A convenient [ListTile] for navigating to the
///   [LoggerScreen].
/// - [LoggingRouter]: Defines the routing for the logger UI.
/// - [LoggerViewModel]: Handles log capture, configuration (including level
///   setting via Firebase Remote Config), in-memory storage, and forwarding of
///   structured logs to Firebase Analytics.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/info_device_package.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/src/logger/logger_data.dart';
import 'package:flutter_heyteacher_utils/src/logger/logger_view_model.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:go_router/go_router.dart';
import '../../formats.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';



/// Defines the routing for the logger screen.
class LoggingRouter {
  static const String path = 'logging';

  /// Builds a [GoRoute] for the logger screen.
  static GoRoute builder() => GoRoute(
      path: path,
      builder: (BuildContext context, GoRouterState state) =>
          const LoggerScreen());
}

class LoggerCard extends StatelessWidget {
  /// The prefix for the route path to the logger screen.
  final String _pathPrefix;

  /// Creates a [LoggerCard].
  /// Requires a [_pathPrefix] to construct the navigation route.
  const LoggerCard(this._pathPrefix, {super.key});

  @override
  StreamBuilder<bool> build(context) => StreamBuilder<bool>(
      stream: InfoDevicePackageViewModel.instance.tapCounterReachedStream,
      builder: (_, tapCounterReachedSnapshot) => Visibility(
            visible: kDebugMode || (tapCounterReachedSnapshot.data ?? false),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: ListTile(
                  key: const ValueKey('lt_fhu_logger'),
                  leading: const Icon(
                    Icons.list,
                  ),
                  title: Text(
                      FlutterHeyteacherUtilsLocalizations.of(context)!.logging),
                  onTap: () {
                    // Navigates to the logger screen using GoRouter.
                    GoRouter.of(context)
                        .go('$_pathPrefix/${LoggingRouter.path}');
                  },
                  trailing: const Icon(Icons.keyboard_arrow_right),
                ),
              ),
            ),
          ));
}


///
/// A [StatelessWidget] that displays a list of log messages.
/// This screen allows users to view logs and filter them by level.
///
/// It listens to the root logger's `onRecord` stream and updates the UI
/// with new log entries as they arrive.
class LoggerScreen extends StatefulWidget {
  /// Creates a [LoggerScreen].
  const LoggerScreen({super.key});

  @override

  /// Creates the mutable state for this widget.
  State<LoggerScreen> createState() => _LoggerScreenState();
}

class _LoggerScreenState
    extends PagingSliverAnimatedListState<LogEntry, LoggerScreen> {
  /// The currently selected [Level] to filter logs by. If null, no filter is
  /// applied.
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  Widget buildData(int index, Animation<double> animation) =>
      index < (dataList?.length ?? 0)
          ? LogEntryCard(logEntry: dataList!.elementAt(index))
          : const SizedBox.shrink();

  @override
  Future<Iterable<LogEntry>?> initData() async =>
      LoggerViewModel.instance().logs(descending: true, limit: pageSize);

  @override
  bool newData(Iterable<LogEntry> dataList) =>
      (dataList.elementAtOrNull(0)?.time ?? DateTime(1900))
          .isAfter((this.dataList?.elementAtOrNull(0)?.time ?? DateTime(1900)));

  @override
  ScrollController get scrollController => _scrollController;

  @override
  Stream<Iterable<LogEntry>> stream({required int limit}) =>
      LoggerViewModel.instance()
          .logs(
              notSavedLogRecords: LoggerViewModel.instance().notSavedLogRecords,
              descending: true,
              limit: limit)
          .asStream();

  @override
  @protected
  Stream<void> get updateStream => LoggerViewModel.instance().updateStream;


  /// Builds the UI for the logger screen.
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(FlutterHeyteacherUtilsLocalizations.of(context)!.logging),
        actions: [
          _buildLevelFilterDropdown(),
          // add refresh button to reload logs
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: LoggerViewModel.instance().refresh,
          )
        ],
      ),
      body: SafeArea(
          child: CustomScrollView(controller: _scrollController, slivers: [
        super.build(context),
      ])));

  /// Builds the dropdown menu for filtering log levels.
  Widget _buildLevelFilterDropdown() => DropdownMenu<Level?>(
        enableSearch: false,
        enableFilter: false,
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          contentPadding: const EdgeInsets.only(left: 20),
          constraints: BoxConstraints.tight(const Size.fromHeight(40)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        label: Text('Log Level', style: Theme.of(context).textTheme.labelSmall),
        textStyle: Theme.of(context).textTheme.labelSmall,
        trailingIcon: const Icon(Icons.filter_list),
        // Updates the _filterLevel and rebuilds the UI when a new level is
        // selected.
        onSelected: LoggerViewModel.instance().updateFilterLevel,
        dropdownMenuEntries: [
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
                    ))
            .toList(),
      );
}

class LogEntryCard extends StatelessWidget {
  final LogEntry logEntry;
  const LogEntryCard({super.key, required this.logEntry});
  @override
  Widget build(BuildContext context) => Card(
        color: _backgroundColor(logEntry.level),
        child: ListTile(
          leading:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(timeWithSecondsFormatter.format(logEntry.time)),
            Text(logEntry.level.name,
                style: TextStyle(
                    color: _backgroundColor(logEntry.level)
                        ?.withValues(alpha: 0.8))),
          ]),
          title: Text(logEntry.loggerName),
          subtitle: Text(logEntry.message),
          isThreeLine: true,
          trailing: logEntry.error != null
              ? IconButton(
                  icon: const Icon(Icons.info),
                  onPressed: () => showConfirmCancelDialog(
                      context: context,
                      content: '${logEntry.error}\n\n'
                          '${logEntry.stackTrace ?? ''}'),
                )
              : null,
        ),
      );

  /// Determines the background color for a log entry based on its [Level].
  static Color? _backgroundColor(Level level) => switch (level) {
        Level.SHOUT =>
          ThemeViewModel.instance().redColor.withValues(alpha: 0.4),
        Level.SEVERE =>
          ThemeViewModel.instance().redColor.withValues(alpha: 0.4),
        Level.WARNING =>
          ThemeViewModel.instance().orangeColor.withValues(alpha: 0.4),
        Level.CONFIG =>
          ThemeViewModel.instance().orangeColor.withValues(alpha: 0.4),
        Level.CONFIG =>
          ThemeViewModel.instance().yellowColor.withValues(alpha: 0.4),
        Level.INFO =>
          ThemeViewModel.instance().greenColor.withValues(alpha: 0.4),
        _ => ThemeViewModel.instance().blueColor.withValues(alpha: 0.4)
      };
}
