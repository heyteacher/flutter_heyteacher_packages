# flutter_heyteacher_views

A Flutter package providing a collection of reusable UI widgets, adaptive layouts, and view utilities, designed for the [Flutter HeyTeacher ecosystem](../..).

## Features

- **Navigation Helpers**: Includes `ScaffoldNavigationShell` for streamlined navigation with packages like `go_router`.
- **Common Widgets**: A set of pre-built widgets for common UI patterns, including `ErrorView`, `ProgressIndicatorView`, `TableView`, and more.
- **Adaptive Layout**: Easily create responsive UIs that adapt to different screen sizes with `AdaptiveScaffold`,  `AdaptiveWrap` and `AdaptiveState`.
- **Animations Utilities**: Includes `PagingSliverAnimatedState`, `BlinkingText` and `AnimatedText`.
- **Theme Management**: Simple theme switching and management capabilities with `ThemeViewModel`.
- **Tutorials**: A `TutorialViewModel` to help guide users through your app's features.
- **Handy Utilities**: dialogs (`showConfirmCancelDialog`), snackbars (`showSnackBar`), and extensions.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_views: ^1.0.0 # Replace with the latest version
```

Then, run `flutter pub get`.

## Usage

The [example](./example/) app show how to use the widgets and utilities provided by this package.

- [Router](./example/lib/src/app_router.dart): How to configure the application routing.

- [Widgets](./example/lib/src/widgets/widgets_screen.dart): `Tutorial`, `GenericsDropDownMenu`, `TableView`, `showSnackBar`, `showConfirmCancelDialog`, `TooltipIconButton`, `FloatingActionTextIconButtom`

  - [Error View](./example/lib/src/widgets/error_screen.dart)

  - [Progress Indicator View](./example/lib/src/widgets/progress_indicator_screen.dart)

- [Adaptive Layout](./example/lib/src/adaptive_layout/adaptive_layout_screen.dart): rotate the smartphone or resize the browser windows and layout will adapt accordingly the new screen size.

  - [Adaptive Scaffold](./example/lib/src/adaptive_layout/adaptive_scaffold.dart)
  
  - [Adaptive State](./example/lib/src/adaptive_layout/adaptive_state.dart)

  - [Adaptive Wrap and Scaffold](./example/lib/src/adaptive_layout/wrap_scaffold.dart)

- [Animations](./example/lib/src/animations/animations_screen.dart): `AnimatedText` and `BlinkingText`

  - [Paging Sliver Animated State](./example/lib/src/animations/paging_sliver_animated_state_screen.dart)

- [Theme](./example/lib/src/theme_screen.dart): `ThemeCard` for change theme mode between `Dark`,  `Light` and `System`
