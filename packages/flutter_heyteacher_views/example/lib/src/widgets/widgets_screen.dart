import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';
import 'package:flutter_heyteacher_views_example/src/app_router.dart'
    show AppRouteName;
import 'package:go_router/go_router.dart';

/// This Widget is the main application widget.
class WidgetsScreen extends StatefulWidget {
  /// Creates the [WidgetsScreen].
  const WidgetsScreen({super.key});

  @override
  State<WidgetsScreen> createState() => _WidgetsScreenState();
}

class _WidgetsScreenState extends State<WidgetsScreen> {
  bool _loading = false;

  static const tutorialScreenName = 'Example';
  static final GlobalKey _floatingActionTextIconButtom = GlobalKey();
  static final GlobalKey _tutorialKey = GlobalKey();
  static final GlobalKey _genericsDropDownMenuKey = GlobalKey();
  static final GlobalKey _tableViewKey = GlobalKey();
  static final GlobalKey _showConfirmCancelDialogKey = GlobalKey();
  static final GlobalKey _showSnackBarKey = GlobalKey();
  static final GlobalKey _tooltipIconButtonKey = GlobalKey();
  static final GlobalKey _errorViewKey = GlobalKey();
  static final GlobalKey _progressIndicatorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_initTutorial);
  }

  void _initTutorial(_) {
    TutorialViewModel.instance.addItem(
      screenName: tutorialScreenName,
      globalKey: _tutorialKey,
      alignment: TutorialContentAlignment.top,
      title: 'Tutorial',
      content: 'A Tutorial Example',
    );
    TutorialViewModel.instance.addItem(
      screenName: tutorialScreenName,
      globalKey: _genericsDropDownMenuKey,
      alignment: TutorialContentAlignment.middleTop,
      title: 'Generics Drop Down Menu',
      content: 'A Generics Drop Down Menu Example',
    );
    TutorialViewModel.instance.addItem(
      screenName: tutorialScreenName,
      globalKey: _tableViewKey,
      title: 'Table View',
      content: 'A Table View Example',
    );
    TutorialViewModel.instance.addItem(
      screenName: tutorialScreenName,
      globalKey: _showConfirmCancelDialogKey,
      title: 'Show Confirm Cancel Dialog',
      content: 'A Show Confirm Cancel Dialog Exampòe',
    );
    TutorialViewModel.instance.addItem(
      screenName: tutorialScreenName,
      globalKey: _showSnackBarKey,
      title: 'Show Snack Bar',
      content: 'A Show Snack Bar Example',
    );
    TutorialViewModel.instance.addItem(
      screenName: tutorialScreenName,
      globalKey: _tooltipIconButtonKey,
      alignment: TutorialContentAlignment.middleTop,
      title: 'Tooltip Icon Button',
      content: 'A Tooltip Icon Button Example',
    );
    TutorialViewModel.instance.addItem(
      screenName: tutorialScreenName,
      globalKey: _errorViewKey,
      alignment: TutorialContentAlignment.middleTop,
      title: 'Error View',
      content: 'An Error View Example',
    );
    TutorialViewModel.instance.addItem(
      screenName: tutorialScreenName,
      globalKey: _progressIndicatorKey,
      title: 'Progress Indicator',
      content: 'A Progress Indicator Example',
    );
    TutorialViewModel.instance.addItem(
      screenName: tutorialScreenName,
      globalKey: _floatingActionTextIconButtom,
      alignment: TutorialContentAlignment.bottom,
      title: 'Floating Action Text Icon Buttom',
      content: 'A Floating Action Text Icon Buttom Example',
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Views'),
      actions: const [ThemeModeButton()],
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: Row(
      key: _floatingActionTextIconButtom,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionTextIconButtom(
          text: 'Play',
          iconData: Icons.play_circle,
          onPressed: () => showSnackBar(context: context, message: 'Play'),
        ),
        FloatingActionTextIconButtom(
          text: 'Stop',
          iconData: Icons.stop_circle,
          onPressed: () =>
              showSnackBar(context: context, message: 'Stop', error: true),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          key: _tutorialKey,
          title: const Text('Tutorial'),
          trailing: OutlinedButton(
            onPressed: () => TutorialViewModel.instance.start(
              context,
              tutorialScreenName,
              forceRestart: true,
            ),
            child: const Text(
              'Start',
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.white24),
        Padding(
          key: _genericsDropDownMenuKey,
          padding: const EdgeInsets.all(8),
          child: Center(
            child: GenericsDropDownMenu<int>(
              label: 'Generics Drop Down Menu',
              initialSelection: 1,
              values: const [
                (icon: Icon(Icons.onetwothree), label: 'one', value: 1),
                (
                  icon: Icon(Icons.onetwothree_outlined),
                  label: 'two',
                  value: 2,
                ),
                (
                  icon: Icon(Icons.onetwothree_rounded),
                  label: 'three',
                  value: 3,
                ),
              ],
              onSelected: (value, {index}) => showSnackBar(
                context: context,
                message: 'value $value selected',
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Colors.white24),
        const Text('Table View'),
        Padding(
          key: _tableViewKey,
          padding: const EdgeInsets.all(8),
          child: _SampleTableView(),
        ),
        const Divider(height: 1, color: Colors.white24),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          key: _showConfirmCancelDialogKey,
          title: const Text('Show Confirm Cancel Dialog'),
          trailing: Wrap(
            spacing: 2,
            children: [
              OutlinedButton(
                onPressed: () => showConfirmCancelDialog(
                  context: context,
                  title: const Text('Title'),
                  content: const Text('Do you confirm this action?'),
                  confirmCallback: (_) async {
                    showSnackBar(
                      context: context,
                      message: 'Confirmed',
                    );
                    return null;
                  },
                  cancelCallback: (_) async {
                    showSnackBar(
                      context: context,
                      message: 'Canceled',
                      error: true,
                    );
                    return null;
                  },
                  timeout: const Duration(seconds: 5),
                ),
                child: const Text(
                  'Open',
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white24),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          key: _showSnackBarKey,
          title: const Text('Show Snack Bar'),
          trailing: Wrap(
            spacing: 2,
            children: [
              OutlinedButton(
                onPressed: () => showSnackBar(
                  context: context,
                  message: 'Snack Bar Message',
                ),
                child: Text(
                  'Message',
                  style: TextStyle(
                    color: ThemeViewModel.instance.greenColor,
                  ),
                ),
              ),
              OutlinedButton(
                onPressed: () => showSnackBar(
                  context: context,
                  message: 'Snack Bar Error',
                  error: true,
                ),
                child: Text(
                  'Error',
                  style: TextStyle(color: ThemeViewModel.instance.redColor),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white24),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          key: _tooltipIconButtonKey,
          title: const Wrap(
            spacing: 2,
            children: [
              Text('Tooltip Icon Button'),
              TooltipIconButton(
                content: Text('This is a tooltip'),
                iconSize: 20,
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white24),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          key: _errorViewKey,
          title: const Text('Error View'),
          trailing: IconButton(
            onPressed: () => unawaited(
              GoRouter.of(
                context,
              ).pushNamed(AppRouteName.errorView.name),
            ),
            icon: const Icon(Icons.keyboard_arrow_right),
          ),
        ),
        const Divider(height: 1, color: Colors.white24),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          key: _progressIndicatorKey,
          title: const Text('Progress Indicator'),
          trailing: Wrap(
            children: [
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: ProgressIndicatorWidget(),
                )
              else
                IconButton(
                  onPressed: () async {
                    setState(() => _loading = true);
                    await Future<void>.delayed(
                      const Duration(seconds: 5),
                    );
                    setState(() => _loading = false);
                  },
                  icon: const Icon(Icons.timer),
                ),
              IconButton(
                onPressed: () async {
                  unawaited(
                    GoRouter.of(
                      context,
                    ).pushNamed(AppRouteName.progressIndicatorView.name),
                  );
                },
                icon: const Icon(Icons.keyboard_arrow_right),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Colors.white24),
      ],
    ),
  );
}

class _SampleTableView extends TableView {
  @override
  Widget build(BuildContext context) => Table(
    columnWidths: const {
      0: FlexColumnWidth(1.5),
      1: FlexColumnWidth(),
      2: FlexColumnWidth(),
      3: FlexColumnWidth(1.5),
    },
    border: TableBorder.all(
      color: ThemeViewModel.instance.darkGreyColor,
    ),
    children: [
      TableRow(
        children: [
          super.valueTextBlue(
            context,
            'valueTextBlue',
            textAlign: TextAlign.right,
          ),
          super.labelText('labelText', textAlign: TextAlign.left),
          super.labelText('labelText'),
          valueTextRed(context, 'valueTextRed'),
        ],
      ),
      TableRow(
        children: [
          super.valueTextGreen(
            context,
            'valueTextGreen',
            textAlign: TextAlign.right,
          ),
          super.labelText('labelText', textAlign: TextAlign.left),
          super.labelText('labelText'),
          valueTextOrange(context, 'valueTextOrange'),
        ],
      ),
      TableRow(
        children: [
          super.valueTextYellow(
            context,
            'valueTextYellow',
            textAlign: TextAlign.right,
          ),
          super.labelText('labelText', textAlign: TextAlign.left),
          super.labelText('labelText'),
          valueText(context, 'valueText'),
        ],
      ),
    ],
  );
}
