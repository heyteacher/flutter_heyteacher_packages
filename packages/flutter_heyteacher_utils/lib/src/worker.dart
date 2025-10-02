import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_heyteacher_utils/src/firebase/remote_config.dart';

/// An abstract class for creating a long-running isolate that can handle
/// multiple requests.
///
/// This class provides a simple way to offload computation to a background
/// isolate, preventing the UI from freezing. Subclasses must implement the
/// [executeCallback] method, which contains the logic to be executed in the
/// background.
///
/// ### Example
///
/// ```dart
/// class MyWorker extends Worker<String, int> {
///   @override
///   Future<int> executeCallback(String input) async {
///     // Perform some heavy computation
///     return input.length;
///   }
/// }
///
/// // In your application code (e.g., inside an async function):
/// final worker = MyWorker();
/// await worker.spawn('MyWorker');
/// final result = await worker.execute('hello');
/// print(result); // 5
/// worker.close();
/// ```
abstract class Worker<I, O> {
  SendPort? _commands;
  ReceivePort? _responses;
  final Map<
    int,
    Completer<({O? output, Object? error, StackTrace? stackTrace})>
  >
  _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;

  // Initializes worker
  Future<void> initialize() async {
    //log('flutter (): ${clock.now().toIso8601String()}: flutter () '
    //'<$debugName.initialize>:');
    if (_commands == null &&
        !(await RemoteConfigViewModel.instance.execWorkerInIsolate)) {
      log(
        'flutter (): ${clock.now().toIso8601String()}: flutter () '
        '($debugName.initialize): _commands is null and execWorkerInIsolate is true, spawn',
      );
      await _spawn();
    }
  }

  /// The callback method that is executed in the background isolate.
  ///
  /// Subclasses must override this method to perform the desired work.
  @protected
  Future<O> executeCallback(I input);

  /// the debug name for debug purpose
  @protected
  String get debugName;

  /// Executes a task in the background isolate.
  ///
  /// Sends the [input] data to the isolate and returns a [Future] that
  /// completes with the result.
  /// Throws a [StateError] if the worker is already closed.
  Future<({O? output, Object? error, StackTrace? stackTrace})> execute(
    I input,
  ) async {
    //log('flutter (): ${clock.now().toIso8601String()}: flutter () '
    //'<$debugName.execute>:');
    try {
      if (await RemoteConfigViewModel.instance.execWorkerInIsolate) {
        return (
          output: await executeCallback(input),
          error: null,
          stackTrace: null,
        );
      }
      await initialize();
      if (_closed) throw StateError('($debugName.execute): $input. Closed');
      final completer =
          Completer<
            ({O? output, Object? error, StackTrace? stackTrace})
          >.sync();
      final id = _idCounter++;
      _activeRequests[id] = completer;
      _commands!.send((id, input));
      return await completer.future;
    } catch (error, stackTrace) {
      return (output: null, error: error, stackTrace: stackTrace);
    }
  }

  /// Shuts down the isolate and closes communication ports.
  ///
  /// After calling this, [execute] will throw a [StateError].
  /// It's safe to call this method multiple times.
  void close() {
    log(
      'flutter (): ${clock.now().toIso8601String()}: flutter () <$debugName.close>:',
    );
    if (!_closed) {
      _closed = true;
      _commands?.send('shutdown');
      if (_activeRequests.isEmpty) _responses?.close();
      log(
        'flutter (): ${clock.now().toIso8601String()}: <$debugName.close>: succesfully closed',
      );
    }
  }

  /// Spawns a new isolate and sets up communication channels.
  ///
  /// This must be called before [execute].
  Future<void> _spawn() async {
    log('flutter (): ${clock.now().toIso8601String()}: <$debugName.spawn>');
    RootIsolateToken? rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      throw Exception('($runtimeType.spawn): Cannot get the RootIsolateToken');
    }
    // Create a receive port and add its initial message handler.
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };
    // Spawn the isolate.
    try {
      await Isolate.spawn(_startRemoteIsolate, (
        initPort.sendPort,
        rootIsolateToken,
      ), debugName: debugName);
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;
    _commands = sendPort;
    _responses = receivePort;
    _responses!.listen(_handleResponsesFromIsolate);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    final (
      int id,
      ({O? output, Object? error, StackTrace? stackTrace}) response,
    ) = message as (int, ({O? output, Object? error, StackTrace? stackTrace}));
    final completer = _activeRequests.remove(id)!;

    if (response is RemoteError) {
      completer.completeError(response);
    } else {
      completer.complete(response);
    }

    if (_closed && _activeRequests.isEmpty) _responses?.close();
  }

  void _handleCommandsToIsolate(ReceivePort receivePort, SendPort sendPort) {
    receivePort.listen((message) async {
      if (message == 'shutdown') {
        receivePort.close();
        return;
      }
      final (int id, I input) = message as (int, I);
      try {
        sendPort.send((
          id,
          (output: await executeCallback(input), error: null, stackTrace: null),
        ));
      } catch (error, stackTrace) {
        sendPort.send((
          id,
          (output: null, error: error, stackTrace: stackTrace),
        ));
        log(
          'flutter (): ${clock.now().toIso8601String()}: ($debugName._handleCommandsToIsolate): error $error '
          'stackTrace $stackTrace',
        );
      }
    });
  }

  void _startRemoteIsolate(
    (SendPort sendPort, RootIsolateToken rootIsolateToken) message,
  ) {
    final (SendPort sendPort, RootIsolateToken rootIsolateToken) = message;
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(receivePort, sendPort);
  }
}
