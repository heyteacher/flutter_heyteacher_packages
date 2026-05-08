import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_connectivity/src/connectivity_view_model.dart';
import 'package:flutter_heyteacher_connectivity/src/l10n/flutter_heyteacher_connectivity.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show FutureStreamBuilder, ThemeViewModel;

/// The list tile which show connectivity status.
class ConnectivityListTile extends StatelessWidget {
  /// Creates a [ConnectivityListTile].
  const ConnectivityListTile({super.key});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const Icon(
      Icons.wifi,
    ),
    title: Text(
      FlutterHeyteacherConnectivityLocalizations.of(
        context,
      )!.connectivityStatus,
    ),
    trailing: FutureStreamBuilder(
      future: ConnectivityViewModel.instance.connected,
      stream: ConnectivityViewModel.instance.stream,
      builder: (context, snapshot) => switch (snapshot.data) {
        true => Badge(
          label: Text(
            FlutterHeyteacherConnectivityLocalizations.of(
              context,
            )!.online,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(color: Colors.white),
          ),
          backgroundColor: ThemeViewModel.instance.greenColor,
        ),
        false => Badge(
          label: Text(
            FlutterHeyteacherConnectivityLocalizations.of(
              context,
            )!.offline,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(color: Colors.white),
          ),
          backgroundColor: ThemeViewModel.instance.redColor,
        ),
        null => const CircularProgressIndicator(),
      },
    ),
  );
}
