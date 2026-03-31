import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_auth/flutter_heyteacher_auth.dart'
    show AuthViewModel;
import 'package:flutter_heyteacher_connectivity/flutter_heyteacher_connectivity.dart';
import 'package:flutter_heyteacher_e2ee/flutter_heyteacher_e2ee.dart';
import 'package:flutter_heyteacher_store/flutter_heyteacher_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'store_test.mocks.dart';
import 'track_store.dart';

@GenerateNiceMocks([MockSpec<ConnectivityViewModel>()])
void main() {
  const userEmail = 'test@example.com';

  setUp(() async {
    final connectivityViewModel = MockConnectivityViewModel();
    when(connectivityViewModel.connected).thenAnswer((_) async => true);
    ConnectivityViewModel.instance = connectivityViewModel;

    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    WidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});
    PackageInfoPlusLinuxPlugin.registerWith();
    // mock sign-in
    unawaited(
      AuthViewModel.instance
          .signInWithEmailAndPassword(email: userEmail, password: userEmail),
    );

    // set AAD
    unawaited(E2EEViewModel.instance(AuthViewModel.instance.uid).setAAD());

    // mock firestore with mock authentication
    final firestore = FakeFirebaseFirestore(
      authObject: AuthViewModel.instance.authForFakeFirestore,
    );
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
        distance: 10000,
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
      TrackStore.instance.storeFilter = LogicalStoreFilter(
        logicalOperator: LogicalOperator.and,
        filter1: ValueStoreFilter(
          field: 'startTime',
          operator: Operator.isGreaterThanOrEqualTo,
          value: DateTime(2023),
        ),
        filter2: ValueStoreFilter(
          field: 'startTime',
          operator: Operator.isLessThan,
          value: DateTime(2024),
        ),
      );
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
      expect(aggregate.getSum('distance'), 80000, reason: 'sum distance wrong');
      expect(
        aggregate.getAverage('distance'),
        20000,
        reason: 'average distance wrong',
      );
      expect(
        aggregate.getSum('duration'),
        8 * 3600 * 1000,
        reason: 'sum duration wrong',
      );
      expect(
        aggregate.getAverage('duration'),
        2 * 3600 * 1000,
        reason: 'average duration wrong',
      );
    });
    test('aggregateStream after add track', () async {
      await TrackStore.instance.set(
        TrackData(
          startTime: DateTime.parse('2020-04-23 08:12:44'),
          stopTime: DateTime.parse('2020-04-23 10:12:44'),
          distance: 20000,
        ),
      );
      final aggregate = await TrackStore.instance.aggregateStream.first;
      expect(aggregate.count, 5, reason: 'aggregate count wrong');
      expect(
        aggregate.getSum('distance'),
        80000 + 20000,
        reason: 'sum distance wrong',
      );
      expect(
        aggregate.getSum('duration'),
        (8 + 2) * 3600 * 1000,
        reason: 'sum duration wrong',
      );
      expect(
        aggregate.getAverage('duration'),
        2 * 3600 * 1000,
        reason: 'average duration wrong',
      );
    });
    test('aggregateStream after filter', () async {
      TrackStore.instance.storeFilter = LogicalStoreFilter(
        logicalOperator: LogicalOperator.and,
        filter1: ValueStoreFilter(
          field: 'startTime',
          operator: Operator.isGreaterThanOrEqualTo,
          value: DateTime(2024),
        ),
        filter2: ValueStoreFilter(
          field: 'startTime',
          operator: Operator.isLessThan,
          value: DateTime(2025),
        ),
      );
      final list = await TrackStore.instance.list();
      expect(list.length, 2, reason: 'list length after filter wrong');
      unawaited(TrackStore.instance.notifyAggregatesChanges());
      final aggregate = await TrackStore.instance.aggregateStream.first;
      expect(aggregate.count, 2, reason: 'aggregate count wrong');
      expect(aggregate.getSum('distance'), 20000, reason: 'sum distance wrong');
      expect(aggregate.getAverage('distance'), 10000,
          reason: 'avg distance wrong',);
      expect(
        aggregate.getSum('duration'),
        2 * 3600 * 1000,
        reason: 'sum duration wrong',
      );
      expect(
        aggregate.getAverage('duration'),
        3600 * 1000,
        reason: 'aggregate duration wrong',
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
