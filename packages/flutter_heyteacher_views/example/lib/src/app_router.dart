import 'package:example/src/adaptive_layout/adaptive_layout_screen.dart';
import 'package:example/src/adaptive_layout/adaptive_state.dart';
import 'package:example/src/adaptive_layout/paging_sliver_animated_state_screen.dart';
import 'package:example/src/adaptive_layout/wrap_scaffold.dart';
import 'package:example/src/animations_screen.dart';
import 'package:example/src/theme_screen.dart';
import 'package:example/src/widgets/error_screen.dart';
import 'package:example/src/widgets/progress_indicator_screen.dart';
import 'package:example/src/widgets/widgets_screen.dart' show WidgetsScreen;
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/views.dart';
import 'package:go_router/go_router.dart';

/// Defines the named routes and their corresponding paths for the application's
/// navigation.
enum AppRouteName {
  /// The root route, which redirects to the home screen.
  adaptiveLayout(path: '/adaptive_layout'),

  /// Adaptive State
  adaptiveState(path: '/adaptive_state'),

  /// AdaptiveWrap and AdaptiveScaffold
  wrapAndScaffold(path: '/wrap_and_scaffold'),

  /// Paging
  pagingSliverAnimatedState(path: '/paging'),

  /// Animations
  animations(path: '/animations'),

  /// Widgets
  widgets(path: '/widgets'),

  /// ErrorView
  errorView(path: '/error_view'),

  /// ProgressIndicatorView
  progressIndicatorView(path: '/progress_indicator_view'),

  /// Theme
  theme(path: '/theme')
  ;

  /// Creates a route name with a given path.
  const AppRouteName({required String path}) : _path = path;

  /// The URL path segment for the route.
  final String _path;
}

/// Manages the application's routing using the `go_router` package.
class AppRouter {
  AppRouter._();
  GoRouter? _router;

  static AppRouter? _instance;

  /// The singleton instance of [AppRouter].
  // ignore: prefer_constructors_over_static_methods
  static AppRouter get instance => _instance ??= AppRouter._();

  /// Generates routes.
  GoRouter get router => _router ??= GoRouter(
    initialLocation: AppRouteName.widgets._path,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => ScaffoldNavigationShell(
          navigationShell: navigationShell,
          bottomNavigationBarDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: ThemeViewModel.instance.darkGreyColor,
              ),
            ),
          ),
          bottomNavigationBarItems: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.widgets),
              label: 'Widgets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.layers),
              label: 'Adaptive Layout',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.animation),
              label: 'Animations',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.color_lens),
              label: 'Theme',
            ),
          ],
        ),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRouteName.widgets.name,
                path: AppRouteName.widgets._path,
                builder: (context, state) => const WidgetsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    name: AppRouteName.errorView.name,
                    path: AppRouteName.errorView._path,
                    builder: (context, state) => const ErrorScreen(),
                  ),
                  GoRoute(
                    name: AppRouteName.progressIndicatorView.name,
                    path: AppRouteName.progressIndicatorView._path,
                    builder: (context, state) =>
                        const ProgressIndicatorScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRouteName.adaptiveLayout.name,
                path: AppRouteName.adaptiveLayout._path,
                builder: (context, state) => const AdaptiveLayoutScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    name: AppRouteName.adaptiveState.name,
                    path: AppRouteName.adaptiveState._path,
                    builder: (context, state) =>
                        const AdaptiveStateScreen(param: 'test param'),
                  ),
                  GoRoute(
                    name: AppRouteName.wrapAndScaffold.name,
                    path: AppRouteName.wrapAndScaffold._path,
                    builder: (context, state) => const WrapAndScaffold(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRouteName.animations.name,
                path: AppRouteName.animations._path,
                builder: (context, state) => const AnimationsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    name: AppRouteName.pagingSliverAnimatedState.name,
                    path: AppRouteName.pagingSliverAnimatedState._path,
                    builder: (context, state) =>
                        const PagingSliverAnimatedStateScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                name: AppRouteName.theme.name,
                path: AppRouteName.theme._path,
                builder: (context, state) => const ThemeScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
