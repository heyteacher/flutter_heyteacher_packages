import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/store.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/store_filters.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'google_play_purchase_details_ext.dart';

class SubscriptionPurchaseStore
    extends Store<SubscriptionPurchaseData, SubscriptionPurchaseData> {
  SubscriptionPurchaseStore._({super.firebaseFirestore})
      : super(
            collection: "subscription_purchases",
            userProfile: false,
            orderByFields: {"startTime": OrderDirection.desc},
            fromFirestoreFactory: SubscriptionPurchaseData.fromFirestore);

  // singleton
  static SubscriptionPurchaseStore? _instance;
  static SubscriptionPurchaseStore instance({dynamic firebaseFirestore}) =>
      _instance ??=
          SubscriptionPurchaseStore._(firebaseFirestore: firebaseFirestore);

  @override
  Query<SubscriptionPurchaseData> query(
      {bool applyOrderBy = false, bool applyFilterBy = true, int? limit}) {
    super.storeFilter = ValueStoreFilter(
        field: "uid",
        operator: Operator.isEqualTo,
        value: Auth.instance().uid ?? "unauth");
    return super.query(applyOrderBy: true, applyFilterBy: true, limit: limit);
  }

  @override
  Future<void> set(SubscriptionPurchaseData detailsData,
      {String? id, WriteBatch? batch}) {
    throw Exception("set not permitted for subscription_purchases collection");
  }

  @override
  Future<void> update(SubscriptionPurchaseData document,
      {required List<String> fields, String? id, WriteBatch? batch}) {
    throw Exception(
        "update not permitted for subscription_purchases collection");
  }

  @override
  Future<void> delete(String id, {WriteBatch? batch}) {
    throw Exception(
        "delete not permitted for subscription_purchases collection");
  }
}

class SubscriptionPurchaseData extends FirestoreData {
  String purchaseToken;
  String uid;
  DateTime startTime;
  PurchaseData purchase;
  GooglePlayPurchaseDetails? googlePlayPurchaseDetails;

  SubscriptionPurchaseData(
      {required this.purchaseToken,
      required this.uid,
      required this.startTime,
      required this.purchase,
      required this.googlePlayPurchaseDetails});

  @override
  String get id => purchaseToken;

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) {
    throw UnimplementedError();
  }

  factory SubscriptionPurchaseData.fromFirestore(Map<String, dynamic> map) =>
      SubscriptionPurchaseData(
          purchaseToken: map["purchaseToken"],
          uid: map["uid"],
          startTime: DateTime.parse(map["startTime"]),
          purchase: PurchaseData.fromFirestore(map["purchase"]),
          googlePlayPurchaseDetails: GooglePlayPurchaseDetailsExt.fromJson(
              map["googlePlayPurchaseDetails"]));
}

class PurchaseData {
  SubscriptionPurchaseState subscriptionPurchaseState;
  DateTime startTime;
  String productId;
  String basePlanId;
  String? offerId;
  DateTime expiryTime;

  String get subscriptionId => offerId ?? basePlanId;

  PurchaseData(
      {required this.subscriptionPurchaseState,
      required this.startTime,
      required this.productId,
      required this.basePlanId,
      this.offerId,
      required this.expiryTime});

  factory PurchaseData.fromFirestore(Map<String, dynamic> map) => PurchaseData(
      subscriptionPurchaseState:
          SubscriptionPurchaseState.fromValue(map["subscriptionState"]),
      startTime: DateTime.parse(map["startTime"]),
      productId: map["lineItems"][0]["productId"],
      basePlanId: map["lineItems"][0]["offerDetails"]["basePlanId"],
      offerId: map["lineItems"][0]["offerDetails"]["offerId"],
      expiryTime: DateTime.parse(map["lineItems"][0]["expiryTime"]));
}

enum SubscriptionPurchaseState {
  // Unspecified subscription state.
  unspecified, // = "SUBSCRIPTION_STATE_UNSPECIFIED",
  // Subscription was created but awaiting payment during signup.
  // In this state, all items are awaiting payment.
  pending, //"SUBSCRIPTION_STATE_PENDING",
  // Subscription is active.
  // - (1) If the subscription is an auto renewing plan, at least one item is
  //   autoRenewEnabled and not expired.
  // - (2) If the subscription is a prepaid plan, at least one item is not
  //   expired.
  active, //"SUBSCRIPTION_STATE_ACTIVE",
  // Subscription is paused. The state is only available when the subscription
  // is an auto renewing plan. In this state, all items are in paused state.
  paused, //"SUBSCRIPTION_STATE_PAUSED",
  // subscription is in grace period. The state is only available when
  // the subscription is an auto renewing plan. In this state, all items are in
  // grace period.
  inGracePeriod, //"SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
  // Subscription is on hold (suspended). The state is only available when
  // the subscription is an auto renewing plan. In this state, all items are on
  // hold.
  onHold, //"SUBSCRIPTION_STATE_ON_HOLD",
  // Subscription is canceled but not expired yet. The state is only available
  // when the subscription is an auto renewing plan. All items have
  // autoRenewEnabled set to false.
  canceled, //"SUBSCRIPTION_STATE_CANCELED",
  // 	Subscription is expired. All items have expiryTime in the past.
  expired, //"SUBSCRIPTION_STATE_EXPIRED",
  // Pending transaction for subscription is canceled.
  // If this pending purchase was for an existing subscription,
  // use linkedPurchaseToken to get the current state of that subscription.
  pendingPurchaseCanceled; //"SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED"

  static SubscriptionPurchaseState fromValue(String value) => switch (value) {
        "SUBSCRIPTION_STATE_UNSPECIFIED" =>
          SubscriptionPurchaseState.unspecified,
        "SUBSCRIPTION_STATE_PENDING" => SubscriptionPurchaseState.pending,
        "SUBSCRIPTION_STATE_ACTIVE" => SubscriptionPurchaseState.active,
        "SUBSCRIPTION_STATE_PAUSED" => SubscriptionPurchaseState.paused,
        "SUBSCRIPTION_STATE_IN_GRACE_PERIOD" =>
          SubscriptionPurchaseState.inGracePeriod,
        "SUBSCRIPTION_STATE_ON_HOLD" => SubscriptionPurchaseState.onHold,
        "SUBSCRIPTION_STATE_CANCELED" => SubscriptionPurchaseState.canceled,
        "SUBSCRIPTION_STATE_EXPIRED" => SubscriptionPurchaseState.expired,
        "SUBSCRIPTION_STATE_PENDING_PURCHASE_CANCELED" =>
          SubscriptionPurchaseState.pendingPurchaseCanceled,
        _ => SubscriptionPurchaseState.unspecified,
      };

  Color get color => switch (this) {
        active => ThemeHepler.instance().greenTextColor,
        canceled => ThemeHepler.instance().greenTextColor,
        pending => ThemeHepler.instance().orangeTextColor,
        paused => ThemeHepler.instance().orangeTextColor,
        inGracePeriod => ThemeHepler.instance().orangeTextColor,
        _ => ThemeHepler.instance().theme.colorScheme.onError
      };
  bool get isValid =>
      this == SubscriptionPurchaseState.active ||
      this == SubscriptionPurchaseState.canceled;
}
