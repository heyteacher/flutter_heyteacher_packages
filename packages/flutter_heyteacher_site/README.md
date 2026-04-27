# flutter_heyteacher_site

A Flutter package providing a set of standardized UI components and utilities for building websites and landing pages within the HeyTeacher ecosystem.

## Features

- **Cookie Consent Management**: Ready-to-use `CookieConsentBanner` and `CookieConsentViewModel` for handling GDPR and privacy requirements.
- **Markdown Support**: Easy rendering of markdown content via `MarkdownView`.
- **Rich Media Components**:
  - **Slides**: `SlideCarouselView` and `SlideSliver` for responsive image or content sliders.
  - **Videos**: `VideoSliverGrid` for displaying collections of video content.
- **UI Building Blocks**:
  - Consistent typography with `TitleText` and `TitleTextSliver`.
  - Store promotion with `GetItOnGooglePlayButton`.
  - Themed iconography with `LeadingIcon`.
- **Localization**: Integrated localization support through `FlutterHeyteacherSiteLocalizations`.

The components in this packages are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.org/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Credits

- [flutter_cookie_consent](https://pub.dev/packages/flutter_cookie_consent): A Flutter plugin for displaying cookie consent banners and managing cookie preferences in your Flutter applications.
  
- [markdown_widget](https://pub.dev/packages/markdown_widget):  simple and easy-to-use markdown rendering component.

- [scroll_to_index](http://pub.dev/packages/scroll_to_index): This package provides the scroll to index mechanism for fixed/variable row height for Flutter scrollable widget.

- [updown_arrow_scroller](https://pub.dev/packages/updown_arrow_scroller): A Flutter web package that enables keyboard up-down arrow navigation for scrolling through pages.

- [video_player](https://pub.dev/packages/video_player): A Flutter plugin for iOS, Android and Web for playing back video on a Widget surface.

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_site:
```

## Usage

Below is a basic example of how to integrate various components into a site landing page using a `CustomScrollView`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/flutter_heyteacher_site.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const TitleTextSliver(title: 'HeyTeacher Platform'),
              SlideSliver(
                slides: [
                  SlideData(imageUrl: 'https://example.com/slide1.jpg', title: 'Connect with Teachers'),
                  SlideData(imageUrl: 'https://example.com/slide2.jpg', title: 'Manage your Classes'),
                ],
              ),
              const VideoSliverGrid(
                videos: [
                  VideoData(url: 'https://youtube.com/...', title: 'Platform Overview'),
                ],
              ),
              const SliverToBoxAdapter(
                child: GetItOnGooglePlayButton(
                  url: 'https://play.google.com/store/apps/details?id=com.heyteacher.app',
                ),
              ),
            ],
          ),
          // Floating Cookie Banner
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CookieConsentBanner(),
          ),
        ],
      ),
    );
  }
}
```

## Example

A complete example where all functionalities are showed in action can be found [Example App](./example/).
