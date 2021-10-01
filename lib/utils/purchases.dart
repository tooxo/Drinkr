import 'dart:ui';

import 'package:drinkr/menus/game_mode.dart';
import 'package:drinkr/widgets/buy_premium.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

const String isPurchasedKey = "PREMIUM_IS_PURCHASED_KEY";

class Purchases {
  static PurchaseState purchaseState = PurchaseState.available;

  static Future<bool> isPremiumPurchased() async {
    const bool premiumOverride = bool.fromEnvironment("OVERRIDE_PREMIUM");
    if (premiumOverride) {
      return true;
    }

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(isPurchasedKey) ?? false;
  }

  static Future<void> setPremiumPurchased() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(isPurchasedKey, true);
  }

  static Future<void> removePremiumPurchased() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(isPurchasedKey, false);
  }

  static void openPremiumMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Material(
          color: Colors.transparent,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: BuyPremium(
              modal: true,
            ),
          ),
        );
      },
    );
  }

  static void listenToPurchaseUpdated(
    List<PurchaseDetails> purchaseDetailsList,
    void Function(void Function()) setState,
  ) {
    // ignore: avoid_function_literals_in_foreach_calls
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          purchaseState = PurchaseState.inProgress;
        });
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          setState(() {
            purchaseState = PurchaseState.available;
          });
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          setState(() {
            purchaseState = PurchaseState.done;
          });
          await Purchases.setPremiumPurchased();
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  static Future<bool> purchasePremium() async {
    print("starting purchase process");
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(<String>{"premium"});
    if (response.notFoundIDs.isNotEmpty) {
      return false;
    }
    List<ProductDetails> products = response.productDetails;
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: products
          .where(
            (element) => element.id == "premium",
          )
          .first,
    );
    await InAppPurchase.instance.buyNonConsumable(
      purchaseParam: purchaseParam,
    );
    return true;
  }
}
