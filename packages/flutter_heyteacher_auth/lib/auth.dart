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

import 'package:firebase_auth/firebase_auth.dart';

export 'src/account_card.dart' show AccountCard;
export 'src/auth_view_model.dart'
    show AuthViewModel, UserNotAuthenticatedException;
export 'src/l10n/flutter_heyteacher_auth.dart'
    show FlutterHeyteacherAuthLocalizations;
export 'src/route.dart' show AuthRouterName,GoAuthRoute;
