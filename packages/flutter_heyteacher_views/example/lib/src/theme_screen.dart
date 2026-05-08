import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// This Widget is the main application widget.
class ThemeScreen extends StatefulWidget {
  /// Creates the [ThemeScreen].
  const ThemeScreen({super.key});

  @override
  State<ThemeScreen> createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Views'),
      actions: const [ThemeModeButton()],
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionTextIconButtom(
          text: 'Theme',
          iconData: Icons.color_lens,
          onPressed: () {},
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      children: [
        const Column(
          children: [
            ThemeModeListTile(),
            Divider(height: 1, color: Colors.white24),
          ],
        ),
        Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              title: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 2,
                children: [
                  Text(
                    'surface',
                    style: TextStyle(
                      color: ThemeViewModel.instance.colorScheme.onSurface,
                      backgroundColor:
                          ThemeViewModel.instance.colorScheme.surface,
                    ),
                  ),
                  Text(
                    'primary',
                    style: TextStyle(
                      color: ThemeViewModel.instance.colorScheme.onPrimary,
                      backgroundColor:
                          ThemeViewModel.instance.colorScheme.primary,
                    ),
                  ),
                  Text(
                    'secondary',
                    style: TextStyle(
                      color: ThemeViewModel.instance.colorScheme.onSecondary,
                      backgroundColor:
                          ThemeViewModel.instance.colorScheme.secondary,
                    ),
                  ),
                  Text(
                    'error',
                    style: TextStyle(
                      color: ThemeViewModel.instance.colorScheme.onError,
                      backgroundColor:
                          ThemeViewModel.instance.colorScheme.error,
                    ),
                  ),
                  Text(
                    'surfaceContainer',
                    style: TextStyle(
                      color:
                          ThemeViewModel.instance.colorScheme.onSurfaceVariant,
                      backgroundColor:
                          ThemeViewModel.instance.colorScheme.surfaceContainer,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
          ],
        ),
        Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),

              title: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 2,
                children: [
                  Text(
                    'Blue',
                    style: TextStyle(
                      color: ThemeViewModel.instance.blueColor,
                    ),
                  ),
                  Text(
                    'Dark Grey',
                    style: TextStyle(
                      color: ThemeViewModel.instance.darkGreyColor,
                    ),
                  ),
                  Text(
                    'Deep Purple',
                    style: TextStyle(
                      color: ThemeViewModel.instance.deepPurpleColor,
                    ),
                  ),
                  Text(
                    'Green',
                    style: TextStyle(
                      color: ThemeViewModel.instance.greenColor,
                    ),
                  ),
                  Text(
                    'Grey',
                    style: TextStyle(
                      color: ThemeViewModel.instance.greyColor,
                    ),
                  ),
                ],
              ),
              subtitle: Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 2,
                children: [
                  Text(
                    'Grey',
                    style: TextStyle(
                      color: ThemeViewModel.instance.greyColor,
                    ),
                  ),
                  Text(
                    'Orange',
                    style: TextStyle(
                      color: ThemeViewModel.instance.orangeColor,
                    ),
                  ),
                  Text(
                    'Purple',
                    style: TextStyle(
                      color: ThemeViewModel.instance.purpleColor,
                    ),
                  ),
                  Text(
                    'Red',
                    style: TextStyle(color: ThemeViewModel.instance.redColor),
                  ),
                  Text(
                    'Yellow',
                    style: TextStyle(
                      color: ThemeViewModel.instance.yellowColor,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
          ],
        ),
        Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text('Text Button'),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('Outline Button'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    child: const Text('Elevated Button'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
          ],
        ),
        Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 8),

              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Badge(
                    label: Text('Badge'),
                    child: Icon(Icons.widgets, size: 40),
                  ),
                  Switch(
                    // This bool value toggles the switch.
                    value: true,
                    onChanged: (enabled) {},
                  ),
                  GenericsDropDownMenu<int>(
                    label: 'Generics Drop DownMenu',
                    onSelected: (onSelected, {index}) {},
                    values: const [(icon: null, label: 'Item 1', value: 1)],
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
          ],
        ),
        Column(
          children: [
            TabBar(
              controller: _tabController,
              tabs: const <Widget>[
                Tab(
                  icon: Icon(Icons.list),
                  text: 'Tab 1',
                ),
                Tab(
                  icon: Icon(Icons.history),
                  text: 'Tab 2',
                ),
              ],
            ),
            SizedBox(
              height: 80,
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  Center(
                    child: Text(
                      'Tab 1 content',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                  Center(
                    child: Text(
                      'Tab 2 content',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white24),
          ],
        ),
      ],
    ),
  );
}
