import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/src/adaptive_screen_size/adaptive_screen_size_data.dart';

/// A mixin to make a [State] object adaptive to screen size changes.
///
/// It listens to media query changes and updates the [screen] property
/// accordingly.
mixin AdaptiveScreenSizeState<T extends StatefulWidget> on State<T> {
  /// The current screen size category.
  @protected
  ScreenSize screen = ScreenSize.small;

  @override
  /// Updates the [screen] size when widget dependencies change.
  void didChangeDependencies() {
    super.didChangeDependencies();
    screen = ScreenSize.of(MediaQuery.of(context).size.width);
  }
}
