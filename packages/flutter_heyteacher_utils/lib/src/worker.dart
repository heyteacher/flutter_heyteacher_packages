import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

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
  late SendPort _commands;
  late ReceivePort _responses;
  final Map<int, Completer<O>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;
  late String _debugName;

  /// Spawns a new isolate and sets up communication channels.
  ///
  /// This must be called before [execute].
  /// The [debugName] is used for logging and debugging purposes.
  Future<void> spawn(String debugName) async {
    _debugName = debugName;
    log('<$_debugName.spawn>');
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
      await Isolate.spawn(
          _startRemoteIsolate, (initPort.sendPort, rootIsolateToken), debugName: debugName);
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;
    _commands = sendPort;
    _responses = receivePort;
    _responses.listen(_handleResponsesFromIsolate);
  }

  /// Executes a task in the background isolate.
  ///
  /// Sends the [input] data to the isolate and returns a [Future] that
  /// completes with the result.
  /// Throws a [StateError] if the worker is already closed.
  Future<O> execute(I input) async {
    if (_closed) throw StateError('($_debugName.execute): $input. Closed');
    final completer = Completer<O>.sync();
    final id = _idCounter++;
    _activeRequests[id] = completer;
    _commands.send((id, input));
    return await completer.future;
  }

  /// Shuts down the isolate and closes communication ports.
  ///
  /// After calling this, [execute] will throw a [StateError].
  /// It's safe to call this method multiple times.
  void close() {
    log('<$_debugName.close>:');
    if (!_closed) {
      _closed = true;
      _commands.send('shutdown');
      if (_activeRequests.isEmpty) _responses.close();
      log('<$_debugName.close>: succesfully closed');
    }
  }

  /// The callback method that is executed in the background isolate.
  ///
  /// Subclasses must override this method to perform the desired work.
  @protected
  Future<O> executeCallback(I input);

  void _handleResponsesFromIsolate(dynamic message) {
    final (int id, O response) = message as (int, O);
    final completer = _activeRequests.remove(id)!;

    if (response is RemoteError) {
      completer.completeError(response);
    } else {
      completer.complete(response);
    }

    if (_closed && _activeRequests.isEmpty) _responses.close();
  }

  void _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
  ) {
    receivePort.listen((message) async {
      if (message == 'shutdown') {
        receivePort.close();
        return;
      }
      try {
        final (int id, I input) = message as (int, I);
        sendPort.send((id, await executeCallback(input)));
      } catch (error, stackTrace) {
        log('($_debugName._handleCommandsToIsolate): '
              'error $error stackTrace $stackTrace');
        
      }
    });
  }

  void _startRemoteIsolate(
      (SendPort sendPort, RootIsolateToken rootIsolateToken) message) {
    final (SendPort sendPort, RootIsolateToken rootIsolateToken) = message;
    BackgroundIsolateBinaryMessenger.ensureInitialized(rootIsolateToken);
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(receivePort, sendPort);
  }
}
