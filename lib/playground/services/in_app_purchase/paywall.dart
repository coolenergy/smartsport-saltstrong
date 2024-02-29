// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/layer_modifier.dart';

import '../../models/user/purchase_outcome.dart';
import '../../models/user/user.dart';

class Paywall extends StatefulWidget {
  final Offering offering;

  static const footerText = //
      """A purchase will be applied to your account upon confirmation of the amount selected. Subscriptions will automatically renew unless canceled within 24 hours of the end of the current period. You can cancel any time using your account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.""";

  const Paywall({Key? key, required this.offering}) : super(key: key);

  @override
  PaywallState createState() => PaywallState();
}

class PaywallState extends State<Paywall> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Wrap(
          children: <Widget>[
            Container(
              height: 70.0,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
              ),
              child: const Center(
                  child: Text(
                'Salt Strong Premium',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              )),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 16, left: 16.0, right: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'The World\'s Largest Saltwater Fishing Club \nAccepting New Members Today',
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ListView.builder(
              itemCount: widget.offering.availablePackages.length,
              itemBuilder: (BuildContext context, int index) {
                final product = widget.offering.availablePackages[index];
                return Card(
                  color: SaltStrongColors.greyFieldBackground,
                  child: ListTile(
                    onTap: () async {
                      try {
                        showLoadingDialog(context);
                        final customerInfo =
                            await Purchases.purchasePackage(product).whenComplete(() => Navigator.of(context).pop());

                        final entitlementID = dotenv.env['ENTITLEMENT_ID'];
                        if (entitlementID == null) throw Exception('Missing entitlement ID');
                        EntitlementInfo? entitlement = customerInfo.entitlements.all[entitlementID];
                        userData.entitlement = entitlement;

                        final purchaseOutcome = PurchaseOutcome.success(
                          entitlement: userData.entitlement!,
                          selectedPackage: product,
                        );
                        Navigator.pop(context, purchaseOutcome);
                      } catch (e) {
                        String errorMessage = e.toString();
                        if (e is PlatformException) errorMessage = e.message ?? e.details;
                        final purchaseOutcome = PurchaseOutcome.failure(
                          errorMessage: kDebugMode ? errorMessage : '',
                          debugMessage: e.toString(),
                        );
                        Navigator.pop(context, purchaseOutcome);
                      }
                    },
                    title: Text(product.storeProduct.title),
                    subtitle: Text(product.storeProduct.description),
                    trailing: Text(product.storeProduct.priceString),
                  ),
                );
              },
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 32, bottom: 16, left: 16.0, right: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  Paywall.footerText,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
