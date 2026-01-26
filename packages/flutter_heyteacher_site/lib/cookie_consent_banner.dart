import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_cookie_consent/flutter_cookie_consent.dart';
import 'package:flutter_cookie_consent/ui/flutter_cookie_consent_banner.dart';
import 'package:flutter_heyteacher_site/src/l10n/flutter_heyteacher_site.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_heyteacher_utils/theme.dart';

/// The Cookie consent banner.
class CookieConsentBanner extends StatefulWidget {
  /// create instance of [CookieConsentBanner]
  const CookieConsentBanner({super.key});

  @override
  State<CookieConsentBanner> createState() => _CookieConsentBannerState();
}


class _CookieConsentBannerState extends State<CookieConsentBanner> {
  final FlutterCookieConsent _cookieConsent = FlutterCookieConsent();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  Future<void> _init(_) async {
    await _cookieConsent.initialize();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) => _cookieConsent.createBanner(
    context: context,
    onAccept: _setCookieConsent,
    onDecline: _setCookieConsent,
    title: FlutterHeyteacherSiteLocalizations.of(context)!.cookieSettings,
    message: FlutterHeyteacherSiteLocalizations.of(context)!.cookieMessage,
    acceptButtonText: FlutterHeyteacherSiteLocalizations.of(context)!.accept,
    declineButtonText: FlutterHeyteacherSiteLocalizations.of(context)!.decline,
    settingsButtonText: FlutterHeyteacherSiteLocalizations.of(
      context,
    )!.settings,
    showSettings: false,
    style: CookieConsentStyle(
      backgroundColor: ThemeViewModel.instance.colorScheme.onPrimary,
      titleStyle: TextStyle(
        color: ThemeViewModel.instance.colorScheme.onSurface,
      ),
      messageStyle: TextStyle(
        color: ThemeViewModel.instance.colorScheme.onSurface,
      ),
      acceptButtonStyle: _cookieConsentButtonStyle(),
      declineButtonStyle: _cookieConsentButtonStyle(),
      settingsButtonStyle: _cookieConsentButtonStyle(),
    ),
    position: BannerPosition.bottom,
  );

  void _setCookieConsent(bool enable) {
    unawaited(GoogleAnalitycsViewModel.instance.status(enable: enable));
    unawaited(
      _cookieConsent.savePreferences({
        'essential': true,
        'analytics': enable,
        'marketing': false,
      }),
    );
  }

  ButtonStyle _cookieConsentButtonStyle() => ButtonStyle(
    backgroundColor: WidgetStateProperty.all(
      ThemeViewModel.instance.colorScheme.primary,
    ),
    foregroundColor: WidgetStateProperty.all(
      ThemeViewModel.instance.colorScheme.onPrimary,
    ),
  );
}
