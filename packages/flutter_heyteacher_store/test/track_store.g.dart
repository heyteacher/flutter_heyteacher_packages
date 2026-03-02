// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'track_store.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$TrackDataCWProxy extends _$BaseTrackDataCWProxy {
  @override
  TrackData startTime(DateTime startTime);

  @override
  TrackData stopTime(DateTime? stopTime);

  @override
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
  @override
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
class _$TrackDataCWProxyImpl extends _$BaseTrackDataCWProxyImpl
    implements _$TrackDataCWProxy {
  const _$TrackDataCWProxyImpl(TrackData super._value);

  @override
  TrackData get _value => super._value as TrackData;

  @override
  TrackData startTime(DateTime startTime) =>
      super.startTime(startTime) as TrackData;

  @override
  TrackData stopTime(DateTime? stopTime) =>
      super.stopTime(stopTime) as TrackData;

  @override
  TrackData distance(num? distance) => super.distance(distance) as TrackData;

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

abstract class _$BaseTrackDataCWProxy {
  BaseTrackData startTime(DateTime startTime);

  BaseTrackData stopTime(DateTime? stopTime);

  BaseTrackData distance(num? distance);

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
    num? distance,
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
  BaseTrackData distance(num? distance) => call(distance: distance);

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
    Object? distance = const $CopyWithPlaceholder(),
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
      distance: distance == const $CopyWithPlaceholder()
          ? _value.distance
          // ignore: cast_nullable_to_non_nullable
          : distance as num?,
    );
  }
}

extension $BaseTrackDataCopyWith on BaseTrackData {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBaseTrackData.copyWith(...)` or `instanceOfBaseTrackData.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BaseTrackDataCWProxy get copyWith => _$BaseTrackDataCWProxyImpl(this);
}
