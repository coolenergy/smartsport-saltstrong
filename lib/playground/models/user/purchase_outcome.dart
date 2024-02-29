import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

class PurchaseOutcome {
  static const entitlementAlreadyActiveErrorMessage = 'Entitlement Already Active.';
  static const emptyOfferingsErrorMessage = 'Offerings are empty';

  final bool failed;
  final String deviceOS;
  final String? errorMessage; // message to be displayed to the user
  final String? debugMessage; // message to be displayed only to the developer/tester
  final EntitlementInfo? entitlement;
  final Package? selectedPackage;

  PurchaseOutcome({
    required this.failed,
    required this.deviceOS,
    this.errorMessage,
    this.debugMessage,
    this.entitlement,
    this.selectedPackage,
  });

  factory PurchaseOutcome.failure({
    String errorMessage = '',
    EntitlementInfo? entitlement,
    String? debugMessage,
  }) =>
      PurchaseOutcome(
        failed: true,
        entitlement: entitlement,
        errorMessage: errorMessage,
        debugMessage: debugMessage,
        deviceOS: Platform.operatingSystem,
      );

  factory PurchaseOutcome.success({
    required EntitlementInfo entitlement,
    String? debugMessage,
    Package? selectedPackage,
  }) =>
      PurchaseOutcome(
        failed: false,
        entitlement: entitlement,
        debugMessage: debugMessage,
        selectedPackage: selectedPackage,
        deviceOS: Platform.operatingSystem,
      );

  @override
  String toString() {
    if (failed) {
      return 'PurchaseOutcomeWithError($errorMessage; $debugMessage; '
          'entitlement $entitlement; '
          'selectedPackage $selectedPackage'
          ')';
    }
    return 'PurchaseOutcomeWithSuccess($debugMessage; entitlement: $entitlement)';
  }
}
