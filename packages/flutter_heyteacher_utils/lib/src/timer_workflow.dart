import 'dart:async';
import 'package:flutter/widgets.dart';

/// Manages a sequential workflow of timed tasks.
///
/// This abstract class provides the core logic for running a series of tasks,
/// each with a specific duration. It handles the state management for playing,
/// pausing, stopping, and skipping tasks.
///
/// Subclasses must implement the [setTasks] method to define the specific
/// sequence of tasks for the workflow.
///
/// The workflow's progress can be monitored by listening to the [stream], which
/// emits the current task and its remaining time every second.
///
/// Example:
/// ```dart
/// class MyWorkflow extends TimerWorkflow<TimerTask> {
///   @override
///   void setTasks() {
///     tasks = [
///       TimerTask(name: 'Step 1', description: 'First step', duration: Duration(seconds: 10)),
///       TimerTask(name: 'Step 2', description: 'Second step', duration: Duration(seconds: 20)),
///     ];
///   }
/// }
/// ```
abstract class TimerWorkflow<T extends TimerTask> {
  /// The list of tasks to be executed in the workflow.
  ///
  /// This list should be populated by the [setTasks] method in a subclass.
  @visibleForTesting
  @protected
  List<T> tasks = [];

  bool _paused = false;
  int _pausedTick = 0;
  int _completedTick = 0;
  Timer? _subscription;

  final StreamController<({T? currentTask, int remainingSeconds})>
      _streamController = StreamController.broadcast();

  /// A stream that emits the state of the workflow every second.
  ///
  /// Each event contains the [currentTask] and the [remainingSeconds] for that task.
  /// When the workflow is completed, the [currentTask] will be null and [remainingSeconds] will be 0.
  Stream<({T? currentTask, int remainingSeconds})> get stream =>
      _streamController.stream;

  /// Returns `true` if all tasks in the workflow have been completed.
  bool get isCompleted => _currentTask == null;

  /// Disposes of the resources used by the workflow.
  ///
  /// This should be called when the workflow is no longer needed to prevent
  /// memory leaks from the [Timer] and [StreamController].
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _streamController.close();
  }

  /// Abstract method for subclasses to define the list of tasks for the workflow.
  void setTasks();

  /// Starts or resumes the workflow.
  ///
  /// If the workflow is paused, it will resume from where it left off.
  /// If it's stopped or has not started, it will begin from the first task.
  void play() {
    _paused = false;
    _subscription ??= Timer.periodic(const Duration(seconds: 1), _execute);
  }

  /// Pauses the currently running workflow.
  ///
  /// The timer will stop ticking, but the internal state is preserved.
  /// Use [play] to resume.
  void pause() {
    _paused = true;
  }

  /// Stops the workflow and resets its state to the beginning.
  ///
  /// All tasks are marked as incomplete, and the internal timer is cancelled.
  void stop() {
    _subscription?.cancel();
    _subscription = null;
    _paused = false;
    _pausedTick = 0;
    _completedTick = 0;
    tasks.forEach(_reopenTask);
  }

  /// Restarts the workflow from the beginning.
  ///
  /// This is a convenience method equivalent to calling [stop] then [play].
  void replay() {
    stop();
    play();
  }

  /// Skips the remainder of the current task and moves to the next one.
  void skip() {
    final currentTask = _currentTask;
    _completedTick += currentTask?.duration.inSeconds ?? 0;
    currentTask?.completed = true;
  }

  void _execute(Timer timer) {
    final currentTask = _currentTask;
    int remainingSeconds = currentTask != null
        ? currentTask.duration.inSeconds -
            (timer.tick - _completedTick - _pausedTick)
        : 0;
    if (currentTask == null) {
      // all task completed
      stop();
    } else if (_paused) {
      // current task not null in pause
      _pausedTick++;
      return;
    } else if (remainingSeconds <= 0) {
      // current task running and remaining second
      _completedTick += currentTask.duration.inSeconds;
      currentTask.completed = true;
    }
    // yield the current task and the remaining second
    _streamController.add((
      currentTask: currentTask,
      remainingSeconds: remainingSeconds,
    ));
  }

  T? get _currentTask => tasks.where(_isNotCompletedTask).firstOrNull;

  bool _isNotCompletedTask(T task) => !task.completed;

  void _reopenTask(T task) => task.completed = false;
}

/// Represents a single, timed task within a [TimerWorkflow].
///
/// This is a base class that holds the essential properties of a task,
/// such as its name, description, duration, and completion status.
class TimerTask {
  /// The name of the task.
  final String name;

  /// A description of the task.
  final String description;

  /// Whether the task has been completed.
  bool completed;

  /// The total duration of the task.
  final Duration duration;

  /// Creates a new [TimerTask].
  TimerTask({
    required this.name,
    required this.description,
    required this.duration,
    this.completed = false,
  });
}