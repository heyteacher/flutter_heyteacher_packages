import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/src/adaptive_screen_size/adaptive_screen_size_data.dart';

/// A mixin to make a [State] object adaptive to screen size changes.
///
/// It listens to media query changes and updates the [_currentScreen] property
/// accordingly.
mixin AdaptiveScreenSizeState<T extends StatefulWidget> on State<T> {
  /// The current screen size category.
  ScreenSize _currentScreen = ScreenSize.small;

  @protected
  /// The current screen size category.
  ScreenSize get currentScreen => _currentScreen;

  @override
  /// Updates the [_currentScreen] size when widget dependencies change.
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentScreen = ScreenSize.of(MediaQuery.of(context).size.width);
  }
}
