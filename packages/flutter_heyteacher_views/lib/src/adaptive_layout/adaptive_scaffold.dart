import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// A widget that adapts to the current display size, displaying a [Drawer],
class AdaptiveScaffold extends StatefulWidget {
  /// Creates a [AdaptiveScaffold].
  const AdaptiveScaffold({
    required Widget Function({
      required int crossAxisCount,
      required ScreenSize screenSize,
    })
    bodyForLargeBuilder,
    required Widget Function({
      required int crossAxisCount,
      required ScreenSize screenSize,
    })
    bodyForSmallBuilder,
    AppBar? appBar,
    Widget? drawler,
    FloatingActionButton? floatingActionButton,
    List<Widget>? persistentFooterButtons,
    AlignmentDirectional? persistentFooterAlignment,
    BoxDecoration? persistentFooterDecoration,
    super.key,
  }) : _appBar = appBar,
       _drawler = drawler,
       _bodyForLargeBuilder = bodyForLargeBuilder,
       _bodyForSmallBuilder = bodyForSmallBuilder,
       _floatingActionButton = floatingActionButton,
       _persistentFooterDecoration = persistentFooterDecoration,
       _persistentFooterAlignment = persistentFooterAlignment,
       _persistentFooterButtons = persistentFooterButtons;

  /// The title of the screen
  final AppBar? _appBar;

  /// The drawer of the screen
  final Widget? _drawler;

  /// The body for large screen
  final Widget Function({
    required int crossAxisCount,
    required ScreenSize screenSize,
  })
  _bodyForLargeBuilder;

  ///  The body for small screen
  final Widget Function({
    required int crossAxisCount,
    required ScreenSize screenSize,
  })
  _bodyForSmallBuilder;

  /// The floating action button of the screen
  final FloatingActionButton? _floatingActionButton;
  final List<Widget>? _persistentFooterButtons;
  final AlignmentDirectional? _persistentFooterAlignment;
  final BoxDecoration? _persistentFooterDecoration;

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class _AdaptiveScaffoldState
    extends
        AdaptiveState<
          AdaptiveScaffold,
          _AbstractAdaptiveScaffoldState,
          ({
            AppBar? appBar,
            Widget Function({
              required int crossAxisCount,
              required ScreenSize screenSize,
            })
            bodyForLargeBuilder,
            Widget Function({
              required int crossAxisCount,
              required ScreenSize screenSize,
            })
            bodyForSmallBuilder,
            FloatingActionButton? floatingActionButton,
            Widget? drawler,
            List<Widget>? persistentFooterButtons,
            AlignmentDirectional? persistentFooterAlignment,
            BoxDecoration? persistentFooterDecoration,
          })
        > {
  @override
  _AbstractAdaptiveScaffoldState createAdaptiveState() =>
      _AbstractAdaptiveScaffoldState();

  @override
  ({
    AppBar? appBar,
    Widget Function({
      required int crossAxisCount,
      required ScreenSize screenSize,
    })
    bodyForLargeBuilder,
    Widget Function({
      required int crossAxisCount,
      required ScreenSize screenSize,
    })
    bodyForSmallBuilder,
    FloatingActionButton? floatingActionButton,
    Widget? drawler,
    List<Widget>? persistentFooterButtons,
    AlignmentDirectional? persistentFooterAlignment,
    BoxDecoration? persistentFooterDecoration,
  })
  get params => (
    appBar: widget._appBar,
    bodyForLargeBuilder: widget._bodyForLargeBuilder,
    bodyForSmallBuilder: widget._bodyForSmallBuilder,
    floatingActionButton: widget._floatingActionButton,
    drawler: widget._drawler,
    persistentFooterButtons: widget._persistentFooterButtons,
    persistentFooterAlignment: widget._persistentFooterAlignment,
    persistentFooterDecoration: widget._persistentFooterDecoration,
  );
}

class _AbstractAdaptiveScaffoldState
    extends
        AbstractAdaptiveState<
          ({
            AppBar? appBar,
            Widget Function({
              required int crossAxisCount,
              required ScreenSize screenSize,
            })
            bodyForLargeBuilder,
            Widget Function({
              required int crossAxisCount,
              required ScreenSize screenSize,
            })
            bodyForSmallBuilder,
            FloatingActionButton? floatingActionButton,
            Widget? drawler,
            List<Widget>? persistentFooterButtons,
            AlignmentDirectional? persistentFooterAlignment,
            BoxDecoration? persistentFooterDecoration,
          })
        > {
  @override
  Widget build(BuildContext context) => switch (widget.screenSize) {
    ScreenSize.large => Row(
      children: [
        if (widget.params.drawler != null)
          Drawer(
            shape: const RoundedRectangleBorder(),
            width: MediaQuery.sizeOf(context).width * 0.3,
            child: widget.params.drawler,
          ),
        VerticalDivider(
          width: 1,
          thickness: 1,
          color: ThemeViewModel.instance.darkGreyColor,
        ),
        Expanded(
          child: Scaffold(
            appBar: widget.params.appBar,
            body: widget.params.bodyForLargeBuilder.call(
              crossAxisCount: widget.crossAxisCount,
              screenSize: widget.screenSize,
            ),
            floatingActionButton: widget.params.floatingActionButton,
          ),
        ),
      ],
    ),
    // ScreenSize.medium and ScreenSize.small
    _ => Scaffold(
      body: widget.params.bodyForSmallBuilder.call(
        crossAxisCount: widget.crossAxisCount,
        screenSize: widget.screenSize,
      ),
      appBar: widget.params.appBar,
      floatingActionButton: widget.params.floatingActionButton,
      persistentFooterButtons: widget.params.persistentFooterButtons,
      persistentFooterAlignment:
          widget.params.persistentFooterAlignment ??
          AlignmentDirectional.center,
      persistentFooterDecoration: widget.params.persistentFooterDecoration,
    ),
  };
}
