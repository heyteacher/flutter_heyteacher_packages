import 'package:firebase_auth/firebase_auth.dart'; // For FirebaseException
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/locale.dart';
import 'package:flutter_heyteacher_utils/router.dart';
import 'package:flutter_heyteacher_utils/src/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart'; // Import the file containing ErrorView
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// Import generated mocks
import 'widgets_test.mocks.dart';

// --- Mock Localization Delegate ---
class MockFlutterHeyteacherUtilsLocalizations
    extends FlutterHeyteacherUtilsLocalizations {
  MockFlutterHeyteacherUtilsLocalizations() : super('en'); // Default locale

  @override
  String get userNotAuthenticated => 'User not authenticated (Mock)';
  @override
  String get id => 'ID: (Mock)';
  @override
  String get version => 'Version: (Mock)';
  @override
  String get askSupport => 'Support (Mock)';

  static const LocalizationsDelegate<FlutterHeyteacherUtilsLocalizations>
  delegate = _MockLocalizationsDelegate();

  static FlutterHeyteacherUtilsLocalizations of(BuildContext context) {
    return Localizations.of<FlutterHeyteacherUtilsLocalizations>(
          context,
          FlutterHeyteacherUtilsLocalizations,
        ) ??
        MockFlutterHeyteacherUtilsLocalizations(); // Fallback
  }

  @override
  String get areYouSureToConfirmTheAction => throw UnimplementedError();

  @override
  String get askSupportFor => throw UnimplementedError();

  @override
  String get confirm => throw UnimplementedError();

  @override
  String get encryptionPassphraseIsEmptySetIt => throw UnimplementedError();

  @override
  String get errorOnDecryptionCheckPassphrase => throw UnimplementedError();

  @override
  String get errorOnEncryptionCheckPassphrase => throw UnimplementedError();

  @override
  String get errorOnRetrieveData => throw UnimplementedError();

  @override
  String get missingEncryptionSecretKeyImportIt => throw UnimplementedError();

  @override
  String get notAuthenticated => throw UnimplementedError();

  @override
  String get timeoutOnRetrieveData => throw UnimplementedError();

  @override
  String get logging => 'Logging';

  @override
  String nMinutes(num minutes) {
    return '$minutes minutes';
  }

  @override
  String get account => 'Account';

  @override
  String get areYouSureToChangeEncryptionPassphrase =>
      'areYouSureToChangeEncryptionPassphrase';

  @override
  String get areYouSureToImportEncryptionSecretKey => '';

  @override
  String get encryptionPassphrase => '';

  @override
  String get encryptionSecretKey => '';

  @override
  String get encryptionSecretKeyImported => '';

  @override
  String
  get scanQRCodeWithAnotherDeviceOrStoreInASecurePlaceRememberToUseSamePassphrase =>
      '';

  @override
  String get errorWorkflowTaskAlreadyInitialized => '';

  @override
  String get errorWorkflowNotInitialized => '';

  @override
  String get contentUnavailableOfflineRetryWhenOnline => '';

  @override
  String get deleteUserData => '';

  @override
  String get doYouConfirmDeletionUserData => '';

  @override
  String get description => '';

  @override
  String get task => '';

  @override
  String get tasks => '';

  @override
  String get skip => '';

  @override
  String get deviceOfflineAskSupportWhenOnline => '';

  @override
  String get loggingLevel => '';

  @override
  String defaultValue(Object defaultValue) => '';

  @override
  String nSeconds(num nSeconds) => '';

  @override
  String get search => '';
  
  @override
  String get enableLogsStorage => throw UnimplementedError();
}

class _MockLocalizationsDelegate
    extends LocalizationsDelegate<FlutterHeyteacherUtilsLocalizations> {
  const _MockLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true; // Support all locales for mock

  @override
  Future<FlutterHeyteacherUtilsLocalizations> load(Locale locale) =>
      SynchronousFuture(MockFlutterHeyteacherUtilsLocalizations());

  @override
  bool shouldReload(_MockLocalizationsDelegate old) => false;
}

// Annotation for Mockito
// Note: GoRouter is often better faked than mocked if complex interactions are needed.
// Here we use Mockito for simplicity assuming only pushNamed is called.
@GenerateMocks([GoRouter])
void main() {
  // Disable logging for tests to avoid console noise
  Logger.root.level = Level.OFF;

  // Helper function to pump the ErrorView widget with necessary providers
  Future<void> pumpErrorView(
    WidgetTester tester, {
    Object? error,
    StackTrace? stackTrace,
    required MockGoRouter mockGoRouter, // Use the generated mock
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          MockFlutterHeyteacherUtilsLocalizations.delegate,
          // Add other delegates if needed (e.g., GlobalMaterialLocalizations)
        ],
        supportedLocales: const [
          Locale('en', ''), // Add supported locales
        ],
        home: InheritedGoRouter(
          goRouter: mockGoRouter,
          child: ErrorView(error, stackTrace),
        ),
      ),
    );
  }

  late MockGoRouter mockGoRouter;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();

    mockGoRouter = MockGoRouter();
  });

  testWidgets('ErrorView displays generic error message correctly', (
    tester,
  ) async {
    final testError = Exception('Something went wrong!');
    final testStackTrace = StackTrace.current;

    await pumpErrorView(
      tester,
      error: testError,
      stackTrace: testStackTrace,
      mockGoRouter: mockGoRouter,
    );

    // Verify the generic error message is displayed
    expect(find.text(testError.toString()), findsOneWidget);

    // Verify the "User not authenticated" message and login button are NOT present
    expect(find.text('User not authenticated (Mock)'), findsNothing);
    expect(find.byKey(const ValueKey('ic_login_logout')), findsNothing);

    // Verify Expanded widgets are present (implicitly tested by finding content)
    expect(
      find.byType(Expanded),
      findsOneWidget,
    ); // The single Expanded wrapping the error text
  });

  testWidgets(
    'ErrorView displays "User not authenticated" message for null error',
    (tester) async {
      await pumpErrorView(
        tester,
        error: null,
        stackTrace: null,
        mockGoRouter: mockGoRouter,
      );

      // Verify the "User not authenticated" message is displayed
      expect(find.text('User not authenticated (Mock)'), findsOneWidget);

      // Verify the login icon button is present
      expect(find.byKey(const ValueKey('ic_login')), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);

      // Verify the generic error text is NOT present
      expect(find.textContaining('Exception'), findsNothing);

      // Verify Expanded widgets are present
      expect(
        find.byType(Expanded),
        findsNWidgets(2),
      ); // Two Expanded widgets in this case
    },
  );

  testWidgets(
    'ErrorView displays "User not authenticated" message for permission-denied error',
    (tester) async {
      final permissionDeniedError = FirebaseException(
        plugin: 'test',
        code: 'permission-denied',
        message: 'Permission denied',
      );
      final testStackTrace = StackTrace.current;

      await pumpErrorView(
        tester,
        error: permissionDeniedError,
        stackTrace: testStackTrace,
        mockGoRouter: mockGoRouter,
      );

      // Verify the "User not authenticated" message is displayed
      expect(find.text('User not authenticated (Mock)'), findsOneWidget);

      // Verify the login icon button is present
      expect(find.byKey(const ValueKey('ic_login')), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);

      // Verify the specific FirebaseException message is NOT displayed
      expect(find.text(permissionDeniedError.toString()), findsNothing);

      // Verify Expanded widgets are present
      expect(find.byType(Expanded), findsNWidgets(2));
    },
  );

  testWidgets('ErrorView navigates to auth-sign-in on login button press', (
    tester,
  ) async {
    when(mockGoRouter.pushNamed(any)).thenAnswer((_) async => true);

    await pumpErrorView(
      tester,
      error: null,
      stackTrace: null,
      mockGoRouter: mockGoRouter,
    );

    // Find the login button
    final loginButtonFinder = find.byKey(const ValueKey('ic_login'));
    expect(loginButtonFinder, findsOneWidget);

    // Tap the login button
    await tester.tap(loginButtonFinder);
    await tester.pumpAndSettle(); // Allow navigation to process

    // Verify that GoRouter.pushNamed was called with the correct route name
    verify(mockGoRouter.pushNamed(AuthRouterName.signIn.name)).called(1);
  });

  testWidgets('ErrorView applies correct style to error messages', (
    tester,
  ) async {
    final testError = Exception('Style Test Error');
    await pumpErrorView(
      tester,
      error: testError,
      stackTrace: StackTrace.current,
      mockGoRouter: mockGoRouter,
    );

    final textWidget = tester.widget<Text>(find.text(testError.toString()));
    final context = tester.element(
      find.text(testError.toString()),
    ); // Get context

    // Check if the style matches the expected style from the widget
    expect(
      textWidget.style?.color,
      ThemeViewModel.instance().colorScheme.onError,
    );
    expect(
      textWidget.style?.fontSize,
      Theme.of(context).textTheme.headlineMedium?.fontSize,
    );

    // Test the style for the "not authenticated" case
    await pumpErrorView(
      tester,
      error: null,
      stackTrace: null,
      mockGoRouter: mockGoRouter,
    );
    final authTextWidget = tester.widget<Text>(
      find.text('User not authenticated (Mock)'),
    );

    expect(
      authTextWidget.style?.color,
      ThemeViewModel.instance().colorScheme.onError,
    );
  });
}
