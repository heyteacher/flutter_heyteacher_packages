# flutter_heyteacher_text_to_speech

A Flutter package for managing `Text-to-Speech` (`TTS`) functionalities, specifically designed for the [Flutter HeyTeacher ecosystem](../../). This package provides view models for controlling TTS output and UI components for user settings.

## Features

- **TTS Management**: Control text-to-speech output using `TTSViewModel`.
- **UI Components**: Ready-to-use widgets like `EnableTTSChoiceCard` for enabling/disabling TTS.
- **Localization**: Integrated localization support via `FlutterHeyteacherTextToSpeechLocalizations`.

The components in this packages are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.or/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_text_to_speech: ^2.0.4
```

## Usage

### Parameters

Configuration is set during `TTSViewModel.instance(bool? defaultEnabled, int? thresholdInSeconds)` initialization.

- `defaultEnabled`: if is enabled by default (`true` by default)
- `thresholdInSeconds`: the minimum interval in seconds between messages speaked (`5` by default)

### TTS Control

Use `TTSViewModel` to handle speech operations.

```dart
import 'package:flutter_heyteacher_text_to_speech/text_to_speech.dart';

void main() async {
  // Example: Speak a sentence
  await TTSViewModel.instance().speak('Hello, welcome to HeyTeacher!');
}
```

### UI Components

Use `EnableTTSChoiceCard` to allow users to toggle TTS settings within your application.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_text_to_speech/text_to_speech.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: EnableTTSChoiceCard(),
      ),
    );
  }
}
```
