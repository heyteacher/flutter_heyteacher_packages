/// Provides authentication services using Firebase Authentication.
///
/// This library offers a singleton `Auth` class to manage user sign-in,
/// sign-out, and access to current user information
/// (like UID and display name).
/// It integrates with `firebase_ui_auth` and `firebase_ui_oauth_google` for
/// Google Sign-In capabilities.
///
/// It supports initialization with a mocked [FirebaseAuth] instance for
/// testing purposes.
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:flutter_heyteacher_utils/router.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

/// A card widget that displays user account information and provides actions
/// for sign-in, sign-out, and data deletion.
///
/// This widget listens to authentication state changes and automatically
/// triggers a callback to create user data upon sign-in. It displays the
/// user's display name when authenticated and provides buttons to sign out or
/// delete all associated user data.
class AccountCard extends StatefulWidget {
  /// Creates an [AccountCard].
  ///
  /// Requires callbacks for creating and deleting user data, which are
  /// triggered by authentication events and user actions.
  const AccountCard({
    required Future<String?> Function(String?) createUserDataCallback,
    required Future<String?> Function(String?) deleteUserDataCallback,
    super.key,
  }) : _createUserDataCallback = createUserDataCallback,
       _deleteUserDataCallback = deleteUserDataCallback;

  /// A callback function that is invoked to delete the user's data.
  /// This is typically triggered when the user confirms the data deletion
  /// action.
  final Future<String?> Function(String?) _deleteUserDataCallback;

  /// A callback function that is invoked to create initial user data.
  /// This is automatically triggered when a user signs in.
  final Future<String?> Function(String?) _createUserDataCallback;

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  StreamSubscription<User?>? _authStreamSubscription;

  @override
  void initState() {
    super.initState();
    _authStreamSubscription = AuthViewModel.instance.stateChangesStream.listen(
      (user) => user != null ? widget._createUserDataCallback(null) : null,
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
    builder: (_, snapshot) {
      return ListTile(
        key: const ValueKey('lt_account'),
        leading: Icon(
          Icons.person,
          color: AuthViewModel.instance.autenticated
              ? Theme.of(context).iconTheme.color
              : Theme.of(context).disabledColor,
          size: Theme.of(context).textTheme.displayMedium!.fontSize,
        ),
        title: Text(FlutterHeyteacherUtilsLocalizations.of(context)!.account),
        subtitle: AuthViewModel.instance.autenticated
            ? Text(AuthViewModel.instance.displayName ?? '')
            : Text(
                FlutterHeyteacherUtilsLocalizations.of(
                  context,
                )!.userNotAuthenticated,
              ),
        trailing: Wrap(
          children: [
            if (AuthViewModel.instance.autenticated)
              IconButton(
                key: const ValueKey('ic_delete_data'),
                icon: const Icon(Icons.delete),
                color: ThemeViewModel.instance.redColor,
                onPressed: () async {
                  unawaited(
                    showConfirmCancelDialog<String>(
                      context: context,
                      confirmCallback: (_) async {
                        await widget._deleteUserDataCallback(null);
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
                        FlutterHeyteacherUtilsLocalizations.of(
                          context,
                        )!.deleteUserData,
                      ),
                      content: Text(
                        FlutterHeyteacherUtilsLocalizations.of(
                          context,
                        )!.doYouConfirmDeletionUserData,
                      ),
                    ),
                  );
                },
              ),
            IconButton(
              key: const ValueKey('ic_login_logout'),
              icon: Icon(
                AuthViewModel.instance.autenticated
                    ? Icons.logout
                    : Icons.login,
              ),
              color: AuthViewModel.instance.autenticated
                  ? ThemeViewModel.instance.redColor
                  : Theme.of(context).iconTheme.color,
              onPressed: () async {
                if (AuthViewModel.instance.autenticated) {
                  unawaited(
                    GoRouter.of(
                      context,
                    ).pushNamed(AuthRouterName.signOut.name),
                  );
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
      );
    },
  );
}

/// Manages user authentication state and operations via Firebase.
///
/// This class is a singleton, accessible via `Auth.instance()`.
/// It provides methods for signing out, accessing the current [User] object,
/// checking authentication status, and listening to authentication state
/// changes.
/// It can be initialized with a real or mocked [FirebaseAuth] instance.
class AuthViewModel {

  /// Private constructor for the singleton.
  /// Initializes [_firebaseAuth] with either the provided [mockedFirebaseAuth]
  /// or the default [FirebaseAuth.instance].
  /// Configures [GoogleProvider] if not using a mocked instance.
  //@visibleForTesting
  AuthViewModel({FirebaseAuth? mockedFirebaseAuth}) {
    // if [mockedFirebaseAuth] is null, inizialize with real FirebaseAuth
    //and configure provider
    if (mockedFirebaseAuth == null && PlatformHelper.isMobile) {
      _googleProvider = GoogleProvider(
        clientId: FirebaseRemoteConfig.instance.getString('authGoogleClientId'),
      );
      FirebaseUIAuth.configureProviders([_googleProvider!]);
    }
    _firebaseAuth = mockedFirebaseAuth ?? FirebaseAuth.instance;
  }
  static final _logger = Logger('AuthViewModel');
  late final FirebaseAuth _firebaseAuth;
  GoogleProvider? _googleProvider;

  // singleton
  static AuthViewModel? _instance;

  /// Provides the singleton instance of the [AuthViewModel] manager.
  ///
  /// Auth, and the Google Sign-In provider will not be configured.
  /// This is useful for testing environments.
  // ignore: prefer_constructors_over_static_methods
  static AuthViewModel get instance {
    _instance ??= AuthViewModel();
    return _instance!;
  }

  //@visibleForTesting
  static set instance(AuthViewModel instance) => _instance = instance;

  /// Signs out the current user from Firebase Authentication.
  ///
  /// If a [GoogleProvider] was configured, it also attempts to sign out
  /// from the Google provider.
  Future<void> signOut() async {
    _logger.info('<signOut>:');
    try {
      await _firebaseAuth.signOut();
      await _googleProvider?.logOutProvider();
      _logger.info('(signOut): success');
    } on Exception catch (error, stackTrace) {
      _logger.severe('(signOut): failed', error, stackTrace);
    }
  }

  /// Signs in with [email] and [password] using Firebase Authentication.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _logger.info('<signInWithEmailAndPassword>: email $email');
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.info('(signInWithEmailAndPassword): email $email. Success');
    } on Exception catch (error, stackTrace) {
      _logger.severe('(signOut): failed', error, stackTrace);
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

  /// A stream that emits the [User] object when the authentication state
  /// changes.
  ///
  /// Emits `null` when the user signs out.
  Stream<User?> get stateChangesStream => _firebaseAuth
      .authStateChanges()
      .distinct((user1, user2) => user1?.uid == user2?.uid);
}

/// Exception thrown when an operation requiring authentication is attempted
/// but no user is currently signed in.
class UserNotAuthenticatedException implements Exception {
  /// Creates a [UserNotAuthenticatedException].
  UserNotAuthenticatedException();

  @override
  String toString() => FlutterHeyteacherUtilsLocalizations.of(
    ContextHelper.context!,
  )!.userNotAuthenticated;
}
