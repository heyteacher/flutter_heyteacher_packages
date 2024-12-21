import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

void showSnackBar(
    {required BuildContext context, required String message, bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        duration: Duration(
            seconds: FirebaseRemoteConfig.instance
                .getInt("snackBarDurationInSeconds")),
        backgroundColor: error? Theme.of(context).colorScheme.onError: Theme.of(context).colorScheme.onPrimary,
        content: Text(message)),
  );
}

Future<void> dialogBuilder<T>(
    {required BuildContext context,
    required Future<String> Function(T?) confirmFn,
    T? confirmFnObj,
    String title = "Attention",
    String confirmQuestion = "Confirm action?"}) async {
  final log = Logger("dialogBuilder");

  final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(confirmQuestion),
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
      if (context.mounted) {
        showSnackBar(context: context, message: message, error: error);
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
