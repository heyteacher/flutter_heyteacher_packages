import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/adaptive_layout/adaptive_layout_data.dart'
    show ScreenSize;

/// The state for the [_AbstractView].
///
/// 1° __Abstract__: this state implement the logic abstracting the screen size.
///
/// Usually [build] returns a [GridView] or a [SliverGrid] settings
/// crossAxisCount to [_AbstractView.crossAxisCount].
abstract class AbstractAdaptiveState<PARAMS>
    extends State<_AbstractView<PARAMS>> {}

/// The state for [SFW].
///
/// 2° __Measures__ the current [ScreenSize] with [AdaptiveStateMixin] and
///   builds the corrisponding branch for [ScreenSize.small],
/// [ScreenSize.medium] and [ScreenSize.large].
abstract class AdaptiveState<
  SFW extends StatefulWidget,
  ST extends AbstractAdaptiveState<PARAMS>,
  PARAMS
>
    extends State<SFW>
    with AdaptiveStateMixin<SFW> {
  @override
  Widget build(BuildContext context) => switch (currentScreenSize) {
    ScreenSize.large => _LargeAdaptiveView(createAdaptiveState, params),
    ScreenSize.medium => _MediumAdaptiveView(createAdaptiveState, params),
    ScreenSize.small => _SmallAdaptiveView(createAdaptiveState, params),
  };

  /// The parameters object pass to abstract
  PARAMS get params;

  /// Returns an instance [ST] State.
  ST createAdaptiveState();
}

/// The abstract statefull widget.
///
/// Exposes [crossAxisCount]
abstract class _AbstractView<PARAMS> extends StatefulWidget {
  /// Creates an instance of [_AbstractView].
  @protected
  const _AbstractView(this.createAdaptiveState, this.params);


  /// the crossAxisCount which change on branch implementations
  int get crossAxisCount;

  final AbstractAdaptiveState<PARAMS> Function() createAdaptiveState;
  
  final PARAMS params;

  @override
  /// Creates the state for the [_AbstractView].
  // ignore: no_logic_in_create_state
  State<_AbstractView<PARAMS>> createState() => createAdaptiveState();
}

/// 3° __Branch__:  implements [_AbstractView] for small screens.
class _LargeAdaptiveView<PARAMS> extends _AbstractView<PARAMS> {
  const _LargeAdaptiveView(super.createAdaptiveState, super.params);

  /// the crossAxisCount which change on branch implementations
  @override
  @protected
  int get crossAxisCount => 3;
}

/// 3° __Branch__  implements [_AbstractView] for medium screens.
class _MediumAdaptiveView<PARAMS> extends _AbstractView<PARAMS> {
  const _MediumAdaptiveView(super.createAdaptiveState, super.params);

  /// the crossAxisCount which change on branch implementations
  @override
  @protected
  int get crossAxisCount => 2;
}

/// 3° __Branch__ implements [_AbstractView] for small screens.
class _SmallAdaptiveView<PARAMS> extends _AbstractView<PARAMS> {
  const _SmallAdaptiveView(super.createAdaptiveState, super.params);

  /// the crossAxisCount which change on branch implementations
  @override
  @protected
  int get crossAxisCount => 1;
}

/// A mixin to make a [State] object adaptive to screen size changes.
///
/// It listens to media query changes and updates the [_currentScreenSize]
/// property accordingly.
mixin AdaptiveStateMixin<T extends StatefulWidget> on State<T> {
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
