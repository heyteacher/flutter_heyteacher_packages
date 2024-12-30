import 'package:flutter_heyteacher_utils/ble/data/ble_user_data.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/store.dart';

class BleUserStore extends Store<BleUserData, BleUserData> {
  // singleton
  static BleUserStore? _instance;
  static BleUserStore instance({dynamic firebaseFirestore}) {
    _instance ??= BleUserStore._(firebaseFirestore: firebaseFirestore);
    return _instance!;
  }

  BleUserStore._({super.firebaseFirestore})
      : super(
            collection: "",
            userProfile: true,
            fromFirestoreFactory: BleUserData.fromFirestore);
}
