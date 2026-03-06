import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/src/widgets.dart';

/// An abstract [State] for creating a paginated [SliverAnimatedList] or 
/// [SliverAnimatedGrid] that is populated from a `Stream`.
///
/// It simplifies the common pattern of displaying a grid of data that is
/// fetched in pages as the user scrolls down. It also handles real-time
/// updates, such as inserting new items at the top of the grid with an
/// animation.
abstract class PagingSliverAnimatedState<D, T extends StatefulWidget>
    extends State<T> {
  /// The current list of data items displayed in the gruid.
  @protected
  List<D>? dataList;

  /// The number of items to fetch in each page. Defaults to 10.
  @protected
  int get pageSize => 10;

  /// The current limit for the number of items to fetch from the [stream].
  ///
  /// This value is increased by [pageSize] when the user scrolls to the end
  /// of the grid.
  late int _limit = pageSize;

  /// A global key for the [SliverAnimatedGrid] to manage its state,
  /// such as inserting or removing items.
  final GlobalKey<SliverAnimatedGridState> _sliverGridGlobalKey =
      GlobalKey<SliverAnimatedGridState>();

  /// A global key for the [SliverAnimatedList] to manage its state,
  /// such as inserting or removing items.
  final GlobalKey<SliverAnimatedListState> _sliverListGlobalKey =
      GlobalKey<SliverAnimatedListState>();

  void _removeItem(int index, AnimatedRemovedItemBuilder builder) =>
      crossAxisCount == 1
      ? _sliverListGlobalKey.currentState?.removeItem(index, builder)
      : _sliverGridGlobalKey.currentState?.removeItem(index, builder);

  bool get _currentStateIsNotNull => crossAxisCount == 1
      ? _sliverListGlobalKey.currentState != null
      : _sliverGridGlobalKey.currentState != null;

  void _insertItem(int index) => crossAxisCount == 1
      ? _sliverListGlobalKey.currentState?.insertItem(index)
      : _sliverGridGlobalKey.currentState?.insertItem(index);

  void _insertAllItems(int index, int length) => crossAxisCount == 1
      ? _sliverListGlobalKey.currentState?.insertAllItems(index, length)
      : _sliverGridGlobalKey.currentState?.insertAllItems(index, length);

  /// The subscription to the data stream.
  StreamSubscription<Iterable<D>>? _streamSubscription;
  StreamSubscription<void>? _updateStreamSubscription;

  bool _loading = true;

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
  /// Inform widget that needed to be updated. Tipically a new filter is
  /// applied.
  @protected
  Stream<void> get updateStream;

  /// Builds the widget for a single item in the list.
  ///
  /// The [index] is the position of the item in [dataList], and the
  /// [animation] should be used to animate the item's appearance (e.g.,
  /// inside a [SizeTransition]).
  ///
  /// If [removing] the animation disapear the item.
  @protected
  Widget buildData(
    int index, {
    required Animation<double> animation,
    bool removing = false,
  });

  /// Fetches the initial data for the list.
  ///
  /// This method is called once in [initState] to populate the list before
  /// the stream subscription starts. It can return `null` or an empty list
  /// if no initial data is available.
  @protected
  Future<Iterable<D>?> initData() async {
    return null;
  }

  /// the cross axis (columns or rows) count
  @protected
  int get crossAxisCount;

  /// the main axis (height or width) extent
  double get mainAxisExtent;

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
    dataList = (await initData())?.toList();
    if (dataList != null) {
      // debugPrint(
      //     'PagingSliverAnimatedGridState.initPostFrame(): $runtimeType '
      //     'dataList from initData not null, set state _loading false');
      setState(() => _loading = false);
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      if (mounted && _currentStateIsNotNull) {
        _insertAllItems(0, dataList!.length);
      }
    }
    unawaited(_updateStreamSubscription?.cancel());
    _updateStreamSubscription = updateStream.listen((_) => updateDataList());
    unawaited(updateDataList());
    _checkScollPosition();
    scrollController.addListener(_checkScollPosition);
  }

  @override
  void dispose() {
    unawaited(_streamSubscription?.cancel());
    unawaited(_updateStreamSubscription?.cancel());
    scrollController.removeListener(_checkScollPosition);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _loading
      ? const SliverFillRemaining(
          hasScrollBody: false,
          child: ProgressIndicatorView(),
        )
      : crossAxisCount == 1
      ? SliverAnimatedList(
          key: _sliverListGlobalKey,
          initialItemCount: dataList?.length ?? 0,
          itemBuilder: (context, index, animation) =>
              (dataList?.isNotEmpty ?? false) && (dataList?.length ?? 0) > index
              ? buildData(index, animation: animation)
              : const SizedBox.shrink(),
        )
      : SliverAnimatedGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: mainAxisExtent,
            mainAxisSpacing: crossAxisCount == 2 ? 8 : 16,
            crossAxisSpacing: crossAxisCount == 2 ? 8 : 16
          ),
          key: _sliverGridGlobalKey,
          initialItemCount: dataList?.length ?? 0,
          itemBuilder: (context, index, animation) =>
              (dataList?.isNotEmpty ?? false) && (dataList?.length ?? 0) > index
              ? buildData(index, animation: animation)
              : const SizedBox.shrink(),
        );

  /// Animates the deletion of an item at the given [index].
  @protected
  Future<void> animateDeleteData(int index) async => _removeItem(
    index,
    (context, animation) =>
        buildData(index, animation: animation, removing: true),
  );

  /// Subscribes to the data [stream] and handles list updates.
  Future<void> updateDataList({bool incrementsLimit = false}) async {
    if (incrementsLimit) {
      _limit += pageSize;
    }
    unawaited(_streamSubscription?.cancel());
    _streamSubscription = stream(limit: _limit).listen((newDataList) {
      final changedIndexes =
          _compare(
            oldList: dataList ?? [],
            newList: newDataList.toList(),
          )..forEach(
            _insertItem,
          );
      // add new item at the end of list, scrollo down e litte bit
      if (changedIndexes.isNotEmpty &&
          (dataList?.length ?? 0) > 0 &&
          changedIndexes.last >= (dataList?.length ?? 0)) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollController.animateTo(
            min(
              scrollController.offset + 200,
              max(scrollController.position.maxScrollExtent, 0),
            ),
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
          ),
        );
      }
      // for each item not in old data list, animate delete
      var removed = false;
      if (dataList != null) {
        final toBeRemoved = dataList!.reversed.where(
          (item) => !newDataList.contains(item),
        );
        toBeRemoved
            .map((item) => dataList!.indexOf(item))
            .forEach(animateDeleteData);
        removed = toBeRemoved.isNotEmpty;
      }
      dataList = newDataList.toList();
      if ((dataList?.length ?? 0) < _limit &&
          changedIndexes.isNotEmpty &&
          removed) {
        unawaited(updateDataList(incrementsLimit: true));
      }
      // first time _loading in true, so we need to wait for the first frame
      // to be built to set it to false
      if (_loading) {
        // debugPrint(
        //     'PagingSliverAnimatedGridState.updateDataList(): $runtimeType '
        //     'set state _loading to false');
        setState(() => _loading = false);
      }
    });
  }

  /// Checks the scroll position to trigger pagination.
  void _checkScollPosition() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        (dataList == null || _limit == (dataList!.length))) {
      // debugPrint(
      //  'PagingSliverAnimatedGridState._checkScollPosition(): $runtimeType '
      //   '_limit $_limit dataList.length ${dataList?.length}. UPDATE');
      _limit += pageSize;
      unawaited(updateDataList());
    }
  }

  Iterable<int> _compare({
    required List<D> oldList,
    required List<D> newList,
  }) => newList.indexed.where((e) => !oldList.contains(e.$2)).map((e) => e.$1);
}

/// A widget that displays text with a blinking (fade in/out) animation.
class BlinkingText extends StatefulWidget {
  /// Creates a [BlinkingText] widget.
  ///
  /// The [text] to be displayed is required.
  const BlinkingText(
    this.text, {
    super.key,
    this.animated = true,
    this.durationInMs = 500,
    this.style,
    this.textAlign,
  });

  /// The text to display.
  final String text;

  /// Whether to enable the blinking animation.
  ///
  /// Defaults to `true`. If `false`, the text is displayed statically.
  final bool animated;

  /// The duration of one half of the blink cycle (e.g., fade in or fade out)
  /// in milliseconds.
  ///
  /// Defaults to 500ms.
  final int durationInMs;

  /// The style to use for the text.
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  @override
  BlinkingTextState createState() => BlinkingTextState();
}

/// The state for the [BlinkingText] widget, which manages the animation timer.
class BlinkingTextState extends State<BlinkingText> {
  bool _isVisible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Set a timer to toggle visibility based on the specified duration.
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: widget.durationInMs), (
      timer,
    ) {
      if (mounted) {
        setState(() => _isVisible = !_isVisible);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.animated
        ? TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: _isVisible ? 1 : 0,
              end: _isVisible ? 0 : 1,
            ),
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            builder: (context, opacity, child) {
              return Opacity(opacity: opacity, child: _text);
            },
          )
        : _text;
  }

  /// A getter that builds the static [Text] widget.
  Text get _text =>
      Text(widget.text, style: widget.style, textAlign: widget.textAlign);
}

/// Shows a Text with (fade in/out) animation
class AnimateText extends StatefulWidget {
  /// Creates a [AnimateText] widget.
  ///
  /// The [text] to be displayed is required.
  const AnimateText(
    this.text, {
    super.key,
    this.animated = true,
    this.durationInMs = 1000,
    this.style,
    this.textAlign,
    this.visibleOnStart = false,
  });

  /// The text to display.
  final String text;

  /// Whether to enable the blinking animation.
  ///
  /// Defaults to `true`. If `false`, the text is displayed statically.
  final bool animated;

  /// The duration of one half of the blink cycle (e.g., fade in or fade out)
  /// in milliseconds.
  ///
  /// Defaults to 500ms.
  final int durationInMs;

  /// The style to use for the text.
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// If widget is visible.
  final bool visibleOnStart;

  @override
  State<AnimateText> createState() => _AnimateTextState();
}

class _AnimateTextState extends State<AnimateText> {
  String? _oldTest;

  bool _isToAnimate() {
    if (!widget.animated) {
      return false;
    }
    if (_oldTest == widget.text) {
      return false;
    }
    _oldTest = widget.text;
    return true;
  }

  @override
  Widget build(BuildContext context) => _isToAnimate()
      ? TweenAnimationBuilder<double>(
          key: UniqueKey(),
          tween: Tween<double>(
            begin: widget.visibleOnStart ? 1 : 0,
            end: widget.visibleOnStart ? 0 : 1,
          ),
          duration: Duration(milliseconds: widget.durationInMs),
          curve: Curves.easeInOut,
          builder: (context, opacity, child) =>
              Opacity(opacity: opacity, child: _text),
        )
      : _text;

  /// A getter that builds the static [Text] widget.
  Text get _text =>
      Text(widget.text, style: widget.style, textAlign: widget.textAlign);
}
