import 'dart:async';

import 'package:flutter/material.dart';

/// A [StreamBuilder] initialized with a [FutureBuilder].
///
/// It first waits for the [future] (an asynchronous operation that completes
/// once) to provide an initial piece of data. Once that future completes
/// successfully and has data, it then uses that data as the initialData for an
/// inner [StreamBuilder]. This StreamBuilder then listens to the provided
/// [stream] for ongoing updates.
///
/// Useful when you need to fetch an initial state (e.g., from a database or
/// API) and then subscribe to real-time updates for that same data.
class FutureStreamBuilder<T> extends FutureBuilder<T> {
  /// Creates a [FutureStreamBuilder].
  const FutureStreamBuilder({
    required super.future,
    required this.stream,
    required super.builder,
    super.key,
  });

  ///  the [stream] parameter of [StreamBuilder]
  final Stream<T> stream;

  @override
  AsyncWidgetBuilder<T> get builder =>
      (context, futureSnapshot) => futureSnapshot.hasData
      ? StreamBuilder(
          stream: stream,
          initialData: futureSnapshot.data,
          builder: super.builder,
        )
      : super.builder(context, futureSnapshot);
}
