import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/src/slide/slide_data.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// The slide Sliver .
class SlideSliver extends StatefulWidget {
  /// The constructor  of the [SlideSliver] for [slides]
  const SlideSliver({
    required List<SlideData> slides,
    Decoration? decoration,
    super.key,
  }) : _slides = slides,
       _decoration = decoration;

  final List<SlideData> _slides;

  final Decoration? _decoration;

  @override
  /// Creates the state for the [SlideSliver] based on the platform.
  ///
  State<SlideSliver> createState() => _SlideSliverState();
}

class _SlideSliverState
    extends
        AdaptiveState<
          SlideSliver,
          _AbstractLiveSlideSliverState,
          ({Decoration? decoration, List<SlideData> slides})
        > {
  @override
  _AbstractLiveSlideSliverState createAdaptiveState() =>
      _AbstractLiveSlideSliverState();

  @override
  ({Decoration? decoration, List<SlideData> slides}) get params =>
      (slides: widget._slides, decoration: widget._decoration);
}

class _AbstractLiveSlideSliverState
    extends
        AbstractAdaptiveState<
          ({Decoration? decoration, List<SlideData> slides})
        > {
  @override
  Widget build(BuildContext context) => SliverGrid(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: _crossAxisCount,
      mainAxisExtent: MediaQuery.sizeOf(context).height / 2.2,
    ),
    delegate: SliverChildListDelegate(
      widget.params.slides
          .map(
            (slideData) => _SlideWidget(
              slideData,
              decoration: widget.params.decoration,
            ),
          )
          .toList(),
    ),
  );

  int get _crossAxisCount => switch (widget.screenSize) {
    ScreenSize.small => 1,
    ScreenSize.medium => 1,
    ScreenSize.large => 2,
  };
}

/// A responsive carousel view that adapts to different screen sizes.
class SlideCarouselView extends StatefulWidget {
  /// Creates an instance of [SlideCarouselView].
  const SlideCarouselView({
    required Iterable<SlideData> slides,
    double? maxHeight,
    double? aspectRatio,
    super.key,
  }) : _maxHeight = maxHeight,
       _aspectRatio = aspectRatio,
       _slides = slides;

  final Iterable<SlideData> _slides;

  final double? _maxHeight;
  final double? _aspectRatio;

  @override
  /// Creates the mutable state for this widget.
  ///
  /// This method is called by the Flutter framework to create the
  /// [State] object for this widget.
  State<SlideCarouselView> createState() => _SlideCarouselViewState();
}

class _SlideCarouselViewState
    extends
        AdaptiveState<
          SlideCarouselView,
          _AbstractSlideCarouselViewState,
          ({
            Iterable<SlideData> slides,
            double? maxHeight,
            double? aspectRatio,
          })
        > {
  @override
  _AbstractSlideCarouselViewState createAdaptiveState() =>
      _AbstractSlideCarouselViewState();

  @override
  ({
    Iterable<SlideData> slides,
    double? maxHeight,
    double? aspectRatio,
  })
  get params => (
    slides: widget._slides,
    maxHeight: widget._maxHeight,
    aspectRatio: widget._aspectRatio,
  );
}

/// The abstract state for [SlideCarouselView].
///
/// Manages the automatic scrolling timer, user interaction handling,
/// and the underlying [CarouselView].
class _AbstractSlideCarouselViewState
    extends
        AbstractAdaptiveState<
          ({
            Iterable<SlideData> slides,
            double? maxHeight,
            double? aspectRatio,
          })
        > {
  /// The controller for the carousel.
  final CarouselController _controller = CarouselController();

  /// A timer for automatically advancing the carousel.
  //Timer? _timer;

  /// The current starting index of the visible items in the carousel.
  int _currentIndex = 0;

  /// Calculates the index for the next set of items.
  ///
  /// Loops back to the beginning if it reaches the end.
  int get _nextIndex => _currentIndex =
      _currentIndex == widget.params.slides.length - widget.flexWeights.length
      ? 0
      : _currentIndex + widget.flexWeights.length;

  /// Calculates the index for the previous set of items.
  ///
  /// Loops to the end if it's at the beginning.
  int get _prevIndex => _currentIndex = _currentIndex == 0
      ? widget.params.slides.length - widget.flexWeights.length
      : _currentIndex - widget.flexWeights.length;

  @override
  /// Disposes the controller when the widget is removed from the widget tree.
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    //debugPrint('${clock.now().toIso8601String()} <Timer.periodic>:');
    unawaited(_controller.animateToItem(_nextIndex));
  }

  void _prev() {
    //debugPrint('${clock.now().toIso8601String()} <Timer.periodic>:');
    unawaited(_controller.animateToItem(_prevIndex));
  }

  @override
  /// Builds the carousel.
  ///
  /// It includes a [Listener] to handle user pointer events for manual
  /// navigation, which also pauses the auto-scroll timer.
  Widget build(BuildContext context) => widget.params.maxHeight != null
      ? ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: widget.params.maxHeight!,
          ),
          child: _buildCarouselView(context),
        )
      : widget.params.aspectRatio != null
      ? AspectRatio(
          aspectRatio: widget.params.aspectRatio!,
          child: _buildCarouselView(context),
        )
      : _buildCarouselView(context);

  Widget _buildCarouselView(BuildContext context) => Listener(
    onPointerDown: (pointerDownEvent) {
      if (pointerDownEvent.position.dx >=
          MediaQuery.sizeOf(context).width / 2) {
        _next();
      } else {
        _prev();
      }
    },
    child: Stack(
      children: [
        CarouselView.weighted(
          controller: _controller,
          itemSnapping: true,
          shrinkExtent: MediaQuery.of(context).size.width,
          flexWeights: widget.flexWeights,
          children: widget.params.slides.map(_SlideWidget.new).toList(),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
              color: ThemeViewModel.instance.colorScheme.primary.withValues(
                alpha: 0.5,
              ),
              icon: const Icon(
                size: 80,
                Icons.keyboard_arrow_left,
              ),
              onPressed: _prev,
            ),
            const Expanded(child: SizedBox.shrink()),
            IconButton(
              color: ThemeViewModel.instance.colorScheme.primary.withValues(
                alpha: 0.5,
              ),
              icon: const Icon(Icons.keyboard_arrow_right, size: 80),
              onPressed: _next,
            ),
          ],
        ),
      ],
    ),
  );
}

/// A widget that displays an image with a title and subtitle overlay,
class _SlideWidget extends StatelessWidget {
  /// Creates a card that displays an image and some text.
  ///
  /// The [slideData] parameter is required and provides the data
  /// for the card.
  const _SlideWidget(
    SlideData slideData, {
    Decoration? decoration,
    super.key,
  }) : _slideData = slideData,
       _decoration = decoration;

  /// The [SlideData] object containing the title, subtitle,
  /// and path for the image displayed in this card.
  ///
  /// This field is private and accessed via the constructor parameter.
  /// It holds all the necessary data to render the card's content.
  final SlideData _slideData;

  final Decoration? _decoration;

  @override
  /// Builds the UI for the [_SlideWidget].
  ///
  /// It uses a [Stack] to layer an image with text overlay.
  /// The image is constrained and uses an [AssetImage].
  Widget build(BuildContext context) => Container(
    decoration: _decoration,
    child: Stack(
      alignment: _slideData.body != null
          ? AlignmentDirectional.topStart
          : AlignmentDirectional.bottomStart,
      children: <Widget>[
        /// show body sentences
        if (_slideData.body != null)
          Padding(
            padding: EdgeInsets.only(
              top: _slideData.subtitle != null ? 128 : 64,
              bottom: 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _slideData.body!
                  .map(
                    (row) => ListTile(
                      leading: Icon(
                        row.leadingIcon,
                        color: row.leadingIconColor,
                        size: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.fontSize,
                      ),
                      title: Text(
                        row.text,
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall,
                      ),
                    ),
                  )
                  .toList(),
            ),
          )
        // show image
        else if (_slideData.imagePaths?.isNotEmpty ?? false)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _slideData.imagePaths!
                  .map(
                    (imagePath) => Image(
                      isAntiAlias: true,
                      filterQuality: FilterQuality.high,
                      height: MediaQuery.sizeOf(context).height / 2,
                      image: AssetImage(imagePath),
                    ),
                  )
                  .toList(),
            ),
          ),
        if (_slideData.title != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _slideData.title!,
                  overflow: TextOverflow.clip,
                  softWrap: false,
                  textAlign: _slideData.body != null
                      ? TextAlign.center
                      : TextAlign.left,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineLarge,
                ),
              ),
              if (_slideData.subtitle?.isNotEmpty ?? false)
                Padding(
                  padding: const EdgeInsets.only(
                    left: 2,
                    right: 2,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Text(
                    _slideData.subtitle!,
                    overflow: TextOverflow.clip,
                    softWrap: true,
                    maxLines: 3,
                    textAlign: _slideData.body != null
                        ? TextAlign.center
                        : TextAlign.left,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall,
                  ),
                ),
            ],
          ),
      ],
    ),
  );
}
