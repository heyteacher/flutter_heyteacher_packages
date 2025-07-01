import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/locale.dart';

/// Represents the possible states of a [TimerWorkflow].
enum WorkflowStatus {
  /// The workflow is actively running and progressing through tasks.
  started,

  /// The workflow is not running and is at its initial or reset state.
  stopped,

  /// The workflow is temporarily suspended and can be resumed.
  paused,
}

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
/// emits a [RunningTask] object every second. This object contains the current
/// state of the workflow, including the current task, the next task, and
/// remaining times.
///
/// Example:
/// ```dart
/// class MyTask extends TimerTask {
///   MyTask({required super.name, required super.description, required super.duration});
/// }
///
/// class MyWorkflow extends TimerWorkflow<MyTask> {
///   @override
///   String get name => 'My Custom Workflow';
///
///   @override
///   void initializeTasks() {
///     tasks.addAll([
///       MyTask(name: 'Step 1', description: 'First step', duration: Duration(seconds: 10)),
///       MyTask(name: 'Step 2', description: 'Second step', duration: Duration(seconds: 20)),
///     ]);
///   }
/// }
/// ```
abstract class TimerWorkflow<T extends TimerTask> {
  /// The list of tasks to be executed in the workflow.
  ///
  /// This list should be populated within the [initializeTasks] method in a subclass.
  @visibleForTesting
  @protected
  List<T> tasks = [];

  String get name;

  bool _paused = false;

  /// The elapsed time in milliseconds for the current task.
  int _currentTaskCompletedInMilliseconds = 0;

  /// The timer that drives the workflow execution.
  Timer? _timer;

  /// Initializes the workflow by calling [initializeTasks].
  TimerWorkflow() {
    initializeTasks();
  }

  /// The stream controller that manages the workflow's state stream.
  final StreamController<RunningTask<T>> _streamController =
      StreamController.broadcast();

  /// A stream that emits the state of the workflow every second.
  ///
  /// Each event is a [RunningTask] object containing the current state,
  /// including the current task, next task, and remaining times.
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

  /// Initializes the tasks for the workflow.
  ///
  /// Subclasses should override this method to populate the [tasks] list.
  /// This base implementation ensures that tasks are not initialized more than once.
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
  /// Throws a [WorkflowTaskNotInitialized] if the [tasks] list is empty.
  void play({({int index, int completedInMilliseconds})? currentState}) {
    if (tasks.isEmpty) {
      throw WorkflowTaskNotInitialized();
    }
    _paused = false;
    if (currentState != null) {
      _restore(currentState);
    }
    _timer ??= Timer.periodic(const Duration(milliseconds: 1000), _execute);
    _execute(null);
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
    _streamController.sink.add(RunningTask(
      workflowName: name,
      status: WorkflowStatus.stopped,
      current: null,
      next: null,
      changed: true,
      remainingTaskMilliseconds: 0,
      remainingTotalMilliseconds: 0,
    ));
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

  /// Gets the current state of the workflow.
  ///
  /// The current state in composed by the index and milliseconds completed
  /// of the current task, first state not completed.
  ({int index, int completedInMilliseconds}) get currentState => (
        index: tasks.where((task) => task.completed).length,
        completedInMilliseconds: _currentTaskCompletedInMilliseconds
      );

  /// Restores the workflow to a specific state.
  ///
  /// This method is useful for resuming a workflow that was previously saved.
  /// It marks all tasks up to [currentState] index as completed and sets the
  /// elapsed time for the current task.
  ///
  /// - [currentState]: The current state in composed by the `index` and
  ///   `completedInMilliseconds`  of the current task, the first state not
  ///   completed.
  void _restore(({int index, int completedInMilliseconds}) currentState) {
    for (var i = 0; i < currentState.index; i++) {
      skip();
    }
    _currentTaskCompletedInMilliseconds = currentState.completedInMilliseconds;
  }

  /// The main execution loop of the workflow, called by the timer every second.
  ///
  /// This method updates the task progress, handles task completion, and emits
  /// the new state to the [stream].
  void _execute(Timer? timer) {
    final currentTask = _currentTask;
    bool changed = false;
    if (currentTask == null) {
      // all task completed
      stop();
      return;
    }
    int remainingTaskMilliseconds = currentTask.duration.inMilliseconds -
        _currentTaskCompletedInMilliseconds;
    if (remainingTaskMilliseconds <= 0) {
      // current task finished, mask as completed and reset current task counter
      _currentTaskCompletedInMilliseconds = 0;
      changed = true;
      currentTask.completed = true;
      remainingTaskMilliseconds = _currentTask?.duration.inMilliseconds ?? 0;
      if (isCompleted) {
        // all tasks completed
        stop();
        return;
      }
    } else if (!_paused && timer != null /*first run skip*/) {
      // current task running and remaining second
      _currentTaskCompletedInMilliseconds += 1000;
    }
    int remainingTotalMilliseconds = totalDurationInMilliseconds -
        _totalCompletedTaskInMilliseconds -
        _currentTaskCompletedInMilliseconds;
    // yield the current task and the remaining second
    _streamController.sink.add(RunningTask(
      workflowName: name,
      status: status,
      current: _currentTask,
      next: _nextTask,
      changed: changed,
      remainingTaskMilliseconds: remainingTaskMilliseconds,
      remainingTotalMilliseconds: remainingTotalMilliseconds,
    ));
  }

  /// Gets the current active task (the first one not marked as completed).
  T? get _currentTask => tasks.where(_isNotCompletedTask).firstOrNull;

  /// Gets the next task in the sequence.
  T? get _nextTask => tasks.where(_isNotCompletedTask).skip(1).firstOrNull;

  /// A predicate to check if a task is not completed.
  bool _isNotCompletedTask(T task) => !task.completed;

  /// Resets the completion status of a task.
  void _reopenTask(T task) => task.completed = false;

  /// The total duration of all tasks in the workflow, in milliseconds.
  int get totalDurationInMilliseconds =>
      tasks.map((task) => task.duration.inMilliseconds).reduce((a, b) => a + b);

  /// The total duration of all completed tasks, in milliseconds.
  int get _totalCompletedTaskInMilliseconds => tasks
      .where((task) => task.completed)
      .map((task) => task.duration.inMilliseconds)
      .fold(0, (a, b) => a + b);

  /// The total number of tasks in the workflow.
  get taskCount => tasks.length;
}

/// Represents a single, timed task within a [TimerWorkflow].
///
/// This is a base class that holds the essential properties of a task,
/// such as its name, description, duration, and completion status.
/// Subclasses can extend this to add more specific properties to a task.
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

/// An exception thrown when an attempt is made to initialize tasks in a
/// workflow that has already been initialized.
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

/// An exception thrown when an attempt is made to play a workflow that has
/// not been initialized with any tasks.
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

/// Represents the current state of a running [TimerWorkflow].
///
/// This object is emitted by the [TimerWorkflow.stream] every second and provides
/// a snapshot of the workflow's progress.
class RunningTask<T extends TimerTask> {
  /// The name of the workflow.
  final String workflowName;

  /// The current status of the workflow ([WorkflowStatus.started],
  /// [WorkflowStatus.paused], or [WorkflowStatus.stopped]).
  final WorkflowStatus status;

  /// The task that is currently being executed. Can be `null` if the workflow
  /// has completed.
  final T? current;

  /// The next task in the sequence. Can be `null` if the current task is the last one.
  final T? next;

  /// The remaining time for the current task, in milliseconds.
  final int remainingTaskMilliseconds;

  /// The total remaining time for the entire workflow, in milliseconds.
  final int remainingTotalMilliseconds;

  /// A flag indicating if the task has just changed in this tick.
  /// `true` on the first tick of a new task.
  final bool changed;

  /// Creates a snapshot of the current workflow state.
  RunningTask(
      {required this.workflowName,
      required this.status,
      required this.current,
      required this.next,
      required this.changed,
      required this.remainingTaskMilliseconds,
      required this.remainingTotalMilliseconds});
}
