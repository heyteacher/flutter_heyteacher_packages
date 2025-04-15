import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heyteacher_utils/src/firebase/auth.dart';
import 'package:flutter_heyteacher_utils/src/iap/iap_model.dart';
import 'package:flutter_heyteacher_utils/src/iap/iap_plan.dart';
import 'package:flutter_heyteacher_utils/src/iap/subscription_purchase_store.dart';
import 'package:flutter_heyteacher_utils/src/iap/subscription_store.dart';
import 'package:flutter_heyteacher_utils/localizations.dart';
import 'package:flutter_heyteacher_utils/theme.dart';
import 'package:flutter_heyteacher_utils/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:url_launcher/url_launcher.dart';

class IapScreen extends StatefulWidget {
  final Map<String, IAPPlan> iapPlanMap;

  const IapScreen({super.key, required this.iapPlanMap});

  @override
  State<IapScreen> createState() => _IapScreenState();
}

class _IapScreenState extends State<IapScreen> {
  @override
  void initState() {
    IapModel.instance
        .setRefresh(() => context.mounted ? setState(() {}) : null);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          FlutterHeyteacherUtilsLocalizations.of(context)!.subscriptions,
        )),
        body: SafeArea(
          child: ListView(
            children: <Widget>[
              if (IapModel.instance.pendingRemoveValidatePurchase)
                _buildRestoreButton(),
              _buildConnectionCheckTile(),
              SubscriptionPurchaseWidget(
                  showGoToIap: false, iapPlanMap: widget.iapPlanMap),
              ProductListWidget(iapPlanMap: widget.iapPlanMap),
            ],
          ),
        ));
  }

  Widget _buildConnectionCheckTile() {
    return FutureBuilder(
        future: IapModel.instance.iapIsAvailable(),
        builder: (context, snapshot) => snapshot.error != null
            ? ErrorView(snapshot.error, snapshot.stackTrace) // error
            : !(snapshot.data ?? true) // not connected
                ? Card(child: ListTile(title: Text('Trying to connect...')))
                : SizedBox.shrink()); // connected
  }

  Widget _buildRestoreButton() {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: ThemeHepler.instance().orangeTextColor,
              foregroundColor: Theme.of(context).primaryColor,
            ),
            onPressed: () => IapModel.instance.iapRestorePurchase(),
            child: const Text('Restore Pending Purchases'),
          ),
        ],
      ),
    );
  }
}

class ProductListWidget extends StatelessWidget {
  final Map<String, IAPPlan> iapPlanMap;

  const ProductListWidget({super.key, required this.iapPlanMap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SubscriptionPurchaseData?>(
        future: IapModel.instance.userSubscriptionPurchase(),
        builder: (_, futureSnapshot) => StreamBuilder<
                SubscriptionPurchaseData?>(
            stream: IapModel.instance.subscriptionPurchaseStream,
            builder: (_, streamSnapshot) => FutureBuilder<
                    SubscriptionsProductDetails>(
                future: IapModel.instance.subscriptionsProductDetails(),
                builder: (_, snapshot) {
                  final subscriptionPurchaseData =
                      streamSnapshot.data ?? futureSnapshot.data;
                  List<Widget> cards = [];
                  if (snapshot.hasData) {
                    for (SubscriptionData subscriptionData
                        in snapshot.data?.subscriptions ?? []) {
                      cards.add(Card(
                        color: iapPlanMap[subscriptionData.productId]
                            ?.color
                            .withValues(alpha: 0.3),
                        child: Column(
                          children: [
                            ListTile(
                              leading: iapPlanMap[subscriptionData.productId]
                                  ?.leading,
                              title: Text(iapPlanMap[subscriptionData.productId]
                                      ?.title ??
                                  ""),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (var feature
                                      in iapPlanMap[subscriptionData.productId]
                                              ?.features ??
                                          [])
                                    Text(feature)
                                ],
                              ),
                            ),
                            ..._buildBasePlanList(
                                context,
                                subscriptionData,
                                subscriptionPurchaseData,
                                snapshot.data?.productDetailsMap)
                          ],
                        ),
                      ));
                    }
                  }
                  return Column(
                    children: cards,
                  );
                })));
  }

  Iterable<Widget> _buildBasePlanList(
      BuildContext context,
      SubscriptionData subscriptionData,
      SubscriptionPurchaseData? subscriptionPurchaseData,
      Map<String, ProductDetails>? productDetailsMap) {
    List<ListTile> listTiles = [];
    for (BasePlanData basePlanData in subscriptionData.basePlans) {
      if (productDetailsMap?[basePlanData.offer!.offerId] != null) {
        listTiles.add(ListTile(
          title: Text(
              "${FlutterHeyteacherUtilsLocalizations.of(context)!.periodDuration(basePlanData.billingPeriodDuration.name)} - "
              "${FlutterHeyteacherUtilsLocalizations.of(context)!.autoRenew}"),
          subtitle: Text(
            (iapPlanMap[subscriptionData.productId]?.offerConditionText ?? "")
                .replaceAll(
                    "_BASEPRICE_",
                    productDetailsMap?[basePlanData.autoRenewBasePlanId]
                            ?.price ??
                        ""),
          ),
          trailing: (subscriptionPurchaseData
                              ?.purchase.subscriptionPurchaseState.isValid ??
                          false) &&
                      subscriptionPurchaseData?.purchase.basePlanId ==
                          basePlanData.autoRenewBasePlanId ||
                  subscriptionPurchaseData?.purchase.offerId ==
                      basePlanData.offer!.offerId
              ? Badge(
                  textColor: ThemeHepler.instance().theme.colorScheme.onPrimary,
                  backgroundColor:
                      iapPlanMap[subscriptionData.productId]?.color,
                  padding: EdgeInsets.only(
                      top: 12.0, bottom: 12.0, left: 4, right: 4),
                  label: Text(FlutterHeyteacherUtilsLocalizations.of(context)!
                      .yourPlan),
                )
              : _buildBuyButton(
                  context,
                  productDetailsMap?[basePlanData.offer!.offerId],
                  subscriptionPurchaseData,
                  basePrice:
                      productDetailsMap?[basePlanData.autoRenewBasePlanId]
                              ?.price ??
                          ""),
        ));
      } else {
        if (productDetailsMap?[basePlanData.autoRenewBasePlanId] != null) {
          listTiles.add(ListTile(
            //leading: Text(basePlanData.autoRenewBasePlanId!),
            title: Text(
                "${FlutterHeyteacherUtilsLocalizations.of(context)!.periodDuration(basePlanData.billingPeriodDuration.name)} - "
                "${FlutterHeyteacherUtilsLocalizations.of(context)!.autoRenew}"),
            trailing: (subscriptionPurchaseData
                            ?.purchase.subscriptionPurchaseState.isValid ??
                        false) &&
                    (subscriptionPurchaseData?.purchase.basePlanId ==
                            basePlanData.autoRenewBasePlanId ||
                        subscriptionPurchaseData?.purchase.offerId ==
                            basePlanData.offer?.offerId)
                ? Badge(
                    textColor:
                        ThemeHepler.instance().theme.colorScheme.onPrimary,
                    backgroundColor:
                        iapPlanMap[subscriptionData.productId]?.color,
                    padding: EdgeInsets.only(
                        top: 12.0, bottom: 12.0, left: 4, right: 4),
                    label: Text(FlutterHeyteacherUtilsLocalizations.of(context)!
                        .yourPlan),
                  )
                : _buildBuyButton(
                    context,
                    productDetailsMap?[basePlanData.autoRenewBasePlanId],
                    subscriptionPurchaseData),
          ));
        }
      }
      if (productDetailsMap?[basePlanData.prePaidBasePlanId] != null) {
        listTiles.add(ListTile(
          title: Text(
              "${FlutterHeyteacherUtilsLocalizations.of(context)!.periodDuration(basePlanData.billingPeriodDuration.name)} - "
              "${FlutterHeyteacherUtilsLocalizations.of(context)!.withoutRenew}"),
          trailing: (subscriptionPurchaseData
                          ?.purchase.subscriptionPurchaseState.isValid ??
                      false) &&
                  subscriptionPurchaseData?.purchase.basePlanId ==
                      basePlanData.prePaidBasePlanId
              ? Badge(
                  textColor: ThemeHepler.instance().theme.colorScheme.onPrimary,
                  backgroundColor:
                      iapPlanMap[subscriptionData.productId]?.color,
                  padding: EdgeInsets.only(
                      top: 12.0, bottom: 12.0, left: 2, right: 2),
                  label: Text(FlutterHeyteacherUtilsLocalizations.of(context)!
                      .yourPlan),
                )
              : _buildBuyButton(
                  context,
                  productDetailsMap?[basePlanData.prePaidBasePlanId],
                  subscriptionPurchaseData),
        ));
      }
    }
    return listTiles.map(
      (listTile) => Card(
        color: iapPlanMap[subscriptionData.productId]
            ?.color
            .withValues(alpha: 0.4),
        child: listTile,
      ),
    );
  }

  _buildBuyButton(BuildContext context, ProductDetails? productDetails,
      SubscriptionPurchaseData? subscriptionPurchaseData,
      {String? basePrice}) {
    if (productDetails == null) {
      return null;
    }
    return TextButton(
        style: TextButton.styleFrom(
          backgroundColor: ThemeHepler.instance().theme.colorScheme.primary,
          foregroundColor: ThemeHepler.instance().theme.colorScheme.onPrimary,
        ),
        onPressed: () {
          IapModel.instance
              .buySubscription(productDetails, subscriptionPurchaseData);
        },
        child: basePrice == null
            ? Text(productDetails.price)
            : RichText(
                text: TextSpan(
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                    children: [
                    TextSpan(
                        style:
                            TextStyle(decoration: TextDecoration.lineThrough),
                        text: basePrice),
                    TextSpan(text: " "),
                    TextSpan(text: productDetails.price),
                  ])));
  }
}

class SubscriptionPurchaseWidget extends StatelessWidget {
  final Map<String, IAPPlan> iapPlanMap;
  final bool showGoToIap;

  const SubscriptionPurchaseWidget(
      {super.key, required this.iapPlanMap, required this.showGoToIap});

  @override
  Widget build(BuildContext context) {
    return Card(
        child: StreamBuilder<User?>(
            stream: Auth.instance().stateChangesStream,
            builder: (_, snapshot) {
              return FutureBuilder<SubscriptionPurchaseData?>(
                  future: IapModel.instance.userSubscriptionPurchase(),
                  builder: (_, futureSnapshot) => StreamBuilder<
                          SubscriptionPurchaseData?>(
                      stream: IapModel.instance.subscriptionPurchaseStream,
                      builder: (_, streamSnapshot) {
                        final subscriptionPurchaseData =
                            streamSnapshot.data ?? futureSnapshot.data;
                        // snapshot.hasError
                        // ? ErrorView(snapshot.error, snapshot.stackTrace)
                        // :
                        return subscriptionPurchaseData != null
                            ? ListTile(
                                leading: Badge(
                                    textColor: Theme.of(context).primaryColor,
                                    backgroundColor: subscriptionPurchaseData
                                        .purchase
                                        .subscriptionPurchaseState
                                        .color,
                                    padding: EdgeInsets.all(8.0),
                                    label: Text(
                                        FlutterHeyteacherUtilsLocalizations.of(
                                                context)!
                                            .subscriptionPurchaseState(
                                                subscriptionPurchaseData
                                                    .purchase
                                                    .subscriptionPurchaseState
                                                    .name))),
                                title: Text(
                                    "${FlutterHeyteacherUtilsLocalizations.of(context)!.yourPlan}:\n"
                                    "${iapPlanMap[subscriptionPurchaseData.purchase.productId]?.title}"),
                                subtitle: Text(
                                    FlutterHeyteacherUtilsLocalizations.of(
                                            context)!
                                        .expiryDateTime(
                                            subscriptionPurchaseData
                                                .purchase.expiryTime
                                                .toLocal(),
                                            subscriptionPurchaseData
                                                .purchase.expiryTime
                                                .toLocal())),
                                trailing: showGoToIap
                                    ? IconButton(
                                        icon: Icon(Icons.keyboard_arrow_right),
                                        onPressed: () {
                                          GoRouter.of(context)
                                              .go("/settings/iap");
                                        },
                                      )
                                    : TextButton(
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              ThemeHepler.instance()
                                                  .theme
                                                  .colorScheme
                                                  .primary,
                                          foregroundColor:
                                              ThemeHepler.instance()
                                                  .theme
                                                  .colorScheme
                                                  .onPrimary,
                                        ),
                                        onPressed: () => launchUrl(Uri.parse(
                                            "http://play.google.com/store/account/subscriptions")),
                                        child: Text(FlutterHeyteacherUtilsLocalizations.of(
                                            context)!
                                        .manage)),
                              )
                            : ListTile(
                                title: Text(
                                    FlutterHeyteacherUtilsLocalizations.of(
                                            context)!
                                        .noPlanPurchased),
                                trailing: showGoToIap
                                    ? Icon(Icons.keyboard_arrow_right)
                                    : null,
                                onTap: showGoToIap
                                    ? () {
                                        GoRouter.of(context)
                                            .go("/settings/iap");
                                      }
                                    : null,
                              );
                      }));
            }));
  }
}
