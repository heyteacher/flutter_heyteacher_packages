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

  const FutureStreamBuilder(
      {super.key,
      required super.future,
      required this.stream,
      required super.builder});

  @override
  AsyncWidgetBuilder<T> get builder =>
      (context, futureSnapshot) => futureSnapshot.hasData
          ? StreamBuilder(
              stream: stream,
              initialData: futureSnapshot.data,
              builder: super.builder)
          : super.builder(context, futureSnapshot);
}

/// Easily display a [SnackBar] (a brief message shown at the bottom of the
/// screen).
///
/// It takes the [BuildContext], the [message] to display, an optional
/// [duration] (in seconds), and a boolean [error] flag to show message in
/// red as an error (othersise in green for succes message)
void showSnackBar(
        {required BuildContext? context,
        required String message,
        int? duration,
        bool error = false}) =>
    context != null
        ? ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                duration: Duration(
                    seconds: duration ??
                        FirebaseRemoteConfig.instance
                            .getInt('snackBarDurationInSeconds')),
                backgroundColor: error
                    ? ThemeViewModel.instance().colorScheme.onError
                    : ThemeViewModel.instance().greenColor,
                content: Text(message,
                    style: TextStyle(
                        color: error
                            ? ThemeViewModel.instance().colorScheme.error
                            : ThemeViewModel.instance()
                                .theme
                                .colorScheme
                                .onPrimary))),
          )
        : null;

/// Displays a standard [AlertDialog] to ask the user for confirmation or
/// cancellation of an action.
///
/// It takes the [BuildContext], a [confirmCallback] (executed if the user
/// confirms) and [cancelCallback] (executed if the user cancels), a [param]
/// of type [ObjectParamType] passed to callbacks, the [title] and the [content]
/// of dialog.
Future<void> showConfirmCancelDialog<ObjectParamType>(
    {required BuildContext context,
    Future<String?> Function(ObjectParamType?)? confirmCallback,
    Future<String?> Function(ObjectParamType?)? cancelCallback,
    ObjectParamType? param,
    String? title,
    required String content}) async {
  final logger = Logger('showConfirmCancelDialog');
  logger.finest('<showConfirmCancelDialog>: title $title');
  final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: title != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(textAlign: TextAlign.center, title),
                )
              : null,
          content: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(textAlign: TextAlign.center, content)),
          actions: <Widget>[
            IconButton(
              key: const ValueKey('ib_dialog_no'),
              icon: Icon(Icons.close,
                  color: ThemeViewModel.instance().colorScheme.onError),
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
      });
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
          '(showConfirmCancelDialog): title $title. error', error, stackTrace);
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

/// Displays a CircularProgressIndicator centered on the screen.
///
/// Typically used to indicate that some background processing or data loading
/// is happening.
class ProgressIndicatorView extends StatefulWidget {
  final Duration timeout;
  const ProgressIndicatorView({
    super.key,
    this.timeout = const Duration(seconds: 15),
  });

  @override
  State<ProgressIndicatorView> createState() => _ProgressIndicatorViewState();
}

class _ProgressIndicatorViewState extends State<ProgressIndicatorView> {
  bool _timeoutReached = false;
  @override
  void initState() {
    super.initState();
    Future.delayed(widget.timeout,
        () => mounted ? setState(() => _timeoutReached = true) : null);
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          _timeoutReached
              ? Text('', style: _noDataStyleContent(context))
              : const CircularProgressIndicator()
        ]),
      );

  TextStyle _noDataStyleContent(context) => Theme.of(context)
      .textTheme
      .headlineMedium!
      .copyWith(color: ThemeViewModel.instance().orangeColor);
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
            ? Column(children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                        textAlign: TextAlign.center,
                        FlutterHeyteacherUtilsLocalizations.of(context)!
                            .userNotAutenticated,
                        style: _errorStyleContent(context)),
                  ),
                ),
                Expanded(
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: IconButton(
                          key: const ValueKey('ic_login'),
                          icon: Icon(Icons.login,
                              size: Theme.of(context)
                                  .textTheme
                                  .displayMedium!
                                  .fontSize),
                          color: Theme.of(context).iconTheme.color,
                          onPressed: () async {
                            GoRouter.of(context).pushNamed('auth-sign-in');
                          })),
                ),
              ])
            : _isFirebaseExceptionCode('unavailable')
                ? Column(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                              FlutterHeyteacherUtilsLocalizations.of(context)!
                                  .contentUnavailableOfflineRetryWhenOnline,
                              textAlign: TextAlign.center,
                              style: _errorStyleContent(context)),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(error.toString(),
                              textAlign: TextAlign.center,
                              style: _errorStyleContent(context)),
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
      .copyWith(color: ThemeViewModel.instance().colorScheme.onError);
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
        padding:
            const EdgeInsets.only(top: 4.0, left: 1, right: 1.0, bottom: 0),
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
              ? IconButton(
                  onPressed: _preAddCallback, icon: const Icon(Icons.add))
              : null,
          trailingIcon: const Icon(Icons.filter_list, applyTextScaling: true),
          textStyle: Theme.of(context).textTheme.labelSmall,
          width: widget.width,
          menuHeight: widget.menuHeight,
          dropdownMenuEntries: [
            DropdownMenuEntry<T?>(value: null, label: ''),
            ...widget.values.map((record) =>
                DropdownMenuEntry<T?>(label: record.label, value: record.value))
          ],
          inputDecorationTheme: InputDecorationTheme(
            contentPadding: const EdgeInsets.only(left: 8, right: 0),
            isDense: widget.isDense,
            constraints: BoxConstraints.tight(Size.fromHeight(widget.height)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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
            error: true);
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
      List<DropdownMenuEntry<T?>> entries, String filter) {
    _filter = filter;
    final filteredEntries = [
      DropdownMenuEntry<T?>(value: null, label: ''),
      ...entries.where((entry) =>
          entry.value != null &&
          entry.value!
              .toString()
              .toLowerCase()
              .contains(_filter!.toLowerCase()))
    ];
    if ((_filter?.isNotEmpty ?? false) &&
        (_lastFilteredEntries?.length) != filteredEntries.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
            _enableAddTag =
                (_filter?.isNotEmpty ?? false) && filteredEntries.length == 1;
          }));
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
          entry.value!
              .toString()
              .toLowerCase()
              .contains(_querySearch!.toLowerCase())) {
        if (mounted) {
          _enableAddTag = false;
        }
        return i;
      }
    }
    if (_querySearch?.isNotEmpty ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {
            _enableAddTag = true;
          }));
    }
    return null;
  }
}

class BlinkingText extends StatefulWidget {
  final String text;
  final bool animated;
  final int durationInMs;
  final TextStyle? style;
  final TextAlign? textAlign;

  const BlinkingText(this.text,
      {super.key,
      this.animated = true,
      this.durationInMs = 500,
      this.style,
      this.textAlign});

  @override
  BlinkingTextState createState() => BlinkingTextState();
}

class BlinkingTextState extends State<BlinkingText> {
  bool _isVisible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Set a timer to toggle visibility every 500 milliseconds
    _timer?.cancel();
    _timer =
        Timer.periodic(Duration(milliseconds: widget.durationInMs), (timer) {
      setState(() => _isVisible = !_isVisible);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.animated
        ? TweenAnimationBuilder<double>(
            tween: Tween<double>(
                begin: _isVisible ? 1 : 0, end: _isVisible ? 0 : 1),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            builder: (BuildContext context, double opacity, Widget? child) {
              return Opacity(
                opacity: opacity,
                child: _text,
              );
            },
          )
        : _text;
  }

  Text get _text {
    return Text(
      widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
    );
  }
}

/// An abstract `State` class for creating a paginated `SliverAnimatedList` that
/// is populated from a `Stream`.
///
/// It simplifies the common pattern of displaying a list of data that is fetched
/// in pages as the user scrolls down. It also handles real-time updates, such
/// as inserting new items at the top of the list with an animation.
abstract class PagingSliverAnimatedListState<D, T extends StatefulWidget>
    extends State<T> {
  /// The current list of data items displayed in the list.
  @protected
  List<D>? dataList;

  /// The number of items to fetch in each page. Defaults to 10.
  @protected
  int get pageSize => 10;

  /// The current limit for the number of items to fetch from the [stream].
  ///
  /// This value is increased by [pageSize] when the user scrolls to the end
  /// of the list.
  late int _limit = pageSize;

  /// A global key for the [SliverAnimatedList] to manage its state,
  /// such as inserting or removing items.
  final GlobalKey<SliverAnimatedListState> _listGlobalKey =
      GlobalKey<SliverAnimatedListState>();

  /// The subscription to the data stream.
  StreamSubscription? _listStreamSubscription, _updateStreamSubscription;

  bool _loading = false;

  /// The [ScrollController] attached to the scroll view containing the list.
  ///
  /// This is used to detect when the user has scrolled to the end of the list
  /// to trigger pagination.
  @protected
  ScrollController get scrollController;

  /// The stream of data for the list.
  ///
  /// This method is called to get the stream of items to display. The [limit]
  /// parameter should be used to control the number of items fetched.
  @protected
  Stream<Iterable<D>> stream({required int limit});

  /// The stream which notify that widget should be updated.
  ///
  /// Inform widget that needed to be updated. Tipically a new filter is applied.
  @protected
  Stream<void> get updateStream;

  /// Builds the widget for a single item in the list.
  ///
  /// The [index] is the position of the item in [dataList], and the
  /// [animation] should be used to animate the item's appearance (e.g.,
  /// inside a [SizeTransition]).
  @protected
  Widget buildData(int index, Animation<double> animation);

  /// Fetches the initial data for the list.
  ///
  /// This method is called once in [initState] to populate the list before
  /// the stream subscription starts. It can return `null` or an empty list
  /// if no initial data is available.
  @protected
  Future<Iterable<D>?> initData() async {
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => initPostFrame());
  }

  /// Initializes the state after the first frame is built.
  ///
  /// Fetches initial data, sets up the list, and adds a scroll listener
  /// for pagination.
  Future<void> initPostFrame() async {
    setState(() => _loading = true);
    dataList = (await initData())?.toList();
    if (dataList != null) {
      setState(() => _loading = false);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _listGlobalKey.currentState != null) {
        _listGlobalKey.currentState?.insertAllItems(0, dataList!.length);
      }
    }
    _updateStreamSubscription?.cancel();
    _updateStreamSubscription = updateStream.listen((_) => updateDataList());
    _checkScollPosition();
    scrollController.addListener(_checkScollPosition);
  }

  @override
  void dispose() {
    _listStreamSubscription?.cancel();
    _updateStreamSubscription?.cancel();
    scrollController.removeListener(_checkScollPosition);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _loading
      ? const SliverFillRemaining(
          hasScrollBody: false, child: ProgressIndicatorView())
      : SliverAnimatedList(
          key: _listGlobalKey,
          initialItemCount: dataList?.length ?? 0,
          itemBuilder: (context, index, animation) =>
              dataList?.isNotEmpty ?? false
                  ? buildData(index, animation)
                  : const SizedBox.shrink());

  /// Animates the deletion of an item at the given [index].
  @protected
  void animateDeleteData(int index) async => _listGlobalKey.currentState
      ?.removeItem(index, (context, animation) => buildData(index, animation));

  /// Subscribes to the data [stream] and handles list updates.
  void updateDataList() {
    if (dataList?.isEmpty ?? true) {
      setState(() => _loading = true);
    }
    _listStreamSubscription?.cancel();
    _listStreamSubscription = stream(limit: _limit).listen((newDataList) {
      if ((dataList?.length ?? 0) < newDataList.length) {
        // animate new items added
        _listGlobalKey.currentState?.insertAllItems(0, newDataList.length);
        // add new track (first track start time in after old fist track)
      }
      dataList = newDataList.toList();
      setState(() => _loading = false);
    });
  }

  /// Checks the scroll position to trigger pagination.
  void _checkScollPosition() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent) {
      _limit += pageSize;
      updateDataList();
    }
  }
}
