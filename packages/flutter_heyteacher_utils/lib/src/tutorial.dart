/// Provides classes for creating and managing in-app tutorials.

/// This library includes [TutorialViewModel] for managing tutorial flows.
/// A tutorial is identify by the `screenMame` which is associated.

/// [TutorialViewModel.addItem] add a item to the tutorial of a screen.
/// [TutorialViewModel.start] show the tutoria per the specified screen.
library;

import 'package:app_tutorial/app_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A singleton class responsible for managing and displaying in-app tutorials.
///
/// It allows adding tutorial items associated with specific screen names and
/// then starting the tutorial sequence for a given screen.
class TutorialViewModel {
  final _logger = Logger('TutorialViewModel');

  static TutorialViewModel? _instance;

  /// Private constructor for the singleton pattern.
  TutorialViewModel._();

  /// Provides access to the singleton instance of [TutorialViewModel].
  static TutorialViewModel get instance => _instance ??= TutorialViewModel._();

  final Map<String, List<TutorialItem>> _screens = {};

  /// Adds a new tutorial item to a specific screen.
  ///
  /// If the [screenName] does not exist, it will be created.
  void addItem(
      {required String screenName,
      required GlobalKey globalKey,
      required String title,
      required String content,
      TutorialContentAlignment alignment = TutorialContentAlignment.center}) {
    if (!_screens.containsKey(screenName)) {
      _screens[screenName] = [];
    }
    _screens[screenName]!.add(TutorialItem(
        globalKey: globalKey,
        color: Colors.black.withValues(alpha: 0.8),
        child: TutorialItemContent(
          title: title,
          content: content,
          alignment: alignment,
        )));
  }

  bool _started = false;

  /// Starts the tutorial for the specified [screenName].
  ///
  /// The tutorial will be displayed after a short delay to ensure the UI is ready.
  /// It logs a message when the tutorial is completed.
  void start(
    BuildContext context,
    String screenName,
  ) async {
    _logger.finest('<start>: screenName $screenName');
    if ((await SharedPreferencesAsync()
                .getBool('$screenName-tutorial-completed') ??
            false) ||
        _started) {
      return;
    }
    _started = true;
    if (context.mounted) {
      _logger.info('((start): screenName $screenName. Show tutorial');
      Tutorial.showTutorial(context, _screens[screenName]!,
          onTutorialComplete: () {
        _logger.info('(start): screenName $screenName. Tutorial completed');
        SharedPreferencesAsync()
            .setBool('$screenName-tutorial-completed', true);
      });
    }
  }
}

enum TutorialContentAlignment {
  top,
  middleTop,
  center,
  middleBottom,
  bottom,
}

/// A widget that defines the content displayed within a single tutorial item.
///
/// It typically includes a [title] and [content] text, along with
/// "Skip onboarding" and "Next" buttons.
class TutorialItemContent extends StatelessWidget {
  /// Creates a [TutorialItemContent] widget.
  TutorialItemContent({
    super.key,
    required this.title,
    required this.content,
    this.alignment = TutorialContentAlignment.center,
  }) {
    assert(title.isNotEmpty, 'Title cannot be empty');
    assert(content.isNotEmpty, 'Content cannot be empty');
    switch (alignment) {
      case TutorialContentAlignment.top:
        _topFlex = 1;
        _bottomFlex = 3;
      case TutorialContentAlignment.middleTop:
        _topFlex = 1;
        _bottomFlex = 2;
      case TutorialContentAlignment.center:
        _topFlex = 1;
        _bottomFlex = 1;
      case TutorialContentAlignment.middleBottom:
        _topFlex = 2;
        _bottomFlex = 1;
      case TutorialContentAlignment.bottom:
        _topFlex = 3;
        _bottomFlex = 1;
    }
  }

  /// The title text for the tutorial item.
  final String title;

  /// The main content/description for the tutorial item.
  final String content;

  /// The alignment of the content within the tutorial item.
  ///
  /// Defaults to [TutorialContentAlignment.center].
  final TutorialContentAlignment alignment;

  late final int _topFlex, _bottomFlex;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: [
            Expanded(
              flex: _topFlex,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: _bottomFlex,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      textAlign: TextAlign.center,
                      content,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  // Row(
                  //   children: [
                  //     TextButton(
                  //       style: TextButton.styleFrom(
                  //         backgroundColor:
                  //             ThemeModel.instance().theme.colorScheme.primary,
                  //       ),
                  //       onPressed: () => Tutorial.skipAll(context),
                  //       child: Text(
                  //         'Skip onboarding',
                  //         style: Theme.of(context)
                  //             .textTheme
                  //             .titleSmall
                  //             ?.copyWith(
                  //                 color:
                  //                     ThemeModel.instance().theme.colorScheme.onPrimary),
                  //       ),
                  //     ),
                  //     const Spacer(),
                  //     TextButton(
                  //       style: TextButton.styleFrom(
                  //         backgroundColor:
                  //             ThemeModel.instance().theme.colorScheme.primary,
                  //       ),
                  //       onPressed: null,
                  //       child: Text(
                  //         'Next',
                  //         style: Theme.of(context)
                  //             .textTheme
                  //             .titleSmall
                  //             ?.copyWith(
                  //                 color:
                  //                     ThemeModel.instance().theme.colorScheme.onPrimary),
                  //       ),
                  //     )
                  //   ],
                  // ),
                ],
              ),
            ),
          ],
        ),
      );
}
