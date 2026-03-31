// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_track_data.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BaseTrackDataCWProxy {
  BaseTrackData startTime(DateTime startTime);

  BaseTrackData stopTime(DateTime? stopTime);

  BaseTrackData distanceInMeters(num? distanceInMeters);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BaseTrackData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BaseTrackData(...).copyWith(id: 12, name: "My name")
  /// ```
  BaseTrackData call({
    DateTime startTime,
    DateTime? stopTime,
    num? distanceInMeters,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBaseTrackData.copyWith(...)` or call `instanceOfBaseTrackData.copyWith.fieldName(value)` for a single field.
class _$BaseTrackDataCWProxyImpl implements _$BaseTrackDataCWProxy {
  const _$BaseTrackDataCWProxyImpl(this._value);

  final BaseTrackData _value;

  @override
  BaseTrackData startTime(DateTime startTime) => call(startTime: startTime);

  @override
  BaseTrackData stopTime(DateTime? stopTime) => call(stopTime: stopTime);

  @override
  BaseTrackData distanceInMeters(num? distanceInMeters) =>
      call(distanceInMeters: distanceInMeters);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BaseTrackData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BaseTrackData(...).copyWith(id: 12, name: "My name")
  /// ```
  BaseTrackData call({
    Object? startTime = const $CopyWithPlaceholder(),
    Object? stopTime = const $CopyWithPlaceholder(),
    Object? distanceInMeters = const $CopyWithPlaceholder(),
  }) {
    return BaseTrackData(
      startTime: startTime == const $CopyWithPlaceholder() || startTime == null
          ? _value.startTime
          // ignore: cast_nullable_to_non_nullable
          : startTime as DateTime,
      stopTime: stopTime == const $CopyWithPlaceholder()
          ? _value.stopTime
          // ignore: cast_nullable_to_non_nullable
          : stopTime as DateTime?,
      distanceInMeters: distanceInMeters == const $CopyWithPlaceholder()
          ? _value.distanceInMeters
          // ignore: cast_nullable_to_non_nullable
          : distanceInMeters as num?,
    );
  }
}

extension $BaseTrackDataCopyWith on BaseTrackData {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBaseTrackData.copyWith(...)` or `instanceOfBaseTrackData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BaseTrackDataCWProxy get copyWith => _$BaseTrackDataCWProxyImpl(this);
}
