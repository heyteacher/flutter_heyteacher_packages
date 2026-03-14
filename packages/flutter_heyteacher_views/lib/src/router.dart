/// Provides routing utilities for Flutter applications using `go_router`.
///
/// This library includes:
///   routes
///   (sign-in, sign-out) compatible with `firebase_ui_auth`.
/// - [ScaffoldNavigationShell]: A reusable scaffold widget that integrates with
///   `go_router`'s `StatefulShellRoute` to provide a common UI structure
///   with a bottom navigation bar.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


/// Builds the navigation shell for the app by building a Scaffold, where child
/// is placed in the body of the Scaffold.
///
class ScaffoldNavigationShell extends StatelessWidget {
  /// Constructs an [ScaffoldNavigationShell].
  ///
  /// [navigationShell] is placed into the body of scaffold, and a bottom
  /// navigation bar decorated with [bottomNavigationBarDecoration] is
  /// displayed with [bottomNavigationBarItems].
  const ScaffoldNavigationShell({
    required StatefulNavigationShell navigationShell,
    AppBar? appBar,
    List<BottomNavigationBarItem> bottomNavigationBarItems =
        const <BottomNavigationBarItem>[],
    Decoration? bottomNavigationBarDecoration,
    Key? key,
  }) : _navigationShell = navigationShell,
       _appBar = appBar,
       _bottomNavigationBarDecoration = bottomNavigationBarDecoration,
       _bottomNavigationBarItems = bottomNavigationBarItems,
       super(key: key ?? const ValueKey<String>('ScaffoldNavigationShell'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell _navigationShell;

  /// The list of items to display in the [BottomNavigationBar].
  final List<BottomNavigationBarItem> _bottomNavigationBarItems;

  /// The decoration to apply to the [BottomNavigationBar].
  final Decoration? _bottomNavigationBarDecoration;

  final PreferredSizeWidget? _appBar;

  /// A callback to determine if navigation to the initial location of a branch
  /// should occur when the currently active item is tapped again.
  /// Returns `true` to navigate to the initial location, `false` otherwise.
  bool onTapInitialLocation(int index) => false;

  // #docregion configuration-custom-shell
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: _appBar,
    // The StatefulNavigationShell from the associated StatefulShellRoute is
    // directly passed as the body of the Scaffold.
    body: _navigationShell,
    bottomNavigationBar: _bottomNavigationBarItems.isEmpty
        ? null
        : Container(
            decoration: _bottomNavigationBarDecoration,

            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              showUnselectedLabels: true,
              // Here, the items of BottomNavigationBar are hard coded. In a
              // real world scenario, the items would most likely be generated
              // from thebranches of the shell route, which can be fetched using
              // `navigationShell.route.branches`.
              items: _bottomNavigationBarItems,
              currentIndex: _navigationShell.currentIndex,

              // Navigate to the current location of the branch at the provided
              // indexwhen tapping an item in the BottomNavigationBar.
              onTap: (index) => onTap(
                context,
                index,
                initialLocation: onTapInitialLocation(index),
              ),
            ),
          ),
  );

  // #enddocregion configuration-custom-shell

  /// NOTE: For a slightly more sophisticated branch switching, change the onTap
  /// handler on the BottomNavigationBar above to the following:
  /// `onTap: (int index) => _onTap(context, index),`
  ///
  /// Navigates to the branch at the given [index].
  ///
  /// The [initialLocation] parameter controls whether to navigate to the
  /// initial location of the branch. This is useful for resetting the
  /// navigation stack of a branch when its tab is re-selected.
  @protected
  void onTap(
    BuildContext context,
    int index, {
    required bool initialLocation,
  }) =>
      // When navigating to a new branch, it's recommended to use the goBranch
      // method, as doing so makes sure the last navigation state of the
      // Navigator for the branch is restored.
      _navigationShell.goBranch(
        index,
        // A common pattern when using bottom navigation bars is to support
        // navigating to the initial location when tapping the item that is
        // already active. This example demonstrates how to support
        // this behavior,  using the initialLocation parameter of goBranch.
        initialLocation: initialLocation,
      );
}
