import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logging/logging.dart';
import '../platform_helper.dart';

class UserNotAuthenticatedException {
  String message;
  UserNotAuthenticatedException(this.message);
  @override
  toString() => message;
}
 
Future<void> signInEmailAndPassword(String email, String password) async {
  await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
}

Future<void> signInWithGoogle() async {
  final log = Logger("signInWithGoogle");
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
      await FirebaseAuth.instance.signInWithCredential(credential);

      log.info(
          "signInWithGoogle[mobile]: ${userAutenticated ? "user autenticated" : "user not autenticated"}");
    } else if (PlatformHelper.isWeb) {
      // Create a new provider
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      googleProvider
          .addScope('https://www.googleapis.com/auth/contacts.readonly');
      googleProvider.setCustomParameters({'login_hint': 'user@example.com'});

      // Once signed in, return the UserCredential
      await FirebaseAuth.instance.signInWithPopup(googleProvider);

      // Or use signInWithRedirect
      // return await FirebaseAuth.instance.signInWithRedirect(googleProvider);
      log.info(
          "signInWithGoogle[web]: ${userAutenticated ? "user autenticated" : "user not autenticated"}");
    }
  } catch (e, s) {
    log.severe("signInWithGoogle: failed", e, s);
  }
}

Future<void> signOut() async {
  final log = Logger("signOut");
  try {
    // Once signed in, return the UserCredential
    await FirebaseAuth.instance.signOut();
    log.info("sign out");
  } catch (e, s) {
    log.severe("signOut: failed", e, s);
  }
}


bool get userAutenticated {
  return FirebaseAuth.instance.currentUser != null;
}

String? get authUserDisplayName {
  return FirebaseAuth.instance.currentUser?.displayName;
}

String? get authUserUid {
  return FirebaseAuth.instance.currentUser?.uid;
}

Stream<User?> authStateChangesStream = FirebaseAuth.instance.authStateChanges();

