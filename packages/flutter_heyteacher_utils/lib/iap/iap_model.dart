import 'dart:async';
import 'dart:ui';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_heyteacher_utils/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/firebase/firestore/user_store.dart';
import 'package:flutter_heyteacher_utils/iap/google_play_purchase_details_ext.dart';
import 'package:flutter_heyteacher_utils/iap/subscription_purchase_store.dart';
import 'package:flutter_heyteacher_utils/iap/subscription_store.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:logging/logging.dart';

class IapModel {
  final Logger _log = Logger("IapModel");

  bool pendingRemoveValidatePurchase = false;

  StreamSubscription<List<PurchaseDetails>>? _iapPurchaseStreamSubscription;
  late String _cloudFunctionURLprefix;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  VoidCallback? _refreshFn;
  void setRefresh(VoidCallback refreshFn) {
    _refreshFn = refreshFn;
  }

  // remeber: stream must be a funtion or getter in order to reinitialize
  // when condition changes. 
  // In these case, stream will be initialized only when user is auth.
  // Previously the fiels stream remain null after user login
  Stream<SubscriptionPurchaseData?>? get subscriptionPurchaseStream =>
      Auth.instance().autenticated
          ? SubscriptionPurchaseStore.instance()
              .stream
              .map((querySnapshot) => querySnapshot.docs.firstOrNull?.data())
          : null;

  static IapModel? _instance;
  static IapModel get instance => _instance ??= IapModel._();
  IapModel._() {
    // prefix cloud functions
    _cloudFunctionURLprefix =
        FirebaseRemoteConfig.instance.getString("cloudFunctionsUrlPrefix");
    // purchase stream subscription listener
    _iapPurchaseStreamSubscription = _inAppPurchase.purchaseStream.listen(
        (List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _iapPurchaseStreamSubscription?.cancel();
    }, onError: (Object error) {
      _log.severe("_inAppPurchase.purchaseStream.listen error", error);
    });
  }

  dispose() {
    _iapPurchaseStreamSubscription?.cancel();
  }

  Future<void> iapRestorePurchase() => _inAppPurchase.restorePurchases();

  Future<bool> iapIsAvailable() => _inAppPurchase.isAvailable();

  Future<SubscriptionPurchaseData?> userSubscriptionPurchase() async {
    UserData? userData =
        await UserStore.instance().getOrNull(Auth.instance().uid ?? "guest");
    if (userData == null) {
      return null;
    }
    return SubscriptionPurchaseStore.instance()
        .getOrNull(userData.purchaseToken);
  }

  Future<SubscriptionsProductDetails> subscriptionsProductDetails() async {
    try {
      // retrieve from firestore the list of subscriptions
      Iterable<SubscriptionData> subscriptions =
          await SubscriptionStore.instance().list();
      // initialize return value
      final subscriptionsProductDetailsValue =
          SubscriptionsProductDetails(subscriptions: subscriptions);
      // query iap to select product details
      final ProductDetailsResponse productDetailResponse = await _inAppPurchase
          .queryProductDetails(subscriptions.map((e) => e.productId).toSet());
      // populate the map of productDetails organized by subscriptionId
      // (offerId or basePlanId)
      for (var productDetails in productDetailResponse.productDetails) {
        final googlePlayProductDetails =
            (productDetails as GooglePlayProductDetails).productDetails;
        // get the subscription offer based on  subscriptionIndex
        final SubscriptionOfferDetailsWrapper? subscriptionOfferDetailsWrapper =
            googlePlayProductDetails.subscriptionOfferDetails?[
                productDetails.subscriptionIndex ?? 0];
        // add the subscription offer to product details map
        subscriptionsProductDetailsValue.productDetailsMap[
            subscriptionOfferDetailsWrapper!.offerId ??
                subscriptionOfferDetailsWrapper.basePlanId] = productDetails;
      }
      return subscriptionsProductDetailsValue;
    } on Exception catch (e, s) {
      _log.severe("subscriptionsProductDetails: error", e, s);
      rethrow;
    }
  }

  void buySubscription(ProductDetails productDetails,
      SubscriptionPurchaseData? subscriptionPurchaseData) {
    final GooglePlayPurchaseDetails? oldSubscription =
        _getOldSubscription(productDetails, subscriptionPurchaseData);

    final purchaseParam = GooglePlayPurchaseParam(
        productDetails: productDetails,
        changeSubscriptionParam: (oldSubscription != null)
            ? ChangeSubscriptionParam(
                oldPurchaseDetails: oldSubscription,
                replacementMode: ReplacementMode.withTimeProration,
              )
            : null);
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  GooglePlayPurchaseDetails? _getOldSubscription(ProductDetails productDetails,
      SubscriptionPurchaseData? subscriptionPurchaseData) {
    // This is just to demonstrate a subscription upgrade or downgrade.
    // This method assumes that you have only 2 subscriptions under a group, 'subscription_silver' & 'subscription_gold'.
    // The 'subscription_silver' subscription can be upgraded to 'subscription_gold' and
    // the 'subscription_gold' subscription can be downgraded to 'subscription_silver'.
    // Please remember to replace the logic of finding the old subscription Id as per your app.
    // The old subscription is only required on Android since Apple handles this internally
    // by using the subscription group feature in iTunesConnect.
    if (subscriptionPurchaseData == null ||
        !subscriptionPurchaseData.purchase.subscriptionPurchaseState.isValid ||
        productDetails.id == subscriptionPurchaseData.purchase.productId) {
      return null;
    }
    return subscriptionPurchaseData.googlePlayPurchaseDetails;
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      _log.info("_listenToPurchaseUpdated: status ${purchaseDetails.status}");
      if (purchaseDetails.status != PurchaseStatus.pending) {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _log.info("_listenToPurchaseUpdated: "
              "error ${purchaseDetails.error}");
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _remoteVerifyPurchase(
              purchaseDetails as GooglePlayPurchaseDetails);
          if (valid) {
            _log.info("_listenToPurchaseUpdated: "
                "valid ${purchaseDetails.productID}");
          } else {
            pendingRemoveValidatePurchase = true;
            if (_refreshFn != null) _refreshFn!();
            _log.info("_listenToPurchaseUpdated: "
                "not valid ${purchaseDetails.productID}");
            return;
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          _log.info("_listenToPurchaseUpdated: "
              "iap completePurchase ${purchaseDetails.productID}");
          await _inAppPurchase.completePurchase(purchaseDetails);
          pendingRemoveValidatePurchase = false;
          if (_refreshFn != null) _refreshFn!();
        }
      }
    }
  }

  Future<bool> _remoteVerifyPurchase(
      GooglePlayPurchaseDetails googlePlayPurchaseDetails) async {
    try {
      googlePlayPurchaseDetails.verificationData.serverVerificationData;
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallableFromUrl(
        '${_cloudFunctionURLprefix}iapVerifyPurchase',
        // options: HttpsCallableOptions(
        //   timeout: const Duration(seconds: 10),
        // ),
      );
      _log.fine("_verifyPurchase: invoke remote function iapVerifyPurchase");
      final result = await callable({
        "token":
            googlePlayPurchaseDetails.verificationData.serverVerificationData,
        "googlePlayPurchaseDetails": googlePlayPurchaseDetails.toJson()
      });
      _log.fine(
          "_verifyPurchase: result remote function iapVerifyPurchase ${result.data}");
      return Future<bool>.value(result.data["ok"] && result.data["result"]);
    } catch (e, s) {
      _log.severe("_verifyPurchase: error", e, s);
      return false;
    }
  }
}

class SubscriptionsProductDetails {
  Iterable<SubscriptionData> subscriptions;
  Map<String, ProductDetails> productDetailsMap = {};

  SubscriptionsProductDetails({required this.subscriptions});
}
