import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/store.dart';

class UserStore extends Store<UserData, UserData> {
  UserStore._({super.firebaseFirestore})
      : super(
            collection: "",
            userProfile: true,
            fromFirestoreFactory: UserData.fromFirestore);

  // singleton
  static UserStore? _instance;
  static UserStore instance({dynamic firebaseFirestore}) {
    _instance ??= UserStore._(firebaseFirestore: firebaseFirestore);
    return _instance!;
  }
}

class UserData extends FirestoreData {
  String? localeLanguageCode;
  String? themeMode;

  @override
  String get id => Auth.instance().uid ?? "guest";

  @protected
  UserData({this.localeLanguageCode, this.themeMode});

  UserData.fromLocale({required Locale locale})
      : this(localeLanguageCode: locale.languageCode);

  UserData.fromThemeMode({required ThemeMode themeMode})
      : this(themeMode: themeMode.name);

  factory UserData.fromFirestore(Map<String, dynamic> map) {
    return UserData(
        localeLanguageCode: map["localeLanguageCode"],
        themeMode: map["themeMode"]);
  }

  @override
  Map<String, dynamic> toFirestore({List<String>? fields}) => {
        if (fields?.contains("localeLanguageCode") ?? true)
          "localeLanguageCode": localeLanguageCode,
        if (fields?.contains("themeMode") ?? true) "themeMode": themeMode
      };

  @override
  String toString() =>
      "localeLanguageCode: $localeLanguageCode themeMode $themeMode";
}
