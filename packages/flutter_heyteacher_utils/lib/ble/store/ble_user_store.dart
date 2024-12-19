
import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/store.dart';

class BleUserStore extends Store<BleUserData, BleUserData> {
  // singleton
  static BleUserStore? _instance;
  static BleUserStore get instance {
    _instance ??= BleUserStore._(
        collection: "",
        listFromFirestoreFactory: BleUserData.fromFirestore,
        objectFromFirestoreFactory: BleUserData.fromFirestore);
    return _instance!;
  }

  BleUserStore._(
      {required super.collection,
      required super.listFromFirestoreFactory,
      required super.objectFromFirestoreFactory});
      
}
