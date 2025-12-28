import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_heyteacher_utils/adaptive_layout.dart';
import 'package:flutter_heyteacher_utils/locale.dart' show LocaleViewModel;
import 'package:markdown_widget/widget/markdown.dart' show MarkdownWidget;
import 'package:url_launcher/url_launcher.dart' show launchUrl;

/// A _Get In On Google Play_ button.
class GetItOnGooglePlayButton extends StatelessWidget {
  /// Creates a [GetItOnGooglePlayButton].
  ///
  /// [appId] on Play Store must be speficied
  const GetItOnGooglePlayButton({
    required String appId,
    required ScreenSize screenSize,
    super.key,
  }) : _screenSize = screenSize,
       _appId = appId;

  final String _appId;
  final ScreenSize _screenSize;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(4),
    child: InkWell(
      onTap: () => launchUrl(
        Uri.https('play.google.com', '/store/apps/details', {
          'id': _appId,
        }),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: switch (_screenSize) {
            ScreenSize.small => 160,
            ScreenSize.medium => 230,
            ScreenSize.large => 270,
          },
        ),
        child: const Image(
          image: AssetImage(
            'assets/images/GetItOnGooglePlay_Badge_Web_color_English.png',
          ),
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
  Widget build(BuildContext context) => InkWell(
    onTap: _onPressed,
    child: const Image(
      image: AssetImage(
        'assets/images/icon.png',
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
      style: Theme.of(context).textTheme.headlineMedium,
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

/// The markdown page widget loding markdown from assets
class MarkdownPage extends StatelessWidget {
  /// Markdown page constructor.
  ///
  /// The markdown is loaded from assets [page] based on the current locale
  /// [LocaleViewModel.locale].
  const MarkdownPage({
    required String page,
    super.key,
  }) : _page = page;

  final String _page;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: StreamBuilder(
      stream: LocaleViewModel.instance.localeStream,
      initialData: LocaleViewModel.instance.locale,
      builder: (_, _) => FutureBuilder<String>(
        future: rootBundle.loadString(
          'assets/pages/${LocaleViewModel.instance.locale.languageCode}/'
          '$_page.md',
        ),
        builder: (_, asyncSnapshot) => MarkdownWidget(
          data: asyncSnapshot.data ?? '',
        ),
      ),
    ),
  );
}
