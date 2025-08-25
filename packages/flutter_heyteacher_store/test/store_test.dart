import 'package:clock/clock.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/connectivity.dart';
import 'package:flutter_heyteacher_utils/e2ee.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_heyteacher_store/flutter_heyteacher_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:mockito/annotations.dart';

import 'store_test.mocks.dart';

@GenerateNiceMocks([MockSpec<ConnectivityViewModel>()]) 
void main() {

  const String userId = 'testuid',
      userEmail = 'test@example.com',
      userDisplayName = 'Test User';

  setUp(() async {
    
    MockConnectivityViewModel connectivityViewModel = MockConnectivityViewModel();
    when(connectivityViewModel.connected).thenAnswer((_) async => true);
    ConnectivityViewModel.instance = connectivityViewModel;

    SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty();
    WidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
     PackageInfoPlusLinuxPlugin.registerWith();
    // mock authentication
    MockFirebaseAuth auth = MockFirebaseAuth(
        mockUser: MockUser(
      isAnonymous: false,
      uid: userId,
      email: userEmail,
      displayName: userDisplayName,
    ));
    // mock sign-in
    auth.signInWithEmailAndPassword(email: userEmail, password: userEmail);

    // initialize Auth with MockFirebaseAuth
    AuthViewModel.instance(mockedFirebaseAuth: auth);

    // set AAD
    E2EEViewModel.instance(AuthViewModel.instance().uid).setAAD(aadValue: 'aadValue');

    // mock firestore with mock authentication
    FakeFirebaseFirestore firestore =
        FakeFirebaseFirestore(authObject: auth.authForFakeFirestore);

    // initialize
    final TrackStore trackStore =
        TrackStore.instance(firebaseFirestore: firestore);
  
    await trackStore.set(TrackData(
        startTime: DateTime.parse('2024-02-27 13:27:56'),
        stopTime: DateTime.parse('2024-02-27 14:27:56'),
        distance: 10000));
    await trackStore.set(TrackData(
        startTime: DateTime.parse('2024-04-27 13:27:56'),
        stopTime: DateTime.parse('2024-04-27 14:27:56'),
        distance: 20000));
    await trackStore.set(TrackData(
        startTime: DateTime.parse('2023-07-12 17:15:22'),
        stopTime: DateTime.parse('2023-07-12 20:15:22'),
        distance: 30000,
        avgBpm: await E2EEViewModel.instance(AuthViewModel.instance().uid).encrypt('100')));
    await trackStore.set(TrackData(
      startTime: DateTime.parse('2023-09-12 17:15:22'),
      stopTime: DateTime.parse('2023-09-12 20:15:22'),
      distance: 30000,
    ));
  });

  group('track list, filter group:', () {
    test('store should contains 4 tracks', () async {
      final TrackStore trackStore = TrackStore.instance();
      expect((await trackStore.list()).length, 4, reason: 'wrong store size');
    });
    test('store should contains 2 tracks filtered by startTime in 2023',
        () async {
      final TrackStore trackStore = TrackStore.instance();
      trackStore.storeFilter = LogicalStoreFilter(
          logicalOperator: LogicalOperator.and,
          filter1: ValueStoreFilter(
              field: 'startTime',
              operator: Operator.isGreaterThanOrEqualTo,
              value: DateTime(2023)),
          filter2: ValueStoreFilter(
              field: 'startTime',
              operator: Operator.isLessThan,
              value: DateTime(2024)));
      expect((await trackStore.list()).length, 2,
          reason: 'wrong store size after filtering');
    });
  });
  group('track exists and get:', () {
    test('store contains 20230712_171522', () async {
      final TrackStore trackStore = TrackStore.instance();
      expect(await trackStore.exists('20230712_171522'), true,
          reason: "track does't exists");
    });
    test('store track doesn\'t exist after delete', () async {
      final TrackStore trackStore = TrackStore.instance();
      await trackStore.delete('20230712_171522');
      expect(await trackStore.exists('20230712_171522'), false,
          reason: 'track exists');
    });
    test('store get track and check fields', () async {
      final TrackStore trackStore = TrackStore.instance();
      TrackData trackData = await trackStore.get('20230712_171522');
      expect(trackData.avgBpm != null, true, reason: 'avgBpm is null ');
      expect(await E2EEViewModel.instance(AuthViewModel.instance().uid).decrypt(trackData.avgBpm!),
          '100',
          reason: 'avgBpm wrong');
      expect(trackData.distance, 30000, reason: 'distance  wrong');
      expect(trackData.duration, 3600 * 3 * 1000, reason: 'duration  wrong');
    });
  });

  group('track update group:', () {
    test('update', () async {
      final TrackStore trackStore = TrackStore.instance();
      TrackData trackData = await trackStore.get('20230712_171522');
      trackData.avgRpm = 80;
      await trackStore.update(trackData, fields: ['avgRpm']);
      trackData = await trackStore.get('20230712_171522');
      expect(trackData.avgRpm, 80, reason: 'avgRpm wrong');
      expect(await E2EEViewModel.instance(AuthViewModel.instance().uid).decrypt(trackData.avgBpm!),
          '100',
          reason: 'avgBpm wrong');
      expect(trackData.distance, 30000, reason: 'distance wrong');
      expect(trackData.duration, 3600 * 3 * 1000, reason: 'duration  wrong');
    });
    test('set single field', () async {
      TrackData trackData = TrackData(
          startTime: DateTime.parse('2023-07-12 17:15:22'),
          avgRpm: 80,
          distance: 0);
      final TrackStore trackStore = TrackStore.instance();
      await trackStore.set(trackData);

      trackData = await trackStore.get('20230712_171522');
      expect(trackData.avgRpm, 80, reason: 'avgRpm wrong');
      expect(trackData.avgBpm, null, reason: 'avgBpm wrong');
      expect(trackData.distance, 0, reason: 'distance wrong');
    });
    test('update single field', () async {
      final TrackStore trackStore = TrackStore.instance();
      TrackData trackData = await trackStore.get('20230712_171522');
      trackData = TrackData(
          startTime: DateTime.parse('2023-07-12 17:15:22'),
          avgRpm: 80,
          distance: 30000);
      await trackStore.update(trackData, fields: ['avgRpm', 'distance']);
      trackData = await trackStore.get('20230712_171522');
      expect(trackData.avgRpm, 80, reason: 'avgRpm wrong');
      expect(await E2EEViewModel.instance(AuthViewModel.instance().uid).decrypt(trackData.avgBpm!),
          '100',
          reason: 'avgBpm wrong');
      expect(trackData.distance, 30000, reason: 'distance wrong');
      expect(trackData.duration, 3600 * 3 * 1000, reason: 'duration  wrong');
    });
  });

  group('track groupByCounter group:', () {
    test('groupByCounter years check map', () async {
      final TrackStore trackStore = TrackStore.instance();
      expect((await trackStore.groupBy())!.length, 2,
          reason: 'years wrong size');
      expect(
          (await trackStore.groupBy())!
              .where((e) => e.groupByFields['year'] == '2023')
              .first
              .value,
          2,
          reason: 'year 2023 wrong size');
      expect(
          (await trackStore.groupBy())!
              .where((e) => e.groupByFields['year'] == '2024')
              .first
              .value,
          2,
          reason: 'year 2024 wrong size');
    });
    test('groupByCounter years check  map after add new track', () async {
      final TrackStore trackStore = TrackStore.instance();
      await trackStore.set(TrackData(startTime: DateTime(2020), distance: 0));
      expect((await trackStore.groupBy())!.length, 3,
          reason: 'years wrong size');
      expect(
          (await trackStore.groupBy())!
              .where((e) => e.groupByFields['year'] == '2020')
              .first
              .value,
          1,
          reason: 'year 2020 wrong size');
      expect(
          (await trackStore.groupBy())!
              .where((e) => e.groupByFields['year'] == '2023')
              .first
              .value,
          2,
          reason: 'year 2023 wrong size');
      expect(
          (await trackStore.groupBy())!
              .where((e) => e.groupByFields['year'] == '2024')
              .first
              .value,
          2,
          reason: 'year 2024 wrong size');
    });
  });
  group('track aggregateStream group:', () {
    test('aggregateStream check', () async {
      final TrackStore trackStore = TrackStore.instance();
      trackStore.notifyAggregatesChanges();
      final aggregate = await trackStore.aggregateStream.first;
      expect(aggregate.count, 4, reason: 'aggregate count wrong');
      expect(aggregate.getSum('distance'), 90000, reason: 'sum distance wrong');
      expect(aggregate.getSum('duration'), 8 * 3600 * 1000,
          reason: 'sum duration wrong');
    });
    test('aggregateStream after add track', () async {
      final TrackStore trackStore = TrackStore.instance();
      await trackStore.set(TrackData(
          startTime: DateTime.parse('2020-04-23 08:12:44'),
          stopTime: DateTime.parse('2020-04-23 09:12:44'),
          distance: 20000));
      var aggregate = await trackStore.aggregateStream.first;
      expect(aggregate.count, 5, reason: 'aggregate count wrong');
      expect(aggregate.getSum('distance'), 90000 + 20000,
          reason: 'sum distance wrong');
      expect(aggregate.getSum('duration'), (8 + 1) * 3600 * 1000,
          reason: 'sum duration wrong');
    });
    test('aggregateStream after filter', () async {
      final TrackStore trackStore = TrackStore.instance();
      trackStore.storeFilter = LogicalStoreFilter(
          logicalOperator: LogicalOperator.and,
          filter1: ValueStoreFilter(
              field: 'startTime',
              operator: Operator.isGreaterThanOrEqualTo,
              value: DateTime(2024)),
          filter2: ValueStoreFilter(
              field: 'startTime',
              operator: Operator.isLessThan,
              value: DateTime(2025)));
      final list = await trackStore.list();
      expect(list.length,2, reason: 'list length after filter wrong');
      trackStore.notifyAggregatesChanges();
      final aggregate = await trackStore.aggregateStream.first;
      expect(aggregate.count, 2, reason: 'aggregate count wrong');
      expect(aggregate.getSum('distance'), 30000, reason: 'sum distance wrong');
      expect(aggregate.getSum('duration'), 2 * 3600 * 1000,
          reason: 'sum duration wrong');
    });
  });

  group('track empty notEmpty group:', () {
    test('not empty check', () async {
      final TrackStore trackStore = TrackStore.instance();
      expect(await trackStore.notEmpty(), true, reason: 'notEmpty wrong');
      expect(await trackStore.empty(), false, reason: 'empty wrong');
    });
    test('empty check', () async {
      final TrackStore trackStore = TrackStore.instance();
      for (var baseTrackData in await trackStore.list()) {
        await trackStore.delete(baseTrackData.id);
      }
      expect(await trackStore.notEmpty(), false, reason: 'notEmpty wrong');
      expect(await trackStore.empty(), true, reason: 'empty wrong');
    });
  });

  tearDown(() async {
    final TrackStore trackStore = TrackStore.instance();
    trackStore.storeFilter = null;
    await trackStore.notifyAggregatesChanges();
    for (var baseTrackData in await trackStore.list()) {
      await trackStore.delete(baseTrackData.id);
    }
  });
}

class TrackData extends BaseTrackData {
  E2EEValue? avgBpm;
  num? avgRpm;

  TrackData(
      {required super.startTime,
      super.stopTime,
      super.distance,
      this.avgBpm,
      this.avgRpm});

  factory TrackData.fromFirestore(Map<String, dynamic> map) => TrackData(
      startTime: FirestoreData.fromFirestoreTimestamp(map['startTime'])!,
      avgBpm: map['avgBpm'] != null ? E2EEValue.fromJson(map['avgBpm']) : null,
      avgRpm: map['avgRpm']);

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) => {
        ...super.toFirestore(fields),
        'startTime': FirestoreData.toFirestoreTimestamp(startTime),
        if (fields?.contains('avgBpm') ?? true) 'avgBpm': avgBpm?.toJson(),
        if (fields?.contains('avgRpm') ?? true) 'avgRpm': avgRpm,
      };

  @override
  void setParentData(FirestoreData parentData) {
    BaseTrackData baseTrackData = parentData as BaseTrackData;
    startTime = baseTrackData.startTime;
    distance = baseTrackData.distance;
    stopTime = baseTrackData.stopTime;
  }

  @override
  FirestoreData getParentData() {
    return BaseTrackData(
        startTime: startTime, distance: distance, stopTime: stopTime);
  }
}

class BaseTrackData extends FirestoreData {
  static final DateFormat keyDateTimeFormatter = DateFormat('yyyyMMdd_HHmmss');

  DateTime startTime;
  DateTime? stopTime;
  num? get duration =>
      (stopTime ?? clock.now()).difference(startTime).inMilliseconds;
  num? distance;

  @override
  String get id => keyDateTimeFormatter.format(startTime.toLocal());

  bool get live => stopTime == null;

  BaseTrackData({required this.startTime, this.stopTime, this.distance});

  factory BaseTrackData.fromFirestore(Map<String, dynamic> map) {
    return BaseTrackData(
      startTime: FirestoreData.fromFirestoreTimestamp(map['startTime'])!,
      stopTime: map['stopTime'] != null
          ? FirestoreData.fromFirestoreTimestamp(map['stopTime'])
          : null,
      distance: ((map['distance'] as num? ?? 0) * 10).round() / 10,
    );
  }

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) => {
        'startTime': FirestoreData.toFirestoreTimestamp(startTime),
        if (fields?.contains('stopTime') ?? true)
          'stopTime': FirestoreData.toFirestoreTimestamp(stopTime),
        if (fields?.contains('duration') ?? true) 'duration': duration,
        if (fields?.contains('distance') ?? true) 'distance': distance,
      };
}

class TrackStore extends Store<BaseTrackData, TrackData> {
  TrackStore._({super.firebaseFirestore})
      : super(
            collection: 'tracks',
            userProfile: true,
            cacheEnabled: false,
            orderByFields: {'startTime': OrderDirection.desc},
            aggregateFields: ['distance', 'duration'],
            fromFirestoreFactory: BaseTrackData.fromFirestore,
            detailsFromFirestoreFactory: TrackData.fromFirestore,
            groupByFields: {
              'year': _groupByYear,
            });

  static String _groupByYear(TrackData trackData) {
    return '${trackData.startTime.year}';
  }

  static TrackStore? _instance;
  static TrackStore instance({dynamic firebaseFirestore}) {
    _instance ??= TrackStore._(firebaseFirestore: firebaseFirestore);
    return _instance!;
  }
}
