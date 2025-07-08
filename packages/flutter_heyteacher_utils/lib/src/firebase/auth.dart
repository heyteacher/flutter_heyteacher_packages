/// Provides authentication services using Firebase Authentication.
///
/// This library offers a singleton `Auth` class to manage user sign-in,
/// sign-out, and access to current user information (like UID and display name).
/// It integrates with `firebase_ui_auth` and `firebase_ui_oauth_google` for
/// Google Sign-In capabilities.
///
/// It supports initialization with a mocked [FirebaseAuth] instance for testing purposes.
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

class AccountCard extends StatelessWidget {
  final Future<String?> Function(String?) _deleteUserDataCallback;
  final Future<String?> Function(String?) _createUserDataCallback;

  late final StreamSubscription<User?>? _authStreamSubscription;
  
  AccountCard(
      {super.key,
      required Future<String?> Function(String?) createUserDataCallback,
      required Future<String?> Function(String?) deleteUserDataCallback})
      : _createUserDataCallback = createUserDataCallback,
        _deleteUserDataCallback = deleteUserDataCallback {
    _authStreamSubscription = AuthViewModel.instance()
        .stateChangesStream
        .listen((user) => user != null ? _createUserDataCallback(null) : null);
  }

  dispose() {
    _authStreamSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) => Card(
        child: StreamBuilder<dynamic>(
            stream: AuthViewModel.instance().stateChangesStream,
            builder: (_, snapshot) {
              return ListTile(
                key: const ValueKey('lt_account'),
                leading: Icon(
                  Icons.person,
                  color: AuthViewModel.instance().autenticated
                      ? Theme.of(context).iconTheme.color
                      : Theme.of(context).disabledColor,
                  size: Theme.of(context).textTheme.displayMedium!.fontSize,
                ),
                title: Text(
                    FlutterHeyteacherUtilsLocalizations.of(context)!.account),
                subtitle: AuthViewModel.instance().autenticated
                    ? Text(AuthViewModel.instance().displayName ?? '')
                    : Text(FlutterHeyteacherUtilsLocalizations.of(context)!
                        .userNotAutenticated),
                trailing: Wrap(
                  children: [
                    if (AuthViewModel.instance().autenticated)
                      IconButton(
                          key: const ValueKey('ic_delete_data'),
                          icon: const Icon(Icons.delete),
                          color: ThemeViewModel.instance()
                              .theme
                              .colorScheme
                              .onError,
                          onPressed: () async {
                            showConfirmCancelDialog<String>(
                              context: context,
                              confirmCallback: (String? _) async {
                                await _deleteUserDataCallback(null);
                                if (context.mounted) {
                                  GoRouter.of(context)
                                      .pushNamed('auth-sign-out');
                                }
                                return null;
                              },
                              title: FlutterHeyteacherUtilsLocalizations.of(
                                      context)!
                                  .deleteUserData,
                              content: FlutterHeyteacherUtilsLocalizations.of(
                                      context)!
                                  .doYouConfirmDeletionUserData,
                            );
                        }),
                    IconButton(
                        key: const ValueKey('ic_login_logout'),
                        icon: Icon(AuthViewModel.instance().autenticated
                            ? Icons.logout
                            : Icons.login),
                        color: AuthViewModel.instance().autenticated
                            ? ThemeViewModel.instance()
                                .theme
                                .colorScheme
                                .onError
                            : Theme.of(context).iconTheme.color,
                        onPressed: () async {
                          if (AuthViewModel.instance().autenticated) {
                            GoRouter.of(context).pushNamed('auth-sign-out');
                          } else {
                            GoRouter.of(context).pushNamed('auth-sign-in');
                          }
                        }),
                  ],
                ),
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
class AuthViewModel {
  final log = Logger('AuthModel');
  late final FirebaseAuth _firebaseAuth;
  GoogleProvider? _googleProvider;

  // singleton
  static AuthViewModel? _instance;

  /// Provides the singleton instance of the [AuthViewModel] manager.
  ///
  /// If [mockedFirebaseAuth] is not null, initialize with the mocked Firebase
  /// Auth, and the Google Sign-In provider will not be configured.
  /// This is useful for testing environments.
  static AuthViewModel instance({FirebaseAuth? mockedFirebaseAuth}) {
    _instance ??= AuthViewModel._(mockedFirebaseAuth: mockedFirebaseAuth);
    return _instance!;
  }

  /// Private constructor for the singleton.
  /// Initializes [_firebaseAuth] with either the provided [mockedFirebaseAuth] or the default [FirebaseAuth.instance].
  /// Configures [GoogleProvider] if not using a mocked instance.
  AuthViewModel._({FirebaseAuth? mockedFirebaseAuth}) {
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
      .distinct((user1, user2) => user1?.uid == user2?.uid);
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
