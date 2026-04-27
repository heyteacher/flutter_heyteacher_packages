# flutter_heyteacher_text_to_speech

A Flutter package based on [flutter_tts](https://pub.dev/packages/flutter_tts) for managing `Text-to-Speech` (`TTS`) functionalities, specifically designed for the [Flutter HeyTeacher ecosystem](../../). This package provides view models for controlling TTS output and UI components for user settings.

## Features

- **TTS Management**: Control text-to-speech output using `TTSViewModel` with `Throttling / Threshold logic` logic
- **UI Components**: Ready-to-use widgets like `EnableTTSChoiceCard` for enabling/disabling TTS.
- **Localization**: Integrated localization support via `FlutterHeyteacherTextToSpeechLocalizations`.

The components in this packages are implemented following [`Model-View-ViewModel` (`MVVM`) architecture](https://codeberg.org/heyteacher/flutter_heyteacher_packages#model-view-viewmodel-mvvm-architecture) and [`Singleton` pattern](https://codeberg.org/heyteacher/flutter_heyteacher_packages#singleton-pattern).

## Getting started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_heyteacher_text_to_speech: any
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
  await TTSViewModel.instance().speak('Hello, welcome to HeyTeacher!', checkTTSThreshold: true);
}
```

### Throttling / Threshold logic

In order to avoid message repeats and overlaps, a threshold logic is implemented.

- speaks of same message are ignored regardless `thresholdInSeconds`  

  ```txt
  speak(Hello) yes -> speak(Hello) no -> await `thresholdInSeconds` seconds -> speak(Hello) no 
  ```

- speak of different message after `thresholdInSeconds` is passed

  ```txt
  speak(Hello) yes -> await `thresholdInSeconds` seconds -> speak(goodbye) yes 
  ```

- speak of message within `thresholdInSeconds` are delayed of `thresholdInSeconds` seconds

  ```txt
  speak(hello) yes -> speak(goodbye) -> await `thresholdInSeconds` seconds -> true
  ```

- speak of message within `thresholdInSeconds` only if last message changes

  ```txt
  'speak(hello) yes -> speak(hello) no -> speak(goodbye) -> await `thresholdInSeconds` seconds -> yes'
  'speak(hello) yes -> speak(goodbye) no -> speak(hello) no -> speak(goodbye) -> await `thresholdInSeconds` seconds -> yes'
  ```

Invoking `speak` setting parameter `checkTTSThreshold` to `false`, skip threshold logic and the text is always spoken.

```dart
  await TTSViewModel.instance().speak('Hello, welcome to HeyTeacher!', checkTTSThreshold: false); 
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
