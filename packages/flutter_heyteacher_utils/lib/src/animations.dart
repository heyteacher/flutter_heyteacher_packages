import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/widgets.dart';

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
    dataList = (await initData())?.toList();
    if (dataList != null) {
      // debugPrint(
      //     'PagingSliverAnimatedListState.initPostFrame(): $runtimeType '
      //     'dataList from initData not null, set state _loading false');
      setState(() => _loading = false);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _listGlobalKey.currentState != null) {
        _listGlobalKey.currentState?.insertAllItems(0, dataList!.length);
      }
    }
    _updateStreamSubscription?.cancel();
    _updateStreamSubscription = updateStream.listen((_) => updateDataList());
    updateDataList();
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
    // debugPrint(
    //     'PagingSliverAnimatedListState.updateDataList(): $runtimeType '
    //     '_loading $_loading');
    _listStreamSubscription?.cancel();
    _listStreamSubscription = stream(limit: _limit).listen((newDataList) {
      // scroll
      if ((dataList?.length ?? 0) == newDataList.length - pageSize) {
        //debugPrint('$runtimeType.updateDataList SCROLL');
        // animate new items added
        // debugPrint(
        //     'PagingSliverAnimatedListState.updateDataList(): $runtimeType '
        //     'dataList.length ${dataList?.length} '
        //     'newDataList.length ${newDataList.length}');
        _listGlobalKey.currentState
            ?.insertAllItems(dataList?.length ?? 0, newDataList.length);
        if ((dataList?.length ?? 0) > 0) {
          // if (newDataList.elementAt(0) != dataList?.elementAt(0)) {
          //   _listGlobalKey.currentState?.insertItem(0);
          // }
          // after loading new data scroll down a little bit to comunicate new
          // data to user
          Future.delayed(
              const Duration(milliseconds: 500),
              () => scrollController.animateTo(
                    min(scrollController.offset + 200,
                        max(scrollController.position.maxScrollExtent, 0)),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.fastOutSlowIn,
                  ));
        }
      } else if ((dataList?.length ?? 0) > newDataList.length) {
        // remove item
        if (dataList == null ||
            dataList!.isEmpty ||
            newDataList.isEmpty ||
            newDataList.elementAt(0) != dataList?.elementAt(0)) {
          //debugPrint('$runtimeType.updateDataList REMOVE');
          _listGlobalKey.currentState
              ?.removeItem(0, (context, animation) => buildData(0, animation));
        }
      } else if ((dataList?.length ?? 0) < newDataList.length) {
        //debugPrint('$runtimeType.updateDataList NEW');
        // add new item
        _listGlobalKey.currentState?.insertItem(0);
      } else if ((dataList?.length ?? 0) == newDataList.length) {
        // add new item
        if (dataList == null ||
            dataList!.isEmpty ||
            newDataList.elementAt(0) != dataList?.elementAt(0)) {
          //debugPrint('$runtimeType.updateDataList UPDATE');
          _listGlobalKey.currentState?.insertItem(0);
        }
      }

      dataList = newDataList.toList();
      // first time _loading in true, so we need to wait for the first frame
      // to be built to set it to false
      if (_loading) {
        // debugPrint(
        //     'PagingSliverAnimatedListState.updateDataList(): $runtimeType '
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
      //     'PagingSliverAnimatedListState._checkScollPosition(): $runtimeType '
      //     '_limit $_limit dataList.length ${dataList?.length}. UPDATE');
      _limit += pageSize;
      updateDataList();
    }
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
