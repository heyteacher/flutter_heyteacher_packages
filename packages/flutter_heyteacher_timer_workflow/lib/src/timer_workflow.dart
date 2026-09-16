import 'dart:async';

import 'package:flutter_heyteacher_timer_workflow/src/exceptions.dart';
import 'package:flutter_heyteacher_timer_workflow/src/timer_workflow_data.dart';

/// Manages a sequential workflow of timed tasks.
///
/// This abstract class provides the core logic for running a series of tasks,
/// each with a specific duration. It handles the state management for playing,
/// pausing, stopping, and skipping tasks.
///
/// Subclasses must implement the [initializeTasks] method to define the
/// specific sequence of tasks for the workflow.
///
/// The workflow's progress can be monitored by listening to the [stream], which
/// emits a [RunningTask] object every second. This object contains the current
/// state of the workflow, including the current task, the next task, and
/// remaining times.
///
/// Example:
/// ```dart
/// class MyTask extends TimerTask {
///   MyTask({required super.name, required super.description,
///         required super.duration});
/// }
///
/// class MyWorkflow extends TimerWorkflow<MyTask> {
///   @override
///   String get name => 'My Custom Workflow';
///
///   @override
///   void initializeTasks() {
///     tasks.addAll([
///       MyTask(name: 'Step 1', description: 'First step',
///        duration: Duration(seconds: 10)),
///       MyTask(name: 'Step 2', description: 'Second step',
///        duration: Duration(seconds: 20)),
///     ]);
///   }
/// }
/// ```
class TimerWorkflow<T extends TimerTask> {
  /// Initializes the workflow by calling [initializeTasks].
  TimerWorkflow({this._name}) {
    initializeTasks();
  }

  /// Disposes of the resources used by the workflow.
  ///
  /// This should be called when the workflow is no longer needed to prevent
  /// memory leaks from the [Timer] and [StreamController].
  void dispose() {
    _timer?.cancel();
    _timer = null;
    unawaited(_streamController.close());
  }

  /// The list of tasks to be executed in the workflow.
  ///
  /// This list should be populated within the [initializeTasks] method in a
  /// subclass.
  final List<T> _tasks = [];

  final String? _name;

  bool _paused = false;

  /// The elapsed time for the current task.
  Duration _completedDuration = Duration.zero;

  /// The timer that drives the workflow execution.
  Timer? _timer;

  /// The stream controller that manages the workflow's state stream.
  final StreamController<RunningTask<T>> _streamController =
      StreamController.broadcast();

  /// A stream that emits the state of the workflow every second.
  ///
  /// Each event is a [RunningTask] object containing the current state,
  /// including the current task, next task, and remaining times.
  Stream<RunningTask<T>> get stream => _streamController.stream;

  /// The name of the workflow.
  String get name => _name ?? '';

  /// Returns an unmodifiable view of the tasks in the workflow.
  List<T> get tasks => _tasks;

  /// Returns `true` if all tasks in the workflow have been completed.
  bool get isCompleted => _currentTask == null;

  /// The current status of the workflow.
  WorkflowStatus get status => _timer == null
      ? WorkflowStatus.stopped
      : _paused
      ? WorkflowStatus.paused
      : WorkflowStatus.started;

  /// Gets the current state of the workflow.
  ///
  /// The current state in composed by the index and elapsed time of current
  /// task, first state not completed.
  ({int index, Duration elapsedTime}) get currentState => (
    index: _tasks.where((task) => task.completed).length,
    elapsedTime: (_currentTask?.duration ?? Duration.zero) - _completedDuration,
  );

  /// The total duration of all tasks in the workflow.
  Duration get totalDuration =>
      _tasks.map((task) => task.duration).reduce((a, b) => a + b);

  /// The total number of tasks in the workflow.
  int get tasksCount => _tasks.length;

  /// The number of completed tasks.
  int get completedTaskCount => _tasks.where((task) => task.completed).length;

  /// Initializes the tasks for the workflow.
  ///
  /// Subclasses should override this method to populate the [tasks] list.
  /// This base implementation ensures that tasks are not initialized more
  /// than once.
  void initializeTasks() {
    if (_tasks.isNotEmpty) {
      throw WorkflowTaskAlreadyInitialized();
    }
  }

  /// Starts or resumes the workflow.
  ///
  /// If the workflow is paused, it will resume from where it left off.
  /// If it's stopped or has not started, it will begin from the first task.
  /// Throws a [WorkflowTaskNotInitialized] if the [tasks] list is empty.
  void start({({int index, Duration elapsedTime})? currentState}) {
    if (_tasks.isEmpty) {
      throw WorkflowTaskNotInitialized();
    }
    _paused = false;
    if (currentState != null) {
      _restore(currentState);
    }
    _timer ??= Timer.periodic(const Duration(seconds: 1), _execute);
    _execute(null);
  }

  /// Pauses the currently running workflow.
  ///
  /// The timer will stop ticking, but the internal state is preserved.
  /// Use [start] to resume.
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
    _completedDuration = Duration.zero;
    _tasks.forEach(_reopenTask);
    _streamController.sink.add(
      RunningTask(
        workflowName: name,
        status: WorkflowStatus.stopped,
        current: null,
        next: null,
        changed: false,
        taskElapsedTime: Duration.zero,
        totalElapsedTime: Duration.zero,
      ),
    );
  }

  /// Restarts the workflow from the beginning.
  ///
  /// This is a convenience method equivalent to calling [stop] then [start].
  void restart() {
    stop();
    start();
  }

  /// Moves to the next task.
  void next() {
    final currentTask = _currentTask;
    _completedDuration = Duration.zero;
    currentTask?.completed = true;
  }

  /// Restores the workflow to a specific state.
  ///
  /// This method is useful for resuming a workflow that was previously saved.
  /// It marks all tasks up to [currentState] index as completed and sets the
  /// elapsed time for the current task.
  ///
  /// - [currentState]: The current state in composed by the `index` and
  ///   `elapsedTime`  of the current task, the first state not
  ///   completed.
  void _restore(({int index, Duration elapsedTime}) currentState) {
    for (var i = 0; i < currentState.index; i++) {
      next();
    }
    _completedDuration =
        (_currentTask?.duration ?? Duration.zero) - currentState.elapsedTime;
  }

  /// The main execution loop of the workflow, called by the timer every second.
  ///
  /// This method updates the task progress, handles task completion, and emits
  /// the new state to the [stream].
  void _execute(Timer? timer) {
    final currentTask = _currentTask;
    final nextTask = _nextTask;
    var changed = false;
    if (currentTask == null) {
      // all task completed
      stop();
      return;
    } else if (!_paused && timer != null /*first run skip*/ ) {
      // current task running and remaining second
      _completedDuration += const Duration(seconds: 1);
      if (currentTask.duration - _completedDuration <= Duration.zero) {
        // current task finished, mask as completed and reset current
        // task counter
        _completedDuration = Duration.zero;
        changed = true;
        currentTask.completed = true;
        if (isCompleted) {
          // all tasks completed
          stop();
        }
      }
    }
    // yield the current task and the remaining second
    _streamController.sink.add(
      RunningTask(
        workflowName: name,
        status: status,
        current: currentTask,
        next: nextTask,
        changed: changed,
        taskElapsedTime: isCompleted
            ? Duration.zero
            : currentTask.duration - _completedDuration,
        totalElapsedTime:
            totalDuration - _totalCompletedDuration - _completedDuration,
      ),
    );
  }

  /// Gets the current active task (the first one not marked as completed).
  T? get _currentTask => _tasks.where(_isNotCompletedTask).firstOrNull;

  /// Gets the next task in the sequence.
  T? get _nextTask => _tasks.where(_isNotCompletedTask).skip(1).firstOrNull;

  /// A predicate to check if a task is not completed.
  bool _isNotCompletedTask(T task) => !task.completed;

  /// Resets the completion status of a task.
  void _reopenTask(T task) => task.completed = false;

  /// The total elapsed time of completed tasks.
  Duration get _totalCompletedDuration => _tasks
      .where((task) => task.completed)
      .map((task) => task.duration)
      .fold(Duration.zero, (a, b) => a + b);
}
