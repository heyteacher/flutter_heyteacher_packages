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
  const LeadingIcon({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(8),
    child: Image(
      image: AssetImage(
        'assets/images/icon.png',
      ),
    ),
  );
}

/// The title text
class TitleText extends StatelessWidget {
  
  /// Creater a [TitleText]
  const TitleText({required this.title, super.key});

  /// The title text
  @protected
  final String title;

  @override
  Widget build(BuildContext context) => Text(
    title,
    textAlign: TextAlign.center,
    style: Theme.of(context).textTheme.headlineLarge,
  );
}

/// The title text as a sliver
class TitleTextSliver extends TitleText {
  /// Creater a [TitleTextSliver]
  const TitleTextSliver({required super.title, super.key});

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: TitleText(title: title),
  );

}
