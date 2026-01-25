import 'dart:async' show StreamController, unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_site/src/misc.dart';
import 'package:flutter_heyteacher_site/src/video/video_data.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
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
  @override
  /// Builds the sliver grid of videos.
  ///
  /// It uses a [SliverGrid] with a [SliverGridDelegateWithMaxCrossAxisExtent]
  /// to create a responsive grid. Each video is
  /// rendered as a [_VideoCard].
  Widget build(BuildContext context) => SliverGrid(
    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: MediaQuery.sizeOf(context).height / 2.2,
    ),
    delegate: SliverChildListDelegate(
      widget._videos
          .map(
            (videoData) => _VideoCard(
              videoData: videoData,
            ),
          )
          .toList(),
    ),
  );
}

/// Stateful widget to fetch and then display video content.
class _VideoCard extends StatelessWidget {
  const _VideoCard({
    required VideoData videoData,
  }) : _videolData = videoData;

  final VideoData _videolData;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: TitleText(title: _videolData.title),
          ),
          Center(
            child: IconButton(
              color: ThemeViewModel.instance.purpleColor,
              icon: Icon(
                Icons.play_circle_outline,
                size: Theme.of(context).textTheme.displayLarge!.fontSize,
              ),
              onPressed: () => _show(context),
            ),
          ),
          Center(
            child: TitleText(
              title: _videolData.subTitle,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    ),
  );

  void _show(BuildContext context) {
    unawaited(
      showConfirmCancelDialog<void>(
        context: context,
        title: Text(
          _videolData.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        content: _VideoPlay(
          videoData: _videolData,
        ),
      ),
    );
  }
}

/// Stateful widget to fetch and then display video content.
class _VideoPlay extends StatefulWidget {
  const _VideoPlay({
    required VideoData videoData,
  }) : _videolData = videoData;

  final VideoData _videolData;

  @override
  State<_VideoPlay> createState() => _VideoPlayState();
}

class _VideoPlayState extends State<_VideoPlay> {
  late VideoPlayerController _videoPlayerController;
  bool _showControl = false;

  @override
  void dispose() {
    unawaited(_videoPlayerController.dispose());
    //debugPrint('dispose ${widget._videolData.url}');
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //debugPrint('initState ${widget._videolData.url}');
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(
        widget._videolData.url,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  Future<void> _init(_) async {
    await _videoPlayerController.initialize();
    await _videoPlayerController.play();
    setState(() {});
    _videoPlayerController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
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
              ? ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height * 2 / 3,
                  ),
                  child: VideoPlayer(_videoPlayerController),
                )
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
                size: Theme.of(context).textTheme.displayLarge!.fontSize,
              ),
              onPressed: () => setState(
                () => _videoPlayerController.value.isPlaying
                    ? unawaited(_videoPlayerController.pause())
                    : unawaited(_videoPlayerController.play()),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
