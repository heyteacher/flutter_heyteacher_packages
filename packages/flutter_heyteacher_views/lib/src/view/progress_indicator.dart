import 'dart:async';

import 'package:flutter/material.dart';

/// A [CircularProgressIndicator] constrained to a [constraints].
///
/// Typically used to indicate that some background processing or data loading
/// is happening.
///
/// After a specified [timeout], it can display an alternative
/// [timeoutWidget] and trigger an [onTimeout] callback.
///
/// If [showCountdown], show the countdown inside indicator
class ProgressIndicatorWidget extends StatefulWidget {
  /// Creates a [ProgressIndicatorWidget].
  const ProgressIndicatorWidget({
    super.key,
    this.timeout = const Duration(seconds: 15),
    this.timeoutWidget,
    this.showCountdown = false,
    this.onTimeout,
    this.constraints = const BoxConstraints(
      minHeight: 20,
      minWidth: 20,
      maxHeight: 20,
      maxWidth: 20,
    ),
    this.padding,
  });

  /// The duration to wait before the progress indicator times out.
  ///
  /// Defaults to 15 seconds.
  final Duration timeout;

  /// An optional widget to display after the [timeout] duration has passed.
  /// If null, a [SizedBox.shrink] is shown.
  final Widget? timeoutWidget;

  /// An optional callback to be executed when the timeout is reached.
  final VoidCallback? onTimeout;

  /// Optional constraints to apply to the [CircularProgressIndicator].
  final BoxConstraints constraints;

  /// Optional padding to apply to the [CircularProgressIndicator].99
  final EdgeInsets? padding;

  /// If true, show the countdown inside indicator
  final bool showCountdown;

  @override
  State<ProgressIndicatorWidget> createState() =>
      _ProgressIndicatorWidgetState();
}

class _ProgressIndicatorWidgetState extends State<ProgressIndicatorWidget> {
  late int _countdownInSec;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownInSec = widget.timeout.inSeconds;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {
        _countdownInSec--;
        if (_countdownInSec <= 0) {
          _countdownTimer?.cancel();
        }
        setState(() => _countdownInSec <= 0);
        if (_countdownInSec <= 0) {
          widget.onTimeout?.call();
        }
      }),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _countdownInSec <= 0
      ? widget.timeoutWidget ?? const SizedBox.shrink()
      : CircularProgressIndicator(
          constraints: widget.constraints,
          value: widget.showCountdown
              ? _countdownInSec / widget.timeout.inSeconds
              : null,
          padding: widget.padding,
        );
}

/// A centered view of [ProgressIndicatorWidget] constrained to
/// a [constraints].
///
/// Typically used to indicate that some background processing or data loading
/// is happening.
///
/// After a specified [timeout], it can display an alternative
/// [timeoutWidget] and trigger an [onTimeout] callback.
///
/// If [showCountdown], show the countdown inside indicator.
class ProgressIndicatorView extends StatelessWidget {
  /// Creates a [ProgressIndicatorView].
  const ProgressIndicatorView({
    super.key,
    this.timeout = const Duration(seconds: 15),
    this.timeoutWidget,
    this.showCountdown = false,
    this.onTimeout,
    this.constraints = const BoxConstraints(
      minHeight: 200,
      minWidth: 200,
      maxHeight: 200,
      maxWidth: 200,
    ),
    this.padding,
  });

  /// The duration to wait before the progress indicator times out.
  ///
  /// Defaults to 15 seconds.
  final Duration timeout;

  /// An optional widget to display after the [timeout] duration has passed.
  /// If null, a [SizedBox.shrink] is shown.
  final Widget? timeoutWidget;

  /// An optional callback to be executed when the timeout is reached.
  final VoidCallback? onTimeout;

  /// Optional constraints to apply to the [ProgressIndicatorWidget].
  final BoxConstraints constraints;

  /// Optional padding to apply to the [ProgressIndicatorWidget].
  final EdgeInsets? padding;

  /// If true, show the countdown inside indicator
  final bool showCountdown;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ProgressIndicatorWidget(
          constraints: constraints,
          padding: padding,
          showCountdown: showCountdown,
          timeout: timeout,
          timeoutWidget: timeoutWidget,
          onTimeout: onTimeout,
        ),
      ],
    ),
  );
}
