import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/flutter_heyteacher_site.dart'
    show SlideData, SlideSliver;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeModeButton;

/// The home screen
class SlidesScreen extends StatelessWidget {
  /// Creates the [SlidesScreen].
  const SlidesScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('SlideSliver'),
      actions: const [
        ThemeModeButton(),
      ],
    ),
    body: CustomScrollView(
      slivers: [
        SlideSliver(
          decoration: BoxDecoration(border: Border.all(color: Colors.white24)),
          slides: [
            SlideData(
              title: 'Slide Title',
              subtitle: 'Slide Subtitle',
              body: [
                (
                  leadingIcon: Icons.abc,
                  text: 'Body 1',
                  leadingIconColor: Colors.blue,
                ),
                (
                  leadingIcon: Icons.ac_unit,
                  text: 'Body 2',
                  leadingIconColor: Colors.green,
                ),
                (
                  leadingIcon: Icons.access_alarm,
                  text: 'Body 3',
                  leadingIconColor: Colors.red,
                ),
              ],
            ),
            SlideData(imagePaths: ['assets/images/sample.png']),
            SlideData(
              title: 'Slide Title',
              subtitle: 'Slide Subtitle',
              body: [
                (
                  leadingIcon: Icons.abc,
                  text: 'Body 1',
                  leadingIconColor: Colors.blue,
                ),
                (
                  leadingIcon: Icons.ac_unit,
                  text: 'Body 2',
                  leadingIconColor: Colors.green,
                ),
                (
                  leadingIcon: Icons.access_alarm,
                  text: 'Body 3',
                  leadingIconColor: Colors.red,
                ),
              ],
            ),
            SlideData(imagePaths: ['assets/images/sample.png']),
          ],
        ),
      ],
    ),
  );
}
