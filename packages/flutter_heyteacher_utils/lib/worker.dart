library;
/// A library for creating and managing long-running isolates.
///
/// This library provides the [Worker] class, an abstraction for offloading
/// computationally intensive tasks to a background isolate, thus keeping the
/// main UI thread responsive.

export 'src/worker.dart' show Worker, WorkerIsolate;