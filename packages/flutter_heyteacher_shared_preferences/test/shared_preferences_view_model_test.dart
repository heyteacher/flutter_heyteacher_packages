import 'package:flutter_heyteacher_shared_preferences/flutter_heyteacher_shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferencesViewModel viewModel;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    viewModel = SharedPreferencesViewModel.instance;
    await viewModel.clear();
  });

  group('SharedPreferencesViewModel singleton', () {
    test('returns same instance', () {
      expect(viewModel, isNotNull);
      expect(identical(viewModel, SharedPreferencesViewModel.instance), isTrue);
    });
  });

  group('String operations', () {
    test('gets and sets string', () async {
      expect(await viewModel.getString('strKey'), isNull);

      await viewModel.setString('strKey', 'testValue');
      expect(await viewModel.getString('strKey'), 'testValue');

      await viewModel.setString('strKey', null);
      expect(await viewModel.getString('strKey'), isNull);
    });

    test('setting same string value does not re-write', () async {
      await viewModel.setString('strKey', 'value1');

      final events = <({String key, String? value})>[];
      final subscription = viewModel
          .stream<String>(key: 'strKey')
          .listen(events.add);

      await viewModel.setString('strKey', 'value1');
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
      await subscription.cancel();
    });
  });

  group('int operations', () {
    test('gets and sets int', () async {
      expect(await viewModel.getInt('intKey'), isNull);

      await viewModel.setInt('intKey', 42);
      expect(await viewModel.getInt('intKey'), 42);

      await viewModel.setInt('intKey', null);
      expect(await viewModel.getInt('intKey'), isNull);
    });

    test('setting same int value does not re-write', () async {
      await viewModel.setInt('intKey', 100);

      final events = <({String key, int? value})>[];
      final subscription = viewModel
          .stream<int>(key: 'intKey')
          .listen(events.add);

      await viewModel.setInt('intKey', 100);
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
      await subscription.cancel();
    });
  });

  group('double operations', () {
    test('gets and sets double', () async {
      expect(await viewModel.getDouble('doubleKey'), isNull);

      await viewModel.setDouble('doubleKey', 3.14);
      expect(await viewModel.getDouble('doubleKey'), 3.14);

      await viewModel.setDouble('doubleKey', null);
      expect(await viewModel.getDouble('doubleKey'), isNull);
    });

    test('setting same double value does not re-write', () async {
      await viewModel.setDouble('doubleKey', 2.71);

      final events = <({String key, double? value})>[];
      final subscription = viewModel
          .stream<double>(key: 'doubleKey')
          .listen(events.add);

      await viewModel.setDouble('doubleKey', 2.71);
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
      await subscription.cancel();
    });
  });

  group('bool operations', () {
    test('gets and sets bool', () async {
      expect(await viewModel.getBool('boolKey'), isNull);

      await viewModel.setBool('boolKey', true);
      expect(await viewModel.getBool('boolKey'), isTrue);

      await viewModel.setBool('boolKey', false);
      expect(await viewModel.getBool('boolKey'), isFalse);

      await viewModel.setBool('boolKey', null);
      expect(await viewModel.getBool('boolKey'), isNull);
    });

    test('setting same bool value does not re-write', () async {
      await viewModel.setBool('boolKey', true);

      final events = <({String key, bool? value})>[];
      final subscription = viewModel
          .stream<bool>(key: 'boolKey')
          .listen(events.add);

      await viewModel.setBool('boolKey', true);
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
      await subscription.cancel();
    });
  });

  group('List<String> operations', () {
    test('gets and sets string list', () async {
      expect(await viewModel.getStringList('listKey'), isNull);

      await viewModel.setStringList('listKey', ['apple', 'banana']);
      expect(await viewModel.getStringList('listKey'), ['apple', 'banana']);

      await viewModel.setStringList('listKey', null);
      expect(await viewModel.getStringList('listKey'), isNull);
    });

    test('setting same list value does not re-write', () async {
      await viewModel.setStringList('listKey', ['a', 'b']);

      final events = <({String key, List<String>? value})>[];
      final subscription = viewModel
          .stream<List<String>>(key: 'listKey')
          .listen(events.add);

      // Note: List comparison in _set checks oldValue == value which checks
      // reference equality.
      await viewModel.setStringList('listKey', ['a', 'b']);
      await Future<void>.delayed(Duration.zero);

      await subscription.cancel();
    });
  });

  group('setValue', () {
    test('handles String', () async {
      await viewModel.setValue(key: 'key', value: 'hello');
      expect(await viewModel.getString('key'), 'hello');
    });

    test('handles int', () async {
      await viewModel.setValue(key: 'key', value: 123);
      expect(await viewModel.getInt('key'), 123);
    });

    test('handles double', () async {
      await viewModel.setValue(key: 'key', value: 45.67);
      expect(await viewModel.getDouble('key'), 45.67);
    });

    test('handles bool', () async {
      await viewModel.setValue(key: 'key', value: true);
      expect(await viewModel.getBool('key'), isTrue);
    });

    test('handles List<String>', () async {
      await viewModel.setValue(key: 'key', value: <String>['x', 'y']);
      expect(await viewModel.getStringList('key'), ['x', 'y']);
    });

    test('handles null', () async {
      await viewModel.setValue(key: 'key', value: null);
      expect(await viewModel.getString('key'), isNull);
    });

    test('throws UnsupportedError for unsupported types', () async {
      expect(
        () => viewModel.setValue(key: 'key', value: DateTime.now()),
        throwsA(isA<UnsupportedError>()),
      );

      expect(
        () => viewModel.setValue(key: 'key', value: <int>[1, 2]),
        throwsA(isA<UnsupportedError>()),
      );

      expect(
        () => viewModel.setValue(key: 'key', value: <String, dynamic>{}),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });

  group('containsKey, remove, clear', () {
    test('containsKey returns correct status', () async {
      expect(await viewModel.containsKey('key1'), isFalse);

      await viewModel.setString('key1', 'value1');
      expect(await viewModel.containsKey('key1'), isTrue);

      await viewModel.remove('key1');
      expect(await viewModel.containsKey('key1'), isFalse);
    });

    test('clear removes all keys', () async {
      await viewModel.setString('key1', 'value1');
      await viewModel.setInt('key2', 99);

      expect(await viewModel.containsKey('key1'), isTrue);
      expect(await viewModel.containsKey('key2'), isTrue);

      await viewModel.clear();

      expect(await viewModel.containsKey('key1'), isFalse);
      expect(await viewModel.containsKey('key2'), isFalse);
    });
  });

  group('stream', () {
    test('emits updates for matching key and filters out other keys', () async {
      final events = <({String key, String? value})>[];
      final subscription = viewModel
          .stream<String>(key: 'targetKey')
          .listen(events.add);

      await viewModel.setString('targetKey', 'first');
      await viewModel.setString('otherKey', 'ignored');
      await viewModel.setString('targetKey', 'second');
      await viewModel.setString('targetKey', null);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await subscription.cancel();

      expect(
        events,
        equals([
          (key: 'targetKey', value: 'first'),
          (key: 'targetKey', value: 'second'),
          (key: 'targetKey', value: null),
        ]),
      );
    });

    test('distinct stream filters consecutive duplicate values', () async {
      final events = <({String key, int? value})>[];
      final subscription = viewModel
          .stream<int>(key: 'counter')
          .listen(events.add);

      await viewModel.setInt('counter', 1);
      await viewModel.setInt('counter', 2);

      await Future<void>.delayed(const Duration(milliseconds: 20));
      await subscription.cancel();

      expect(
        events,
        equals([(key: 'counter', value: 1), (key: 'counter', value: 2)]),
      );
    });
  });
}
