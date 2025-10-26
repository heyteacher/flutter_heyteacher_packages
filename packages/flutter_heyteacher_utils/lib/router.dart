/// Provides routing utilities for Flutter applications using `go_router`.
///
/// This library includes:
/// - [GoAuthRoute]: A helper class to easily set up authentication-related
///   routes
///   (sign-in, sign-out) compatible with `firebase_ui_auth`.
/// - [ScaffoldWithNavBar]: A reusable scaffold widget that integrates with
///   `go_router`'s `StatefulShellRoute` to provide a common UI structure
///   with a bottom navigation bar.
library;

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// Defines the names for authentication-related routes.
enum AuthRouterName {
  /// sign in route
  signIn,

  /// sign out route
  signOut,
}

/// Helper to build the [GoRoute] paths for authentication.
///
/// Exposes `sign-in` and `sign-out` actions.
class GoAuthRoute {
  static final _logger = Logger('AuthRoute');

  /// Builds the [GoRoute] paths for authentication.
  ///
  /// The paths defined are `sign-in` and `sign-out`, and paths start from
  /// [signedOutRoute] prefix.
  ///
  /// The [signedOutRoute] is the route to redirect to after a successful
  /// sign-out.
  static GoRoute builder({required String signedOutRoute}) => GoRoute(
    path: 'auth',
    builder: (BuildContext context, GoRouterState state) =>
        const SizedBox.shrink(),
    routes: <RouteBase>[
      GoRoute(
        name: AuthRouterName.signIn.name,
        path: 'sign-in',
        builder: (BuildContext context, GoRouterState state) => SignInScreen(
          showAuthActionSwitch: false,
          actions: [
            AuthStateChangeAction<UserCreated>((context, userCreated) {
              _logger.info('<UserCreated>:');
              GoRouter.of(context).pop();
            }),
            AuthStateChangeAction<SignedIn>((context, state) {
              _logger.info('<SignedIn>:');
              GoRouter.of(context).pop();
            }),
          ],
        ),
      ),
      GoRoute(
        name: AuthRouterName.signOut.name,
        path: 'sign-out',
        redirect: (context, state) async {
          _logger.info('<SignedOut>:');
          await AuthViewModel.instance.signOut();
          return signedOutRoute;
        },
      ),
    ],
  );
}

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where child is placed in the body of the Scaffold.
abstract class ScaffoldWithNavBar extends StatelessWidget {
  /// Constructs an [ScaffoldWithNavBar].
  const ScaffoldWithNavBar({
    required this.navigationShell,
    required List<BottomNavigationBarItem> items,
    Key? key,
  }) : _items = items,
       super(key: key ?? const ValueKey<String>('ScaffoldWithNavBar'));

  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  /// The list of items to display in the [BottomNavigationBar].
  final List<BottomNavigationBarItem> _items;

  /// A callback to determine if navigation to the initial location of a branch
  /// should occur when the currently active item is tapped again.
  /// Returns `true` to navigate to the initial location, `false` otherwise.
  bool onTapInitialLocation(int index);

  // #docregion configuration-custom-shell
  @override
  Widget build(BuildContext context) => Scaffold(
    // The StatefulNavigationShell from the associated StatefulShellRoute is
    // directly passed as the body of the Scaffold.
    body: navigationShell,
    bottomNavigationBar: BottomNavigationBar(
      showUnselectedLabels: true,
      // Here, the items of BottomNavigationBar are hard coded. In a real
      // world scenario, the items would most likely be generated from the
      // branches of the shell route, which can be fetched using
      // `navigationShell.route.branches`.
      items: _items,
      currentIndex: navigationShell.currentIndex,

      // Navigate to the current location of the branch at the provided index
      // when tapping an item in the BottomNavigationBar.
      onTap: (int index) =>
          onTap(context, index, initialLocation: onTapInitialLocation(index)),
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
      navigationShell.goBranch(
        index,
        // A common pattern when using bottom navigation bars is to support
        // navigating to the initial location when tapping the item that is
        // already active. This example demonstrates how to support
        // this behavior,  using the initialLocation parameter of goBranch.
        initialLocation: initialLocation,
      );
}
