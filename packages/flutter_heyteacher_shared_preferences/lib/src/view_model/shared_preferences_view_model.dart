import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

/// View model for [SharedPreferences] operations.
///
/// Emits an event whenever a value in [SharedPreferences] changes.
class SharedPreferencesViewModel {
  /// Creates a new [SharedPreferencesViewModel].
  SharedPreferencesViewModel._();

  static SharedPreferencesViewModel? _instance;

  /// The singleton instance of [SharedPreferencesViewModel].
  // ignore: prefer_constructors_over_static_methods
  static SharedPreferencesViewModel get instance =>
      _instance ??= SharedPreferencesViewModel._();

  final SharedPreferencesAsync _sharedPrefs = SharedPreferencesAsync();

  final StreamController<({String key, Object? value})> _streamController =
      StreamController<({String key, Object? value})>.broadcast();

  /// A stream that emits an event whenever a key changes.
  ///
  /// Widgets can listen to this stream to rebuild when the key is updated.
  Stream<({String key, T? value})> stream<T>({required String key}) =>
      _streamController.stream
          .where((e) => e.key == key)
          .cast<({String key, T? value})>()
          .distinct();

  /// Gets a string value from [SharedPreferences].
  ///
  ///  - [key]: The key used to store and retrieve the value.
  Future<String?> getString(String key) => _sharedPrefs.getString(key);

  /// Gets an integer value from [SharedPreferences].
  ///
  ///  - [key]: The key used to store and retrieve the value.
  Future<int?> getInt(String key) => _sharedPrefs.getInt(key);

  /// Gets a double value from [SharedPreferences].
  ///
  ///  - [key]: The key used to store and retrieve the value.
  Future<double?> getDouble(String key) => _sharedPrefs.getDouble(key);

  /// Gets a boolean value from [SharedPreferences].
  ///
  ///  - [key]: The key used to store and retrieve the value.
  Future<bool?> getBool(String key) => _sharedPrefs.getBool(key);

  /// Sets a string value in [SharedPreferences].
  ///
  ///  - [key]: The key used to store and retrieve the value.
  ///  - [value]: The value to store.
  Future<void> setString(String key, String? value) =>
      _set<String>(key, value, getString, _sharedPrefs.setString);

  /// Sets an integer value in [SharedPreferences].
  ///
  ///  - [key]: The key used to store and retrieve the value.
  ///  - [value]: The value to store.
  Future<void> setInt(String key, int? value) =>
      _set<int>(key, value, getInt, _sharedPrefs.setInt);

  /// Sets a double value in [SharedPreferences].
  ///
  ///  - [key]: The key used to store and retrieve the value.
  ///  - [value]: The value to store.
  Future<void> setDouble(String key, double? value) =>
      _set<double>(key, value, getDouble, _sharedPrefs.setDouble);

  /// Sets a boolean value in [SharedPreferences].
  ///
  ///  - [key]: The key used to store and retrieve the value.
  ///  - [value]: The value to store.
  Future<void> setBool(
    String key,
    //
    // ignore: avoid_positional_boolean_parameters
    bool? value,
  ) => _set<bool>(key, value, getBool, _sharedPrefs.setBool);

  /// Sets a value in [SharedPreferences].
  ///
  ///  - [key]: The key used to store and retrieve the value.
  ///  - [value]: The value to store.
  ///
  ///  Throws [UnsupportedError] if the type is not supported.
  Future<void> setValue({required String key, required Object? value}) async {
    switch (value) {
      case String():
        await setString(key, value);
      case int():
        await setInt(key, value);
      case double():
        await setDouble(key, value);
      case bool():
        await setBool(key, value);
      case List<String>():
        await setStringList(key, value);
      case _:
        throw UnsupportedError(
          'Unsupported type ${value.runtimeType} for key $key',
        );
    }
  }

  Future<void> _set<T>(
    String key,
    T? value,
    Future<T?> Function(String) getter,
    Future<void> Function(String, T) setter,
  ) async {
    final oldValue = await getter(key);
    if (oldValue == value) return;
    if (value == null) {
      await _sharedPrefs.remove(key);
    } else {
      await setter(key, value);
    }
    _streamController.add((key: key, value: value));
  }

  /// Removes [key] from [SharedPreferences].
  Future<void> remove(String key) => _sharedPrefs.remove(key);

  /// Gets a list of strings from [SharedPreferences].
  Future<List<String>?> getStringList(String key) =>
      _sharedPrefs.getStringList(key);

  /// Sets a list of strings in [SharedPreferences].
  Future<void> setStringList(String key, List<String>? value) =>
      _set<List<String>>(key, value, getStringList, _sharedPrefs.setStringList);

  /// Checks if a [key] exists in [SharedPreferences].
  Future<bool> containsKey(String key) => _sharedPrefs.containsKey(key);

  /// Clears all keys from [SharedPreferences].
  Future<void> clear() => _sharedPrefs.clear();
}
