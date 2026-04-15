import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart'
    show AggregateStageOptions, CountAll, Field;
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:flutter_heyteacher_e2ee/flutter_heyteacher_e2ee.dart';
import 'package:flutter_heyteacher_store/flutter_heyteacher_store.dart';
import 'package:intl/intl.dart';

part 'track_store.g.dart';

@CopyWith()
class TrackData extends BaseTrackData {
  const TrackData({
    required super.startTime,
    super.stopTime,
    super.distance,
    this.avgBpm,
    this.avgRpm,
  });

  factory TrackData.fromFirestore(Map<String, dynamic> map) => TrackData(
        startTime: FirestoreData.fromFirestoreTimestamp(map['startTime'])!,
        avgBpm: map['avgBpm'] != null
            ? E2EEValue.fromJson(map['avgBpm'] as Map<String, dynamic>)
            : null,
        avgRpm: map['avgRpm'] as num?,
      );
  final E2EEValue? avgBpm;
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
        distance: parentData.distance,
        stopTime: parentData.stopTime,
      );

  @override
  FirestoreData<dynamic> getParentData() {
    return BaseTrackData(
      startTime: startTime,
      distance: distance,
      stopTime: stopTime,
    );
  }
}

@CopyWith()
class BaseTrackData extends FirestoreData<dynamic> {
  const BaseTrackData({required this.startTime, this.stopTime, this.distance});

  factory BaseTrackData.fromFirestore(Map<String, dynamic> map) {
    return BaseTrackData(
      startTime: FirestoreData.fromFirestoreTimestamp(map['startTime'])!,
      stopTime: map['stopTime'] != null
          ? FirestoreData.fromFirestoreTimestamp(map['stopTime'])
          : null,
      distance: ((map['distance'] as num? ?? 0) * 10).round() / 10,
    );
  }
  static final DateFormat keyDateTimeFormatter = DateFormat('yyyyMMdd_HHmmss');

  final DateTime startTime;
  final DateTime? stopTime;
  final num? distance;

  num? get duration =>
      (stopTime ?? clock.now()).difference(startTime).inMilliseconds;

  @override
  String get id => keyDateTimeFormatter.format(startTime.toLocal());

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) => {
        'startTime': FirestoreData.toFirestoreTimestamp(startTime),
        'year': startTime.year,
        if (fields?.contains('stopTime') ?? true)
          'stopTime': FirestoreData.toFirestoreTimestamp(stopTime),
        if (fields?.contains('duration') ?? true) 'duration': duration,
        if (fields?.contains('distance') ?? true) 'distance': distance,
      };
}

/// Represents the count for a specific year
class CountPerYearData {
  /// Creates an instance of [CountPerYearData] specifying the
  /// [count] of track for a specific [year]
  const CountPerYearData._({
    required this.count,
    required this.year,
  });

  /// Creates a [CountPerYearData] instance from a JSON map from a pipeline.
  factory CountPerYearData.fromJson(Map<String, dynamic> json) =>
      CountPerYearData._(
        count: json['count'] as int,
        year: json['year'] as int,
      );

  /// The user's Functional Threshold Power (FTP) in watts at the time of the
  /// track.
  final int count;

  /// The user's Functional Threshold Heart Rate (FTHR) in BPM at the time of
  /// the track.
  final int year;
}

class TrackStore extends Store<BaseTrackData, TrackData> {
  TrackStore({super.firebaseFirestore})
      : super(
          collection: 'tracks',
          userProfile: true,
          cacheEnabled: false,
          orderByFields: {'startTime': OrderDirection.desc},
          aggregateFields: [
            (field: 'distance', aggregatationType: AggregatationType.sum),
            (field: 'distance', aggregatationType: AggregatationType.average),
            (field: 'duration', aggregatationType: AggregatationType.sum),
            (field: 'duration', aggregatationType: AggregatationType.average),
          ],
          fromFirestoreFactory: BaseTrackData.fromFirestore,
          detailsFromFirestoreFactory: TrackData.fromFirestore,
        );

  static TrackStore? _instance;

  /// Creates singleton [TrackStore] instance
  // ignore: prefer_constructors_over_static_methods
  static TrackStore get instance => _instance ??= TrackStore();
  static set instance(TrackStore instance) => _instance = instance;

  /// Returns the count per year using pipeline
  Future<Iterable<CountPerYearData?>> get countPerTrackTypeAndYearList async {
    final snapshot = await collectionPipeline
        .aggregateWithOptions(
          AggregateStageOptions(
            accumulators: [CountAll().as('count')],
            groups: [Field('year')],
          ),
        )
        .execute();
    return snapshot.result.map(
      (pipelineResult) => pipelineResult.data() != null
          ? CountPerYearData.fromJson(pipelineResult.data()!)
          : null,
    );
  }
}
