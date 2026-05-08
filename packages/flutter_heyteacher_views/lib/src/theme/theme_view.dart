/// Manages application-wide theming, including theme selection UI,
/// theme persistence, and dynamic theme updates.
///
/// This library provides:
/// - [ThemeModeListTile] and [ThemeModeButton]: A widget for users to select
///   between light, dark, or system default themes.
/// - [ThemeViewModel]: A singleton class responsible for holding the current
///   theme state, persisting user preferences, providing theme data, and
///    broadcasting theme changes.
///
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;

/// The theme mode button.
class ThemeModeButton extends StatefulWidget {
  /// Creates the theme mode button.
  const ThemeModeButton({
    super.key,
  });

  @override
  State<ThemeModeButton> createState() => _ThemeModeButtonState();
}

class _ThemeModeButtonState extends State<ThemeModeButton> {
  StreamSubscription<({ThemeData themeData, ThemeMode themeMode})>?
  _themeStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  @override
  void dispose() {
    unawaited(_themeStreamSubscription?.cancel());
    super.dispose();
  }

  Future<void> _init(_) async {
    await ThemeViewModel.instance.themeMode;
    setState(() {});
    unawaited(_themeStreamSubscription?.cancel());
    _themeStreamSubscription = ThemeViewModel.instance.themeStream.listen(
      (
        event,
      ) => setState(() {}),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        ThemeViewModel.instance.isDark ? Icons.light_mode : Icons.dark_mode,
      ),
      onPressed: () async {
        await ThemeViewModel.instance.setThemeMode(
          ThemeViewModel.instance.isDark ? ThemeMode.light : ThemeMode.dark,
        );
        setState(() {});
      },
    );
  }
}

/// A [ListTile] widget that allows users to select the application's
/// [ThemeMode].
///
/// It presents [ChoiceChip] options for system, dark, and light themes.
/// Changes are propagated through the [ThemeViewModel] singleton.
class ThemeModeListTile extends StatefulWidget {
  /// Creates a [ThemeModeListTile].
  const ThemeModeListTile({super.key});

  @override
  State<ThemeModeListTile> createState() =>
      ThemeModeListTileState<ThemeModeListTile>();
}

/// The state for [ThemeModeListTile], which builds the UI for theme selection.
///
/// This class is generic (`<T extends StatefulWidget>`) to allow it to be
/// extended by other state classes that may want to override its behavior,
/// such as the `onSelected` method.
class ThemeModeListTileState<T extends StatefulWidget> extends State<T> {
  ThemeMode? _themeMode;

  StreamSubscription<({ThemeData themeData, ThemeMode themeMode})>?
  _themeStreamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  @override
  void dispose() {
    unawaited(_themeStreamSubscription?.cancel());
    super.dispose();
  }

  Future<void> _init(_) async {
    _themeMode = await ThemeViewModel.instance.themeMode;
    setState(() {});
    unawaited(_themeStreamSubscription?.cancel());
    _themeStreamSubscription = ThemeViewModel.instance.themeStream.listen(
      (
        event,
      ) => setState(() => _themeMode = event.themeMode),
    );
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(Icons.contrast),
    title: Wrap(
      alignment: WrapAlignment.center,
      spacing: 2,
      children: [
        SegmentedButton<ThemeMode?>(
          emptySelectionAllowed: true,
          showSelectedIcon: false,
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          segments: <ButtonSegment<ThemeMode>>[
            ButtonSegment<ThemeMode>(
              value: ThemeMode.system,
              label: Text(ThemeMode.system.name),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.dark,
              label: Text(ThemeMode.dark.name),
              icon: const Icon(
                Icons.dark_mode,
              ),
            ),
            ButtonSegment<ThemeMode>(
              value: ThemeMode.light,
              label: Text(ThemeMode.light.name),
              icon: const Icon(
                Icons.light_mode,
              ),
            ),
          ],
          selected: <ThemeMode>{_themeMode ?? ThemeMode.system},
          onSelectionChanged: onSelected,
        ),
      ],
    ),
  );

  /// Called when a [ChoiceChip] is selected.
  ///
  /// Updates the [ThemeViewModel] with the [newSelection]. If [newSelection]
  /// is null (which can happen if a chip is deselected, though not in this
  /// specific UI setup),
  /// it defaults to [ThemeMode.system].
  ///
  /// - [newSelection]: The [ThemeMode] selected by the user.
  @protected
  void onSelected(Set<ThemeMode?> newSelection) => setState(() {
    unawaited(
      ThemeViewModel.instance.setThemeMode(
        newSelection.first ?? ThemeMode.system,
      ),
    );
  });
}
