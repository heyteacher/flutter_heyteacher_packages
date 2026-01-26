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

  /// Sets the analytics collection status to [enable].
  ///
  /// Source - https://stackoverflow.com/a/60336946
  /// Posted by Jakob Kühne, modified by community. See post 'Timeline' for
  /// change history
  /// Retrieved 2026-01-25, License - CC BY-SA 4.0
  Future<void> status({required bool enable}) async {
    _logger.info('<status>: enable $enable');
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enable);
  }
}
