import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_timer_workflow/src/timer_workflow.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';

/// Represents the possible states of a [TimerWorkflow].
enum WorkflowStatus {
  /// The workflow is actively running and progressing through tasks.
  started,

  /// The workflow is not running and is at its initial or reset state.
  stopped,

  /// The workflow is temporarily suspended and can be resumed.
  paused;

  /// The color associated with the workflow status.
  Color? get color {
    switch (this) {
      case WorkflowStatus.started:
        return ThemeViewModel.instance.greenColor;
      case WorkflowStatus.stopped:
        return ThemeViewModel.instance.redColor;
      case WorkflowStatus.paused:
        return ThemeViewModel.instance.amberColor;
    }
  }
}

/// Represents a single, timed task within a [TimerWorkflow].
///
/// This is a base class that holds the essential properties of a task,
/// such as its name, description, duration, and completion status.
/// Subclasses can extend this to add more specific properties to a task.
class TimerTask {
  /// Creates a new [TimerTask].
  TimerTask({
    required this.name,
    required this.description,
    required this.duration,
    this.completed = false,
  });

  /// The name of the task.
  final String name;

  /// A description of the task.
  final String description;

  /// Whether the task has been completed.
  bool completed;

  /// The total duration of the task.
  final Duration duration;
}

/// Represents the current state of a running [TimerWorkflow].
///
/// This object is emitted by the [TimerWorkflow.stream] every second and
/// provides
/// a snapshot of the workflow's progress.
class RunningTask<T extends TimerTask> {
  /// Creates a snapshot of the current workflow state.
  RunningTask({
    required this.workflowName,
    required this.status,
    required this.current,
    required this.next,
    required this.changed,
    required this.taskElapsedTime,
    required this.totalElapsedTime,
  });

  /// The name of the workflow.
  final String workflowName;

  /// The current status of the workflow ([WorkflowStatus.started],
  /// [WorkflowStatus.paused], or [WorkflowStatus.stopped]).
  final WorkflowStatus status;

  /// The task that is currently being executed. Can be `null` if the workflow
  /// has completed.
  final T? current;

  /// The next task in the sequence. Can be `null` if the current task is the
  /// last one.
  final T? next;

  /// The current task elapsed time.
  final Duration taskElapsedTime;

  /// The total elapsed time of completed tasks.
  final Duration totalElapsedTime;

  /// A flag indicating if the task has just changed in this tick.
  /// `true` on the first tick of a new task.
  final bool changed;

  @override
  String toString() =>
      'RunningTask(workflowName: "$workflowName", status: ${status.name}, '
      'current: $current, next: $next, changed: $changed, '
      'taskElapsedTime: $taskElapsedTime, '
      'totalElapsedTime: $totalElapsedTime)';
}
