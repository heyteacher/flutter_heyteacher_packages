// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_test.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TrackDataCWProxy {
  TrackData startTime(DateTime startTime);

  TrackData stopTime(DateTime? stopTime);

  TrackData distance(num? distance);

  TrackData avgBpm(E2EEValue? avgBpm);

  TrackData avgRpm(num? avgRpm);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `TrackData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TrackData(...).copyWith(id: 12, name: "My name")
  /// ```
  TrackData call({
    DateTime startTime,
    DateTime? stopTime,
    num? distance,
    E2EEValue? avgBpm,
    num? avgRpm,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfTrackData.copyWith(...)` or call `instanceOfTrackData.copyWith.fieldName(value)` for a single field.
class _$TrackDataCWProxyImpl implements _$TrackDataCWProxy {
  const _$TrackDataCWProxyImpl(this._value);

  final TrackData _value;

  @override
  TrackData startTime(DateTime startTime) => call(startTime: startTime);

  @override
  TrackData stopTime(DateTime? stopTime) => call(stopTime: stopTime);

  @override
  TrackData distance(num? distance) => call(distance: distance);

  @override
  TrackData avgBpm(E2EEValue? avgBpm) => call(avgBpm: avgBpm);

  @override
  TrackData avgRpm(num? avgRpm) => call(avgRpm: avgRpm);

  @override

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `TrackData(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// TrackData(...).copyWith(id: 12, name: "My name")
  /// ```
  TrackData call({
    Object? startTime = const $CopyWithPlaceholder(),
    Object? stopTime = const $CopyWithPlaceholder(),
    Object? distance = const $CopyWithPlaceholder(),
    Object? avgBpm = const $CopyWithPlaceholder(),
    Object? avgRpm = const $CopyWithPlaceholder(),
  }) {
    return TrackData(
      startTime: startTime == const $CopyWithPlaceholder() || startTime == null
          ? _value.startTime
          // ignore: cast_nullable_to_non_nullable
          : startTime as DateTime,
      stopTime: stopTime == const $CopyWithPlaceholder()
          ? _value.stopTime
          // ignore: cast_nullable_to_non_nullable
          : stopTime as DateTime?,
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as num?,
      avgBpm: avgBpm == const $CopyWithPlaceholder()
          ? _value.avgBpm
          // ignore: cast_nullable_to_non_nullable
          : avgBpm as E2EEValue?,
      avgRpm: avgRpm == const $CopyWithPlaceholder()
          ? _value.avgRpm
          // ignore: cast_nullable_to_non_nullable
          : avgRpm as num?,
    );
  }
}

extension $TrackDataCopyWith on TrackData {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfTrackData.copyWith(...)` or `instanceOfTrackData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$TrackDataCWProxy get copyWith => _$TrackDataCWProxyImpl(this);
}
