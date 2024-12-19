import 'package:flutter_heyteacher_utils/ble/data/enums.dart';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/user_data.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleUserData extends UserData {
  Map<BleType, Map<BleField, String?>> devices = {};

  @override
  String get id => authUserUid ?? "guest";

  BleUserData._(this.devices) : super(null);

  BleUserData.fromBle(Map<BleType, BluetoothDevice?> devices)
      : this._(devices.map((bleType, device) => MapEntry(bleType, {
              BleField.id: device?.remoteId.str ?? "",
              BleField.name: device?.platformName ?? ""
            })));

  factory BleUserData.fromFirestore(Map<String, dynamic> map) {
    return BleUserData._({
      for (BleType bleType in BleType.values)
        bleType: {
          BleField.id: map[bleType.firestoreFieldId],
          BleField.name: map[bleType.firestoreFieldName],
        },
    });
  }

  @override
  Map<String, dynamic> toFirestore() => {
        ...super.toFirestore(),
        // set firestoreFieldId for each ble types
        for (BleType bleType in BleType.values)
          // update only if not null, empty string for reset
          if (devices[bleType]?[BleField.id] != null)
            bleType.firestoreFieldId: devices[bleType]?[BleField.id],
        
        // set firestoreFieldName  for each ble types
        // if id in not null or empty, dont update name if is empty
        // id not null and name empty occurs when ble device is restore on app restart
        // so, in this way is preserved the stored name during scan and connect
        for (BleType bleType in BleType.values)
          if (devices[bleType]?[BleField.id] == "" ||
              (devices[bleType]?[BleField.name] != null &&
                  devices[bleType]?[BleField.name]?.trim() != ""))
            bleType.firestoreFieldName: devices[bleType]?[BleField.name],
      };

  @override
  String toString() => "${super.toString()}, "
      "bleDevices: ${devices.map((key, value) => MapEntry(key.name, "${value[BleField.name]} (${value[BleField.id]})"))}";
}
