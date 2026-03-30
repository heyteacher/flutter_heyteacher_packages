import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart'
    show FormatterHelper;
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
  @override
  void initState() {
    super.initState();
    unawaited(TrackStore.instance.notifyAggregatesChanges());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Flutter Heyteacher Store'),
      actions: const [
        ThemeModeButton(),
      ],
    ),
    body: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          StreamBuilder(
            stream: TrackStore.instance.aggregateStream,
            builder: (context, aggregatesAsyncSnapshot) => Text(
              'count ${aggregatesAsyncSnapshot.data?.count}, '
              'total distance ${FormatterHelper.intFormat(
                aggregatesAsyncSnapshot.data?.getSum(
                  'distanceInMeters',
                ),
              )} meters ',

              // TODO(heyteacher): fix average aggregate
              // 'avg distance ${aggregatesAsyncSnapshot.data?.getAverage(
              //   'distanceInMeters',
              // )} ',
            ),
          ),
          const Divider(),
          StreamBuilder(
            stream: TrackStore.instance.stream(),
            builder: (context, asyncSnapshot) => Column(
              spacing: 8,
              children: asyncSnapshot.hasData
                  ? asyncSnapshot.data!
                        .map<Widget>(
                          (trackData) => Card(
                            child: ListTile(
                              title: Text(trackData.id),
                              subtitle: Text(
                                'start time '
                                '${FormatterHelper.timeWithSecondsFormat(
                                  trackData.startTime,
                                )}\n'
                                'stop time '
                                '${FormatterHelper.timeWithSecondsFormat(
                                  trackData.stopTime,
                                )}\n'
                                'distance  ${FormatterHelper.intFormat(
                                  trackData.distanceInMeters,
                                )} meters \n'
                                'duration  ${FormatterHelper.formatDuration(
                                  trackData.durationInMilliseconds,
                                  showSeconds: true
                                )}',
                              ),
                              onTap: () => GoRouter.of(context).pushNamed(
                                'details',
                                pathParameters: {'id': trackData.id},
                              ),
                              trailing: const Icon(Icons.keyboard_arrow_right),
                            ),
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
}
