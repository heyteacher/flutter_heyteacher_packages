import 'package:flutter_heyteacher_utils/firebase/firestore/store.dart';

class Subscription extends FirestoreData {
  String productId;
  BasePlan basePlan;

  Subscription(this.productId, this.basePlan);

  @override
  String get id => productId;

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) {
    throw UnimplementedError();
  }

  factory Subscription.fromFirestore(Map<String, dynamic> map) =>
      Subscription(map["productId"], BasePlan.fromFirestore(map["basePlan"]));
}

class BasePlan {
  String billingPeriodDuration;
  String productId;
  String? autoRenewBasePlanId;
  String? prePaidBasePlanId;
  Offer? offer;

  BasePlan(
      {required this.billingPeriodDuration,
      required this.productId,
      this.autoRenewBasePlanId,
      this.prePaidBasePlanId,
      this.offer});

  factory BasePlan.fromFirestore(Map<String, dynamic> map) => BasePlan(
      billingPeriodDuration: map["billingPeriodDuration"],
      productId: map["productId"],
      autoRenewBasePlanId: map["autoRenewBasePlanId"],
      prePaidBasePlanId: map["prePaidBasePlanId"],
      offer: map["offer"] != null ? Offer.fromFirestore(map["offer"]) : null);
}

class Offer {
  String offerId;
  String acquisitionScope;
  String? freeDuration;
  num? freeRecurrenceCount;
  String? discountDuration;
  num? discountRecurrenceCount;
  num? discountRelative;

  Offer(
      {required this.offerId,
      required this.acquisitionScope,
      this.freeDuration,
      this.freeRecurrenceCount,
      this.discountDuration,
      this.discountRecurrenceCount,
      this.discountRelative});

  factory Offer.fromFirestore(Map<String, dynamic> map) => Offer(
        offerId: map["offerId"],
        acquisitionScope: map["acquisitionScope"],
        freeDuration: map["freeDuration"],
        freeRecurrenceCount: map["freeRecurrenceCount"],
        discountDuration: map["discountDuration"],
        discountRecurrenceCount: map["discountRecurrenceCount"],
        discountRelative: map["discountRelative"],
      );
}

class SubscriptionPurchase extends FirestoreData {
  String purchaseToken;
  String uid;
  Purchase purchase;

  SubscriptionPurchase(
      {required this.purchaseToken, required this.uid, required this.purchase});

  @override
  String get id => purchaseToken;

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) {
    throw UnimplementedError();
  }

  factory SubscriptionPurchase.fromFirestore(Map<String, dynamic> map) =>
      SubscriptionPurchase(
          purchaseToken: map["purchaseToken"],
          uid: map["uid"],
          purchase: Purchase.fromFirestore(map["purchase"]));
}

class Purchase {
  Purchase();
  factory Purchase.fromFirestore(Map<String, dynamic> map) => Purchase();
}
