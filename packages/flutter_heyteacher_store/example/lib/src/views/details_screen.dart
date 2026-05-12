import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart';
import 'package:flutter_heyteacher_e2ee/flutter_heyteacher_e2ee.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart'
    show FormatterHelper;
import 'package:flutter_heyteacher_store_example/src/store/track_store.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ProgressIndicatorWidget;

/// The home screen
class DetailsScreen extends StatelessWidget {
  /// Creates the [DetailsScreen].
  const DetailsScreen({required this.id, super.key});

  /// The id of the track
  final String id;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Details: $id'),
      actions: [
        IconButton(
          onPressed: () {
            unawaited(TrackStore.instance.delete(id));
            Navigator.pop(context);
          },
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ],
    ),

    body: FutureBuilder(
      future: TrackStore.instance.get(id),
      builder: (context, getAsyncSnapshot) => getAsyncSnapshot.hasData
          ? Column(
              children: [
                ListTile(
                  title: const Text('start time'),
                  subtitle: Text(
                    FormatterHelper.timeWithSecondsFormat(
                      getAsyncSnapshot.data!.startTime,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('distance'),
                  subtitle: Text(
                    FormatterHelper.intFormat(
                      getAsyncSnapshot.data!.distanceInMeters,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('stop time'),
                  subtitle: Text(
                    FormatterHelper.timeWithSecondsFormat(
                      getAsyncSnapshot.data!.stopTime,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('duration'),
                  subtitle: Text(
                    FormatterHelper.formatDuration(
                      getAsyncSnapshot.data!.durationInMilliseconds,
                      showSeconds: true,
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('avg rpm'),
                  subtitle: Text(
                    FormatterHelper.intFormat(
                      getAsyncSnapshot.data!.avgRpm,
                    ),
                  ),
                ),
                const Divider(height: 1),
                FutureBuilder(
                  future: E2EEViewModel.instance(
                    AuthViewModel.instance.uid,
                  ).decrypt(getAsyncSnapshot.data!.avgBpm!),
                  builder: (context, decryptAsyncSnapshot) => ListTile(
                    title: const Text('avg bpm'),
                    subtitle: Text(
                      decryptAsyncSnapshot.data ?? '',
                    ),
                  ),
                ),

                const Divider(height: 1),
              ],
            )
          : const ProgressIndicatorWidget(),
    ),
  );
}
