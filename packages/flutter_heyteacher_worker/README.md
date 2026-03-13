# Flutter Heyteacher Worker

This package provides a [generics](https://dart.dev/language/generics) `Worker<I,O>` class to run long-running tasks in a background isolate, preventing the UI from freezing. It simplifies the process of offloading computation from the main thread.

The implementation is based on [Robust ports example](https://dart.dev/language/isolates#robust-ports-example) described in [Dart Isolates](https://dart.dev/language/isolates) official documentation.

## Features

- **`Worker<I, O>`**: A [generics](https://dart.dev/language/generics) class that manages the lifecycle of a long-running isolate.

> [!IMPORTANT]
>The `Worker<I, O>` will not spawn a real isolate on the `web` plaftorm or during `Flutter tests`.
>
>**In `web` and `Flutter tests` environments, the task will be executed on the main thread instead**.

## Usage

Import the main library file to access the components:

```dart
import 'package:flutter_heyteacher_worker/worker.dart';
```

To use `Worker<I, O>`, you need to:

- define a top-level or static function that matches the signature `Future<O> function(I input)`
- pass it to the `Worker` constructor.

### Example

Here is a simple example of how to use the `Worker<I, O>` to perform a computation in a background isolate.

```dart
// 1. Define your worker logic as a top-level or static function.
// This function will be executed in the background isolate.
// `I` is the input type is `String` 
// `O` is the output type is `int`.
Future<int> calculateStringLength(String input) async {
  // Simulate a heavy computation
  await Future.delayed(const Duration(seconds: 1));
  return input.length;
}

Future<void> runWorker() async {
  final worker = Worker<String, int>(calculateStringLength);
  final result = await worker.execute('hello worker');

  print('Result from worker: ${result.output}'); // Result from worker: 12

  worker.close();
}
```
