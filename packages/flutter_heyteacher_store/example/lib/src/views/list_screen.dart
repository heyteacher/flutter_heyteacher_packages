import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart'
    show FormatterHelper;
import 'package:flutter_heyteacher_store_example/src/data/base_track_data.dart';
import 'package:flutter_heyteacher_store_example/src/store/track_store.dart'
    show TrackStore;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeModeButton;
import 'package:go_router/go_router.dart';

/// The list screen
class ListScreen extends StatefulWidget {
  /// Creates the [ListScreen].
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  int? _count;
  double? _sumDistanceInMeters;
  double? _avgDistanceInMeters;

  StreamSubscription<void>? _aggregatesSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_init);
  }

  void _init(_) {
    unawaited(_aggregatesSubscription?.cancel());
    _aggregatesSubscription = TrackStore.instance.updateStream.listen((
      _,
    ) async {
      final aggregatesAsyncSnapshot = await TrackStore.instance.aggregates;
      setState(() {
        _count = aggregatesAsyncSnapshot?.count;
        _sumDistanceInMeters = aggregatesAsyncSnapshot?.getSum(
          'distanceInMeters',
        );
        _avgDistanceInMeters = aggregatesAsyncSnapshot?.getAverage(
          'distanceInMeters',
        );
      });
    });
  }

  @override
  void dispose() {
    unawaited(_aggregatesSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Store'),
      actions: const [ThemeModeButton()],
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
      child: Column(
        children: [
          StreamBuilder(
            stream: TrackStore.instance.updateStream,
            builder: (_, _) => Text(
              'count $_count, '
              'total distance '
              '${FormatterHelper.intFormat(_sumDistanceInMeters)} meters, '
              'avg distance '
              '${FormatterHelper.intFormat(_avgDistanceInMeters)} meters',
            ),
          ),
          const Divider(height: 1),
          StreamBuilder(
            stream: TrackStore.instance.stream(),
            builder: (context, asyncSnapshot) => Column(
              spacing: 8,
              children: asyncSnapshot.hasData
                  ? asyncSnapshot.data!
                        .map<Widget>(
                          (trackData) => Column(
                            children: [
                              ListTile(
                                title: Text(trackData.id),
                                subtitle: _buildSubtitle(trackData),
                                onTap: () => GoRouter.of(context).pushNamed(
                                  'details',
                                  pathParameters: {'id': trackData.id},
                                ),
                                trailing: const Icon(
                                  Icons.keyboard_arrow_right,
                                ),
                              ),
                              const Divider(height: 1),
                            ],
                          ),
                        )
                        .toList()
                  : <Widget>[],
            ),
          ),
        ],
      ),
    ),
  );

  Text _buildSubtitle(BaseTrackData trackData) => Text(
    'start time '
    '${FormatterHelper.timeWithSecondsFormat(trackData.startTime)}\n'
    'stop time '
    '${FormatterHelper.timeWithSecondsFormat(trackData.stopTime)}\n'
    'distance '
    '${FormatterHelper.intFormat(trackData.distanceInMeters)} meters \n'
    'duration '
    //
    // ignore: lines_longer_than_80_chars
    '${FormatterHelper.formatDuration(trackData.durationInMilliseconds, showSeconds: true)}',
  );
}
