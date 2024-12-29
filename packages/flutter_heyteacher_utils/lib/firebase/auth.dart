import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import '../platform_helper.dart';

class Auth {
  final log = Logger("Auth");
  late final FirebaseAuth _firebaseAuth;

  Auth._({FirebaseAuth? firebaseAuth}) {
    _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;
  }

  // singleton
  static Auth? _instance;
  static Auth instance({FirebaseAuth? firebaseAuth}) {
    _instance ??= Auth._(firebaseAuth: firebaseAuth);
    return _instance!;
  }

  Future<void> signInEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signInWithGoogle() async {
    // Trigger the authentication flow
    try {
      if (PlatformHelper.isMobile) {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        // Obtain the auth details from the request
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;
        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        // Once signed in, return the UserCredential
        await _firebaseAuth.signInWithCredential(credential);

        log.info(
            "signInWithGoogle[mobile]: ${autenticated ? "user autenticated" : "user not autenticated"}");
      } else if (PlatformHelper.isWeb) {
        // Create a new provider
        GoogleAuthProvider googleProvider = GoogleAuthProvider();

        googleProvider
            .addScope('https://www.googleapis.com/auth/contacts.readonly');
        googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

        // Once signed in, return the UserCredential
        await _firebaseAuth.signInWithPopup(googleProvider);

        // Or use signInWithRedirect
        // return await _firebaseAuth.signInWithRedirect(googleProvider);
        log.info(
            "signInWithGoogle[web]: ${autenticated ? "user autenticated" : "user not autenticated"}");
      }
    } catch (e, s) {
      log.severe("signInWithGoogle: failed", e, s);
    }
  }

  Future<void> signOut() async {
    final log = Logger("signOut");
    try {
      // Once signed in, return the UserCredential
      await _firebaseAuth.signOut();
      log.info("sign out");
    } catch (e, s) {
      log.severe("signOut: failed", e, s);
    }
  }

  bool get autenticated => _firebaseAuth.currentUser != null;

  bool get notAutenticated => _firebaseAuth.currentUser == null;

  String? get displayName => _firebaseAuth.currentUser?.displayName;

  String? get uid => _firebaseAuth.currentUser?.uid;

  Stream<User?> get stateChangesStream => _firebaseAuth.authStateChanges();
}

class UserNotAuthenticatedException {
  String message;
  UserNotAuthenticatedException(this.message);
  @override
  toString() => message;
}
