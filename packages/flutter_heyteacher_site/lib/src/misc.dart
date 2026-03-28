import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_firebase/flutter_heyteacher_firebase.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

/// A _Get In On Google Play_ button.
class GetItOnGooglePlayButton extends StatefulWidget {
  /// Creates a [GetItOnGooglePlayButton].
  ///
  /// [appId] on Play Store must be speficied
  const GetItOnGooglePlayButton({
    required String appId,
    super.key,
  }) : _appId = appId;

  final String _appId;
 
  @override
  State<GetItOnGooglePlayButton> createState() =>
      _GetItOnGooglePlayButtonState();
}

class _GetItOnGooglePlayButtonState
    extends
        AdaptiveState<
          GetItOnGooglePlayButton,
          _AbstractGetItOnGooglePlayButtonState,
          String
        > {
  @override
  _AbstractGetItOnGooglePlayButtonState createAdaptiveState() =>
      _AbstractGetItOnGooglePlayButtonState();

  @override
  String get params => widget._appId;
}

class _AbstractGetItOnGooglePlayButtonState
    extends AbstractAdaptiveState<String> {
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(4),
    child: InkWell(
      onTap: () async {
        await GoogleAnalitycsViewModel.instance.logCustomEvent(
          name: 'get_it_on_google_play',
        );
        unawaited(
          launchUrl(
            Uri.https('play.google.com', '/store/apps/details', {
              'id': widget.params,
            }),
          ),
        );
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: switch (widget.screenSize) {
            ScreenSize.small => 150,
            ScreenSize.medium => 225,
            ScreenSize.large => 275,
          },
        ),
        child: const Image(
          image: AssetImage(
            'assets/images/GetItOnGooglePlay_Badge_Web_color_English.png',
              package: 'flutter_heyteacher_site',
          ),
        ),
      ),
    ),
  );
}

/// The leading Icon.
///
/// show the logo `assetIconPath` (default  `assets/images/icon.png`)
class LeadingIcon extends StatelessWidget {
  /// Creates a [LeadingIcon] with imaged stored in [assetIconPath]
  /// (default  `assets/images/icon.png`)
  const LeadingIcon({
    String assetIconPath = 'assets/images/icon.png',
    super.key,
    void Function()? onPressed,
  }) : _assetIconPath = assetIconPath,
       _onPressed = onPressed;

  final VoidCallback? _onPressed;

  final String _assetIconPath;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: _onPressed,
    child: Image(image: AssetImage(_assetIconPath)),
  );
}

/// The title text
class TitleText extends StatelessWidget {
  /// Creater a [TitleText]
  const TitleText({
    required this.title,
    TextStyle? style,
    super.key,
    TextAlign textAlign = TextAlign.center,
    EdgeInsets? padding,
  }) : _style = style,
       _padding = padding,
       _textAlign = textAlign;

  /// The title text
  @protected
  final String title;

  final TextAlign _textAlign;

  final EdgeInsets? _padding;

  final TextStyle? _style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: _padding ?? EdgeInsets.zero,
    child: Text(
      title,
      textAlign: _textAlign,
      style: _style ?? Theme.of(context).textTheme.headlineMedium,
    ),
  );
}

/// The title text as a sliver
class TitleTextSliver extends TitleText {
  /// Creater a [TitleTextSliver]
  const TitleTextSliver({required super.title, super.key, super.padding});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: super.build(context),
  );
}
