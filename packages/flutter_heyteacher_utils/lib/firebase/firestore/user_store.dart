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

  @override
  String get id => Auth.instance().uid ?? "guest";

  @protected
  UserData(this.localeLanguageCode);

  UserData.fromLocale({required locale}) : this(locale.languageCode);

  factory UserData.fromFirestore(Map<String, dynamic> map) {
    return UserData(map["localeLanguageCode"]);
  }

  @override
  Map<String, dynamic> toFirestore({List<String>? fields}) => {
        if (fields?.contains("localeLanguageCode") ?? true)
          "localeLanguageCode": localeLanguageCode
      };

  @override
  String toString() => "localeLanguageCode: $localeLanguageCode";
}
