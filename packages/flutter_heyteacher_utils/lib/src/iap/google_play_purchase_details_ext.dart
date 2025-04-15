import 'dart:convert';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

extension PurchaseWrapperExt on PurchaseWrapper {
  static PurchaseWrapper fromJson(Map<String, dynamic> map) => PurchaseWrapper(
        isAcknowledged: map["acknowledged"],
        orderId: map["orderId"],
        isAutoRenewing: map["autoRenewing"],
        originalJson: jsonEncode(map),
        packageName: map["packageName"],
        products: [map["productId"]],
        purchaseState: switch (map["purchaseState"]) {
          1 => PurchaseStateWrapper.pending,
          2 => PurchaseStateWrapper.purchased,
          _ => PurchaseStateWrapper.unspecified_state,
        },
        purchaseTime: map["purchaseTime"],
        purchaseToken: map["purchaseToken"],
        signature: "", //map["signature"],
        developerPayload: map["developerPayload"],
        obfuscatedAccountId: map["obfuscatedAccountId"],
        obfuscatedProfileId: map["obfuscatedProfileId"],
        pendingPurchaseUpdate: map["pendingPurchaseUpdate"] != null
            ? PendingPurchaseUpdateWrapper(
                purchaseToken: map["pendingPurchaseUpdate"]["purchaseToken"],
                products: map["pendingPurchaseUpdate"]["products"])
            : null,
      );
}

extension PurchaseVerificationDataExt on PurchaseVerificationData {
  Map<String, dynamic> toJson() => {
        "localVerificationData": localVerificationData,
        "serverVerificationData": serverVerificationData,
        "source": source,
      };

  static PurchaseVerificationData fromJson(Map<String, dynamic> map) =>
      PurchaseVerificationData(
          localVerificationData: map["localVerificationData"],
          serverVerificationData: map["serverVerificationData"],
          source: map["source"]);
}

extension GooglePlayPurchaseDetailsExt on GooglePlayPurchaseDetails {
  Map<String, dynamic> toJson() => {
        "billingClientPurchase": billingClientPurchase.originalJson,
        "productID": productID,
        "pendingCompletePurchase": pendingCompletePurchase,
        "status": status.name,
        "verificationData": verificationData.toJson(),
        "purchaseID": purchaseID,
        "transactionDate": transactionDate
      };

  static GooglePlayPurchaseDetails? fromJson(Map<String, dynamic>? map) =>
      map != null
          ? GooglePlayPurchaseDetails(
              billingClientPurchase: PurchaseWrapperExt.fromJson(
                  jsonDecode(map["billingClientPurchase"])),
              productID: map["productID"],
              status: switch (map["status"]) {
                "canceled" => PurchaseStatus.canceled,
                "pending" => PurchaseStatus.pending,
                "purchased" => PurchaseStatus.purchased,
                "restored" => PurchaseStatus.restored,
                _ => PurchaseStatus.error,
              },
              transactionDate: map["transactionDate"],
              verificationData:
                  PurchaseVerificationDataExt.fromJson(map["verificationData"]),
              purchaseID: map["purchaseID"])
          : null;
}
