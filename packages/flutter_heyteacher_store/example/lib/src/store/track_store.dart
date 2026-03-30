import 'package:flutter_heyteacher_store/flutter_heyteacher_store.dart';
import 'package:flutter_heyteacher_store_example/src/data/base_track_data.dart' show BaseTrackData;
import 'package:flutter_heyteacher_store_example/src/data/track_data.dart' show TrackData;

/// The generics implementation of Tracks
class TrackStore extends Store<BaseTrackData, TrackData> {
  
  /// Creates [TrackStore]
  TrackStore({super.firebaseFirestore})
      : super(
          collection: 'tracks',
          userProfile: true,
          cacheEnabled: false,
          orderByFields: {'startTime': OrderDirection.desc},
          aggregateFields: ['distanceInMeters'],
          fromFirestoreFactory: BaseTrackData.fromFirestore,
          detailsFromFirestoreFactory: TrackData.fromFirestore,
          groupByFields: {
            'year': _groupByYear,
          },
        );

  static TrackStore? _instance;

  /// Creates singleton [TrackStore] instance
  // ignore: prefer_constructors_over_static_methods
  static TrackStore get instance => _instance ??= TrackStore();
  static set instance(TrackStore instance) => _instance = instance;

  static String _groupByYear(TrackData trackData) {
    return '${trackData.startTime.year}';
  }
}
