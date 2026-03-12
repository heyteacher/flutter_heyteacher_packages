import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart'
    show MockFirebaseAuth, MockUser;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_heyteacher_auth/auth.dart';
import 'package:flutter_heyteacher_platform/platform.dart';
import 'package:logging/logging.dart';

/// Manages user authentication state and operations via Firebase.
///
/// This class is a singleton, accessible via `Auth.instance()`.
/// It provides methods for signing out, accessing the current [User] object,
/// checking authentication status, and listening to authentication state
/// changes.
/// It can be initialized with a real or mocked [FirebaseAuth] instance.
class AuthViewModel {
  /// Private constructor for the singleton.
  /// Initializes [_firebaseAuth] with either the provided [MockFirebaseAuth]
  /// or the default [FirebaseAuth.instance].
  /// Configures [GoogleProvider] if not using a mocked instance.
  //@visibleForTesting
  AuthViewModel() {
    try {
      _googleProvider = GoogleProvider(
        clientId: FirebaseRemoteConfig.instance.getString(
          'authGoogleClientId',
        ),
      );
      FirebaseUIAuth.configureProviders([_googleProvider!]);
      _firebaseAuth = FirebaseAuth.instance;
    //
    // ignore: avoid_catches_without_on_clauses
    } catch (_) {
      _logger.warning(
        '(AuthViewModel): no firebase, mock authentication with uid "testuid". '
        'Do not use in production mode',
      );
      // Mock Firebase Authentication
      _firebaseAuth = MockFirebaseAuth(
        mockUser: MockUser(
          uid: 'testuid',
          email: 'test@example.com',
          displayName: 'Test User',
        ),
      );
    }
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

  /// Gets the authForFakeFirestore
  @visibleForTesting
  Stream<Map<String, dynamic>?> get authForFakeFirestore =>
      _firebaseAuth is MockFirebaseAuth
      ? _firebaseAuth.authForFakeFirestore
      : const Stream.empty();

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
  String toString() => ContextHelper.context != null
      ? FlutterHeyteacherAuthLocalizations.of(
          ContextHelper.context!,
        )!.userNotAuthenticated
      : 'user not authenticated';
}
