import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/store.dart';

class SubscriptionStore extends Store<SubscriptionData, SubscriptionData> {
  SubscriptionStore._({super.firebaseFirestore})
      : super(
            collection: "subscriptions",
            userProfile: false,
            fromFirestoreFactory: SubscriptionData.fromFirestore);

  // singleton
  static SubscriptionStore? _instance;
  static SubscriptionStore instance({dynamic firebaseFirestore}) =>
      _instance ??= SubscriptionStore._(firebaseFirestore: firebaseFirestore);

  @override
  Future<void> set(SubscriptionData detailsData,
      {String? id, WriteBatch? batch}) {
    throw Exception("set not permitted for subscriptions collection");
  }

  @override
  Future<void> update(SubscriptionData document,
      {required List<String> fields, String? id, WriteBatch? batch}) {
    throw Exception("update not permitted for subscriptions collection");
  }

  @override
  Future<void> delete(String id, {WriteBatch? batch}) {
    throw Exception("delete not permitted for subscriptions collection");
  }
}

class SubscriptionData extends FirestoreData {
  String productId;
  Iterable<BasePlanData> basePlans;

  SubscriptionData(this.productId, this.basePlans);

  @override
  String get id => productId;

  @override
  Map<String, dynamic> toFirestore(List<String>? fields) {
    throw UnimplementedError();
  }

  factory SubscriptionData.fromFirestore(Map<String, dynamic> map) =>
      SubscriptionData(
          map["productId"],
          (map["basePlans"] as Map<String, dynamic>)
              .values
              .map((inMap) => BasePlanData.fromFirestore(inMap)));
}

class BasePlanData {
  PeriodDuration billingPeriodDuration;
  String productId;
  ListingData listing;
  String? autoRenewBasePlanId;
  String? prePaidBasePlanId;
  OfferData? offer;

  BasePlanData(
      {required this.billingPeriodDuration,
      required this.productId,
      required this.listing,
      this.autoRenewBasePlanId,
      this.prePaidBasePlanId,
      this.offer});

  factory BasePlanData.fromFirestore(Map<String, dynamic> map) => BasePlanData(
      billingPeriodDuration:
          PeriodDuration.fromValue(map["billingPeriodDuration"])!,
      productId: map["productId"],
      listing: ListingData.fromFirestore(map["listing"][0]),
      autoRenewBasePlanId: map["autoRenewBasePlanId"],
      prePaidBasePlanId: map["prePaidBasePlanId"],
      offer:
          map["offer"] != null ? OfferData.fromFirestore(map["offer"]) : null);
}

class ListingData {
  String title;
  Iterable<String> benefits;
  String languageCode;

  ListingData(
      {required this.title,
      required this.languageCode,
      required this.benefits});

  factory ListingData.fromFirestore(Map<String, dynamic> map) => ListingData(
      title: map["title"],
      languageCode: map["languageCode"],
      benefits: (map["benefits"] as List<dynamic>).map((e) => e.toString()));
}

class OfferData {
  String offerId;
  AcquisitionScope acquisitionScope;
  PeriodDuration? freeDuration;
  num? freeRecurrenceCount;
  PeriodDuration? discountDuration;
  num? discountRecurrenceCount;
  num? discountRelative;

  OfferData(
      {required this.offerId,
      required this.acquisitionScope,
      this.freeDuration,
      this.freeRecurrenceCount,
      this.discountDuration,
      this.discountRecurrenceCount,
      this.discountRelative});

  factory OfferData.fromFirestore(Map<String, dynamic> map) => OfferData(
        offerId: map["offerId"],
        acquisitionScope: AcquisitionScope.fromValue(map["acquisitionScope"]),
        freeDuration: PeriodDuration.fromValue(map["freeDuration"]),
        freeRecurrenceCount: map["freeRecurrenceCount"],
        discountDuration: PeriodDuration.fromValue(map["discountDuration"]),
        discountRecurrenceCount: map["discountRecurrenceCount"],
        discountRelative: map["discountRelative"],
      );
}

enum PeriodDuration {
  weekly,
  every2Weeks,
  every3Weeks,
  every4Weeks,
  monthly,
  every2Months,
  every3Months,
  every4Months,
  every6Months,
  every8Months,
  yearly;

  static PeriodDuration? fromValue(String value) => switch (value) {
        "P1W" => PeriodDuration.weekly,
        "P2W" => PeriodDuration.every2Weeks,
        "P3W" => PeriodDuration.every3Weeks,
        "P4W" => PeriodDuration.every4Weeks,
        "P1M" => PeriodDuration.monthly,
        "P2M" => PeriodDuration.every2Months,
        "P3M" => PeriodDuration.every3Months,
        "P4M" => PeriodDuration.every4Months,
        "P6M" => PeriodDuration.every6Months,
        "P8M" => PeriodDuration.every8Months,
        "P1Y" => PeriodDuration.yearly,
        _ => null
      };
}

enum AcquisitionScope {
  thisScope,
  any;

  static AcquisitionScope fromValue(String value) => switch (value) {
        "THIS" => AcquisitionScope.thisScope,
        _ => AcquisitionScope.any
      };
}
