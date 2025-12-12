import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' show launchUrl;

/// A _Get In On Google Play_ button.
class GetItOnGooglePlayButton extends StatelessWidget {
  /// Creates a [GetItOnGooglePlayButton].
  ///
  /// [appId] on Play Store must be speficied
  const GetItOnGooglePlayButton({required String appId, super.key})
    : _appId = appId;

  final String _appId;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: InkWell(
      onTap: () => launchUrl(
        Uri.https('play.google.com', '/store/apps/details', {
          'id': _appId,
        }),
      ),
      child: const Image(
        image: AssetImage(
          'assets/images/GetItOnGooglePlay_Badge_Web_color_English.png',
        ),
      ),
    ),
  );
}

/// The leading Icon
class LeadingIcon extends StatelessWidget {
  /// Creates a [LeadingIcon].
  const LeadingIcon({super.key, void Function()? onPressed})
    : _onPressed = onPressed;

  final VoidCallback? _onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: InkWell(
      onTap: _onPressed,
      child: const Image(
        image: AssetImage(
          'assets/images/icon.png',
        ),
      ),
    ),
  );
}

/// The title text
class TitleText extends StatelessWidget {
  /// Creater a [TitleText]
  const TitleText({
    required this.title,
    super.key,
    TextAlign textAlign = TextAlign.center,
    EdgeInsets? padding,
  }) : _padding = padding,
       _textAlign = textAlign;

  /// The title text
  @protected
  final String title;

  final TextAlign _textAlign;

  final EdgeInsets? _padding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: _padding ?? EdgeInsets.zero,
    child: Text(
      title,
      textAlign: _textAlign,
      style: Theme.of(context).textTheme.headlineLarge,
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
