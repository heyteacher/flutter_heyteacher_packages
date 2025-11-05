import 'dart:async' show StreamController, StreamSubscription, unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/src/video/video_data.dart';
import 'package:flutter_heyteacher_utils/animations.dart' show BlinkingText;
import 'package:flutter_heyteacher_utils/theme.dart' show ThemeViewModel;
import 'package:video_player/video_player.dart';

/// A sliver grid that displays videos.
///
/// This widget arranges videos in a grid layout that can be
/// placed within a [CustomScrollView]. It manages the playback of videos
/// to ensure that only one video plays at a time across all
/// [_VideoCard] instances.
class VideoSliverGrid extends StatefulWidget {
  /// Creates a sliver grid for displaying videos.
  const VideoSliverGrid({required List<VideoData> videos, super.key})
    : _videos = videos;

  final List<VideoData> _videos;

  @override
  /// Creates the mutable state for this widget.
  State<VideoSliverGrid> createState() => _VideoSliverGridState();
}

/// The state for [VideoSliverGrid].
///
/// This class manages the [StreamController] that coordinates video playback
/// among the [_VideoCard] children.
class _VideoSliverGridState extends State<VideoSliverGrid> {
  /// A stream controller to notify video cards when a video starts playing.
  ///
  /// When a video is played, its URL is added to this stream. All other
  /// video cards listening to the stream will pause their playback, ensuring
  /// that only one video plays at a time.
  late StreamController<String> _videoPlayedStreamController;

  @override
  /// Initializes the state of the widget.
  ///
  /// This method sets up the broadcast [StreamController] for video playback
  /// coordination.
  void initState() {
    super.initState();
    _videoPlayedStreamController = StreamController<String>.broadcast();
  }

  @override
  /// Builds the sliver grid of videos.
  ///
  /// It uses a [SliverGrid] with a [SliverGridDelegateWithMaxCrossAxisExtent]
  /// to create a responsive grid. Each video is
  /// rendered as a [_VideoCard].
  Widget build(BuildContext context) => SliverGrid(
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 300,
      childAspectRatio: 1 / 2,
    ),
    delegate: SliverChildListDelegate(
      widget._videos
          .map(
            (videoData) => _VideoCard(
              videoData: videoData,
              videoPlayedStreamController: _videoPlayedStreamController,
            ),
          )
          .toList(),
    ),
  );

  @override
  /// Disposes the resources used by this state.
  ///
  /// This method closes the [_videoPlayedStreamController] to prevent memory
  /// leaks.
  void dispose() {
    unawaited(_videoPlayedStreamController.close());
    super.dispose();
  }
}

/// Stateful widget to fetch and then display video content.
class _VideoCard extends StatefulWidget {
  const _VideoCard({
    required VideoData videoData,
    required StreamController<String> videoPlayedStreamController,
  }) : _videolData = videoData,
       _videoPlayedStreamController = videoPlayedStreamController;

  final VideoData _videolData;

  final StreamController<String> _videoPlayedStreamController;

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  late VideoPlayerController _videoPlayerController;
  StreamSubscription<String>? _videoStreamSubscription;
  bool _showControl = false;

  @override
  void dispose() {
    unawaited(_videoPlayerController.dispose());
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    debugPrint('load ${widget._videolData.url}');
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        widget._videolData.url,
      ),
    );
    unawaited(_init());
  }

  Future<void> _init() async {
    await _videoPlayerController.initialize();
    setState(() {});
    _videoPlayerController.addListener(() => setState(() {}));
    await _videoStreamSubscription?.cancel();
    _videoStreamSubscription = widget._videoPlayedStreamController.stream
        .listen(
          // stops (paused and seeked to start) all videos except current video
          // played
          (url) =>
              url != widget._videolData.url ? _pause(seekToStart: true) : null,
        );
  }

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.hardEdge,
    child: MouseRegion(
      // on mouse enter, show the control to play and pause
      onEnter: (event) => setState(() => _showControl = true),
      // on mouse exit, hide the control to play and pause
      onExit: (event) => setState(() => _showControl = false),
      child: Stack(
        alignment: AlignmentDirectional.bottomStart,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: _videoPlayerController.value.isInitialized
                ? VideoPlayer(_videoPlayerController)
                : const SizedBox.shrink(),
          ),
          Center(
            child: Visibility(
              visible: !_videoPlayerController.value.isPlaying || _showControl,
              child: IconButton(
                icon: Icon(
                  _videoPlayerController.value.isPlaying
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                  size: Theme.of(context).textTheme.displayMedium!.fontSize,
                ),
                onPressed: () => setState(
                  () => _videoPlayerController.value.isPlaying
                      ? _pause()
                      : _play(),
                ),
              ),
            ),
          ),
          ColoredBox(
            color: ThemeViewModel.instance.colorScheme.surface.withValues(
              alpha: 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Center(
                    child: BlinkingText(
                      animated: _videoPlayerController.value.isPlaying,
                      textAlign: TextAlign.center,
                      widget._videolData.title,
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  void _play() {
    unawaited(_videoPlayerController.play());
    // notify to all other videos that this video i played
    // other video are listening this controll and will be stopped
    widget._videoPlayedStreamController.sink.add(widget._videolData.url);
  }

  void _pause({bool seekToStart = false}) {
    unawaited(_videoPlayerController.pause());
    if (seekToStart) {
      // seek to start (duration to 0)
      unawaited(_videoPlayerController.seekTo(Duration.zero));
    }
  }
}
