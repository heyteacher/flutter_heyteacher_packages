import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_heyteacher_locale/locale.dart' show LocaleViewModel;
import 'package:flutter_heyteacher_views/views.dart';
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:updown_arrow_scroller/updown_arrow_scroller.dart'
    show UpDownArrowScroller;
import 'package:url_launcher/url_launcher.dart';

/// The markdown view loading markdown page from assets
class MarkdownView extends StatefulWidget {
  /// Markdown page constructor.
  ///
  /// The markdown is loaded from assets [page] based on the current locale
  /// [LocaleViewModel.locale].
  const MarkdownView({
    required String page,
    String Function(BuildContext)? markdownAppendixCallback,
    super.key,
  }) : _page = page,
       _markdownAppendixCallback = markdownAppendixCallback;

  final String _page;

  final String Function(BuildContext)? _markdownAppendixCallback;

  @override
  State<MarkdownView> createState() => _MarkdownViewState();
}

class _MarkdownViewState extends State<MarkdownView> {
  String _markdownContents = '';

  final TocController _tocController = TocController();

  final List<TocItem> _tocList = [];

  final Map<String, int> _headerIndexes = {};

  final AutoScrollController _autoScrollController = AutoScrollController();

  StreamSubscription<Locale>? _localeStreamSubscription;

  Iterable<String> _headerRows = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  Future<void> _init(_) async {
    _tocList.clear();
    _headerIndexes.clear();
    _markdownContents = await rootBundle.loadString(
      'assets/pages/${LocaleViewModel.instance.locale.languageCode}/'
      '${widget._page}.md',
    );
    if (mounted) {
      _markdownContents +=
          widget._markdownAppendixCallback?.call(context) ?? '';
    }
    _headerRows = _markdownContents
        .split('\n')
        .where((row) => row.contains('# '));
    _tocController.setTocList(_tocList);
    unawaited(_localeStreamSubscription?.cancel());
    _localeStreamSubscription = LocaleViewModel.instance.localeStream.listen(
      _init,
    );
    setState(() {});
  }

  @override
  void dispose() {
    unawaited(_localeStreamSubscription?.cancel());
    _tocController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8),
    child: AdaptiveScaffold(
      drawler: TocWidget(controller: _tocController),
      bodyForLargeBuilder: _buildMarkdownWidget,
      bodyForSmallBuilder: _buildMarkdownWidget,
    ),
  );

  Widget _buildMarkdownWidget({
    required int crossAxisCount,
    required ScreenSize screenSize,
  }) {
    _tocList.clear();
    _headerIndexes.clear();
    unawaited(_init(context));
    return UpDownArrowScroller(
      childScrollController: _autoScrollController,
      child: MarkdownWidget(
        autoScrollController: _autoScrollController,
        markdownGenerator: MarkdownGenerator(
          // build the toc list on load the document
          // this is needed for small screens without TocWidget
          onNodeAccepted: (node, index) {
            if (node is HeadingNode) {
              final listLength = _tocList.length;
              _tocList.add(
                TocItem(
                  node: node,
                  widgetIndex: index,
                  tocListIndex: listLength,
                ),
              );
              final title = _headerRows
                  .elementAt(listLength)
                  .toLowerCase()
                  .split('# ')
                  .last
                  .replaceAll(' ', '-')
                  .replaceAll('_', '')
                  .replaceAll('(', '')
                  .replaceAll(')', '');
              _headerIndexes['#$title'] = index;
            }
          },
        ),
        config: MarkdownConfig.darkConfig.copy(
          configs: [
            _paragraphLinkConfig,
            if (ThemeViewModel.instance.isDark)
              PreConfig.darkConfig.copy(wrapper: _codeWrapper)
            else
              const PreConfig().copy(wrapper: _codeWrapper),
          ],
        ),
        padding: const EdgeInsets.all(8),
        tocController: _tocController,
        data: _markdownContents,
      ),
    );
  }

  /// Manages paragraph links
  LinkConfig get _paragraphLinkConfig => LinkConfig(
    onTap: (value) => value.startsWith('#')
        ? _jumpToParagraph(value)
        : launchUrl(Uri.parse(value)),
  );

  void _jumpToParagraph(String value) {
    final decoded = Uri.decodeQueryComponent(value);
    if (_headerIndexes[decoded] == null) return;
    _tocController.jumpToWidgetIndex(_headerIndexes[decoded]!);
  }

  Widget _codeWrapper(Widget child, String code, String language) =>
      _CodeWrapperWidget(
        text: code,
        language: language,
        showCopyButton: false,
        child: child,
      );
}

class _CodeWrapperWidget extends StatefulWidget {
  const _CodeWrapperWidget({
    required this.text,
    required this.language,
    required this.showCopyButton,
    required this.child,
  });
  final String text;
  final String language;
  final bool showCopyButton;
  final Widget child;

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
    return Stack(
      children: [
        widget.child,
        if (widget.showCopyButton)
          Align(
            alignment: Alignment.topRight,
            child: Container(
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
                            color: ThemeViewModel.instance.isDark
                                ? Colors.white
                                : Colors.black,
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
