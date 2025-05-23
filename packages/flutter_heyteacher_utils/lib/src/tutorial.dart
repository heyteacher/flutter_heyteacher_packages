/// Provides classes for creating and managing in-app tutorials.

/// This library includes [TutorialModel] for managing tutorial flows.
/// A tutorial is identify by the `screenMame` which is associated.

/// [TutorialModel.addItem] add a item to the tutorial of a screen.
/// [TutorialModel.start] show the tutoria per the specified screen.
library;

import 'package:app_tutorial/app_tutorial.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/theme.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A singleton class responsible for managing and displaying in-app tutorials.
///
/// It allows adding tutorial items associated with specific screen names and
/// then starting the tutorial sequence for a given screen.
class TutorialModel {
  final _log = Logger('TutorialModel');

  static TutorialModel? _instance;

  /// Private constructor for the singleton pattern.
  TutorialModel._();

  /// Provides access to the singleton instance of [TutorialModel].
  static TutorialModel get instance => _instance ??= TutorialModel._();

  final Map<String, List<TutorialItem>> _screens = {};

  /// Adds a new tutorial item to a specific screen.
  ///
  /// If the [screenName] does not exist, it will be created.
  void addItem(
      {required String screenName,
      required GlobalKey globalKey,
      required String title,
      required String content}) {
    if (!_screens.containsKey(screenName)) {
      _screens[screenName] = [];
    }
    _screens[screenName]!.add(TutorialItem(
        globalKey: globalKey,
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: const Radius.circular(15.0),
        shapeFocus: ShapeFocus.roundedSquare,
        child: TutorialItemContent(
          title: title,
          content: content,
        )));
  }

  /// Starts the tutorial for the specified [screenName].
  ///
  /// The tutorial will be displayed after a short delay to ensure the UI is ready.
  /// It logs a message when the tutorial is completed.
  void start(
    BuildContext context,
    String screenName,
  ) async {
    await Future.delayed(const Duration(microseconds: 200));
    if (context.mounted) {
      if ((await SharedPreferencesAsync()
              .getBool('$screenName-tutorial-completed') ??
          false)) {
        return;
      }
      if (context.mounted) {
        Tutorial.showTutorial(context, _screens[screenName]!,
            onTutorialComplete: () {
          _log.info('Tutorial completed');
          SharedPreferencesAsync()
              .setBool('$screenName-tutorial-completed', true);
        });
      }
    }
  }
}

/// A widget that defines the content displayed within a single tutorial item.
///
/// It typically includes a [title] and [content] text, along with
/// "Skip onboarding" and "Next" buttons.
class TutorialItemContent extends StatelessWidget {
  /// Creates a [TutorialItemContent] widget.
  const TutorialItemContent({
    super.key,
    required this.title,
    required this.content,
  });

  /// The title text for the tutorial item.
  final String title;

  /// The main content/description for the tutorial item.
  final String content;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Center(
      child: SizedBox(
        height: height * 0.9,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.1, vertical: height * 0.5),
          child: Column(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10.0),
              Text(
                content,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              Row(
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          ThemeModel.instance().theme.colorScheme.onPrimary,
                      foregroundColor:
                          ThemeModel.instance().theme.colorScheme.primary,
                    ),
                    onPressed: () => Tutorial.skipAll(context),
                    child: Text(
                      'Skip onboarding',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor:
                          ThemeModel.instance().theme.colorScheme.primary,
                      foregroundColor:
                          ThemeModel.instance().theme.colorScheme.onPrimary,
                    ),
                    onPressed: null,
                    child: Text(
                      'Next',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
