import 'package:clock/clock.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_heyteacher_store/flutter_heyteacher_store.dart';
import 'package:intl/intl.dart';

part 'base_track_data.g.dart';

/// The basic track data information `<LightDataType>`, the lighweight
/// [FirestoreData] document /// used in [Store.list] and [Store.query]
@CopyWith()
class BaseTrackData extends FirestoreData<dynamic> {
  /// Creates [BaseTrackData]
  const BaseTrackData({
    required this.startTime,
    this.stopTime,
    this.distanceInMeters,
  });

  /// Creates [BaseTrackData] from [Map]
  factory BaseTrackData.fromFirestore(Map<String, dynamic> map) {
    return BaseTrackData(
      startTime: FirestoreData.fromFirestoreTimestamp(map['startTime'])!,
      stopTime: map['stopTime'] != null
          ? FirestoreData.fromFirestoreTimestamp(map['stopTime'])
          : null,
      distanceInMeters:
          ((map['distanceInMeters'] as num? ?? 0) * 10).round() / 10,
    );
  }
  static final DateFormat _keyDateTimeFormatter = DateFormat('yyyyMMdd_HHmmss');

  /// the start time of the track
  final DateTime startTime;

  /// the stop time of the track
  final DateTime? stopTime;

  /// the distance of the track
  final num? distanceInMeters;

  /// the duration of the track
  num? get durationInMilliseconds =>
      (stopTime ?? clock.now()).difference(startTime).inMilliseconds;

  @override
  String get id => _keyDateTimeFormatter.format(startTime.toLocal());

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) => {
    'startTime': FirestoreData.toFirestoreTimestamp(startTime),
    if (fields?.contains('stopTime') ?? true)
      'stopTime': FirestoreData.toFirestoreTimestamp(stopTime),
    if (fields?.contains('duration') ?? true)
      'duration': durationInMilliseconds,
    if (fields?.contains('distanceInMeters') ?? true)
      'distanceInMeters': distanceInMeters,
  };
}
