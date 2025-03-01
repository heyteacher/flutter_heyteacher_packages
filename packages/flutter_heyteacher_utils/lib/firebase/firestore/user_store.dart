import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/store.dart';
import 'package:intl/intl.dart';

class UserStore extends Store<UserData, UserData> {
  UserStore._({super.firebaseFirestore})
      : super(
            collection: "",
            userProfile: true,
            fromFirestoreFactory: UserData.fromFirestore);

  // singleton
  static UserStore? _instance;
  static UserStore instance({dynamic firebaseFirestore}) =>
      _instance ??= UserStore._(firebaseFirestore: firebaseFirestore);

  final StreamController<UserData> _userUpdatedStreamController =
      StreamController<UserData>.broadcast();
  Stream<UserData> get onUserUpdated => _userUpdatedStreamController.stream;

  @override
  Future<void> update(UserData document,
      {required List<String> fields, String? id, WriteBatch? batch}) async {
    if (Auth.instance().autenticated) {
      await super.update(document, fields: fields, id: id, batch: batch);
      _userUpdatedStreamController.sink.add(await get(id ??= document.id));
    // anyway, yield user to stream controller  
    } else {
      _userUpdatedStreamController.sink.add(document);
    }
  }
}

class UserData extends FirestoreData {
  Locale? locale;
  ThemeMode? themeMode;
  String? purchaseToken; // readOnly

  @override
  String get id => Auth.instance().uid ?? "guest";

  @protected
  UserData({this.locale, this.themeMode, this.purchaseToken});

  factory UserData.fromFirestore(Map<String, dynamic> map) {
    return UserData(
        locale: Locale(map["locale"] ?? Intl.getCurrentLocale()),
        themeMode: switch (map["themeMode"]) {
          "light" => ThemeMode.light,
          "dark" => ThemeMode.dark,
          _ => ThemeMode.system
        },
        purchaseToken: map["purchaseToken"]);
  }

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) => {
        if (fields?.contains("locale") ?? true) "locale": locale?.languageCode,
        if (fields?.contains("themeMode") ?? true) "themeMode": themeMode?.name,
        //purchaseToken cannot be update by user
      };

  @override
  String toString() => "locale: $locale themeMode $themeMode";
}
