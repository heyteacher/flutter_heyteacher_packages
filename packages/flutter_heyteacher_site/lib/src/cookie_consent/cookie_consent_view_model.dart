import 'dart:async';

import 'package:flutter_cookie_consent/flutter_cookie_consent.dart';
import 'package:flutter_heyteacher_firebase/flutter_heyteacher_firebase.dart';
import 'package:logging/logging.dart';

/// The cookie consent view model.
///
/// Checks the cookie consent status with [enabled] and set the cookie consent
/// status with [set].
class CookieConsentViewModel {
  /// Private constructor for the singleton pattern.
  CookieConsentViewModel._();

  final Logger _logger = Logger('CookieConsentViewModel');

  static CookieConsentViewModel? _instance;

  /// Provides the singleton instance of [CookieConsentViewModel].
  // ignore: prefer_constructors_over_static_methods
  static CookieConsentViewModel get instance =>
      _instance ??= CookieConsentViewModel._();

  FlutterCookieConsent? _cookieConsent;

  /// Provides the cookie consent instance.
  FlutterCookieConsent? get cookieConsent => _cookieConsent;

  /// Initializes the cookie consent.
  Future<void> initialize() async {
    _logger.finer('<initialize>:');
    if (_cookieConsent == null) {
      _logger.info('(initialize): create and initialize cookie consent');
      _cookieConsent = FlutterCookieConsent();
      await _cookieConsent!.initialize();
    }
  }

  /// Checks the cookie consent status.
  /// 
  /// If unclicked, returns null, otherwide returns if has consent or not.
  Future<bool?> get enabled async {
    _logger.finer('<enabled>:');
    await initialize();
    final enabled = _cookieConsent!.shouldShowBanner
        ? null
        : _cookieConsent!.hasConsent;
    _logger.finer('(enabled): returns $enabled');
    return enabled;
  }

  /// Sets the cookie consent status to [enable].
  Future<void> set({required bool enable}) async {
    _logger.finer('<set>: enable $enable');
    await initialize();
    _logger.info(
      '(set): enable $enable. set google analytics to $enable and save '
      'preferences',
    );
    unawaited(GoogleAnalitycsViewModel.instance.set(enable: enable));
    unawaited(
      _cookieConsent!.savePreferences({
        'essential': true,
        'analytics': enable,
        'marketing': false,
      }),
    );
  }
}
