import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_heyteacher_e2ee/flutter_heyteacher_e2ee.dart';
import 'package:flutter_heyteacher_store/flutter_heyteacher_store.dart';
import 'package:flutter_heyteacher_store_example/src/data/base_track_data.dart' show BaseTrackData;

part 'track_data.g.dart';

/// The detailed track data information `<DetailsDataType>`, the full detailed 
/// [FirestoreData] document used in [Store.get], [Store.set] and [Store.update]
@CopyWith()
class TrackData extends BaseTrackData {
  /// Creates [TrackData]
  const TrackData({
    required super.startTime,
    super.stopTime,
    super.distanceInMeters,
    this.avgBpm,
    this.avgRpm,
  });

  /// Creates [TrackData] from [Map]
  factory TrackData.fromFirestore(Map<String, dynamic> map) => TrackData(
        startTime: FirestoreData.fromFirestoreTimestamp(map['startTime'])!,
        avgBpm: map['avgBpm'] != null
            ? E2EEValue.fromJson(map['avgBpm'] as Map<String, dynamic>)
            : null,
        avgRpm: map['avgRpm'] as num?,
      );

  /// the average bpm of the track End-to-End Encrypted   
  final E2EEValue? avgBpm;
  /// the average rpm of the track
  final num? avgRpm;

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) => {
        ...super.toFirestore(fields),
        'startTime': FirestoreData.toFirestoreTimestamp(startTime),
        if (fields?.contains('avgBpm') ?? true) 'avgBpm': avgBpm?.toJson(),
        if (fields?.contains('avgRpm') ?? true) 'avgRpm': avgRpm,
      };

  @override
  TrackData setParentData(FirestoreData<dynamic> parentData) => copyWith(
        startTime: (parentData as BaseTrackData).startTime,
        distanceInMeters: parentData.distanceInMeters,
        stopTime: parentData.stopTime,
      );

  @override
  FirestoreData<dynamic> getParentData() {
    return BaseTrackData(
      startTime: startTime,
      distanceInMeters: distanceInMeters,
      stopTime: stopTime,
    );
  }
}
