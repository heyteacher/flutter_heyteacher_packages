/// Defines the keys for user preferences related to Text-To-Speech stored in
/// SharedPreferences.
enum TTSPreferencesKeys {
  /// A boolean flag for the user's preference to enable or disable
  /// Text-To-Speech, overriding the global remote config setting.
  htuTtsEnableTTS,

  /// the threshold in seconds
  htuTtsThresholdInSeconds,
}
