import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException;
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart'
    show AuthRouterName, FlutterHeyteacherAuthLocalizations;
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart'
    show FlutterHeyteacherLocaleLocalizations;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show ThemeViewModel;
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// A widget that displays a user-friendly screen for different error states.
///
/// It handles specific [FirebaseException] codes to provide contextual
/// feedback and actions:
/// - `permission-denied`: Shows a "user not authenticated" message and a login
///   button to navigate to the sign-in screen.
/// - `unavailable`: Informs the user they are offline and should retry when
///   a connection is available.
///
/// For all other errors, it displays the error's string representation.
/// The error and stack trace are also logged using `Logger`.
class ErrorView extends StatelessWidget {
  /// Creates an [ErrorView] to display information about an [_error].
  ///
  /// The [_stackTrace] is also logged for debugging purposes.
  ErrorView(
    this._error,
    this._stackTrace, {
    this._title = '',
    this._actions = const <Widget>[],
    super.key,
  }) {
    _logger.severe('<ErrorView>', _error, _stackTrace);
  }
  static final _logger = Logger('ErrorView');

  /// The error object to be displayed.
  ///
  /// This is typically an [Exception] or [Error].
  final Object? _error;

  /// The stack trace associated with the [_error].
  ///
  /// This is used for logging and debugging.
  final StackTrace? _stackTrace;

  final String _title;

  final List<Widget> _actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_title), actions: _actions),

    body: _isFirebaseExceptionCode('permission-denied')
        ? Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    textAlign: TextAlign.center,
                    FlutterHeyteacherAuthLocalizations.of(
                      context,
                    )!.userNotAuthenticated,
                    style: _errorStyleContent(context),
                  ),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: IconButton(
                    key: const ValueKey('ic_login'),
                    icon: Icon(
                      Icons.login,
                      size: Theme.of(context).textTheme.displayMedium!.fontSize,
                    ),
                    color: Theme.of(context).iconTheme.color,
                    onPressed: () async {
                      unawaited(
                        GoRouter.of(
                          context,
                        ).pushNamed(AuthRouterName.signIn.name),
                      );
                    },
                  ),
                ),
              ),
            ],
          )
        : _isFirebaseExceptionCode('unavailable')
        ? Column(
            children: [
              Expanded(
                child: Align(
                  child: Text(
                    FlutterHeyteacherLocaleLocalizations.of(
                      context,
                    )!.contentUnavailableOfflineRetryWhenOnline,
                    textAlign: TextAlign.center,
                    style: _errorStyleContent(context),
                  ),
                ),
              ),
            ],
          )
        : Column(
            children: [
              Expanded(
                child: Align(
                  child: Text(
                    _error.toString(),
                    textAlign: TextAlign.center,
                    style: _errorStyleContent(context),
                  ),
                ),
              ),
            ],
          ),
  );

  bool _isFirebaseExceptionCode(String code) =>
      _error == null || (_error is FirebaseException && _error.code == code);

  TextStyle _errorStyleContent(BuildContext context) => Theme.of(context)
      .textTheme
      .headlineMedium!
      .copyWith(color: ThemeViewModel.instance.colorScheme.onError);
}
