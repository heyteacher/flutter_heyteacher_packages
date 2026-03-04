/// A library for creating and managing long-running isolates.
///
/// This library provides the [Worker] class, an abstraction for offloading
/// computationally intensive tasks to a background isolate, thus keeping the
/// main UI thread responsive.
library;

import 'package:flutter_heyteacher_utils/worker.dart';

export 'src/worker.dart' show Worker, WorkerIsolate;
