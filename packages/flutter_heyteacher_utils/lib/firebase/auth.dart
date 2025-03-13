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
  static Auth instance({FirebaseAuth? firebaseAuth}) {
    _instance ??= Auth._(mockedFirebaseAuth: firebaseAuth);
    return _instance!;
  }

  Auth._({FirebaseAuth? mockedFirebaseAuth}) {
    // if [mockedFirebaseAuth] is null, inizialize with real FirebaseAuth and configure provider
    if (mockedFirebaseAuth == null) {
      _googleProvider = GoogleProvider(
          clientId:
              FirebaseRemoteConfig.instance.getString("authGoogleClientId"));
      FirebaseUIAuth.configureProviders([_googleProvider!]);
    }
    _firebaseAuth = mockedFirebaseAuth ?? FirebaseAuth.instance;
  }

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

  User? get user => _firebaseAuth.currentUser;

  bool get autenticated => user != null;

  bool get notAutenticated => !autenticated;

  String? get displayName => user?.displayName;

  String? get uid => user?.uid;

  Stream<User?> get stateChangesStream => _firebaseAuth.authStateChanges();
}

class UserNotAuthenticatedException implements Exception {
  UserNotAuthenticatedException();

  @override
  String toString() =>
      FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .userNotAutenticated;
}
