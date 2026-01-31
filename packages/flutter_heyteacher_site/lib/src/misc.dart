import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_heyteacher_utils/adaptive_layout.dart';
import 'package:flutter_heyteacher_utils/locale.dart' show LocaleViewModel;
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/all.dart';
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

/// The markdown page widget loding markdown from assets
class MarkdownPage extends StatelessWidget {
  /// Markdown page constructor.
  ///
  /// The markdown is loaded from assets [page] based on the current locale
  /// [LocaleViewModel.locale].
  MarkdownPage({
    required String page,
    super.key,
  }) : _page = page;

  final String _page;

  final TocController _tocController = TocController();

  Widget _codeWrapper(Widget child, String code, String language) =>
      _CodeWrapperWidget(child, code, language);

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
        builder: (_, asyncSnapshot) => AdaptiveScaffold(
          drawler: TocWidget(controller: _tocController),
          bodyForLargeBuilder: () => MarkdownWidget(
            config: MarkdownConfig.darkConfig.copy(
              configs: [PreConfig.darkConfig.copy(wrapper: _codeWrapper)],
            ),
            padding: const EdgeInsets.all(8),
            tocController: _tocController,
            data: asyncSnapshot.data ?? '',
          ),
          bodyForSmallBuilder: () => MarkdownWidget(
            tocController: _tocController,
            data: asyncSnapshot.data ?? '',
          ),
        ),
      ),
    ),
  );
}

class _CodeWrapperWidget extends StatefulWidget {
  const _CodeWrapperWidget(this.child, this.text, this.language);
  final Widget child;
  final String text;
  final String language;

  @override
  State<_CodeWrapperWidget> createState() => _PreWrapperState();
}

class _PreWrapperState extends State<_CodeWrapperWidget> {
  late Widget _switchWidget;
  bool hasCopied = false;

  @override
  void initState() {
    super.initState();
    _switchWidget = Icon(Icons.copy_rounded, key: UniqueKey());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        widget.child,
        Align(
          alignment: Alignment.topRight,
          child: Container(
            color: isDark? Colors.white10 : Colors.white70,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.language.isNotEmpty)
                  SelectionContainer.disabled(
                    child: Container(
                      margin: const EdgeInsets.only(right: 2),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          width: 0.5,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      child: Text(widget.language),
                    ),
                  ),
                InkWell(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _switchWidget,
                  ),
                  onTap: () async {
                    if (hasCopied) return;
                    await Clipboard.setData(ClipboardData(text: widget.text));
                    _switchWidget = Icon(Icons.check, key: UniqueKey());
                    refresh();
                    Future.delayed(const Duration(seconds: 2), () {
                      hasCopied = false;
                      _switchWidget = Icon(
                        Icons.copy_rounded,
                        key: UniqueKey(),
                      );
                      refresh();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void refresh() {
    if (mounted) setState(() {});
  }
}
