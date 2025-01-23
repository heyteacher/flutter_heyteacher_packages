import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:go_router/go_router.dart';

void showSnackBar(
    {required BuildContext context,
    required String message,
    bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        duration: Duration(
            seconds: FirebaseRemoteConfig.instance
                .getInt("snackBarDurationInSeconds")),
        backgroundColor: error
            ? Theme.of(context).colorScheme.error
            : ThemeHepler.instance().greenTextColor,
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

class ErrorView extends StatelessWidget {
  final Object? error;
  final StackTrace? stackTrace;

  const ErrorView(this.error, this.stackTrace, {super.key});

  @override
  Widget build(context) => error == null ||
          (error is FirebaseException &&
              (error as FirebaseException).code == "permission-denied")
      ? Column(children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                  textAlign: TextAlign.center,
                  FlutterHeyteacherUtilsLocalizations.of(context)!
                      .userNotAutenticated,
                  style: _errorStyle(context)),
            ),
          ),
          Expanded(
            child: Align(
                alignment: Alignment.topCenter,
                child: IconButton(
                    key: ValueKey("ic_login_logout"),
                    icon: Icon(Icons.login,
                        size: Theme.of(context)
                            .textTheme
                            .displayMedium!
                            .fontSize),
                    color: Theme.of(context).iconTheme.color,
                    onPressed: () async {
                      GoRouter.of(context).pushNamed("auth-sign-in");
                    })),
          ),
        ])
      : Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                    FlutterHeyteacherUtilsLocalizations.of(context)!
                        .errorOnRetrieveData,
                    style: _errorStyle(context)),
              ),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(error.toString(), style: _errorStyle(context)),
              ),
            ),
          ],
        );

  TextStyle _errorStyle(context) => Theme.of(context)
      .textTheme
      .headlineLarge!
      .copyWith(color: Theme.of(context).colorScheme.onError);
}

class NotAuthenticatedView extends StatelessWidget {
  const NotAuthenticatedView({super.key});

  @override
  Column build(BuildContext context) => Column(
        children: [
          Expanded(
              child: Center(
                  child: Text(
                      key: ValueKey("text_notAuth"),
                      FlutterHeyteacherUtilsLocalizations.of(context)!
                          .userNotAutenticated))),
        ],
      );
}
