import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/views.dart';

/// The state for the [_BranchView].
///
/// 1° __Abstract__: this state implement the logic abstracting the screen size.
///
/// Usually [build] returns a [GridView] or a [SliverGrid] settings
/// crossAxisCount to [_BranchView.crossAxisCount].
abstract class AbstractAdaptiveState<PARAMS>
    extends State<_BranchView<PARAMS>> {}

/// The state for generics [SFW].
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
/// - [screenSize]
/// - [crossAxisCount] for [GridView] and [SliverGrid]
class _BranchView<PARAMS> extends StatefulWidget {
  
  /// Creates an instance of [_BranchView].
  @protected
  const _BranchView({
    required ScreenSize currentScreenSize,
    required AbstractAdaptiveState<PARAMS> Function() createAdaptiveState,
    required PARAMS params,
  }) : _createAdaptiveState = createAdaptiveState, _params = params,
       _screenSize = currentScreenSize;

  final ScreenSize _screenSize;

  ScreenSize get screenSize => _screenSize;

  final PARAMS _params;

  PARAMS get params => _params;

  /// the crossAxisCount which change on branch implementations
  int get crossAxisCount => switch (_screenSize) {
    ScreenSize.small => 1,
    ScreenSize.medium => 2,
    ScreenSize.large => 3,
  };

  /// The weights that each visible child should occupy in the [CarouselView] 
  /// viewport.
  List<int> get flexWeights => switch (_screenSize) {
    ScreenSize.small => [1],
    ScreenSize.medium => [1, 1],
    ScreenSize.large => [1, 1, 1]
  };

  final AbstractAdaptiveState<PARAMS> Function() _createAdaptiveState;

  @override
  /// Creates the state for the [_BranchView].
  // ignore: no_logic_in_create_state
  State<_BranchView<PARAMS>> createState() => _createAdaptiveState();
}
