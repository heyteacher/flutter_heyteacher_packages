import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where child is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
  static final _log = Logger("ScaffoldWithNavBar");

  final Function onTapInitialLocation;

  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar(
      {required this.navigationShell,
      Key? key,
      required this.bottomNavigationBarItem,
      required this.onTapInitialLocation})
      : super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  final List<BottomNavigationBarItem> bottomNavigationBarItem;

  // #docregion configuration-custom-shell
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The StatefulNavigationShell from the associated StatefulShellRoute is
      // directly passed as the body of the Scaffold.
      body: navigationShell,
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        // Here, the items of BottomNavigationBar are hard coded. In a real
        // world scenario, the items would most likely be generated from the
        // branches of the shell route, which can be fetched using
        // `navigationShell.route.branches`.
        items: bottomNavigationBarItem,
        currentIndex: navigationShell.currentIndex,
        // Navigate to the current location of the branch at the provided index
        // when tapping an item in the BottomNavigationBar.
        onTap: (int index) {
          _log.fine("go(index, initialLocation: ${onTapInitialLocation(index)})");
          return navigationShell.goBranch(index,
              initialLocation: onTapInitialLocation(index));
        },
      ),
    );
  }
  // #enddocregion configuration-custom-shell

  /// NOTE: For a slightly more sophisticated branch switching, change the onTap
  /// handler on the BottomNavigationBar above to the following:
  /// `onTap: (int index) => _onTap(context, index),`
  // ignore: unused_element
  void _onTap(BuildContext context, int index) {
    // When navigating to a new branch, it's recommended to use the goBranch
    // method, as doing so makes sure the last navigation state of the
    // Navigator for the branch is restored.
    navigationShell.goBranch(
      index,
      // A common pattern when using bottom navigation bars is to support
      // navigating to the initial location when tapping the item that is
      // already active. This example demonstrates how to support this behavior,
      // using the initialLocation parameter of goBranch.
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
