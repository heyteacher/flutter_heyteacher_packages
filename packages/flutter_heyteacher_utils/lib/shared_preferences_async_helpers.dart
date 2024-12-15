import 'package:shared_preferences/shared_preferences.dart';

extension SharedPreferencesAsyncHelpers on SharedPreferencesAsync {
  Future<String> getStringWithDefault(String key, String defaultValue) async =>
      await getString(key) ?? defaultValue;
}
