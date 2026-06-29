import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart'
    show MockFirebaseAuth, MockUser;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart';
import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';
import 'package:logging/logging.dart';

/// Manages user authentication state and operations via Firebase.
///
/// This class is a singleton, accessible via `Auth.instance()`.
/// It provides methods for signing out, accessing the current [User] object,
/// checking authentication status, and listening to authentication state
/// changes.
/// It can be initialized with a real or mocked [FirebaseAuth] instance.
class AuthViewModel {
  AuthViewModel._();

  static final _logger = Logger('AuthViewModel');

  /// Local user constants for testing purposes.
  static const String localUid = 'localUid';

  /// Local user email.
  static const String _localEmail = 'user@localhost.localdomain';

  /// Local user name.
  static const String _localName = 'Local User';

  FirebaseAuth? _firebaseAuth;
  GoogleProvider? _googleProvider;

  // singleton
  static AuthViewModel? _instance;

  /// Provides the singleton instance of the [AuthViewModel] manager.
  ///
  /// Auth, and the Google Sign-In provider will not be configured.
  /// This is useful for testing environments.
  // ignore: prefer_constructors_over_static_methods
  static AuthViewModel get instance {
    _instance ??= AuthViewModel._();
    return _instance!;
  }

  /// Initializes [_firebaseAuth] with either the provided [MockFirebaseAuth]
  /// or the default [FirebaseAuth.instance].
  /// Configures [GoogleProvider] if not using a mocked instance.
  //@visibleForTesting
  Future<void> initialize() async {
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
        '(AuthViewModel): no firebase, local authentication with uid '
        '"$localUid". ',
      );
      // Mock Firebase Authentication
      await localInitialize();
    }
  }

  /// Local sign in with local user credentials
  Future<void> localInitialize() async {
    _logger.fine('<localInitialize>:');
    if (_firebaseAuth != null && notLocalAuthentication) {
      throw Exception(
        '(initializeLocalAuthentication): Cannot initialize local '
        'authentication, already using real authentication',
      );
    }
    _firebaseAuth ??= MockFirebaseAuth(
      mockUser: MockUser(
        uid: localUid,
        email: _localEmail,
        displayName: _localName,
      ),
    );
    await signInWithEmailAndPassword(
      email: _localEmail,
      password: _localEmail,
    );
    await localSignIn();
  }

  /// Sign in with local user credentials
  Future<void> localSignIn() async => signInWithEmailAndPassword(
    email: _localEmail,
    password: _localEmail,
  );

  /// Whether local authentication is used
  bool get localAuthentication =>
      _firebaseAuth != null && _firebaseAuth is MockFirebaseAuth;

  /// Whether local authentication is not used
  bool get notLocalAuthentication => !localAuthentication;

  /// Signs out the current user from Firebase Authentication.
  ///
  /// If a [GoogleProvider] was configured, it also attempts to sign out
  /// from the Google provider.
  Future<void> signOut() async {
    _logger.info('<signOut>:');
    try {
      await _firebaseAuth?.signOut();
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
      if (_firebaseAuth == null) {
        throw Exception('Firebase Authentication is not initialized');
      }
      await _firebaseAuth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.info('(signInWithEmailAndPassword): email $email. Success');
    } on Exception catch (error, stackTrace) {
      _logger.severe('(signInWithEmailAndPassword): failed', error, stackTrace);
    }
  }

  /// Gets the authForFakeFirestore
  Stream<Map<String, dynamic>?> get authForFakeFirestore =>
      _firebaseAuth != null && _firebaseAuth is MockFirebaseAuth
      ? (_firebaseAuth! as MockFirebaseAuth).authForFakeFirestore
      : const Stream.empty();

  /// Returns `true` if a user is currently authenticated, `false` otherwise.
  bool get autenticated => _firebaseAuth?.currentUser != null;

  /// Returns `true` if no user is currently authenticated, `false` otherwise.
  bool get notAutenticated => !autenticated;

  /// Gets the display name of the currently authenticated user.
  ///
  /// Returns `null` if no user is signed in or if the user has no display name.
  String? get displayName => _firebaseAuth?.currentUser?.displayName;

  /// Gets the email of the currently authenticated user.
  ///
  /// Returns `null` if no user is signed in or if the user has no email.
  String? get email => _firebaseAuth?.currentUser?.email;

  /// Gets the unique ID (UID) of the currently authenticated user.
  ///
  /// Returns `null` if no user is signed in.
  String? get uid => _firebaseAuth?.currentUser?.uid;

  /// A stream that emits the [User] object when the authentication state
  /// changes.
  ///
  /// Emits `null` when the user signs out.
  Stream<User?> get stateChangesStream => _firebaseAuth != null
      ? _firebaseAuth!.authStateChanges().distinct(
          (user1, user2) => user1?.uid == user2?.uid,
        )
      : const Stream.empty();
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
