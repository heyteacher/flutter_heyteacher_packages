import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/src/adaptive_screen_size/adaptive_screen_size_data.dart';

/// A mixin to make a [State] object adaptive to screen size changes.
///
/// It listens to media query changes and updates the [_currentScreenSize] 
/// property accordingly.
mixin AdaptiveScreenSizeState<T extends StatefulWidget> on State<T> {
  /// The current screen size category.
  ScreenSize _currentScreenSize = ScreenSize.small;

  @protected
  /// The current screen size category.
  ScreenSize get currentScreenSize => _currentScreenSize;

  @override
  /// Updates the [_currentScreenSize] size when widget dependencies change.
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentScreenSize = ScreenSize.of(MediaQuery.of(context).size.width);
  }
}

/// The abstract adaptive view mixin used by abstract statefull widgets
mixin AbstractAdaptiveViewMixin {
  /// the crossAxisCount which change on branch implementations
  int get crossAxisCount;
}

/// the large adaptive screen size state mixin 
mixin LargeAdaptiveScreenSizeStateMixin {
  /// the crossAxisCount which change on branch implementations
  @protected
  int get crossAxisCount => 3;
}

/// The medium adaptive screen size state mixin 
mixin MediumAdaptiveScreenSizeStateMixin {
  /// the crossAxisCount which change on branch implementations
  @protected
  int get crossAxisCount => 2;
}

/// The small adaptive screen size state mixin 
mixin SmallAdaptiveScreenSizeStateMixin {
  /// the crossAxisCount which change on branch implementations
  @protected
  int get crossAxisCount => 1;
}
