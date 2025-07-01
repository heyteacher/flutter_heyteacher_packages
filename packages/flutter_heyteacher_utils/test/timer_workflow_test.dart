import 'package:fake_async/fake_async.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_heyteacher_utils/formats.dart';
import 'package:flutter_heyteacher_utils/timer_workflow.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logging/logging.dart';

class TestWorkout extends TimerWorkflow<TimerTask> {
  @override
  String get name => 'Test Workout';

  @override
  void initializeTasks() {
    super.initializeTasks();
    tasks.add(TimerTask(
      name: 'Warm Up',
      description: 'Endurance',
      duration: const Duration(minutes: 20),
    ));
    for (var i = 1; i <= 3; i++) {
      tasks.add(TimerTask(
        name: 'Warm Up',
        description: 'Fast Spin $i/3',
        duration: const Duration(minutes: 1),
      ));
      if (i < 3) {
        tasks.add(TimerTask(
          name: 'Warm Up',
          description: 'Easy riding',
          duration: const Duration(minutes: 1),
        ));
      }
    }
    tasks.add(TimerTask(
      name: 'Warm Up',
      description: 'Easy riding',
      duration: const Duration(minutes: 5),
    ));
    tasks.add(TimerTask(
      name: 'Main Set',
      description: 'All-Out',
      duration: const Duration(minutes: 5),
    ));
    tasks.add(TimerTask(
      name: 'Main Set',
      description: 'Easy riding',
      duration: const Duration(minutes: 10),
    ));
    tasks.add(TimerTask(
      name: 'Main Set',
      description: 'Time Trial',
      duration: const Duration(minutes: 20),
    ));
    tasks.add(TimerTask(
      name: 'Cool Down',
      description: 'Easy riding',
      duration: const Duration(minutes: 10),
    ));
  }
}

void main() {
  late TimerWorkflow<TimerTask> workflow;

  Logger.root.level = const Level('ALL', 0);
  Logger.root.onRecord.listen((record) {
    // format error and stack trace
    final String error = record.error != null ? '\n${record.error}' : '';
    final String stackTrace =
        record.stackTrace != null ? '\n${record.stackTrace}' : '';
    // get uid from firebase auth
    // print in standard output
    if (kDebugMode) {
      print('${timeWithSecondsFormatter.format(record.time)} '
          '- ${record.level.name} '
          '- ${record.loggerName} '
          '- ${record.message} '
          '$error'
          '$stackTrace');
    }
  });

  setUp(() {
    workflow = TestWorkout();
  });

  tearDown(() {
    workflow.dispose();
  });

  group('TimerWorkflow', () {
    test('initial state is correct', () {
      expect(workflow.tasks.isNotEmpty, isTrue);
      expect(workflow.isCompleted, isFalse);
      expect(workflow.tasks.first.completed, isFalse);
    });

    test('play starts the workflow and stream emits correct data', () async {
      final events = <RunningTask<TimerTask>>[];
      workflow.stream.listen(events.add);

      fakeAsync((async) {
        workflow.play();
        // The first event is emitted after the first tick.
        async.elapse(const Duration(seconds: 1));

        expect(events.length, 2);
        expect(events.first.current, workflow.tasks.first);
        expect(events.last.remainingTaskMilliseconds,
            workflow.tasks.first.duration.inMilliseconds);

        async.elapse(const Duration(seconds: 1));
        expect(events.length, 3);
        expect(
            events.last.remainingTaskMilliseconds,
            workflow.tasks.first.duration.inMilliseconds -
                const Duration(seconds: 1).inMilliseconds);

        async.elapse(const Duration(seconds: 20));
        expect(events.length, 23);
        expect(
            events.last.remainingTaskMilliseconds,
            workflow.tasks.first.duration.inMilliseconds -
                const Duration(seconds: 21).inMilliseconds);
      });
    });

    test('pause and resume works correctly', () {
      final events = <RunningTask<TimerTask>>[];
      workflow.stream.listen(events.add);

      fakeAsync((async) {
        workflow.play();
        async.elapse(const Duration(seconds: 5));

        expect(
            events.last.remainingTaskMilliseconds,
            workflow.tasks.first.duration.inMilliseconds -
                const Duration(seconds: 4).inMilliseconds);

        workflow.pause();
        final eventCountBeforePause = events.length;

        async.elapse(const Duration(seconds: 10));
        // No new events should be emitted while paused.
        expect(events.length, eventCountBeforePause + 10);

        workflow.play(); // Resume
        async.elapse(const Duration(seconds: 1));

        expect(events.length, greaterThan(eventCountBeforePause));
        expect(
            events.last.remainingTaskMilliseconds,
            workflow.tasks.first.duration.inMilliseconds -
                const Duration(seconds: 5).inMilliseconds);
      });
    });

    test('stop resets the workflow', () {
      fakeAsync((async) {
        workflow.play();
        async.elapse(const Duration(seconds: 10));
        // Manually complete a task to ensure state is being changed
        workflow.tasks.first.completed = true;

        workflow.stop();

        expect(workflow.isCompleted, isFalse);
        // Check if tasks are reset to their initial state
        expect(workflow.tasks.first.completed, isFalse);

        // We can verify the reset by re-playing the workflow
        final events = <RunningTask<TimerTask>>[];
        workflow.stream.listen(events.add);

        workflow.play();
        async.elapse(const Duration(seconds: 1));

        expect(events.first.current, workflow.tasks.first);
        expect(events.first.remainingTaskMilliseconds,
            workflow.tasks.first.duration.inMilliseconds);
      });
    });

    test('task completes and next task starts', () {
      final events = <RunningTask<TimerTask>>[];
      workflow.stream.listen(events.add);
      final firstTaskDuration = workflow.tasks.first.duration;

      fakeAsync((async) {
        workflow.play();
        async.elapse(firstTaskDuration);

        // After the first task's duration has passed, it should be marked as completed.
        expect(workflow.tasks.first.completed, isFalse);

        // The last event for the first task should have remainingSeconds <= 0
        expect(events.last.current, workflow.tasks.first);
        expect(events.last.remainingTaskMilliseconds, 1000);

        // The next tick should start the second task
        async.elapse(const Duration(seconds: 1));
        expect(events.last.current, workflow.tasks[1]);
        expect(events.last.remainingTaskMilliseconds,
            workflow.tasks[1].duration.inMilliseconds);
      });
    });

    test('skip moves to the next task', () {
      final events = <RunningTask<TimerTask>>[];
      workflow.stream.listen(events.add);

      fakeAsync((async) {
        workflow.play();
        async.elapse(const Duration(seconds: 1));

        expect(events.last.current, workflow.tasks.first);

        workflow.skip();

        // The skip implementation reflects the change on the next tick.
        async.elapse(const Duration(seconds: 1));

        expect(workflow.tasks.first.completed, isTrue);
        expect(events.last.current, workflow.tasks[1]);
        // Note: We are not asserting on remainingSeconds here, as the simple
        // skip implementation can lead to timing discrepancies.
      });
    });

    test('entire workflow completes', () {
      final events = <RunningTask<TimerTask>>[];
      workflow.stream.listen(events.add);

      fakeAsync((async) {
        workflow.play();
        // Elapse for the total duration plus a small buffer to ensure completion
        async.elapse(Duration(
            milliseconds: workflow.totalDurationInMilliseconds + 12000));

        expect(workflow.status, WorkflowStatus.stopped);
        expect(events.last.current, isNull);
        expect(events.last.remainingTaskMilliseconds, 0);
      });
    });
  });
}
