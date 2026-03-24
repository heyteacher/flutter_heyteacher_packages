import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_views/flutter_heyteacher_views.dart'
    show PagingSliverAnimatedState;

/// A screen that displays a paginated list of sample records.
class PagingSliverAnimatedStateScreen extends StatefulWidget {
  /// Creates a [PagingSliverAnimatedStateScreen].
  const PagingSliverAnimatedStateScreen({super.key});

  @override
  /// Creates the mutable state for this widget.
  State<PagingSliverAnimatedStateScreen> createState() =>
      _PagingSliverAnimatedStateScreenState();
}

class _PagingSliverAnimatedStateScreenState
    extends
        PagingSliverAnimatedState<
          SampleRecord,
          PagingSliverAnimatedStateScreen
        > {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  int get crossAxisCount => 1;

  @override
  double get mainAxisExtent => 100;

  @override
  Widget buildData(
    int index, {
    Animation<double>? animation,
    bool removing = false,
  }) => index < (dataList?.length ?? 0)
      ? Card(
          child: ListTile(
            title: Text(dataList!.elementAt(index).title),
            subtitle: Text(dataList!.elementAt(index).message),
          ),
        )
      : const SizedBox.shrink();

  Future<Iterable<SampleRecord>> _loadData({required int limit}) async => [
    for (var i = 0; i < limit; i++)
      SampleRecord(
        title: 'Record #$i',
        message: 'loaded $limit records',
      ),
  ];

  @override
  ScrollController get scrollController => _scrollController;

  @override
  Stream<Iterable<SampleRecord>> stream({required int limit}) =>
      _loadData(limit: limit).asStream();

  @override
  @protected
  Stream<void> get updateStream => const Stream.empty();

  /// Builds the UI wrapping paginated list into a [Scaffold].
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Paging Sliver Animated State'),
    ),
    body: SafeArea(
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [super.build(context)],
      ),
    ),
  );
}

/// An example record.
class SampleRecord {
  /// Creates a [SampleRecord].
  const SampleRecord({
    required this.title,
    required this.message,
  });

  /// The title of the record.
  final String title;

  /// The message of the record.
  final String message;
}
