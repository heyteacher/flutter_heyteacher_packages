import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_heyteacher_utils/context_helper.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logging/logging.dart';

class IapModel {
  final Logger _log = Logger("IapModel");

  List<PurchaseDetails> purchases = <PurchaseDetails>[];

  late String cloudFunctionURLprefix;
  StreamSubscription<List<PurchaseDetails>>? _purchaseStreamSubscription;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;

  static IapModel? _instance;
  static IapModel get instance => _instance ??= IapModel._();
  IapModel._() {
    // prefix cloud functions
    cloudFunctionURLprefix =
        // kDebugMode
        // ? FirebaseRemoteConfig.instance
        //     .getString("cloudFunctionsUrlPrefixDebug")
        // :
        FirebaseRemoteConfig.instance.getString("cloudFunctionsUrlPrefix");
    // purchase stream subscription listener
    _purchaseStreamSubscription = _inAppPurchase.purchaseStream.listen(
        (List<PurchaseDetails> purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        },
        onDone: () {},
        onError: (Object error) {
          // handle error here.
        });
  }

  dispose() {
    _purchaseStreamSubscription?.cancel();
  }

  Future<void> _listenToPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        //showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          //handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          final bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            unawaited(deliverProduct(purchaseDetails));
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  Future<void> deliverProduct(PurchaseDetails purchaseDetails) async {
    _log.info("deliverProduct ${purchaseDetails.productID}");
    purchases.add(purchaseDetails);
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    try {
      purchaseDetails.verificationData.serverVerificationData;
      HttpsCallable callable = FirebaseFunctions.instance.httpsCallableFromUrl(
        '${cloudFunctionURLprefix}iapVerifyPurchase',
        options: HttpsCallableOptions(
          timeout: const Duration(seconds: 5),
        ),
      );
      final result = await callable(
          {"token": purchaseDetails.verificationData.serverVerificationData});
      return Future<bool>.value(result.data["ok"] && result.data["result"]);
    } catch (e, s) {
      _log.severe("_verifyPurchase: error", e, s);
      return false;
    }
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    _log.warning(
        "subscription ${purchaseDetails.productID}  purchase is invalid");
    showSnackBar(
        context: ContextHelper.context,
        message:
            "subscription ${purchaseDetails.productID} purchase is invalid",
        error: true);
  }

  Future<String> userActivePurchase() async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallableFromUrl(
      '${cloudFunctionURLprefix}iapUserActivePurchase',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 5),
      ),
    );
    final result = await callable();
    final activePurchaseProductId =
        result.data["ok"] ? result.data["result"]["productId"] : null;
    _log.fine(
        "iapUserActivePurchase ok: ${result.data["ok"]} result $activePurchaseProductId");
    return activePurchaseProductId;
  }

  Future<void> availableSubscriptionsByUser() async {
    HttpsCallable callable = FirebaseFunctions.instance.httpsCallableFromUrl(
      '${cloudFunctionURLprefix}iapAvailableSubscriptionsByUser',
      options: HttpsCallableOptions(
        timeout: const Duration(seconds: 5),
      ),
    );
    final result = await callable();
    _log.fine(
        "iapAvailableSubscriptionsByUser ok: ${result.data["ok"]} result ${result.data["result"]}");
  }
}
