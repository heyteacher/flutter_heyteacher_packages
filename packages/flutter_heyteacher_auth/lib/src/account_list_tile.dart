import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_auth/src/auth_view_model.dart';
import 'package:flutter_heyteacher_auth/src/l10n/flutter_heyteacher_auth.dart';
import 'package:flutter_heyteacher_auth/src/route.dart' show AuthRouterName;
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';
import 'package:go_router/go_router.dart';

/// A list tile that displays user account information and provides actions
/// for sign-in, sign-out, and data deletion.
///
/// This widget listens to authentication state changes and automatically
/// triggers a callback to create user data upon sign-in. It displays the
/// user's display name when authenticated and provides buttons to sign out or
/// delete all associated user data.
///
/// - [_postSignInCallback]: A callback function that is invoked to create
///   initial user data. This is automatically triggered when a user signs in.
///
/// -[_preSignOutCallback]: A callback function that is invoked before sign out.
///
/// - [_deleteCallback]: A callback function that is invoked to delete the
///   user's data. This is typically triggered when the user confirms the data
///   deletion action.
///
/// - [_deleteConfirmMessage]: A message that is displayed when the user
///   confirms the data deletion action.
///
/// - [_disableLoginLogout]: A boolean that indicates whether the login/logout
/// functionality should be disabled.
///
/// Example:
///
/// ```dart
/// AccountListTile(
///   deleteCallback: () async {
///     // insert here your logic to delete user data
///     showSnackBar(context: context, message: 'content');
///   },
///   deleteConfirmMessage: 'Are you sure to delete your user data?',
///   postSignInCallback: () async {
///     // insert here your logic to create user data
///   },
///   preSignOutCallback: () async {
///     // insert here your logic before sign out
///   },
///   disableLoginLogout: false,
/// )
/// ```
///
class AccountListTile extends StatefulWidget {
  /// Creates an [AccountListTile].
  ///
  /// Requires callbacks for creating and deleting user data, which are
  /// triggered by authentication events and user actions.
  const AccountListTile({
    this._postSignInCallback,
    this._preSignOutCallback,
    this._deleteCallback,
    this._deleteConfirmMessage,
    this._disableLoginLogout = false,
    super.key,
  });

  /// A callback function that is invoked to delete the user's data.
  /// This is typically triggered when the user confirms the data deletion
  /// action.
  final AsyncCallback? _deleteCallback;

  /// A callback function that is invoked to create initial user data.
  /// This is automatically triggered when a user signs in.
  final AsyncCallback? _postSignInCallback;

  /// A callback function that is invoked before sign out.
  final AsyncCallback? _preSignOutCallback;

  final String? _deleteConfirmMessage;

  final bool _disableLoginLogout;

  @override
  State<AccountListTile> createState() => _AccountListTileState();
}

class _AccountListTileState extends State<AccountListTile> {
  StreamSubscription<User?>? _authStreamSubscription;

  @override
  void initState() {
    super.initState();
    _authStreamSubscription = AuthViewModel.instance.stateChangesStream.listen(
      (user) => user != null ? widget._postSignInCallback?.call() : null,
    );
  }

  @override
  void dispose() {
    unawaited(_authStreamSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<dynamic>(
    stream: AuthViewModel.instance.stateChangesStream,
    builder: (_, snapshot) => ListTile(
      key: const ValueKey('lt_account'),
      leading: Icon(
        Icons.person,
        color: AuthViewModel.instance.autenticated
            ? Theme.of(context).iconTheme.color
            : Theme.of(context).disabledColor,
      ),
      title: Text(FlutterHeyteacherAuthLocalizations.of(context)!.account),
      subtitle: AuthViewModel.instance.autenticated
          ? AuthViewModel.instance.displayName != null
                ? Text(AuthViewModel.instance.displayName!)
                : null
          : Text(
              FlutterHeyteacherAuthLocalizations.of(
                context,
              )!.userNotAuthenticated,
            ),
      trailing: Wrap(
        children: [
          if (AuthViewModel.instance.autenticated &&
              widget._deleteCallback != null)
            IconButton(
              key: const ValueKey('ic_delete_data'),
              icon: const Icon(Icons.delete),
              color: ThemeViewModel.instance.redColor,
              onPressed: () async => unawaited(
                showConfirmCancelDialog<String>(
                  context: context,
                  confirmCallback: (_) async {
                    await widget._preSignOutCallback?.call();
                    await widget._deleteCallback?.call();
                    if (context.mounted) {
                      unawaited(
                        GoRouter.of(
                          context,
                        ).pushNamed(AuthRouterName.signOut.name),
                      );
                    }
                    return null;
                  },
                  title: Text(
                    FlutterHeyteacherAuthLocalizations.of(
                      context,
                    )!.deleteUserData,
                  ),
                  content: Text(widget._deleteConfirmMessage ?? ''),
                ),
              ),
            ),
          IconButton(
            key: const ValueKey('ic_login_logout'),
            icon: Icon(
              AuthViewModel.instance.autenticated ? Icons.logout : Icons.login,
            ),
            color: AuthViewModel.instance.autenticated
                ? ThemeViewModel.instance.redColor
                : Theme.of(context).iconTheme.color,
            onPressed: widget._disableLoginLogout
                ? null
                : () async {
                    // sign out
                    if (AuthViewModel.instance.autenticated) {
                      await widget._preSignOutCallback?.call();
                      if (context.mounted) {
                        unawaited(
                          GoRouter.of(
                            context,
                          ).pushNamed(AuthRouterName.signOut.name),
                        );
                      }
                      // sign in
                    } else {
                      unawaited(
                        GoRouter.of(
                          context,
                        ).pushNamed(AuthRouterName.signIn.name),
                      );
                    }
                  },
          ),
        ],
      ),
    ),
  );
}
