import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:go_router/go_router.dart';

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
                    ? ThemeHepler.instance().theme.colorScheme.onError
                    : ThemeHepler.instance().greenTextColor,
                content: Text(message,
                    style: TextStyle(
                        color: error
                            ? ThemeHepler.instance().theme.colorScheme.error
                            : ThemeHepler.instance()
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
    String? content}) async {
  final log = Logger("dialogBuilder");

  title = title ?? FlutterHeyteacherUtilsLocalizations.of(context)!.confirm;
  content = content ??
      FlutterHeyteacherUtilsLocalizations.of(context)!
          .areYouSureToConfirmTheAction;
  final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title!),
          content: Text(content!),
          actions: <Widget>[
            IconButton(
              key: ValueKey("ib_dialog_no"),
              icon: Icon(Icons.close,
                  color: Theme.of(context).colorScheme.onError),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            if (confirmCallback != null)
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
                      child:
                          Text(error.toString(), style: _errorStyle(context)),
                    ),
                  ),
                ],
              ),
      );

  TextStyle _errorStyle(context) => Theme.of(context)
      .textTheme
      .headlineMedium!
      .copyWith(color: Theme.of(context).colorScheme.onError);
}
