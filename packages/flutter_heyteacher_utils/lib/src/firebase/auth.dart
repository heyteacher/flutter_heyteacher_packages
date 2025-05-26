/// Provides authentication services using Firebase Authentication.
///
/// This library offers a singleton `Auth` class to manage user sign-in,
/// sign-out, and access to current user information (like UID and display name).
/// It integrates with `firebase_ui_auth` and `firebase_ui_oauth_google` for
/// Google Sign-In capabilities.
///
/// It supports initialization with a mocked [FirebaseAuth] instance for testing purposes.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

class AccountCard extends StatelessWidget {
  const AccountCard({super.key});

  @override
  Widget build(BuildContext context) => Card(
        child: StreamBuilder<dynamic>(
            stream: AuthModel.instance().stateChangesStream,
            builder: (_, snapshot) {
              return ListTile(
                key: const ValueKey('lt_account'),
                leading: Icon(
                  Icons.person,
                  color: AuthModel.instance().autenticated
                      ? Theme.of(context).iconTheme.color
                      : Theme.of(context).disabledColor,
                  size: Theme.of(context).textTheme.displayMedium!.fontSize,
                ),
                title: Text(
                    FlutterHeyteacherUtilsLocalizations.of(context)!.account),
                subtitle: AuthModel.instance().autenticated
                    ? Text(AuthModel.instance().displayName ?? '')
                    : Text(FlutterHeyteacherUtilsLocalizations.of(context)!
                        .userNotAutenticated),
                trailing: IconButton(
                    key: const ValueKey('ic_login_logout'),
                    icon: Icon(AuthModel.instance().autenticated
                        ? Icons.logout
                        : Icons.login),
                    color: AuthModel.instance().autenticated
                        ? Theme.of(context).colorScheme.onError
                        : Theme.of(context).iconTheme.color,
                    onPressed: () async {
                      if (AuthModel.instance().autenticated) {
                        GoRouter.of(context).pushNamed('auth-sign-out');
                      } else {
                        GoRouter.of(context).pushNamed('auth-sign-in');
                      }
                    }),
              );
            }),
      );
}

/// Manages user authentication state and operations via Firebase.
///
/// This class is a singleton, accessible via `Auth.instance()`.
/// It provides methods for signing out, accessing the current [User] object,
/// checking authentication status, and listening to authentication state changes.
/// It can be initialized with a real or mocked [FirebaseAuth] instance.
class AuthModel {
  final log = Logger('AuthModel');
  late final FirebaseAuth _firebaseAuth;
  GoogleProvider? _googleProvider;

  // singleton
  static AuthModel? _instance;

  /// Provides the singleton instance of the [AuthModel] manager.
  ///
  /// If [mockedFirebaseAuth] is not null, initialize with the mocked Firebase
  /// Auth, and the Google Sign-In provider will not be configured.
  /// This is useful for testing environments.
  static AuthModel instance({FirebaseAuth? mockedFirebaseAuth}) {
    _instance ??= AuthModel._(mockedFirebaseAuth: mockedFirebaseAuth);
    return _instance!;
  }

  /// Private constructor for the singleton.
  /// Initializes [_firebaseAuth] with either the provided [mockedFirebaseAuth] or the default [FirebaseAuth.instance].
  /// Configures [GoogleProvider] if not using a mocked instance.
  AuthModel._({FirebaseAuth? mockedFirebaseAuth}) {
    // if [mockedFirebaseAuth] is null, inizialize with real FirebaseAuth
    //and configure provider
    if (mockedFirebaseAuth == null) {
      _googleProvider = GoogleProvider(
          clientId:
              FirebaseRemoteConfig.instance.getString('authGoogleClientId'));
      FirebaseUIAuth.configureProviders([_googleProvider!]);
    }
    _firebaseAuth = mockedFirebaseAuth ?? FirebaseAuth.instance;
  }

  /// Signs out the current user from Firebase Authentication.
  ///
  /// If a [GoogleProvider] was configured, it also attempts to sign out
  /// from the Google provider.
  Future<void> signOut() async {
    final log = Logger('signOut');
    try {
      await _firebaseAuth.signOut();
      _googleProvider?.logOutProvider();
      log.info('sign out');
    } catch (e, s) {
      log.severe('signOut: failed', e, s);
    }
  }

  /// Gets the currently authenticated Firebase [User].
  ///
  /// Returns `null` if no user is currently signed in.
  User? get user => _firebaseAuth.currentUser;

  /// Returns `true` if a user is currently authenticated, `false` otherwise.
  bool get autenticated => user != null;

  /// Returns `true` if no user is currently authenticated, `false` otherwise.
  bool get notAutenticated => !autenticated;

  /// Gets the display name of the currently authenticated user.
  ///
  /// Returns `null` if no user is signed in or if the user has no display name.
  String? get displayName => user?.displayName;

  /// Gets the unique ID (UID) of the currently authenticated user.
  ///
  /// Returns `null` if no user is signed in.
  String? get uid => user?.uid;

  /// A stream that emits the [User] object when the authentication state changes.
  ///
  /// Emits `null` when the user signs out.
  Stream<User?> get stateChangesStream => _firebaseAuth
      .authStateChanges()
      .distinct((user1, user2) => user1 == null && user2 == null
          ? true
          : user1 == null || user2 == null
              ? false
              : user1.uid == user2.uid);
}

/// Exception thrown when an operation requiring authentication is attempted
/// but no user is currently signed in.
class UserNotAuthenticatedException implements Exception {
  UserNotAuthenticatedException();

  @override
  String toString() =>
      FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .userNotAutenticated;
}
