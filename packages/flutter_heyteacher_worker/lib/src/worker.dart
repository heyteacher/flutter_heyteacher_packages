import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';
import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// The Isolate worker type.
typedef _WorkerIsolate<I, O> = Future<O> Function(I input);

/// An abstract class for creating a long-running isolate that can handle
/// multiple requests.
///
/// This class provides a simple way to offload computation to a background
/// isolate, preventing the UI from freezing.
///
/// ### Example
///
/// ```dart
/// class MyWorkerIsolate extends WorkerIsolate<String, int> {
///   @override
///   Future<int> executeCallback(String input) async {
///     // Perform some heavy computation
///     return input.length;
///   }
/// }
///
/// // In your application code (e.g., inside an async function):
/// final myWorker = Worker(MyWorkerIsolate());
/// final result = await myWorker.execute('hello');
/// print(result); // 5
/// worker.close();
/// ```
final class Worker<I, O> {
  /// Create a [Worker] instance with function [_workerIsolate] to be executed
  /// in isolete
  Worker(this._workerIsolate);
  static final Logger _logger = Logger('Worker');

  final _WorkerIsolate<I, O> _workerIsolate;

  SendPort? _sendPort;
  ReceivePort? _receivePort;
  final Map<int, Completer<({O? output, String? error, String? stackTrace})>>
  _completers = {};
  int _idCounter = 0;
  bool _closed = false;

  /// Initializes worker.
  ///
  /// Only if not web and not flutter tests.
  Future<void> initialize() async {
    if (_sendPort == null &&
        !kIsWeb &&
        !Platform.environment.containsKey('FLUTTER_TEST')) {
      _logger.finest(
        '(${_workerIsolate.runtimeType}.initialize): _sendPort is null and '
        'not web or flutter test, spawn',
      );
      await _spawn();
    }
  }

  /// Executes a task in the background isolate.
  ///
  /// Sends the [input] data to the isolate and returns a [Future] that
  /// completes with the result.
  /// Throws a [StateError] if the worker is already closed.
  Future<({O? output, String? error, String? stackTrace})> execute(
    I input,
  ) async {
    try {
      if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) {
        debugPrint(
          '(${_workerIsolate.runtimeType}.execute): plaftorm web '
          'or unit test, execute in main thread, not in Isolate',
        );
        return (
          output: await _workerIsolate.call(input),
          error: null,
          stackTrace: null,
        );
      }
      await initialize();
      if (_closed) {
        throw StateError(
          '(${_workerIsolate.runtimeType}.execute): $input. Closed',
        );
      }
      final completer =
          Completer<({O? output, String? error, String? stackTrace})>.sync();
      final id = _idCounter++;
      _completers[id] = completer;
      _sendPort?.send((id, input));
      return await completer.future;
    } on Exception catch (error, stackTrace) {
      return (
        output: null,
        error: error.toString(),
        stackTrace: stackTrace.toString(),
      );
    }
  }

  /// Shuts down the isolate and closes communication ports.
  ///
  /// After calling this, [execute] will throw a [StateError].
  /// It's safe to call this method multiple times.
  void close() {
    _logger.finer('<${_workerIsolate.runtimeType}.close>:');
    if (!_closed) {
      _closed = true;
      _sendPort?.send('shutdown');
      if (_completers.isEmpty) _receivePort?.close();
      _logger.finer(
        '(${_workerIsolate.runtimeType}.close): succesfully closed',
      );
    }
  }

  /// Spawns a new isolate and sets up communication channels.
  ///
  /// This must be called before [execute].
  Future<void> _spawn() async {
    _logger.finer('<${_workerIsolate.runtimeType}._spawn>:');
    final rootIsolateToken = RootIsolateToken.instance;
    if (rootIsolateToken == null) {
      _logger.severe(
        '(${_workerIsolate.runtimeType}._spawn): '
        'Cannot get the RootIsolateToken',
      );
      throw Exception(
        'Cannot get the RootIsolateToken in ${_workerIsolate.runtimeType}',
      );
    }
    // Create a receive port and add its initial message handler.
    final rawReceivePort = RawReceivePort();
    // Spawn the isolate.
    final completer = Completer<(ReceivePort, SendPort)>.sync();
    // without type, sendPort cannot be inferred
    // ignore: avoid_types_on_closure_parameters
    rawReceivePort.handler = (SendPort sendPort) {
      completer.complete((
        ReceivePort.fromRawReceivePort(rawReceivePort),
        sendPort,
      ));
    };
    try {
      // Spawn the isolate.
      await Isolate.spawn(_startRemoteIsolate, (
        sendPort: rawReceivePort.sendPort,
        rootIsolateToken: rootIsolateToken,
        workerIsolate: _workerIsolate,
      ), debugName: _workerIsolate.runtimeType.toString());
    } catch (error, stackTrace) {
      _logger.severe(
        '(${_workerIsolate.runtimeType}._spawn): error $error '
        'stackTrace $stackTrace',
      );
      completer.completeError(error, stackTrace);
      rawReceivePort.close();
      rethrow;
    }
    final (ReceivePort receivePort, SendPort sendPort) = await completer.future;
    _sendPort = sendPort;
    _receivePort = receivePort;
    receivePort.listen(_handleResponsesFromIsolate);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    _logger.finer(
      '<${_workerIsolate.runtimeType}._handleResponsesFromIsolate>:',
    );
    final (int id, dynamic response) = message as (int, dynamic);
    final completer = _completers.remove(id)!;
    if (response is RemoteError) {
      _logger.finer(
        '(${_workerIsolate.runtimeType}._handleResponsesFromIsolate): '
        'id $id completed with error $response',
      );
      completer.completeError(response, response.stackTrace);
    } else {
      _logger.finer(
        '(${_workerIsolate.runtimeType}._handleResponsesFromIsolate): '
        'id $id completed with success',
      );
      completer.complete(
        response as ({O? output, String? error, String? stackTrace}),
      );
    }
    if (_closed && _completers.isEmpty) {
      _logger.finer(
        '(${_workerIsolate.runtimeType}._handleResponsesFromIsolate): '
        'worker is closed and completers is empty, close the receive port',
      );
      _receivePort?.close();
    }
  }

  static void _startRemoteIsolate(
    ({
      SendPort sendPort,
      RootIsolateToken rootIsolateToken,
      Function workerIsolate,
    })
    message,
  ) {
    BackgroundIsolateBinaryMessenger.ensureInitialized(
      message.rootIsolateToken,
    );
    final receivePort = ReceivePort();
    message.sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(
      receivePort,
      message.sendPort,
      message.workerIsolate,
    );
  }

  static void _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
    Function workerIsolate,
  ) {
    receivePort.listen((message) async {
      if (message == 'shutdown') {
        receivePort.close();
        return;
      }
      final (int id, dynamic input) = message as (int, dynamic);
      try {
        sendPort.send((
          id,
          (
            //
            // ignore: avoid_dynamic_calls
            output: await workerIsolate.call(input),
            error: null,
            stackTrace: null,
          ),
        ));
      } on Exception catch (error, stackTrace) {
        log(
          'flutter (): ${clock.now().toIso8601String()}: '
          '(_handleCommandsToIsolate): error $error stackTrace $stackTrace',
        );
        sendPort.send((
          id,
          (
            output: null,
            error: error.toString(),
            stackTrace: stackTrace.toString(),
          ),
        ));
      }
    });
  }
}
