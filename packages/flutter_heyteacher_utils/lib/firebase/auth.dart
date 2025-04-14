/// The Authentication utility based on [FirebaseAuth] and [GoogleProvider].
///
/// Provider the current user authenticated info (`uid`, `display name`).
/// 
/// Can be instantiated with a `mocked` Firebase Auth useful for tests and
/// E2E tests.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:logging/logging.dart';

class Auth {
  final log = Logger("Auth");
  late final FirebaseAuth _firebaseAuth;
  GoogleProvider? _googleProvider;

  // singleton
  static Auth? _instance;

  /// Gets an instance of [Auth].
  /// 
  /// If [mockedFirebaseAuth] is not null, initialize with the mocked Firebase
  /// Auth and doesn't instantiate the Google Provider
  static Auth instance({FirebaseAuth? mockedFirebaseAuth}) {
    _instance ??= Auth._(mockedFirebaseAuth: mockedFirebaseAuth);
    return _instance!;
  }

  Auth._({FirebaseAuth? mockedFirebaseAuth}) {
    // if [mockedFirebaseAuth] is null, inizialize with real FirebaseAuth 
    //and configure provider
    if (mockedFirebaseAuth == null) {
      _googleProvider = GoogleProvider(
          clientId:
              FirebaseRemoteConfig.instance.getString("authGoogleClientId"));
      FirebaseUIAuth.configureProviders([_googleProvider!]);
    }
    _firebaseAuth = mockedFirebaseAuth ?? FirebaseAuth.instance;
  }

  /// Manage the signout from [FirebaseAuth] and [GoogleProvider].
  Future<void> signOut() async {
    final log = Logger("signOut");
    try {
      await _firebaseAuth.signOut();
      _googleProvider?.logOutProvider();
      log.info("sign out");
    } catch (e, s) {
      log.severe("signOut: failed", e, s);
    }
  }

  /// Gets the current user authenticated.
  ///
  /// Return null if not authenthenticated
  User? get user => _firebaseAuth.currentUser;

  /// Returns if the user is authenticated.
  bool get autenticated => user != null;

  /// Returns if the user is not authenticated.
  bool get notAutenticated => !autenticated;

  /// Returns if the `displayName` is not authenticated.
  String? get displayName => user?.displayName;

  /// Returns if the `uid` is not authenticated.
  String? get uid => user?.uid;

  /// Returns the stream of user state changes
  Stream<User?> get stateChangesStream => _firebaseAuth.authStateChanges();
}


/// Exception raised when autentication is required but user isn't 
/// authenticated.
class UserNotAuthenticatedException implements Exception {
  UserNotAuthenticatedException();

  @override
  String toString() =>
      FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .userNotAutenticated;
}
