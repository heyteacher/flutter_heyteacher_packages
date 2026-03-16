import 'dart:async';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';

import 'package:flutter_heyteacher_auth/src/auth_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' show Logger;

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
  /// The [landingRoutePath] is the route to redirect to after a successful
  /// sign-out / sign-out.
  static GoRoute builder({
    required String landingRoutePath,
    Future<void> Function()? fakeSignIn,
  }) => GoRoute(
    path: 'auth',
    builder: (context, state) => const SizedBox.shrink(),
    routes: <RouteBase>[
      GoRoute(
        name: AuthRouterName.signIn.name,
        path: 'sign-in',
        // if fake sign in is set, invoke and redirect to landing route
        redirect: fakeSignIn == null
            ? null
            : (context, state) async {
                _logger.info(
                  '<SignedIn>: fake sign-in redirect to $landingRoutePath',
                );
                await fakeSignIn.call();
                return landingRoutePath;
              },
        // if fake sign in is not set, show sign-in screen
        builder: fakeSignIn != null
            ? null
            : (context, state) => SignInScreen(
                showAuthActionSwitch: false,
                actions: [
                  AuthStateChangeAction<UserCreated>((context, userCreated) {
                    _logger.info(
                      '<UserCreated>: landingRoute $landingRoutePath',
                    );
                    GoRouter.of(context).go(landingRoutePath);
                  }),
                  AuthStateChangeAction<SignedIn>((context, state) {
                    _logger.info('<SignedIn>: landingRoute $landingRoutePath');
                    GoRouter.of(context).go(landingRoutePath);
                  }),
                ],
              ),
      ),
      GoRoute(
        name: AuthRouterName.signOut.name,
        path: 'sign-out',
        redirect: (context, state) async {
          _logger.info('<SignedOut>: redirect to $landingRoutePath');
          await AuthViewModel.instance.signOut();
          return landingRoutePath;
        },
      ),
    ],
  );
}
