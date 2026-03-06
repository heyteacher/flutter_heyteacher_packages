import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logging/logging.dart';

/// The google analytics view model.
class GoogleAnalitycsViewModel {
  /// Private constructor for the singleton pattern.
  GoogleAnalitycsViewModel._();
  static GoogleAnalitycsViewModel? _instance;

  static final _logger = Logger('GoogleAnalitycsViewModel');

  /// Provides the singleton instance of [GoogleAnalitycsViewModel].
  // ignore: prefer_constructors_over_static_methods
  static GoogleAnalitycsViewModel get instance =>
      _instance ??= GoogleAnalitycsViewModel._();

  bool _enabled = true;

  /// Provides the analytics collection status.
  bool get enabled => _enabled;

  /// Sets the analytics collection status to [enable].
  ///
  /// Source - https://stackoverflow.com/a/60336946
  /// Posted by Jakob Kühne, modified by community. See post 'Timeline' for
  /// change history
  /// Retrieved 2026-01-25, License - CC BY-SA 4.0
  Future<void> set({required bool enable}) async {
    _logger.info('<set>: enable $enable');
    _enabled = enable;
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enable);
  }

  /// Logs an event with the given [name] and [parameters].
  Future<void> logCustomEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    _logger.finer('<logCustomEvent>: name $name. enabled $enabled');
    await FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  /// Logs a view item with the given [id], [name], and [affiliation].
  Future<void> logViewItem({
    required String id,
    required String name,
    String? affiliation,
  }) async {
    _logger.finer(
      '<logViewItem>: id $id name $name affiliation $affiliation. '
      'enabled $enabled',
    );
    await FirebaseAnalytics.instance.logViewItem(
      items: [
        AnalyticsEventItem(
          itemId: id,
          itemName: name,
          affiliation: affiliation,
        ),
      ],
    );
  }
}
