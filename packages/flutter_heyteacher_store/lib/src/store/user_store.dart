import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_store/src/store/store.dart';
import 'package:flutter_heyteacher_utils/firebase.dart';
import 'package:intl/intl.dart';

/// The User Store implementation to manage [UserData] storec in `/users/[uid]/`
/// Firestore collection.
class UserStore extends Store<UserData, UserData> {
  UserStore._({super.firebaseFirestore})
      : super(
            collection: '',
            userProfile: true,
            fromFirestoreFactory: UserData.fromFirestore);

  // singleton
  static UserStore? _instance;
  static UserStore instance({dynamic firebaseFirestore}) =>
      _instance ??= UserStore._(firebaseFirestore: firebaseFirestore);

  final StreamController<UserData> _userUpdatedStreamController =
      StreamController<UserData>.broadcast();
  Stream<UserData> get onUserUpdated => _userUpdatedStreamController.stream;

  /// Update the user data.
  /// 
  /// If user isn't authenticated, doesn't update and doesn't raise Exception 
  /// but yield in [_userUpdatedStreamController] the documents.
  @override
  Future<void> update(UserData document,
      {required List<String> fields, String? id, WriteBatch? batch}) async {
    if (AuthModel.instance().autenticated) {
      await super.update(document, fields: fields, id: id, batch: batch);
      _userUpdatedStreamController.sink.add(await get(id ??= document.id));
    // anyway, yield user to stream controller  
    } else {
      _userUpdatedStreamController.sink.add(document);
    }
  }
}

/// the User [FirestoreData] implementation.
class UserData extends FirestoreData {

  /// the user locale
  Locale? locale;

  /// the user [ThemeMode] 
  ThemeMode? themeMode;

  /// The user purchaseToken of subscription
  String? purchaseToken; // readOnly

  /// The user identifier supplyed by Auth if authenticated otherwise `guest`.
  @override
  String get id => AuthModel.instance().uid ?? 'guest';

  @protected
  UserData({this.locale, this.themeMode, this.purchaseToken});

  factory UserData.fromFirestore(Map<String, dynamic> map) {
    return UserData(
        locale: Locale(map['locale'] ?? Intl.getCurrentLocale()),
        themeMode: switch (map['themeMode']) {
          'light' => ThemeMode.light,
          'dark' => ThemeMode.dark,
          _ => ThemeMode.system
        },
        purchaseToken: map['purchaseToken']);
  }

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) => {
        if (fields?.contains('locale') ?? true) 'locale': locale?.languageCode,
        if (fields?.contains('themeMode') ?? true) 'themeMode': themeMode?.name,
        //purchaseToken cannot be update by user
      };

  @override
  String toString() => 'locale: $locale themeMode $themeMode';
}
