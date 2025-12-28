import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/src/hero_carousel/hero_carousel_data.dart';
import 'package:flutter_heyteacher_utils/adaptive_layout.dart';

/// A responsive carousel view that adapts to different screen sizes.
class HeroCarouselView extends StatefulWidget {
  /// Creates an instance of [HeroCarouselView].
  const HeroCarouselView({
    required Iterable<HeroCarouselItemData> heroCarouselItems,
    double? maxHeight,
    double? aspectRatio,
    super.key,
  }) : _maxHeight = maxHeight,
       _aspectRatio = aspectRatio,
       _heroCarouselItems = heroCarouselItems;

  final Iterable<HeroCarouselItemData> _heroCarouselItems;

  final double? _maxHeight;
  final double? _aspectRatio;

  @override
  /// Creates the mutable state for this widget.
  ///
  /// This method is called by the Flutter framework to create the
  /// [State] object for this widget.
  State<HeroCarouselView> createState() => _HeroCarouselViewState();
}

class _HeroCarouselViewState
    extends
        AdaptiveState<
          HeroCarouselView,
          _AbstractHeroCarouselViewState,
          ({
            Iterable<HeroCarouselItemData> heroCarouselItems,
            double? maxHeight,
            double? aspectRatio,
          })
        > {
  @override
  _AbstractHeroCarouselViewState createAdaptiveState() =>
      _AbstractHeroCarouselViewState();

  @override
  ({
    Iterable<HeroCarouselItemData> heroCarouselItems,
    double? maxHeight,
    double? aspectRatio,
  })
  get params => (
    heroCarouselItems: widget._heroCarouselItems,
    maxHeight: widget._maxHeight,
    aspectRatio: widget._aspectRatio,
  );
}

/// The abstract state for [HeroCarouselView].
///
/// Manages the automatic scrolling timer, user interaction handling,
/// and the underlying [CarouselView].
class _AbstractHeroCarouselViewState
    extends
        AbstractAdaptiveState<
          ({
            Iterable<HeroCarouselItemData> heroCarouselItems,
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
      _currentIndex ==
          widget.params.heroCarouselItems.length - widget.flexWeights.length
      ? 0
      : _currentIndex + widget.flexWeights.length;

  /// Calculates the index for the previous set of items.
  ///
  /// Loops to the end if it's at the beginning.
  int get _prevIndex => _currentIndex = _currentIndex == 0
      ? widget.params.heroCarouselItems.length - widget.flexWeights.length
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
          children: widget.params.heroCarouselItems
              .map(
                (screenshotCarouselItem) => _HeroLayoutCard(
                  screenshotCarouselItem: screenshotCarouselItem,
                ),
              )
              .toList(),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IconButton(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
              icon: const Icon(
                size: 80,
                Icons.keyboard_arrow_left,
              ),
              onPressed: _prev,
            ),
            const Expanded(child: SizedBox.shrink()),
            IconButton(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.5),
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
/// typically used within a carousel or hero section.
class _HeroLayoutCard extends StatelessWidget {
  /// Creates a card that displays an image and some text in a "hero" layout.
  ///
  /// The [screenshotCarouselItem] parameter is required and provides the data
  /// for the card.
  const _HeroLayoutCard({
    required HeroCarouselItemData screenshotCarouselItem,
  }) : _screenshotCarouselItem = screenshotCarouselItem;

  /// The [HeroCarouselItemData] object containing the title, subtitle,
  /// and path for the image displayed in this card.
  ///
  /// This field is private and accessed via the constructor parameter.
  /// It holds all the necessary data to render the card's content.
  final HeroCarouselItemData _screenshotCarouselItem;

  @override
  /// Builds the UI for the [_HeroLayoutCard].
  ///
  /// It uses a [Stack] to layer an image with text overlay.
  /// The image is constrained and uses an [AssetImage].
  Widget build(BuildContext context) => Stack(
    alignment: _screenshotCarouselItem.body != null
        ? AlignmentDirectional.topStart
        : AlignmentDirectional.bottomStart,
    children: <Widget>[
      /// show body sentences
      if (_screenshotCarouselItem.body != null)
        Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            top: 60,
            bottom: 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: _screenshotCarouselItem.body!
                .map(
                  (row) => Expanded(
                    child: Row(
                      spacing: 16,
                      children: [
                        Icon(
                          row.leadingIcon,
                          color: row.leadingIconColor,
                          size: Theme.of(
                            context,
                          ).textTheme.headlineLarge!.fontSize,
                        ),
                        Flexible(
                          child: Text(
                            row.text,
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        )
      // show image
      else if (_screenshotCarouselItem.imagePath?.isNotEmpty ?? false)
        ClipRect(
          child: OverflowBox(
            maxWidth: MediaQuery.sizeOf(context).width * 7 / 8,
            minWidth: MediaQuery.sizeOf(context).width * 7 / 8,
            child: Image(image: AssetImage(_screenshotCarouselItem.imagePath!)),
          ),
        ),
      if (_screenshotCarouselItem.title != null)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Text(
                _screenshotCarouselItem.title!,
                overflow: TextOverflow.clip,
                softWrap: false,
                textAlign: _screenshotCarouselItem.body != null
                    ? TextAlign.center
                    : TextAlign.left,
                style: Theme.of(
                  context,
                ).textTheme.headlineMedium,
              ),
            ),
            if (_screenshotCarouselItem.subtitle?.isNotEmpty ?? false)
              Padding(
                padding: const EdgeInsets.only(
                  left: 2,
                  right: 2,
                  top: 16,
                  bottom: 8,
                ),
                child: Text(
                  _screenshotCarouselItem.subtitle!,
                  overflow: TextOverflow.clip,
                  softWrap: true,
                  maxLines: 3,
                  textAlign: _screenshotCarouselItem.body != null
                      ? TextAlign.center
                      : TextAlign.left,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium,
                ),
              ),
          ],
        ),
    ],
  );
}
