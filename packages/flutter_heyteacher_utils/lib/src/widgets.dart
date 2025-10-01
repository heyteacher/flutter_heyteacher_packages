/// A collection of reusable Flutter widgets and utility functions,
/// likely intended to streamline UI development within the Flutter application.
///
/// * [FutureStreamBuilder] builder: cleverly combines a [FutureBuilder] with
///   a [StreamBuilder].
///
/// * [showSnackBar] function: displays a SnackBar
///
/// * [showConfirmCancelDialog] function: displays a
///    standard `AlertDialog` to ask the user for confirmation or cancellation
///    of an action.
///
/// * [ProgressIndicatorView] widget: displays a [CircularProgressIndicator]
///    centered on the screen.
///
/// * [ErrorView] widget: displays different error states to the user.
library;

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/router.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// A [StreamBuilder] initialized with a [FutureBuilder].
///
/// It first waits for the [future] (an asynchronous operation that completes
/// once) to provide an initial piece of data. Once that future completes
/// successfully and has data, it then uses that data as the initialData for an
/// inner [StreamBuilder]. This StreamBuilder then listens to the provided
/// [stream] for ongoing updates.
///
/// Useful when you need to fetch an initial state (e.g., from a database or
/// API) and then subscribe to real-time updates for that same data.
class FutureStreamBuilder<T> extends FutureBuilder<T> {
  ///  the [stream] parameter of [StreamBuilder]
  final Stream<T> stream;

  const FutureStreamBuilder({
    super.key,
    required super.future,
    required this.stream,
    required super.builder,
  });

  @override
  AsyncWidgetBuilder<T> get builder =>
      (context, futureSnapshot) => futureSnapshot.hasData
      ? StreamBuilder(
          stream: stream,
          initialData: futureSnapshot.data,
          builder: super.builder,
        )
      : super.builder(context, futureSnapshot);
}

/// Easily display a [SnackBar] (a brief message shown at the bottom of the
/// screen).
///
/// It takes the [BuildContext], the [message] to display, an optional
/// [duration] (in seconds), and a boolean [error] flag to show message in
/// red as an error (othersise in green for succes message)
void showSnackBar({
  required BuildContext? context,
  required String message,
  int? duration,
  bool error = false,
}) => context != null
    ? ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: Duration(
            seconds:
                duration ??
                FirebaseRemoteConfig.instance.getInt(
                  'snackBarDurationInSeconds',
                ),
          ),
          backgroundColor: error
              ? ThemeViewModel.instance.colorScheme.onError
              : ThemeViewModel.instance.greenColor,
          content: Text(
            message,
            style: TextStyle(
              color: error
                  ? ThemeViewModel.instance.colorScheme.error
                  : ThemeViewModel.instance.theme.colorScheme.onPrimary,
            ),
          ),
        ),
      )
    : null;

/// Displays a standard [AlertDialog] to ask the user for confirmation or
/// cancellation of an action.
///
/// It takes the [BuildContext], a [confirmCallback] (executed if the user
/// confirms) and [cancelCallback] (executed if the user cancels), a [param]
/// of type [ObjectParamType] passed to callbacks, the [title] and the [content]
/// of dialog.
Future<void> showConfirmCancelDialog<ObjectParamType>({
  required BuildContext context,
  Future<String?> Function(ObjectParamType?)? confirmCallback,
  Future<String?> Function(ObjectParamType?)? cancelCallback,
  ObjectParamType? param,
  Widget? title,
  required Widget content,
}) async {
  final logger = Logger('showConfirmCancelDialog');
  logger.finest('<showConfirmCancelDialog>: title $title');
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: title != null
            ? Padding(padding: const EdgeInsets.only(top: 8.0), child: title)
            : null,
        content: Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: content,
        ),
        actions: <Widget>[
          IconButton(
            key: const ValueKey('ib_dialog_no'),
            icon: Icon(Icons.close, color: ThemeViewModel.instance.redColor),
            onPressed: () {
              // https://stackoverflow.com/questions/55618717/error-thrown-on-navigator-pop-until-debuglocked-is-not-true
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pop(false);
              });
            },
          ),
          if (confirmCallback != null)
            IconButton(
              key: const ValueKey('ib_dialog_yes'),
              icon: const Icon(Icons.check),
              onPressed: () async {
                // https://stackoverflow.com/questions/55618717/error-thrown-on-navigator-pop-until-debuglocked-is-not-true
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pop(true);
                });
              },
            ),
        ],
      );
    },
  );
  if (confirmCallback != null && confirm != null && confirm) {
    logger.finest('(showConfirmCancelDialog): title $title. Confirm');
    String? message;
    bool errorRaised = false;
    try {
      message = await confirmCallback(param);
    } catch (error, stackTrace) {
      errorRaised = true;
      message = error.toString();
      logger.severe(
        '(showConfirmCancelDialog): title $title. error',
        error,
        stackTrace,
      );
      rethrow;
    } finally {
      if (context.mounted && message != null) {
        showSnackBar(context: context, message: message, error: errorRaised);
      }
    }
  } else {
    if (cancelCallback != null) cancelCallback(param);
  }
}

/// Displays a [Tooltip] button.
///
/// It takes the [title] and the [content] of tooltip showed on pressed
class TooltipIconButton extends StatelessWidget {
  final Widget? title;
  final Widget content;
  final double? iconSize;
  final Color? iconColor;

  const TooltipIconButton({
    super.key,
    this.title,
    required this.content,
    this.iconSize,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) => InkResponse(
    child: Icon(
      Icons.info,
      size: iconSize,
      color: iconColor ?? ThemeViewModel.instance.colorScheme.onSurface,
    ),
    onTap: () => showConfirmCancelDialog(
      context: context,
      title: title ?? const SizedBox.shrink(),
      content: content,
    ),
  );
}

/// Displays a CircularProgressIndicator centered on the screen.
///
/// Typically used to indicate that some background processing or data loading
/// is happening.
class ProgressIndicatorView extends StatefulWidget {
  final Duration timeout;
  final Widget? timeoutWidget;
  final VoidCallback? onTimeout;
  final BoxConstraints? constraints;
  final EdgeInsets? padding;


  const ProgressIndicatorView({
    super.key,
    this.timeout = const Duration(seconds: 15),
    this.timeoutWidget,
    this.onTimeout,
    this.constraints,
    this.padding
  });

  @override
  State<ProgressIndicatorView> createState() => _ProgressIndicatorViewState();
}

class _ProgressIndicatorViewState extends State<ProgressIndicatorView> {
  bool _timeoutReached = false;
  
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.timeout, () {
      mounted ? setState(() => _timeoutReached = true) : null;
      if (widget.onTimeout != null) widget.onTimeout!();
    });
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _timeoutReached
            ? widget.timeoutWidget ?? const SizedBox.shrink()
            : CircularProgressIndicator(constraints: widget.constraints, padding: widget.padding ),
      ],
    ),
  );
}

/// Displays different error states to the user.
///
///  It takes [error] and [stackTrace] raised by [Exception].
///
/// If the exception is a [FirebaseException] with [FirebaseException.code]
/// `permission-denied` it shows a login button to navigate on auth screen.
class ErrorView extends StatelessWidget {
  static final _logger = Logger('ErrorView');

  final Object? error;
  final StackTrace? stackTrace;

  ErrorView(this.error, this.stackTrace, {super.key}) {
    _logger.severe('<ErrorView>', error, stackTrace);
  }

  @override
  Widget build(context) => Scaffold(
    appBar: AppBar(),
    body: _isFirebaseExceptionCode('permission-denied')
        ? Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    textAlign: TextAlign.center,
                    FlutterHeyteacherUtilsLocalizations.of(
                      context,
                    )!.userNotAuthenticated,
                    style: _errorStyleContent(context),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: IconButton(
                    key: const ValueKey('ic_login'),
                    icon: Icon(
                      Icons.login,
                      size: Theme.of(context).textTheme.displayMedium!.fontSize,
                    ),
                    color: Theme.of(context).iconTheme.color,
                    onPressed: () async {
                      GoRouter.of(
                        context,
                      ).pushNamed(AuthRouterName.signIn.name);
                    },
                  ),
                ),
              ),
            ],
          )
        : _isFirebaseExceptionCode('unavailable')
        ? Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    FlutterHeyteacherUtilsLocalizations.of(
                      context,
                    )!.contentUnavailableOfflineRetryWhenOnline,
                    textAlign: TextAlign.center,
                    style: _errorStyleContent(context),
                  ),
                ),
              ),
            ],
          )
        : Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    error.toString(),
                    textAlign: TextAlign.center,
                    style: _errorStyleContent(context),
                  ),
                ),
              ),
            ],
          ),
  );

  bool _isFirebaseExceptionCode(String code) {
    return error == null ||
        (error is FirebaseException &&
            (error as FirebaseException).code == code);
  }

  TextStyle _errorStyleContent(context) => Theme.of(context)
      .textTheme
      .headlineMedium!
      .copyWith(color: ThemeViewModel.instance.colorScheme.onError);
}

/// a Generics implementation of [DropdownMenu].
class GenericsDropDownMenu<T> extends StatefulWidget {
  final String _label;
  final void Function(T?, {int? index}) onSelected;
  final List<({String label, T value})> values;
  final T? initialSelection;
  final bool enableFilter;
  final bool enableSearch;
  final void Function(String, {int? index})? addCallback;
  final int? index;
  final bool isDense;
  final double height;
  final double? width;
  final double menuHeight;
  final List<String> deniedValues;

  const GenericsDropDownMenu({
    super.key,
    required String label,
    required this.onSelected,
    required this.values,
    this.deniedValues = const [],
    this.initialSelection,
    this.enableFilter = true,
    this.enableSearch = false,
    this.addCallback,
    this.index,
    this.isDense = false,
    this.height = 40,
    this.width,
    this.menuHeight = 300,
  }) : _label = label;

  @override
  State<GenericsDropDownMenu<T>> createState() =>
      _GenericsDropDownMenuState<T>();
}

class _GenericsDropDownMenuState<T> extends State<GenericsDropDownMenu<T>> {
  bool _enableAddTag = false;
  String? _filter;
  String? _querySearch;
  final FocusNode _focusNode = FocusNode();
  List<DropdownMenuEntry<T?>>? _lastFilteredEntries;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4.0, left: 1, right: 1.0, bottom: 0),
    child: DropdownMenu<T?>(
      focusNode: _focusNode,
      label: Text(widget._label, style: const TextStyle(fontSize: 11)),
      initialSelection: widget.initialSelection,
      onSelected: _preOnSelected,
      enableSearch: widget.enableSearch,
      searchCallback: widget.enableSearch ? _searchCallback : null,
      requestFocusOnTap: widget.enableFilter || widget.enableSearch,
      enableFilter: widget.enableFilter,
      filterCallback: widget.enableFilter ? _filterCallback : null,
      leadingIcon: widget.addCallback != null && _enableAddTag
          ? IconButton(onPressed: _preAddCallback, icon: const Icon(Icons.add))
          : null,
      trailingIcon: const Icon(Icons.filter_list, applyTextScaling: true),
      textStyle: Theme.of(context).textTheme.labelSmall,
      width: widget.width,
      menuHeight: widget.menuHeight,
      dropdownMenuEntries: [
        DropdownMenuEntry<T?>(value: null, label: ''),
        ...widget.values.map(
          (record) =>
              DropdownMenuEntry<T?>(label: record.label, value: record.value),
        ),
      ],
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.only(left: 8, right: 0),
        isDense: widget.isDense,
        constraints: BoxConstraints.tight(Size.fromHeight(widget.height)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );

  void _preAddCallback() async {
    if (_filter != null || _querySearch != null) {
      final newValue = _filter ?? _querySearch;
      if (widget.deniedValues.contains(newValue)) {
        showSnackBar(
          context: context,
          message: 'cannot add denied value $newValue ',
          error: true,
        );
      } else {
        widget.addCallback?.call(newValue!, index: widget.index);
      }
      _focusNode.unfocus();
      setState(() {
        _enableAddTag = false;
      });
    }
  }

  void _preOnSelected(T? value) {
    widget.onSelected(value, index: widget.index);
    _focusNode.unfocus();
  }

  List<DropdownMenuEntry<T?>> _filterCallback(
    List<DropdownMenuEntry<T?>> entries,
    String filter,
  ) {
    _filter = filter;
    final filteredEntries = [
      DropdownMenuEntry<T?>(value: null, label: ''),
      ...entries.where(
        (entry) =>
            entry.value != null &&
            entry.value!.toString().toLowerCase().contains(
              _filter!.toLowerCase(),
            ),
      ),
    ];
    if ((_filter?.isNotEmpty ?? false) &&
        (_lastFilteredEntries?.length) != filteredEntries.length) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() {
          _enableAddTag =
              (_filter?.isNotEmpty ?? false) && filteredEntries.length == 1;
        }),
      );
    }
    _lastFilteredEntries = filteredEntries;
    return filteredEntries;
  }

  int? _searchCallback(List<DropdownMenuEntry<T?>> entries, String query) {
    _querySearch = query;
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      if (entry.value != null &&
          (_querySearch?.isNotEmpty ?? false) &&
          entry.value!.toString().toLowerCase().contains(
            _querySearch!.toLowerCase(),
          )) {
        if (mounted) {
          _enableAddTag = false;
        }
        return i;
      }
    }
    if (_querySearch?.isNotEmpty ?? false) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => setState(() {
          _enableAddTag = true;
        }),
      );
    }
    return null;
  }
}

class FloatingActionTextIconButtom extends StatelessWidget {
  const FloatingActionTextIconButtom({
    super.key,
    this.fabKey,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
  });

  final Key? fabKey;
  final String text;
  final Widget icon;
  final Color? backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1.0),
    child: SizedBox(
      height: 100,
      width: 100,
      child: FloatingActionButton(
        key: fabKey,
        // heroTag must be set unique in app for each FloatingActionButton
        // to avoid warning introduce by go_router
        heroTag: '${icon}HeroTag',
        backgroundColor: backgroundColor,
        onPressed: onPressed,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.vertical,
          alignment: WrapAlignment.end,
          children: [
            icon,
            Text(
              text,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.labelSmall!.fontSize,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

abstract class TableView extends StatelessWidget {
  /// An abstract base class for creating views with a table-like layout.
  ///
  /// Provides a set of protected helper methods for creating consistently styled
  /// text widgets and dividers, intended for use within a [Table] or similar layout.
  const TableView({super.key});

  @protected
  /// Creates a styled [Text] widget for labels within the table.
  Widget labelText(
    String text, {
    textAlign = TextAlign.right,
    TextStyle? style,
    Widget? tooltip,
  }) => Padding(
    padding: const EdgeInsets.only(right: 4.0, left: 4.0),
    child: Wrap(
      alignment: textAlign == TextAlign.right
          ? WrapAlignment.end
          : WrapAlignment.start,
      children: [
        if (tooltip != null && textAlign == TextAlign.right)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: tooltip,
          ),
        Text(text, textAlign: textAlign, style: style),
        if (tooltip != null && textAlign == TextAlign.left)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: tooltip,
          ),
      ],
    ),
  );

  @protected
  /// Creates a value [Text] widget with a blue color.
  Widget valueTextBlue(
    BuildContext context,
    String text, {
    textAlign = TextAlign.left,
  }) => _valueText(
    context,
    text,
    color: ThemeViewModel.instance.blueColor,
    textAlign: textAlign,
  );

  @protected
  /// Creates a value [Text] widget with an orange color.
  Widget valueTextOrange(
    BuildContext context,
    String text, {
    textAlign = TextAlign.left,
  }) => _valueText(
    context,
    text,
    color: ThemeViewModel.instance.orangeColor,
    textAlign: textAlign,
  );

  @protected
  /// Creates a value [Text] widget with a red color.
  Widget valueTextRed(
    BuildContext context,
    String text, {
    textAlign = TextAlign.left,
  }) => _valueText(
    context,
    text,
    color: ThemeViewModel.instance.redColor,
    textAlign: textAlign,
  );

  @protected
  /// Creates a value [Text] widget with a yellow color.
  Widget valueTextYellow(
    BuildContext context,
    String text, {
    textAlign = TextAlign.left,
  }) => _valueText(
    context,
    text,
    color: ThemeViewModel.instance.yellowColor,
    textAlign: textAlign,
  );

  @protected
  /// Creates a value [Text] widget with a green color.
  Widget valueTextGreen(
    BuildContext context,
    String text, {
    textAlign = TextAlign.left,
  }) => _valueText(
    context,
    text,
    color: ThemeViewModel.instance.greenColor,
    textAlign: textAlign,
  );

  /// A private helper to create a styled [Text] widget for displaying values.
  Widget _valueText(
    BuildContext context,
    String text, {
    textAlign = TextAlign.left,
    Color? color,
  }) => Padding(
    padding: const EdgeInsets.only(left: 4.0, right: 4.0),
    child: Text(text, textAlign: textAlign, style: _textStyle(context, color)),
  );

  /// Returns a [TextStyle] for value widgets, based on the current theme.
  TextStyle _textStyle(BuildContext context, Color? color) =>
      Theme.of(context).textTheme.labelLarge!.copyWith(color: color);
}
