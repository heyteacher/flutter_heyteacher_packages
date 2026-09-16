import 'package:flutter_heyteacher_platform/flutter_heyteacher_platform.dart';
import 'package:flutter_heyteacher_timer_workflow/src/l10n/flutter_heyteacher_timer_workflow.dart';

/// An exception thrown when an attempt is made to initialize tasks in a
/// workflow that has already been initialized.
class WorkflowTaskAlreadyInitialized implements Exception {
  /// Returns a localized error message.
  @override
  String toString() {
    if (ContextHelper.context != null) {
      return FlutterHeyteacherTimerWorkflowLocalizations.of(
        ContextHelper.context!,
      )!.errorWorkflowTaskAlreadyInitialized;
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
      return FlutterHeyteacherTimerWorkflowLocalizations.of(
        ContextHelper.context!,
      )!.errorWorkflowNotInitialized;
    } else {
      return 'error: workflow not initialized';
    }
  }
}
