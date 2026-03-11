# flutter_heyteacher_locale

A Flutter package for managing application locale, date/time formatting, and localization helpers, specifically designed for the Flutter HeyTeacher ecosystem.

## Features

- **Locale Management**: Centralized management of application locale using `LocaleViewModel`.
- **Persistence**: Automatically persists selected locale preferences using `shared_preferences`.
- **Formatting Utilities**: Extensive helpers in `FormatterHelper` for formatting dates, times, durations, and numbers based on the current locale.
- **Date Extensions**: `DateHelpers` extension on `DateTime` for relative day checks (Today, Yesterday, Tomorrow).
- **UI Widgets**: Pre-built widgets like `LocaleCard` and `LocaleWrap` for language selection.

## Getting started

Add the package and `flutter_localizations` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_locale: ^1.0.0
  flutter_localizations:
    sdk: flutter
```

## Usage

### Locale Management

Initialize the `LocaleViewModel` at the start of your application to load saved preferences.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/locale.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize with supported countries
  await LocaleViewModel.instance.initLocale(
    supportedCountries: [      
      'AR',
      'BR',
      'CA',
      'DE',
      'ES',
      'FR',
      'GB',
      'IT',
      'PT',
      'US',
    ],
  );

  runApp(const MyApp());
}
```

Configure your `MaterialApp` setting `localizationsDelegates`, `supportedLocales`, and `locale`.

Listen `LocaleViewModel.instance.localeStream` for `locale` changes:

```dart

/// This Widget is the main application widget.
class MyApp extends StatelessWidget {
  /// Creates the [MyApp].
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => StreamBuilder(
    stream: LocaleViewModel.instance.localeStream,
    builder: (context, localeAsyncSnapshot) {
      return MaterialApp(
        .
        .
        .
        .
        localizationsDelegates: const [
          FlutterHeyteacherLocaleLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: LocaleViewModel.instance.supportedLocales,
        locale: localeAsyncSnapshot.data,
      );
    },
  );
}
```

Access the current locale or listen to changes:

```dart
// Get current locale
Locale current = LocaleViewModel.instance.locale;

// Listen to changes
LocaleViewModel.instance.localeStream.listen((locale) {
  print('Locale changed to: $locale');
});

// Change locale (persists automatically)
LocaleViewModel.instance.locale = const Locale('it', 'IT');
```

### Formatting

Use `FormatterHelper` for consistent formatting across your app.

```dart
import 'package:flutter_heyteacher_locale/locale.dart';

final now = DateTime.now();

// Date and Time
print(FormatterHelper.dateFormat(now)); // e.g., 10/25/2023
print(FormatterHelper.timeFormat(now)); // e.g., 2:30 PM
print(FormatterHelper.dateTimeFormat(now)); // e.g., 10/25/2023 2:30 PM

// Numbers
print(FormatterHelper.doubleFormat(1234.56)); // e.g., 1,234.5

// Duration (Human readable)
print(FormatterHelper.formatDuration(3661000)); // e.g., 01:01:01 (hh:mm:ss)

// Duration for Text-to-Speech
// Returns a localized string like "1 hour 1 minute 1 second"
final ttsString = await FormatterHelper.formatDurationTts(
  const Duration(hours: 1, minutes: 30),
);
```
