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

  /// A stream that emits an event whenever [key] changes.
  ///
  /// Widgets can listen to this stream to rebuild when the key is updated.
  Stream<({String key, T? value})> stream<T>({required String key}) =>
      _streamController.stream
          .where((e) => e.key == key)
          .cast<({String key, T? value})>()
          .distinct();

  /// Gets string for [key] in [SharedPreferences].
  ///
  /// If [key] is not found, it returns [defaultValue].
  Future<String?> getString(String key, {String? defaultValue}) async =>
      (await _sharedPrefs.getString(key)) ?? defaultValue;

  /// Gets int for [key] in [SharedPreferences].
  ///
  /// If [key] is not found, it returns [defaultValue].
  Future<int?> getInt(String key, {int? defaultValue}) async =>
      (await _sharedPrefs.getInt(key)) ?? defaultValue;

  /// Gets double for [key] in [SharedPreferences].
  ///
  /// If [key] is not found, it returns [defaultValue].
  Future<double?> getDouble(String key, {double? defaultValue}) async =>
      (await _sharedPrefs.getDouble(key)) ?? defaultValue;

  /// Gets boolean [key] in [SharedPreferences].
  ///
  /// If [key] is not found, it returns [defaultValue].
  Future<bool?> getBool(String key, {bool? defaultValue}) async =>
      (await _sharedPrefs.getBool(key)) ?? defaultValue;

  /// Gets a list of strings from [SharedPreferences].
  ///
  /// If [key] is not found, it returns [defaultValue].
  Future<List<String>?> getStringList(
    String key, {
    List<String>? defaultValue,
  }) async => (await _sharedPrefs.getStringList(key)) ?? defaultValue;

  /// Sets string [value] for [key] in [SharedPreferences].
  ///
  /// If the [value] is null, the key is removed from [SharedPreferences].
  Future<void> setString(String key, String? value) =>
      _set<String>(key, value, getString, _sharedPrefs.setString);

  /// Sets int [value] for [key] in [SharedPreferences].
  ///
  /// If the [value] is null, the key is removed from [SharedPreferences].
  Future<void> setInt(String key, int? value) =>
      _set<int>(key, value, getInt, _sharedPrefs.setInt);

  /// Sets double [value] for [key] in [SharedPreferences].
  ///
  /// If the [value] is null, the key is removed from [SharedPreferences].
  Future<void> setDouble(String key, double? value) =>
      _set<double>(key, value, getDouble, _sharedPrefs.setDouble);

  /// Sets boolean [value] for [key] in [SharedPreferences].
  ///
  /// If the [value] is null, the key is removed from [SharedPreferences].
  // ignore: avoid_positional_boolean_parameters
  Future<void> setBool(String key, bool? value) =>
      _set<bool>(key, value, getBool, _sharedPrefs.setBool);

  /// Sets a list of strings in [SharedPreferences].
  ///
  /// If the [value] is null, the key is removed from [SharedPreferences].
  Future<void> setStringList(String key, List<String>? value) =>
      _set<List<String>>(key, value, getStringList, _sharedPrefs.setStringList);

  /// Sets a generic [value] for [key] in [SharedPreferences].
  ///
  ///  Throws [UnsupportedError] if the type is not supported:
  ///  - [String]
  ///  - [int]
  ///  - [double]
  ///  - [bool]
  ///  - [List] of [String]
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
      case null:
        await remove(key);
      case _:
        throw UnsupportedError(
          'Unsupported type ${value.runtimeType} for key $key',
        );
    }
  }

  /// Removes [key] from [SharedPreferences].
  Future<void> remove(String key) => _sharedPrefs.remove(key);

  /// Checks if a [key] exists in [SharedPreferences].
  Future<bool> containsKey(String key) => _sharedPrefs.containsKey(key);

  /// Clears all keys from [SharedPreferences].
  Future<void> clear() => _sharedPrefs.clear();

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
}
