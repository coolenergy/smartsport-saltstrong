// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/material.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/layer_modifier.dart';

import '../../models/user/purchase_outcome.dart';
import '../../models/user/user.dart';
import 'paywall.dart';
import '../../../auth/widgets/purchase_dialog.dart';
import 'store_config.dart';

class InAppPurchaseService {
  static void initializeStoreConfig() {
    assert(Platform.isAndroid || Platform.isIOS);
    final store = Platform.isIOS ? Store.appStore : Store.playStore;
    final apiKey = Platform.isIOS ? dotenv.env['IAP_KEY_IOS'] : dotenv.env['IAP_KEY_ANDROID'];
     StoreConfig(store: store, apiKey: apiKey!);
  }

  static Future<void> configureSDK() async {
    // Enable debug logs before calling `configure`.
    await Purchases.setLogLevel(LogLevel.debug);
    /*
    - appUserID is nil, so an anonymous ID will be generated automatically by the Purchases SDK.
    Read more about Identifying Users here: https://docs.revenuecat.com/docs/user-ids

    - observerMode is false, so Purchases will automatically handle finishing transactions.
    Read more about Observer Mode here: https://docs.revenuecat.com/docs/observer-mode
    */
    PurchasesConfiguration configuration;

    configuration = PurchasesConfiguration(StoreConfig.instance.apiKey)
      ..appUserID = null
      ..observerMode = false;

    await Purchases.configure(configuration);
  }

  static Future<void> updateUserEntitlement() async {
   await Purchases.invalidateCustomerInfoCache();
    CustomerInfo customerInfo = await Purchases.getCustomerInfo();
    final entitlementID = dotenv.env['ENTITLEMENT_ID'];
    assert(entitlementID != null, 'Missing entitlement ID');
    userData.entitlement = customerInfo.entitlements.all[entitlementID];
  }

  static Future<void> initPlatformState() async {
    userData.appUserID = await Purchases.appUserID;

    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      userData.appUserID = await Purchases.appUserID;
      updateUserEntitlement();
    });
  }

  static Future<PurchaseOutcome> openPaywall(BuildContext context) async {
    await Purchases.invalidateCustomerInfoCache();

    showLoadingDialog(context);

    updateUserEntitlement();
    if (userData.entitlementIsActive) {
      Navigator.of(context).pop();
      return PurchaseOutcome.failure(
        errorMessage: PurchaseOutcome.entitlementAlreadyActiveErrorMessage,
        debugMessage: PurchaseOutcome.entitlementAlreadyActiveErrorMessage,
        entitlement: userData.entitlement,
      );
    }

    Offerings? offerings;
    try {
      offerings = await Purchases.getOfferings();
    } on PlatformException catch (e) {
      await showDialog(
        context: context,
        builder: (BuildContext context) => PurchaseDialog(
          title: "Error",
          content: e.message ?? "Unknown error",
          buttonText: 'OK',
        ),
      );

      /// There is an issue with your configuration. Check the underlying error for more details.
      /// There's a problem with your configuration. None of the products registered in the
      /// RevenueCat dashboard could be fetched from App Store Connect
      /// (or the StoreKit Configuration file if one is being used).
      /// More information: https://rev.cat/why-are-offerings-empty

      Navigator.of(context).pop(); // Todo success maybe???
      return PurchaseOutcome.failure(debugMessage: e.message);
    }

    Navigator.of(context).pop();

    // ignore: unnecessary_null_comparison
    if (offerings == null || offerings.current == null) {
      return PurchaseOutcome.failure(
        errorMessage: PurchaseOutcome.emptyOfferingsErrorMessage,
        debugMessage: PurchaseOutcome.emptyOfferingsErrorMessage,
      );
    }

    // current offering is available, show paywall
    final result = await showModalBottomSheet<PurchaseOutcome>(
      useRootNavigator: true,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (BuildContext context, StateSetter setModalState) {
          return Paywall(offering: offerings!.current!);
        });
      },
    );

    return result ?? PurchaseOutcome.failure(debugMessage: 'User closed the paywall');
  }

  static Future<CustomerInfo> getCustomerInfo() async{
    await Purchases.invalidateCustomerInfoCache();

    return Purchases.getCustomerInfo();
  }


}
