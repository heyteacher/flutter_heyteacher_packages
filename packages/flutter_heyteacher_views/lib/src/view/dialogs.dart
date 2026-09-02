import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_heyteacher_views/src/theme/theme_view_model.dart';
import 'package:flutter_heyteacher_views/src/view/progress_indicator.dart';
import 'package:logging/logging.dart';

/// Display a [SnackBar] (a brief message shown at the bottom of the
/// screen).
///
/// if [persist] is `false`, display [message] for
/// [duration] (default: 5 seconds) otherwise ignore timeout and show the close
/// button.
///
/// If [action] is provided, a button is show in trailing with `onPressed`
/// callback.
///
/// If [error] show error background and foreground color
void showSnackBar({
  required BuildContext? context,
  required String message,
  Widget? leading,
  Color? backgroundColor,
  Color? foregroundColor,
  Duration duration = const Duration(seconds: 5),
  bool persist = false,
  bool showClose = false,
  String? actionLabel,
  SnackBarAction? action,
  bool error = false,
}) => context != null && context.mounted
    ? ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          showCloseIcon: showClose,
          closeIconColor:
              foregroundColor ??
              (error
                  ? ThemeViewModel.instance.colorScheme.error
                  : ThemeViewModel.instance.colorScheme.onPrimary),
          persist: persist,
          action: action,
          duration: duration,
          backgroundColor:
              backgroundColor ??
              (error
                  ? ThemeViewModel.instance.colorScheme.onError
                  : ThemeViewModel.instance.greenColor),
          content: Row(
            spacing: 8,
            children: [
              ?leading,
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color:
                        foregroundColor ??
                        (error
                            ? ThemeViewModel.instance.colorScheme.error
                            : ThemeViewModel.instance.colorScheme.onPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      )
    : null;

/// Displays a standard [AlertDialog] to ask the user for confirmation or
/// cancellation of an action.
///
/// It takes the [context], a [confirmCallback] (executed if the user
/// confirms) and [cancelCallback] (executed if the user cancels), a [param]
/// of type [ObjectParamType] passed to callbacks, the [title] and the [content]
/// of dialog.
///
/// If [timeout] is provided, show a [ProgressIndicatorWidget] and close the
/// dialog when [timeout] reached.
///
/// If [timeoutCallback] is provided, call them when [timeout] reached.
Future<bool> showConfirmCancelDialog<ObjectParamType>({
  required BuildContext context,
  required Widget content,
  Widget? title,
  ObjectParamType? param,
  Future<String?> Function(ObjectParamType?)? confirmCallback,
  Future<String?> Function(ObjectParamType?)? cancelCallback,
  VoidCallback? timeoutCallback,
  Duration? timeout,
  Color? backgroundColor,
}) async {
  assert(
    (timeoutCallback == null || timeout != null),
    'if timeoutCallback provided, also timeout must be provided',
  );
  final logger = Logger('showConfirmCancelDialog')
    ..finer('<showConfirmCancelDialog>:');
  BuildContext? dialogContext;
  final confirm = await showDialog<bool>(
    context: context,
    builder: (context) {
      dialogContext = context;
      return AlertDialog(
        backgroundColor: backgroundColor,
        title: title != null
            ? Padding(padding: const EdgeInsets.only(top: 8), child: title)
            : null,
        content: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: content,
        ),
        actions: <Widget>[
          if (timeout != null)
            ProgressIndicatorWidget(
              timeout: timeout,
              showCountdown: true,
              constraints: const BoxConstraints(
                maxHeight: 15,
                maxWidth: 15,
                minHeight: 15,
                minWidth: 15,
              ),
              onTimeout: () => dialogContext != null
                  ? SchedulerBinding.instance.addPostFrameCallback((_) {
                      Navigator.of(dialogContext!).pop(false);
                      timeoutCallback?.call();
                    })
                  : null,
            ),

          IconButton(
            key: const ValueKey('ib_dialog_no'),
            icon: Icon(Icons.close, color: ThemeViewModel.instance.redColor),
            onPressed: () =>
                // https://stackoverflow.com/questions/55618717/error-thrown-on-navigator-pop-until-debuglocked-is-not-true
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(dialogContext!).pop(false);
                  dialogContext = null;
                }),
          ),
          if (confirmCallback != null)
            IconButton(
              key: const ValueKey('ib_dialog_yes'),
              icon: const Icon(Icons.check),
              onPressed:
                  () => // https://stackoverflow.com/questions/55618717/error-thrown-on-navigator-pop-until-debuglocked-is-not-true
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(dialogContext!).pop(true);
                    dialogContext = null;
                  }),
            ),
        ],
      );
    },
  );
  if (confirm != null) {
    if (confirm) {
      logger.finer('(showConfirmCancelDialog): Confirm');
      String? message;
      var errorRaised = false;
      try {
        message = await confirmCallback?.call(param);
      } catch (error, stackTrace) {
        errorRaised = true;
        message = error.toString();
        logger.severe(
          '(showConfirmCancelDialog): error',
          error,
          stackTrace,
        );
        rethrow;
      } finally {
        if (context.mounted && message != null) {
          showSnackBar(
            context: context,
            message: message,
            error: errorRaised,
          );
        }
      }
    } else {
      logger.finer('(showConfirmCancelDialog): cancel');
      unawaited(cancelCallback?.call(param));
    }
  }
  return confirm ?? false;
}
