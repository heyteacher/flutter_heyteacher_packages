/// A collection of reusable Flutter widgets and utility functions, 
/// likely intended to streamline UI development within the Flutter application.
/// 
/// * [FutureStreamBuilder] builder: cleverly combines a [FutureBuilder] with 
///   a [StreamBuilder].
///
/// * [showSnackBar] function: displays a SnackBar 
///
/// * [showConfirmCancelDialog] function: displays a 
///    standard `AlertDialog` to ask the user for confirmation or cancellation 
///    of an action.
///
/// * [ProgressIndicatorView] widget: displays a [CircularProgressIndicator] 
///    centered on the screen.
///
/// * [ErrorView] widget: displays different error states to the user.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// A [StreamBuilder] initialized with a [FutureBuilder].
/// 
/// It first waits for the [future] (an asynchronous operation that completes 
/// once) to provide an initial piece of data. Once that future completes 
/// successfully and has data, it then uses that data as the initialData for an 
/// inner [StreamBuilder]. This StreamBuilder then listens to the provided 
/// [stream] for ongoing updates.
/// 
/// Useful when you need to fetch an initial state (e.g., from a database or 
/// API) and then subscribe to real-time updates for that same data.
class FutureStreamBuilder<T> extends FutureBuilder<T> {

  ///  the [stream] parameter of [StreamBuilder]
  final Stream<T> stream;

  const FutureStreamBuilder(
      {super.key,
      required super.future,
      required this.stream,
      required super.builder});

  @override
  AsyncWidgetBuilder<T> get builder =>
      (context, futureSnapshot) => futureSnapshot.hasData
          ? StreamBuilder(
              stream: stream,
              initialData: futureSnapshot.data,
              builder: super.builder)
          : super.builder(context, futureSnapshot);
}

/// Easily display a [SnackBar] (a brief message shown at the bottom of the 
/// screen).
/// 
/// It takes the [BuildContext], the [message] to display, an optional 
/// [duration] (in seconds), and a boolean [error] flag to show message in 
/// red as an error (othersise in green for succes message)
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

/// Displays a standard [AlertDialog] to ask the user for confirmation or 
/// cancellation of an action.
/// 
/// It takes the [BuildContext], a [confirmCallback] (executed if the user 
/// confirms) and [cancelCallback] (executed if the user cancels), a [param] 
/// of type [ObjectParamType] passed to callbacks, the [title] and the [content]
/// of dialog. 
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
                // https://stackoverflow.com/questions/55618717/error-thrown-on-navigator-pop-until-debuglocked-is-not-true
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
                  // https://stackoverflow.com/questions/55618717/error-thrown-on-navigator-pop-until-debuglocked-is-not-true
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

/// Displays a CircularProgressIndicator centered on the screen.
/// 
/// Typically used to indicate that some background processing or data loading 
/// is happening.
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

/// Displays different error states to the user.
///
///  It takes [error] and [stackTrace] raised by [Exception].
/// 
/// If the exception is a [FirebaseException] with [FirebaseException.code] 
/// `permission-denied` it shows a login button to navigate on auth screen.
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
