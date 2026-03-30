import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/flutter_heyteacher_site.dart'
    show VideoData, VideoSliverGrid;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeModeButton;

/// The home screen
class VideosScreen extends StatelessWidget {
  /// Creates the [VideosScreen].
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('VideoSliverGrid'),
      actions: const [
        ThemeModeButton(),
      ],
    ),
    body: const CustomScrollView(
      slivers: [
        VideoSliverGrid(
          videos: [
            VideoData(
              title: 'Video Title',
              subTitle: 'Video Subtitle',
              url:
                  'https://d13vk0shg231tb.cloudfront.net/videos/authentication_configure_encryption_passphrase.mp4',
            ),
            VideoData(
              title: 'Video Title',
              subTitle: 'Video Subtitle',
              url:
                  'https://d13vk0shg231tb.cloudfront.net/videos/live_outdoor_track.mp4',
            ),
            VideoData(
              title: 'Video Title',
              subTitle: 'Video Subtitle',
              url:
                  'https://d13vk0shg231tb.cloudfront.net/videos/live_indoor_track.mp4',
            ),
            VideoData(
              title: 'Video Title',
              subTitle: 'Video Subtitle',
              url:
                  'https://d13vk0shg231tb.cloudfront.net/videos/track_details.mp4',
            ),
          ],
        ),
      ],
    ),
  );
}
