import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

void showSnackBar(
        {required BuildContext? context,
        required String message,
        int? duration,
        bool error = false}) =>
    context != null
        ? ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                duration: Duration(
                    seconds: duration ??
                        FirebaseRemoteConfig.instance
                            .getInt("snackBarDurationInSeconds")),
                backgroundColor: error
                    ? ThemeModel.instance().theme.colorScheme.onError
                    : ThemeModel.instance().greenColor,
                content: Text(message,
                    style: TextStyle(
                        color: error
                            ? ThemeModel.instance().theme.colorScheme.error
                            : ThemeModel.instance()
                                .theme
                                .colorScheme
                                .onPrimary))),
          )
        : null;

Future<void> showConfirmCancelDialog<ObjectParamType>(
    {required BuildContext context,
    Future<String?> Function(ObjectParamType?)? confirmCallback,
    Future<String?> Function(ObjectParamType?)? cancelCallback,
    ObjectParamType? param,
    String? title,
    required String content}) async {
  final log = Logger("showConfirmCancelDialog");

  final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: title != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(textAlign: TextAlign.center, title),
                )
              : null,
          content: Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Text(textAlign: TextAlign.center, content)),
          actions: <Widget>[
            IconButton(
              key: ValueKey("ib_dialog_no"),
              icon: Icon(Icons.close,
                  color: Theme.of(context).colorScheme.onError),
              onPressed: () {
                // // https://stackoverflow.com/questions/55618717/error-thrown-on-navigator-pop-until-debuglocked-is-not-true
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pop(false);
                });
              },
            ),
            if (confirmCallback != null)
              IconButton(
                key: ValueKey("ib_dialog_yes"),
                icon: Icon(Icons.check),
                onPressed: () async {
                  // // https://stackoverflow.com/questions/55618717/error-thrown-on-navigator-pop-until-debuglocked-is-not-true
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pop(true);
                  });
                },
              ),
          ],
        );
      });
  if (confirmCallback != null && confirm != null && confirm) {
    String? message;
    bool error = false;
    try {
      message = await confirmCallback(param);
    } catch (e, s) {
      error = true;
      message = e.toString();
      log.severe("${confirmCallback.toString()}: error", e, s);
      rethrow;
    } finally {
      if (context.mounted && message != null) {
        showSnackBar(context: context, message: message, error: error);
      }
    }
  } else {
    if (cancelCallback != null) cancelCallback(param);
  }
}

class ProgressIndicatorView extends StatelessWidget {
  const ProgressIndicatorView({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator()]),
      );
}

class ErrorView extends StatelessWidget {
  static final _log = Logger("ErrorView");

  final Object? error;
  final StackTrace? stackTrace;

  ErrorView(this.error, this.stackTrace, {super.key}) {
    _log.severe("error", error, stackTrace);
  }

  @override
  Widget build(context) => Scaffold(
        appBar: AppBar(),
        body: error == null ||
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
                        style: _errorStyleContent(context)),
                  ),
                ),
                Expanded(
                  child: Align(
                      alignment: Alignment.topCenter,
                      child: IconButton(
                          key: ValueKey("ic_login"),
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
                      alignment: Alignment.center,
                      child: Text(error.toString(),
                          textAlign: TextAlign.center,
                          style: _errorStyleContent(context)),
                    ),
                  ),
                ],
              ),
      );

  TextStyle _errorStyleContent(context) => Theme.of(context)
      .textTheme
      .headlineMedium!
      .copyWith(color: Theme.of(context).colorScheme.onError);
}

