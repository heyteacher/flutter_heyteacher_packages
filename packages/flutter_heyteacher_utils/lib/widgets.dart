import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

void showSnackBarError({required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          duration: Duration(
              seconds: FirebaseRemoteConfig.instance
                  .getInt("snackBarDurationInSeconds")),
          backgroundColor: Theme.of(context).colorScheme.onError,
          content: Text(message)),
    );
}


Future<void> dialogBuilder(
    BuildContext context, String title, String content, Function confirmFn,
    [dynamic confirmFnObj]) async {
  final log = Logger("dialogBuilder");
  final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            IconButton(
              key: ValueKey("ib_dialog_no"),
              icon: Icon(Icons.close,
                  color: Theme.of(context).colorScheme.onError),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            IconButton(
              key: ValueKey("ib_dialog_yes"),
              icon: Icon(Icons.check),
              onPressed: () async {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      });
  if (confirm != null && confirm) {
    String message = "";
    bool error = false;
    try {
      message = await confirmFn(confirmFnObj);
    } catch (e, s) {
      error = true;
      message = e.toString();
      log.severe("${confirmFn.toString()}: error", e, s);
      rethrow;
    } finally {
      if (context.mounted && error) {
        showSnackBarError(context: context, message: message);
      }
    }
  }
}

class ProgressIndicatorWidget extends StatelessWidget {
  const ProgressIndicatorWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                  child: Container(
                      alignment: Alignment.center,
                      child: CircularProgressIndicator())),
            ],
          ),
        ),
      ],
    );
  }
}
