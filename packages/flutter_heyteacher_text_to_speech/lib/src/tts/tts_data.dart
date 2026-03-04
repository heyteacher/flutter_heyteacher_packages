/// Defines the keys for Firebase Remote Config values related 
/// to Text-To-Speech.
enum TTSRemoteConfigKeys {
  /// A boolean flag to enable or disable Text-To-Speech functionality globally.
  ttsEnable,

  /// An integer representing the minimum time in seconds between consecutive
  /// speech requests to prevent spamming.
  ttsThresholdInSeconds
}

/// Defines the keys for user preferences related to Text-To-Speech stored in
/// SharedPreferences.
enum TTSPreferencesKeys {
  /// A boolean flag for the user's preference to enable or disable
  /// Text-To-Speech, overriding the global remote config setting.
  htuTtsEnableTTS
}
