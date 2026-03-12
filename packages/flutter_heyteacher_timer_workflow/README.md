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

## Usage

Import the main library file to access the components:

```dart
import 'package:flutter_heyteacher_timer_workflow/timer_workflow.dart';
```
