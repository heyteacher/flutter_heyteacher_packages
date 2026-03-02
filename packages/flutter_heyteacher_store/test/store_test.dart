import 'dart:async';

import 'package:clock/clock.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_store/flutter_heyteacher_store.dart';
import 'package:flutter_heyteacher_utils/connectivity.dart';
import 'package:flutter_heyteacher_utils/e2ee.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:flutter_heyteacher_utils/platform_helper.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'store_test.mocks.dart';

part 'store_test.g.dart';

@GenerateNiceMocks([MockSpec<ConnectivityViewModel>()])
void main() {
  const userId = 'testuid';
  const userEmail = 'test@example.com';
  const userDisplayName = 'Test User';

  setUp(() async {
    final connectivityViewModel = MockConnectivityViewModel();
    when(connectivityViewModel.connected).thenAnswer((_) async => true);
    ConnectivityViewModel.instance = connectivityViewModel;

    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    WidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
    PackageInfoPlusLinuxPlugin.registerWith();
    // mock authentication
    final auth = MockFirebaseAuth(
      mockUser: MockUser(
        uid: userId,
        email: userEmail,
        displayName: userDisplayName,
      ),
    );
    // mock sign-in
    unawaited(
      auth.signInWithEmailAndPassword(email: userEmail, password: userEmail),
    );

    // initialize Auth with MockFirebaseAuth
    AuthViewModel.instance = AuthViewModel(mockedFirebaseAuth: auth);

    // set AAD
    unawaited(
      E2EEViewModel.instance(AuthViewModel.instance.uid)
          .setAAD(aadValue: 'aadValue'),
    );

    // mock firestore with mock authentication
    final firestore =
        FakeFirebaseFirestore(authObject: auth.authForFakeFirestore);
    TrackStore.instance = TrackStore(firebaseFirestore: firestore);

    // initialize

    await TrackStore.instance.set(
      TrackData(
        startTime: DateTime.parse('2024-02-27 13:27:56'),
        stopTime: DateTime.parse('2024-02-27 14:27:56'),
        distance: 10000,
      ),
    );
    await TrackStore.instance.set(
      TrackData(
        startTime: DateTime.parse('2024-04-27 13:27:56'),
        stopTime: DateTime.parse('2024-04-27 14:27:56'),
        distance: 20000,
      ),
    );
    await TrackStore.instance.set(
      TrackData(
        startTime: DateTime.parse('2023-07-12 17:15:22'),
        stopTime: DateTime.parse('2023-07-12 20:15:22'),
        distance: 30000,
        avgBpm: await E2EEViewModel.instance(AuthViewModel.instance.uid)
            .encrypt('100'),
      ),
    );
    await TrackStore.instance.set(
      TrackData(
        startTime: DateTime.parse('2023-09-12 17:15:22'),
        stopTime: DateTime.parse('2023-09-12 20:15:22'),
        distance: 30000,
      ),
    );
  });

  group('track list, filter group:', () {
    test('store should contains 4 tracks', () async {
      expect(
        (await TrackStore.instance.list()).length,
        4,
        reason: 'wrong store size',
      );
    });
    test('store should contains 2 tracks filtered by startTime in 2023',
        () async {
      expect(
        (await TrackStore.instance.list()).length,
        2,
        reason: 'wrong store size after filtering',
      );
    });
  });
  group('track exists and get:', () {
    test('store contains 20230712_171522', () async {
      expect(
        await TrackStore.instance.exists('20230712_171522'),
        true,
        reason: "track does't exists",
      );
    });
    test("store track doesn't exist after delete", () async {
      await TrackStore.instance.delete('20230712_171522');
      expect(
        await TrackStore.instance.exists('20230712_171522'),
        false,
        reason: 'track exists',
      );
    });
    test('store get track and check fields', () async {
      final trackData = await TrackStore.instance.get('20230712_171522');
      expect(trackData.avgBpm != null, true, reason: 'avgBpm is null ');
      expect(
        await E2EEViewModel.instance(AuthViewModel.instance.uid)
            .decrypt(trackData.avgBpm!),
        '100',
        reason: 'avgBpm wrong',
      );
      expect(trackData.distance, 30000, reason: 'distance  wrong');
      expect(trackData.duration, 3600 * 3 * 1000, reason: 'duration  wrong');
    });
  });

  group('track update group:', () {
    test('update', () async {
      var trackData = (await TrackStore.instance.get('20230712_171522'))
          .copyWith
          .avgRpm(80);
      await TrackStore.instance.update(trackData, fields: ['avgRpm']);
      trackData = await TrackStore.instance.get('20230712_171522');
      expect(trackData.avgRpm, 80, reason: 'avgRpm wrong');
      expect(
        await E2EEViewModel.instance(AuthViewModel.instance.uid)
            .decrypt(trackData.avgBpm!),
        '100',
        reason: 'avgBpm wrong',
      );
      expect(trackData.distance, 30000, reason: 'distance wrong');
      expect(trackData.duration, 3600 * 3 * 1000, reason: 'duration  wrong');
    });
    test('set single field', () async {
      var trackData = TrackData(
        startTime: DateTime.parse('2023-07-12 17:15:22'),
        avgRpm: 80,
        distance: 0,
      );
      await TrackStore.instance.set(trackData);

      trackData = await TrackStore.instance.get('20230712_171522');
      expect(trackData.avgRpm, 80, reason: 'avgRpm wrong');
      expect(trackData.avgBpm, null, reason: 'avgBpm wrong');
      expect(trackData.distance, 0, reason: 'distance wrong');
    });
    test('update single field', () async {
      var trackData = await TrackStore.instance.get('20230712_171522');
      trackData = TrackData(
        startTime: DateTime.parse('2023-07-12 17:15:22'),
        avgRpm: 80,
        distance: 30000,
      );
      await TrackStore.instance
          .update(trackData, fields: ['avgRpm', 'distance']);
      trackData = await TrackStore.instance.get('20230712_171522');
      expect(trackData.avgRpm, 80, reason: 'avgRpm wrong');
      expect(
        await E2EEViewModel.instance(AuthViewModel.instance.uid)
            .decrypt(trackData.avgBpm!),
        '100',
        reason: 'avgBpm wrong',
      );
      expect(trackData.distance, 30000, reason: 'distance wrong');
      expect(trackData.duration, 3600 * 3 * 1000, reason: 'duration  wrong');
    });
  });

  group('track groupByCounter group:', () {
    test('groupByCounter years check map', () async {
      expect(
        (await TrackStore.instance.groupBy())?.length,
        2,
        reason: 'years wrong size',
      );
      expect(
        (await TrackStore.instance.groupBy())
            ?.where((e) => e.groupByFields['year'] == '2023')
            .first
            .value,
        2,
        reason: 'year 2023 wrong size',
      );
      expect(
        (await TrackStore.instance.groupBy())
            ?.where((e) => e.groupByFields['year'] == '2024')
            .first
            .value,
        2,
        reason: 'year 2024 wrong size',
      );
    });
    test('groupByCounter years check  map after add new track', () async {
      await TrackStore.instance
          .set(TrackData(startTime: DateTime(2020), distance: 0));
      expect(
        (await TrackStore.instance.groupBy())!.length,
        3,
        reason: 'years wrong size',
      );
      expect(
        (await TrackStore.instance.groupBy())!
            .where((e) => e.groupByFields['year'] == '2020')
            .first
            .value,
        1,
        reason: 'year 2020 wrong size',
      );
      expect(
        (await TrackStore.instance.groupBy())!
            .where((e) => e.groupByFields['year'] == '2023')
            .first
            .value,
        2,
        reason: 'year 2023 wrong size',
      );
      expect(
        (await TrackStore.instance.groupBy())!
            .where((e) => e.groupByFields['year'] == '2024')
            .first
            .value,
        2,
        reason: 'year 2024 wrong size',
      );
    });
    test('track groupByCounter order of keys', () async {
      expect(
        (await TrackStore.instance.groupBy())?.map((e) => e.key),
        ['2023', '2024'],
      );
      expect(
        (await TrackStore.instance
                .groupBy(groupByFieldsOrderDirection: OrderDirection.desc))
            ?.map((e) => e.key),
        ['2024', '2023'],
      );
    });
  });
  group('track aggregateStream group:', () {
    test('aggregateStream check', () async {
      unawaited(TrackStore.instance.notifyAggregatesChanges());
      final aggregate = await TrackStore.instance.aggregateStream.first;
      expect(aggregate.count, 4, reason: 'aggregate count wrong');
      expect(aggregate.getSum('distance'), 90000, reason: 'sum distance wrong');
      expect(
        aggregate.getSum('duration'),
        8 * 3600 * 1000,
        reason: 'sum duration wrong',
      );
    });
    test('aggregateStream after add track', () async {
      await TrackStore.instance.set(
        TrackData(
          startTime: DateTime.parse('2020-04-23 08:12:44'),
          stopTime: DateTime.parse('2020-04-23 09:12:44'),
          distance: 20000,
        ),
      );
      final aggregate = await TrackStore.instance.aggregateStream.first;
      expect(aggregate.count, 5, reason: 'aggregate count wrong');
      expect(
        aggregate.getSum('distance'),
        90000 + 20000,
        reason: 'sum distance wrong',
      );
      expect(
        aggregate.getSum('duration'),
        (8 + 1) * 3600 * 1000,
        reason: 'sum duration wrong',
      );
    });
    test('aggregateStream after filter', () async {
      final list = await TrackStore.instance.list();
      expect(list.length, 2, reason: 'list length after filter wrong');
      unawaited(TrackStore.instance.notifyAggregatesChanges());
      final aggregate = await TrackStore.instance.aggregateStream.first;
      expect(aggregate.count, 2, reason: 'aggregate count wrong');
      expect(aggregate.getSum('distance'), 30000, reason: 'sum distance wrong');
      expect(
        aggregate.getSum('duration'),
        2 * 3600 * 1000,
        reason: 'sum duration wrong',
      );
    });
  });

  group('track empty notEmpty group:', () {
    test('not empty check', () async {
      expect(
        await TrackStore.instance.notEmpty(),
        true,
        reason: 'notEmpty wrong',
      );
      expect(await TrackStore.instance.empty(), false, reason: 'empty wrong');
    });
    test('empty check', () async {
      for (final baseTrackData in await TrackStore.instance.list()) {
        await TrackStore.instance.delete(baseTrackData.id);
      }
      expect(
        await TrackStore.instance.notEmpty(),
        false,
        reason: 'notEmpty wrong',
      );
      expect(await TrackStore.instance.empty(), true, reason: 'empty wrong');
    });
  });

  tearDown(() async {
    await TrackStore.instance.notifyAggregatesChanges();
    for (final baseTrackData in await TrackStore.instance.list()) {
      await TrackStore.instance.delete(baseTrackData.id);
    }
  });
}

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
        if (fields?.contains('stopTime') ?? true)
          'stopTime': FirestoreData.toFirestoreTimestamp(stopTime),
        if (fields?.contains('duration') ?? true) 'duration': duration,
        if (fields?.contains('distance') ?? true) 'distance': distance,
      };
}

class TrackStore extends Store<BaseTrackData, TrackData> {
  TrackStore({super.firebaseFirestore})
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
          },
          // if web or test, use bkdb database
          databaseId: PlatformHelper.isNotMobile ? 'bkdb' : null,
        );

  static String _groupByYear(TrackData trackData) {
    return '${trackData.startTime.year}';
  }

  static TrackStore? _instance;

  /// Creates singleton [TrackStore] instance
  // ignore: prefer_constructors_over_static_methods
  static TrackStore get instance => _instance ??= TrackStore();
  static set instance(TrackStore instance) => _instance = instance;
}
