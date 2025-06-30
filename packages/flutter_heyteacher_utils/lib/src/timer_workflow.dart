import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/locale.dart';

/// The workflow states
enum WorkflowStatus { started, stopped, paused }

/// Manages a sequential workflow of timed tasks.
///
/// This abstract class provides the core logic for running a series of tasks,
/// each with a specific duration. It handles the state management for playing,
/// pausing, stopping, and skipping tasks.
///
/// Subclasses must implement the [initializeTasks] method to define the specific
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
  /// This list should be populated by the [initializeTasks] method in a subclass.
  @visibleForTesting
  @protected
  List<T> tasks = [];

  String get name;

  bool _paused = false;
  int _currentTaskCompletedInMilliseconds = 0;
  Timer? _timer;

  TimerWorkflow() {
    initializeTasks();
  }

  final StreamController<RunningTask<T>> _streamController =
      StreamController.broadcast();

  /// A stream that emits the state of the workflow every second.
  ///
  /// Each event contains the [currentTask] and the [remainingSeconds] for that task.
  /// When the workflow is completed, the [currentTask] will be null and [remainingSeconds] will be 0.
  Stream<RunningTask<T>> get stream => _streamController.stream;

  /// Returns `true` if all tasks in the workflow have been completed.
  bool get isCompleted => _currentTask == null;

  /// Disposes of the resources used by the workflow.
  ///
  /// This should be called when the workflow is no longer needed to prevent
  /// memory leaks from the [Timer] and [StreamController].
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _streamController.close();
  }

  /// method for subclasses to define the list of tasks for the workflow.
  void initializeTasks() {
        if (tasks.isNotEmpty) {
      throw WorkflowTaskAlreadyInitialized();
    }
  }

  /// The current status of the workflow.
  WorkflowStatus get status => _timer == null
      ? WorkflowStatus.stopped
      : _paused
          ? WorkflowStatus.paused
          : WorkflowStatus.started;

  /// Starts or resumes the workflow.
  ///
  /// If the workflow is paused, it will resume from where it left off.
  /// If it's stopped or has not started, it will begin from the first task.
  void play() {
    if (tasks.isEmpty) {
      throw WorkflowTaskNotInitialized();
    }
    _paused = false;
    _timer ??= Timer.periodic(const Duration(milliseconds: 1000), _execute);
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
    _timer?.cancel();
    _timer = null;
    _paused = false;
    _currentTaskCompletedInMilliseconds = 0;
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
    _currentTaskCompletedInMilliseconds = 0;
    currentTask?.completed = true;
  }

  void _execute(Timer _) {
    final changed = _currentTaskCompletedInMilliseconds == 0;
    final currentTask = _currentTask;
    final nextTask = _nextTask;

    int remainingTaskMilliseconds = currentTask != null
        ? currentTask.duration.inMilliseconds -
            _currentTaskCompletedInMilliseconds
        : 0;
    int remainingTotalMilliseconds = totalDurationInMilliseconds -
        _totalCompletedTaskInMilliseconds -
        _currentTaskCompletedInMilliseconds;
    if (currentTask == null) {
      // all task completed
      stop();
    } else {
      if (remainingTaskMilliseconds <= 0) {
        // current task finished, mask as completed and reset current task counter
        _currentTaskCompletedInMilliseconds = 0;
        currentTask.completed = true;
      } else if (!_paused) {
        // current task running and remaining second
        _currentTaskCompletedInMilliseconds += 1000;
      }
    }
    // yield the current task and the remaining second
    _streamController.sink.add(RunningTask(
      workflowName: name,
      status: status,
      current: currentTask,
      next: nextTask,
      changed: changed,
      remainingTaskMilliseconds: remainingTaskMilliseconds,
      remainingTotalMilliseconds: remainingTotalMilliseconds,
    ));
  }

  T? get _currentTask => tasks.where(_isNotCompletedTask).firstOrNull;

  T? get _nextTask => tasks.where(_isNotCompletedTask).skip(1).firstOrNull;

  bool _isNotCompletedTask(T task) => !task.completed;

  void _reopenTask(T task) => task.completed = false;

  int get totalDurationInMilliseconds =>
      tasks.map((task) => task.duration.inMilliseconds).reduce((a, b) => a + b);

  int get _totalCompletedTaskInMilliseconds => tasks
      .where((task) => task.completed)
      .map((task) => task.duration.inMilliseconds)
      .fold(0, (a, b) => a + b);

  get taskCount => tasks.length;
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

class WorkflowTaskAlreadyInitialized implements Exception {
  /// Returns a localized error message.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .errorWorkflowTaskAlreadyInitialized;
    } else {
      return 'error: workflow task already initialized';
    }
  }
}


class WorkflowTaskNotInitialized implements Exception {
  /// Returns a localized error message.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherUtilsLocalizations.of(ContextHelper.context!)!
          .errorWorkflowNotInitialized;
    } else {
      return 'error: workflow not initialized';
    }
  }

}

class RunningTask<T extends TimerTask> {
  final String workflowName;
  final WorkflowStatus status;
  final T? current;
  final T? next;
  final int remainingTaskMilliseconds;
  final int remainingTotalMilliseconds;
  final bool changed;
  RunningTask(
      {required this.workflowName,
      required this.status,
      required this.current,
      required this.next,
      required this.changed,
      required this.remainingTaskMilliseconds,
      required this.remainingTotalMilliseconds});
}
