import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_locale/flutter_heyteacher_locale.dart';
import 'package:flutter_heyteacher_timer_workflow/flutter_heyteacher_timer_workflow.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  // ensureInitialized
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// The root widget of the application.
class MyApp extends StatelessWidget {
  /// Creates a new instance of [MyApp].
  const new({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Timer Workflow Example',
    theme: ThemeViewModel.instance.lightTheme,
    darkTheme: ThemeViewModel.instance.darkTheme,
    themeMode: ThemeMode.dark,
    home: const _MyHomePage(),
    localizationsDelegates: const [
      FlutterHeyteacherTimerWorkflowLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
  );
}

class _MyHomePage extends StatefulWidget {
  const new();

  @override
  State<_MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<_MyHomePage> {
  final _workflow = MyWorkflow();
  RunningTask<MyTask>? _runningTask;

  @override
  void initState() {
    super.initState();
    _workflow.stream.listen((runningTask) {
      if (runningTask.changed && mounted) {
        showSnackBar(
          context: context,
          message:
              '${runningTask.current?.name} completed '
              '${runningTask.next != null ? ', '
                        '${runningTask.next?.name} started ' : ', '
                        'all done'} ',
        );
      }
      setState(() => _runningTask = runningTask);
    });
  }

  @override
  void dispose() {
    _workflow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Timer Workflow Example')),
    body: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 8,
        children: [
          const Row(
            children: [Expanded(child: Center(child: Text('Workflow')))],
          ),
          Row(
            children: [
              const Expanded(child: Text('Name')),
              Expanded(child: Text(_workflow.name)),
            ],
          ),
          Row(
            children: [
              const Expanded(child: Text('Tasks Count')),
              Expanded(child: Text(_workflow.tasksCount.toString())),
            ],
          ),
          Row(
            children: [
              const Expanded(child: Text('Total Duration')),
              Expanded(
                child: Text(
                  FormatterHelper.formatDuration(
                    _workflow.totalDuration.inMilliseconds,
                    showSeconds: true,
                  ),
                ),
              ),
            ],
          ),
          ..._workflow.tasks.map(
            (task) => Row(
              children: [
                Expanded(child: Text(task.name)),
                Expanded(
                  child: Text(
                    //
                    // ignore: lines_longer_than_80_chars
                    '${task.description} (${FormatterHelper.formatDuration(task.duration.inMilliseconds, showSeconds: true)})',
                  ),
                ),
              ],
            ),
          ),
          if (_runningTask != null)
            Column(
              spacing: 8,
              children: [
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Expanded(child: Center(child: Text('Running Task'))),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Status')),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Badge(
                            label: Text(_runningTask!.status.name),
                            backgroundColor: _runningTask!.status.color,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Changed')),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Badge(
                            label: Text(_runningTask!.changed.toString()),
                            backgroundColor: _runningTask!.changed
                                ? ThemeViewModel.instance.greenColor
                                : ThemeViewModel.instance.redColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Task Elapsed Time')),
                    Expanded(
                      child: Text(
                        FormatterHelper.formatDuration(
                          _runningTask!.taskElapsedTime.inMilliseconds,
                          showSeconds: true,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Total Elapsed Time')),
                    Expanded(
                      child: Text(
                        FormatterHelper.formatDuration(
                          _runningTask!.totalElapsedTime.inMilliseconds,
                          showSeconds: true,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Current Task')),
                    Expanded(
                      child: Text(
                        '${_runningTask!.current?.name ?? 'N/A'} '
                        '('
                        //
                        // ignore: lines_longer_than_80_chars
                        '${FormatterHelper.formatDuration(_runningTask!.current?.duration.inMilliseconds ?? 0, showSeconds: true)}'
                        ') ',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Next Task')),
                    Expanded(
                      child: Text(
                        '${_runningTask!.next?.name ?? 'N/A'} '
                        //
                        // ignore: lines_longer_than_80_chars
                        '(${FormatterHelper.formatDuration(_runningTask!.next?.duration.inMilliseconds ?? 0, showSeconds: true)}'
                        ') ',
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Expanded(child: Text('Completed Tasks')),
                    Expanded(
                      child: Text(
                        '${_workflow.completedTaskCount} '
                        'of ${_workflow.tasks.length}',
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    floatingActionButton: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_workflow.status == WorkflowStatus.stopped ||
            _workflow.status == WorkflowStatus.paused)
          FloatingActionTextIconButtom(
            text: _workflow.status == WorkflowStatus.stopped
                ? 'Play'
                : 'Resume',
            iconData: Icons.play_circle,
            backgroundColor: ThemeViewModel.instance.greenColor,
            onPressed: _workflow.start,
          ),
        if (_workflow.status == WorkflowStatus.started)
          FloatingActionTextIconButtom(
            text: 'restart',
            iconData: Icons.restart_alt,
            backgroundColor: ThemeViewModel.instance.greenColor,
            onPressed: _workflow.restart,
          ),
        if (_workflow.status == WorkflowStatus.started)
          FloatingActionTextIconButtom(
            text: 'Pause',
            iconData: Icons.pause_circle,
            backgroundColor: ThemeViewModel.instance.yellowColor,
            onPressed: _workflow.pause,
          ),
        if (_workflow.status == WorkflowStatus.started ||
            _workflow.status == WorkflowStatus.paused)
          FloatingActionTextIconButtom(
            text: 'Skip',
            iconData: Icons.skip_next,
            backgroundColor: ThemeViewModel.instance.blueColor,
            onPressed: _workflow.next,
          ),
        if (_workflow.status == WorkflowStatus.started ||
            _workflow.status == WorkflowStatus.paused)
          FloatingActionTextIconButtom(
            text: 'Stop',
            iconData: Icons.stop_circle,
            backgroundColor: ThemeViewModel.instance.redColor,
            onPressed: _workflow.stop,
          ),
      ],
    ),
  );
}

/// A workflow that contains a sequence of [MyTask] tasks.
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

/// A custom task for the timer workflow example.
///
/// This class extends [TimerTask] and provides specific properties for
/// the example workflow, such as a description.
class MyTask extends TimerTask {
  /// Creates a new instance of [MyTask].
  new({
    required super.name,
    required super.description,
    required super.duration,
  });
}
