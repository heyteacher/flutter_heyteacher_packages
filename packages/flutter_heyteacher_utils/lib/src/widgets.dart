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
  /// Creates a [FutureStreamBuilder].
  const FutureStreamBuilder({
    required super.future,
    required this.stream,
    required super.builder,
    super.key,
  });

  ///  the [stream] parameter of [StreamBuilder]
  final Stream<T> stream;

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
  required Widget content,
  Widget? title,
  ObjectParamType? param,
  Future<String?> Function(ObjectParamType?)? confirmCallback,
  Future<String?> Function(ObjectParamType?)? cancelCallback,
  Duration? timeout,
}) async {
  final logger = Logger('showConfirmCancelDialog')
    ..finer('<showConfirmCancelDialog>:');
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: title != null
          ? Padding(padding: const EdgeInsets.only(top: 8), child: title)
          : null,
      content: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: content,
      ),
      actions: <Widget>[
        IconButton(
          key: const ValueKey('ib_dialog_no'),
          icon: Icon(Icons.close, color: ThemeViewModel.instance.redColor),
          onPressed: () {
            // https://stackoverflow.com/questions/55618717/error-thrown-on-navigator-pop-until-debuglocked-is-not-true
            SchedulerBinding.instance.addPostFrameCallback(
              (_) => Navigator.of(context).pop(false),
            );
          },
        ),
        if (confirmCallback != null)
          IconButton(
            key: const ValueKey('ib_dialog_yes'),
            icon: const Icon(Icons.check),
            onPressed: () async {
              // https://stackoverflow.com/questions/55618717/error-thrown-on-navigator-pop-until-debuglocked-is-not-true
              SchedulerBinding.instance.addPostFrameCallback(
                (_) => Navigator.of(context).pop(true),
              );
            },
          ),
      ],
    ),
  );
  if (confirm != null) {
    if (confirm) {
      logger.finer('(showConfirmCancelDialog): Confirm');
      String? message;
      var errorRaised = false;
      try {
        message = await confirmCallback?.call(param);
      } catch (error, stackTrace) {
        errorRaised = true;
        message = error.toString();
        logger.severe(
          '(showConfirmCancelDialog): error',
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
      logger.finer('(showConfirmCancelDialog): cancel');
      unawaited(cancelCallback?.call(param));
    }
  }
}

/// An icon button that displays an informational dialog when tapped.
///
/// This widget shows an `info` icon. When the user taps on it, a dialog
/// is displayed using [showConfirmCancelDialog], showing the provided [title]
/// and [content]. It's a convenient way to provide more detailed information
/// without cluttering the main UI.
class TooltipIconButton extends StatelessWidget {
  /// Creates a [TooltipIconButton].
  const TooltipIconButton({
    required this.content,
    super.key,
    this.title,
    this.iconSize = 14,
    this.iconColor,
  });

  /// The optional title widget to display at the top of the dialog.
  final Widget? title;

  /// The main content widget to display in the dialog.
  final Widget content;

  /// The size of the info icon.
  ///
  /// Defaults to 14.
  final double iconSize;

  /// The color of the info icon.
  ///
  /// Defaults to the theme's `onSurface` color.
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => InkResponse(
    child: Padding(
      padding: const EdgeInsets.only(left: 3, top: 3),
      child: Icon(
        Icons.info,
        size: iconSize,
        color: iconColor ?? ThemeViewModel.instance.colorScheme.onSurface,
      ),
    ),
    onTap: () => showConfirmCancelDialog<void>(
      context: context,
      title: title ?? const SizedBox.shrink(),
      content: content,
    ),
  );
}

/// A centered [CircularProgressIndicator] that can time out.
///
/// Typically used to indicate that some background processing or data loading
/// is happening. After a specified [timeout], it can display an alternative
/// [timeoutWidget] and trigger an [onTimeout] callback.
class ProgressIndicatorView extends StatefulWidget {
  /// Creates a [ProgressIndicatorView].
  const ProgressIndicatorView({
    super.key,
    this.timeout = const Duration(seconds: 15),
    this.timeoutWidget,
    this.onTimeout,
    this.constraints,
    this.padding,
  });

  /// The duration to wait before the progress indicator times out.
  ///
  /// Defaults to 15 seconds.
  final Duration timeout;

  /// An optional widget to display after the [timeout] duration has passed.
  /// If null, a [SizedBox.shrink] is shown.
  final Widget? timeoutWidget;

  /// An optional callback to be executed when the timeout is reached.
  final VoidCallback? onTimeout;

  /// Optional constraints to apply to the [CircularProgressIndicator].
  final BoxConstraints? constraints;

  /// Optional padding to apply to the [CircularProgressIndicator].
  final EdgeInsets? padding;

  @override
  State<ProgressIndicatorView> createState() => _ProgressIndicatorViewState();
}

class _ProgressIndicatorViewState extends State<ProgressIndicatorView> {
  bool _timeoutReached = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.timeout, () {
      if (mounted) setState(() => _timeoutReached = true);
      widget.onTimeout?.call();
    });
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_timeoutReached)
          widget.timeoutWidget ?? const SizedBox.shrink()
        else
          CircularProgressIndicator(
            constraints: widget.constraints,
            padding: widget.padding,
          ),
      ],
    ),
  );
}

/// A widget that displays a user-friendly screen for different error states.
///
/// It handles specific [FirebaseException] codes to provide contextual
/// feedback and actions:
/// - `permission-denied`: Shows a "user not authenticated" message and a login
///   button to navigate to the sign-in screen.
/// - `unavailable`: Informs the user they are offline and should retry when
///   a connection is available.
///
/// For all other errors, it displays the error's string representation.
/// The error and stack trace are also logged using `Logger`.
class ErrorView extends StatelessWidget {
  /// Creates an [ErrorView] to display information about an [error].
  ///
  /// The [stackTrace] is also logged for debugging purposes.
  ErrorView(this.error, this.stackTrace, {super.key}) {
    _logger.severe('<ErrorView>', error, stackTrace);
  }
  static final _logger = Logger('ErrorView');

  /// The error object to be displayed.
  ///
  /// This is typically an [Exception] or [Error].
  final Object? error;

  /// The stack trace associated with the [error].
  ///
  /// This is used for logging and debugging.
  final StackTrace? stackTrace;

  @override
  Widget build(BuildContext context) => Scaffold(
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
                      unawaited(
                        GoRouter.of(
                          context,
                        ).pushNamed(AuthRouterName.signIn.name),
                      );
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
            (error! as FirebaseException).code == code);
  }

  TextStyle _errorStyleContent(BuildContext context) => Theme.of(context)
      .textTheme
      .headlineMedium!
      .copyWith(color: ThemeViewModel.instance.colorScheme.onError);
}

/// a Generics implementation of [DropdownMenu].
class GenericsDropDownMenu<T> extends StatefulWidget {
  /// Creates a generic dropdown menu.
  const GenericsDropDownMenu({
    required String label,
    required this.onSelected,
    required this.values,
    super.key,
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
  final String _label;

  /// The callback that is called when a new item is selected.
  final void Function(T?, {int? index}) onSelected;

  /// The list of items to display in the dropdown menu.
  final List<({String label, T value})> values;

  /// The initially selected value.
  final T? initialSelection;

  /// Whether to enable filtering of the dropdown menu entries.
  final bool enableFilter;

  /// Whether to enable searching of the dropdown menu entries.
  final bool enableSearch;

  /// A callback to add a new item to the dropdown menu.
  final void Function(String, {int? index})? addCallback;

  /// An optional index to pass to the [onSelected] and [addCallback] callbacks.
  final int? index;

  /// Whether the dropdown menu is dense.
  final bool isDense;

  /// The height of the dropdown menu.
  final double height;

  /// The width of the dropdown menu.
  final double? width;

  /// The height of the dropdown menu's list of entries.
  final double menuHeight;

  /// A list of values that are not allowed to be added.
  final List<String> deniedValues;

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
  Widget build(BuildContext context) => DropdownMenu<T?>(
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
      contentPadding: const EdgeInsets.only(left: 4),
      isDense: widget.isDense,
      constraints: BoxConstraints.tight(Size.fromHeight(widget.height)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  Future<void> _preAddCallback() async {
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
        _lastFilteredEntries?.length != filteredEntries.length) {
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

/// A floating action button with text and an icon.
class FloatingActionTextIconButtom extends StatelessWidget {
  /// Creates a floating action button with text and an icon.
  const FloatingActionTextIconButtom({
    required this.text,
    required this.iconData,
    required this.onPressed,
    super.key,
    this.fabKey,
    this.backgroundColor,
  });

  /// An optional key for the floating action button.
  final Key? fabKey;

  /// The text to display below the icon.
  final String text;

  /// The icon to display.
  final IconData iconData;

  /// The background color of the button.
  final Color? backgroundColor;

  /// The callback that is called when the button is tapped.
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 1),
    child: SizedBox(
      height: 88,
      width: 88,
      child: FloatingActionButton(
        key: fabKey,
        // heroTag must be set unique in app for each FloatingActionButton
        // to avoid warning introduce by go_router
        heroTag: '${iconData}HeroTag',
        backgroundColor: backgroundColor,
        onPressed: onPressed,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          direction: Axis.vertical,
          alignment: WrapAlignment.end,
          children: [
            Icon(size: 72, iconData),
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

/// An abstract base class for creating views with a table-like layout.
///
/// Provides a set of protected helper methods for creating consistently
/// styled text widgets and dividers, intended for use within a [Table]
/// or similar layout.
abstract class TableView extends StatelessWidget {
  /// Creates a [TableView].
  const TableView({super.key});

  @protected
  /// Creates a styled [Text] widget for labels within the table.
  Widget labelText(
    String text, {
    TextAlign textAlign = TextAlign.right,
    TextStyle? style,
    Widget? tooltip,
  }) => Padding(
    padding: const EdgeInsets.only(right: 4, left: 4),
    child: Wrap(
      alignment: textAlign == TextAlign.right
          ? WrapAlignment.end
          : WrapAlignment.start,
      children: [
        if (tooltip != null && textAlign == TextAlign.right)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: tooltip,
          ),
        Text(text, textAlign: textAlign, style: style),
        if (tooltip != null && textAlign == TextAlign.left)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
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
    TextAlign textAlign = TextAlign.left,
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
    TextAlign textAlign = TextAlign.left,
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
    TextAlign textAlign = TextAlign.left,
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
    TextAlign textAlign = TextAlign.left,
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
    TextAlign textAlign = TextAlign.left,
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
    TextAlign textAlign = TextAlign.left,
    Color? color,
  }) => Padding(
    padding: const EdgeInsets.only(left: 4, right: 4),
    child: Text(text, textAlign: textAlign, style: _textStyle(context, color)),
  );

  /// Returns a [TextStyle] for value widgets, based on the current theme.
  TextStyle _textStyle(BuildContext context, Color? color) =>
      Theme.of(context).textTheme.labelLarge!.copyWith(color: color);
}
