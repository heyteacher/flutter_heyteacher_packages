
/// Provides routing utilities for Flutter applications using `go_router`.
///
/// This library includes:
/// - [GoAuthRoute]: A helper class to easily set up authentication-related routes
///   (sign-in, sign-out) compatible with `firebase_ui_auth`.
/// - [ScaffoldWithNavBar]: A reusable scaffold widget that integrates with
///   `go_router`'s `StatefulShellRoute` to provide a common UI structure
///   with a bottom navigation bar.
library;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';


/// Helper to build the [GoRoute] paths for authentication.
///  
/// Exposes `sign-in`and `sign-out` actions.
class GoAuthRoute {
  static final _log = Logger('AuthRoute');

  /// build the [GoRoute] paths for authenrication.
  /// 
  /// The paths defined are `sign-in`and `sign-out` and pats start for
  /// [signedOutRoutePath] prefix. 
  static GoRoute builder({required String signedOutRoutePath}) => GoRoute(
        path: 'auth',
        builder: (BuildContext context, GoRouterState state) =>
            const SizedBox.shrink(),
        routes: <RouteBase>[
          GoRoute(
              name: 'auth-sign-in',
              path: 'sign-in',
              builder: (BuildContext context, GoRouterState state) =>
                  SignInScreen(
                    showAuthActionSwitch: false,
                    actions: [
                      AuthStateChangeAction<UserCreated>(
                          (context, userCreated) {
                        _log.info('auth/sign-in (user created)');
                        GoRouter.of(context).pop();
                      }),
                      AuthStateChangeAction<SignedIn>((context, state) {
                        _log.info('auth/sign-in');
                        GoRouter.of(context).pop();
                      }),
                    ],
                  )),
          GoRoute(
            name: 'auth-sign-out',
            path: 'sign-out',
            redirect: (context, state) async {
              await AuthViewModel.instance().signOut();
              return signedOutRoutePath;
            },
          ),
        ],
      );
}

/// Builds the "shell" for the app by building a Scaffold with a
/// BottomNavigationBar, where child is placed in the body of the Scaffold.
class ScaffoldWithNavBar extends StatelessWidget {
 
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
            items: bottomNavigationBarItem,
            currentIndex: navigationShell.currentIndex,

            // Navigate to the current location of the branch at the provided index
            // when tapping an item in the BottomNavigationBar.
            onTap: (int index) =>
                _onTap(index, onTapInitialLocation(index))),
      );

  // #enddocregion configuration-custom-shell

  /// NOTE: For a slightly more sophisticated branch switching, change the onTap
  /// handler on the BottomNavigationBar above to the following:
  /// `onTap: (int index) => _onTap(context, index),`
  // ignore: unused_element
  void _onTap(int index, bool initialLocation) =>
      // When navigating to a new branch, it's recommended to use the goBranch
      // method, as doing so makes sure the last navigation state of the
      // Navigator for the branch is restored.
      navigationShell.goBranch(
        index,
        // A common pattern when using bottom navigation bars is to support
        // navigating to the initial location when tapping the item that is
        // already active. This example demonstrates how to support this behavior,
        // using the initialLocation parameter of goBranch.
        initialLocation: initialLocation,
      );
}