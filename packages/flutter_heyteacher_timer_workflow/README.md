# Flutter Heyteacher Timer Workflow

This package provides functionalities to manage timer-based workflows for the Heyteacher project.

## Features

This package exports the following modules via `timer_workflow.dart`:

- **Workflow Management**:
  - `TimerWorkflow`: The core class for managing the lifecycle of a timer workflow.
  - `WorkflowStatus`: Defines the current state of the workflow.
- **Tasks**:
  - `TimerTask`: Represents a specific task definition within the workflow.
  - `RunningTask`: Represents an active instance of a task.
- **Localization**: `FlutterHeyteacherTimerWorkflowLocalizations` provides localized strings for workflow-related UI.
- **Error Handling**:
  - `WorkflowTaskAlreadyInitialized`
  - `WorkflowTaskNotInitialized`

The action available on a workflow are:

- `start()`: start the workflow
- `stop()`: stop the workflow
- `pause()`: pause the workflow
- `restart()`: restart the workflow
- `next()`: go to the next task

The stream of the workflow is a [Stream<RunningTask<T>>] is emitting every
second with running task data:

- `workflowName`: the name of the workflow
- `status`: the current status of the workflow
- `current`: the current task
- `next`: the next task
- `changed`: if the task has just changed
- `taskElapsedTime`: the elapsed time of the current task
- `totalElapsedTime`: the total elapsed time of completed tasks

## Usage

Define your workflow by extending `TimerWorkflow<T>`:

```dart
class MyWorkflow extends TimerWorkflow<MyTask> {
  @override
  String get name => 'My Workflow';

  @override
  void initializeTasks() => tasks.addAll([
    MyTask(
      name: 'Task 1',
      description: 'First Task',
      duration: const Duration(seconds: 10),
    ),
    MyTask(
      name: 'Task 2',
      description: 'Second Task',
      duration: const Duration(seconds: 20),
    ),
    MyTask(
      name: 'Task 3',
      description: 'Third Task',
      duration: const Duration(seconds: 15),
    ),
  ]);
}
```

Define your task by extending `TimerTask`:

```dart
class MyTask extends TimerTask {
  const MyTask({
    required super.name,
    required super.description,
    required super.duration,
  });
}
```

Start the workflow:

```dart
_workflow.start();
```

Listen to the workflow changes:

```dart
_workflow.stream.listen((runningTask) {
  if (runningTask.changed) {
    print('Task ${runningTask.current?.name} completed');
    if (runningTask.next != null) {
      print('Task ${runningTask.next?.name} started');
    } else {
      print('All done');
    }
  }
});
```

A complete app example can be found in [example](example)
