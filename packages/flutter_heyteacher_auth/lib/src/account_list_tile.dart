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
class AccountListTile extends StatefulWidget {
  /// Creates an [AccountListTile].
  ///
  /// Requires callbacks for creating and deleting user data, which are
  /// triggered by authentication events and user actions.
  const AccountListTile({
    AsyncCallback? createAccountCallback,
    AsyncCallback? deleteAccountCallback,
    String? deleteAccountConfirmMessage,
    super.key,
  }) : _createUserDataCallback = createAccountCallback,
       _deleteUserDataCallback = deleteAccountCallback,
       _deleteUserDataCallbackMessage = deleteAccountConfirmMessage;

  /// A callback function that is invoked to delete the user's data.
  /// This is typically triggered when the user confirms the data deletion
  /// action.
  final AsyncCallback? _deleteUserDataCallback;

  /// A callback function that is invoked to create initial user data.
  /// This is automatically triggered when a user signs in.
  final AsyncCallback? _createUserDataCallback;

  final String? _deleteUserDataCallbackMessage;

  @override
  State<AccountListTile> createState() => _AccountListTileState();
}

class _AccountListTileState extends State<AccountListTile> {
  StreamSubscription<User?>? _authStreamSubscription;

  @override
  void initState() {
    super.initState();
    _authStreamSubscription = AuthViewModel.instance.stateChangesStream.listen(
      (user) => user != null ? widget._createUserDataCallback?.call() : null,
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
                ? Text(
                    AuthViewModel.instance.displayName!,
                  )
                : null
          : Text(
              FlutterHeyteacherAuthLocalizations.of(
                context,
              )!.userNotAuthenticated,
            ),
      trailing: Wrap(
        children: [
          if (AuthViewModel.instance.autenticated &&
              widget._deleteUserDataCallback != null)
            IconButton(
              key: const ValueKey('ic_delete_data'),
              icon: const Icon(Icons.delete),
              color: ThemeViewModel.instance.redColor,
              onPressed: () async => unawaited(
                showConfirmCancelDialog<String>(
                  context: context,
                  confirmCallback: (_) async {
                    await widget._deleteUserDataCallback?.call();
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
                  content: Text(
                    widget._deleteUserDataCallbackMessage ?? '',
                  ),
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
            onPressed: () async {
              // sign out
              if (AuthViewModel.instance.autenticated) {
                unawaited(
                  GoRouter.of(
                    context,
                  ).pushNamed(AuthRouterName.signOut.name),
                );
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
