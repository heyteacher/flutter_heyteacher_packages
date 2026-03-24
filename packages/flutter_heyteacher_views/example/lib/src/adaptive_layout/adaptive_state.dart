import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show AbstractAdaptiveState, AdaptiveState;

/// This Widget is the main application widget.
class AdaptiveStateScreen extends StatefulWidget {
  /// Creates the [AdaptiveStateScreen].
  const AdaptiveStateScreen({required String param, super.key})
    : _param = param;

  final String _param;

  @override
  State<AdaptiveStateScreen> createState() => _AdaptiveStateScreenState();
}

class _AdaptiveStateScreenState
    extends
        AdaptiveState<
          AdaptiveStateScreen,
          _AbstractAdaptiveStateScreenState,
          String
        > {
  @override
  _AbstractAdaptiveStateScreenState createAdaptiveState() =>
      _AbstractAdaptiveStateScreenState();

  @override
  String get params => widget._param;
}

class _AbstractAdaptiveStateScreenState extends AbstractAdaptiveState<String> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Adaptive State'),
    ),
    body: GridView.count(
      crossAxisCount: widget.crossAxisCount,
      children: _childred,
    ),
  );

  List<Widget> get _childred => [
    for (var i = 0; i < 10; i++)
      Card(
        child: Center(
          child: ListTile(
            title: Text(
              'GridView Child #${i + 1}',
              textAlign: TextAlign.center,
            ),
            subtitle: Text(
              'Param: "${widget.params}"\n'
              'crossAxisCount: ${widget.crossAxisCount}\n'
              'ScreenSize: ${widget.screenSize.name}',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
  ];
}
