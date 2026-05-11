import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/flutter_heyteacher_site.dart'
    show
        CookieConsentBanner,
        CookieConsentViewModel,
        GetItOnGooglePlayButton,
        LeadingIcon,
        TitleText;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeModeButton;
import 'package:go_router/go_router.dart' show GoRouter;

/// The home screen
class HomeScreen extends StatefulWidget {
  /// Creates the [HomeScreen].
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: Builder(
        builder: (context) => LeadingIcon(
          onPressed: () => GoRouter.of(context).goNamed('home'),
        ),
      ),
      title: Text(
        'Flutter Heyteacher Site',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      actions: const [
        ThemeModeButton(),
        GetItOnGooglePlayButton(
          appId: 'me.heyteacher.flutter_heyteacher_site_example',
        ),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Stack(
        children: [
          Column(
            spacing: 8,
            children: [
              ListTile(
                title: const Text('Markdown'),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => GoRouter.of(context).pushNamed('markdown'),
              ),
              const Divider(height: 1, color: Colors.white24),
              ListTile(
                title: const Text('SlideSliver'),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => GoRouter.of(context).pushNamed('slides'),
              ),
              const Divider(height: 1, color: Colors.white24),
              ListTile(
                title: const Text('SlideCarouselView'),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => GoRouter.of(context).pushNamed('carousel'),
              ),
              const Divider(height: 1, color: Colors.white24),
              ListTile(
                title: const Text('VideoSliverGrid'),
                trailing: const Icon(Icons.keyboard_arrow_right),
                onTap: () => GoRouter.of(context).pushNamed('videos'),
              ),
              const Divider(height: 1, color: Colors.white24),
              const TitleText(
                title: 'TitleText',
                padding: EdgeInsets.all(32),
              ),
              ListTile(
                title: const Text('Cookie Consent'),
                trailing: FutureBuilder(
                  future: CookieConsentViewModel.instance.enabled,
                  builder: (context, snapshot) => Badge(
                    label: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        snapshot.data == null
                            ? 'Unclicked'
                            : snapshot.data!
                            ? 'Enabled'
                            : 'Disabled',
                      ),
                    ),
                    backgroundColor: snapshot.data == null
                        ? Colors.white10
                        : snapshot.data!
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),
              const Divider(height: 1, color: Colors.white24),
            ],
          ),
          CookieConsentBanner(
            callback: ({required enabled}) => setState(() {}),
          ),
        ],
      ),
    ),
  );
}
