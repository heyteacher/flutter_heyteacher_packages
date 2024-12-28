import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/store.dart';

class UserStore extends Store<UserData, UserData> {

  UserStore._()
      : super(
            collection: "",
            userProfile: true,
            fromFirestoreFactory: UserData.fromFirestore);

  // singleton
  static UserStore? _instance;
  static UserStore get instance {
    _instance ??= UserStore._();
    return _instance!;
  }
}

class UserData extends FirestoreData {
  String? localeLanguageCode;

  @override
  String get id => FirebaseAuth.instance.currentUser?.uid ?? "guest";

  @protected
  UserData(this.localeLanguageCode);

  UserData.fromLocalization({required locale}) : this(locale.languageCode);

  factory UserData.fromFirestore(Map<String, dynamic> map) {
    return UserData(map["locale_language_code"]);
  }

  @override
  Map<String, dynamic> toFirestore() => {
        if (localeLanguageCode != null)
          "locale_language_code": localeLanguageCode
      };

  @override
  String toString() => "localeLanguageCode: $localeLanguageCode";
}
