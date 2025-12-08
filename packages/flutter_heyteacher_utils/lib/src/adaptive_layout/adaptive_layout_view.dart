import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/adaptive_layout/adaptive_layout_data.dart'
    show ScreenSize;

/// The state for the [_BranchView].
///
/// 1° __Abstract__: this state implement the logic abstracting the screen size.
///
/// Usually [build] returns a [GridView] or a [SliverGrid] settings
/// crossAxisCount to [_BranchView.crossAxisCount].
abstract class AbstractAdaptiveState<PARAMS>
    extends State<_BranchView<PARAMS>> {}

/// The state for [SFW].
///
/// 2° __Measures__ the current [ScreenSize] and
///   builds the corrisponding branch for [ScreenSize.small],
/// [ScreenSize.medium] and [ScreenSize.large].
abstract class AdaptiveState<
  SFW extends StatefulWidget,
  ST extends AbstractAdaptiveState<PARAMS>,
  PARAMS
>
    extends State<SFW> {
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

  @override
  Widget build(BuildContext context) => _BranchView(
    currentScreenSize: currentScreenSize,
    createAdaptiveState: createAdaptiveState,
    params: params,
  );

  /// The parameters object pass to abstract
  PARAMS get params;

  /// Returns an instance [ST] State.
  ST createAdaptiveState();
}

/// The branch statefull widget.
///
/// 3° __Branches__ implementation for [ScreenSize.small],
/// [ScreenSize.medium] and [ScreenSize.large].

/// Exposes:
/// - [params]
/// - [currentScreenSize]
/// - [crossAxisCount] for [GridView] and [SliverGrid]
class _BranchView<PARAMS> extends StatefulWidget {
  
  /// Creates an instance of [_BranchView].
  @protected
  const _BranchView({
    required ScreenSize currentScreenSize,
    required this.createAdaptiveState,
    required PARAMS params,
  }) : _params = params,
       _currentScreenSize = currentScreenSize;

  final ScreenSize _currentScreenSize;

  final PARAMS _params;

  ScreenSize get currentScreenSize => _currentScreenSize;

  /// the crossAxisCount which change on branch implementations
  int get crossAxisCount => switch (currentScreenSize) {
    ScreenSize.large => 3,
    ScreenSize.medium => 2,
    ScreenSize.small => 1,
  };

  PARAMS get params => _params;

  final AbstractAdaptiveState<PARAMS> Function() createAdaptiveState;

  @override
  /// Creates the state for the [_BranchView].
  // ignore: no_logic_in_create_state
  State<_BranchView<PARAMS>> createState() => createAdaptiveState();
}
