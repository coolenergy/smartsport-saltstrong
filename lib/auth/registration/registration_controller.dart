// ignore_for_file: use_build_context_synchronously, avoid_public_notifier_properties

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:salt_strong_poc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:salt_strong_poc/auth/utils/input_validation.dart';
import 'package:salt_strong_poc/auth/widgets/salt_strong_greeting.dart';
import 'package:salt_strong_poc/playground/helpers/logger.dart';
import 'package:salt_strong_poc/playground/models/user/registration_query.dart';
import 'package:salt_strong_poc/playground/services/in_app_purchase/in_app_purchase_service.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/layer_modifier.dart';

import '../../playground/models/user/access_keys_query.dart';
import '../../playground/models/user/membership_query.dart';
import '../../playground/services/user/user_service.dart';
import '../../playground/models/user/user.dart';
import '../../routing/router.dart';
import 'email_provider.dart';

final registrationControllerProvider = NotifierProvider<RegistrationController, AuthState>(() {
  return RegistrationController();
});

class RegistrationController extends Notifier<AuthState> {
  RegistrationController();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final ScrollController scrollController = ScrollController();

  String get _firstName => firstNameController.text.trim();

  String get _lastName => lastNameController.text.trim();

  String get email => emailController.text.trim().toLowerCase();

  UserRegistrationRequest _createRegistrationRequest(String accessKey2, String revenueCatId) =>
      UserRegistrationRequest(
        firstName: _firstName,
        lastName: _lastName,
        email: email,
        accessKey: accessKey2,
        revenueCatId: revenueCatId,
      );

  bool showEmailError = false;

  @override
  AuthState build() {
    InAppPurchaseService.initPlatformState();
    return AuthSuccess();
  }

  Future<GetAccessKeyResponse> fetchUserAccessData() async {
    if (userData.hasAccessKeys) return userData.accessData!;
    userData.accessData = await ref.read(userServiceProvider).getAccessKey();
    return userData.accessData!;
  }

  void onRegister({required BuildContext context, required WidgetRef ref}) async {
    /// Validating input data
    if (!_validate()) return;

    showLoadingDialog(context);

    /// Acquiring access keys necessary for the registration apis
    final userAccessData = await fetchUserAccessData();
    if (userAccessData.isError) {
      state = AuthInputError(AuthValidator.networkConnectionErrorMessage);
      Navigator.of(context).pop();
      return;
    }

    /// Checking if user is already a Salt Strong member
    final request = UserValidationRequest(email: email, accessKey: userAccessData.accessKey1!);
    final userValidationData = await ref.read(userServiceProvider).checkUserMembership(request);
    if (userValidationData.hasMembership) {
      state = AuthInputError(AuthValidator.alreadyASaltStrongMember);
      Navigator.of(context).pop();
      return;
    }

    /// Buying Salt Strong membership
    final purchaseOutcome = await InAppPurchaseService.openPaywall(context);
    if (purchaseOutcome.failed) {
      state = AuthInputError(purchaseOutcome.errorMessage!);
      Navigator.of(context).pop();
      return;
    }
    logger.info("Purchase outcome: $purchaseOutcome");
    final customer = await InAppPurchaseService.getCustomerInfo();

    /// After successful payment comes user registration and automatic login
    final registrationRequest =
        _createRegistrationRequest(userAccessData.accessKey2!, customer.originalAppUserId);
    final registrationResult = await ref.read(userServiceProvider).register(registrationRequest);
    if (registrationResult.data == null) {
      // Todo how to handle this case?
      if (kDebugMode) print('Unexpected error with registration $registrationResult');
      state = AuthInputError('Unexpected error with registration. Please contact support');
      Navigator.of(context).pop();
      return;
    }
    // save email to emailProvider
    ref.read(emailProvider.notifier).state = email;

    /// Open the app after successful login
    GoRouter.of(context).pushReplacement(RoutePaths.home);
    state = AuthInput();
  }

  bool _validate() {
    final validEmail = EmailValidator.validatorFunction(email) == null;
    final validFirstName = AuthValidator.minimumRequirements(_firstName) == null;
    final validLastName = AuthValidator.minimumRequirements(_lastName) == null;
    return validEmail && validFirstName && validLastName;
  }

  void hideError() {
    if (state.isSuccess || state is! AuthInputError) return;
    state = (state as AuthInputError).copyWith(showError: false);
  }

  void handleKeyboard(BuildContext context, {required bool isOpen}) {
    final double scrollValue = isOpen ? SaltStrongGreeting.imageHeight : 0;

    scrollController.animateTo(
      scrollValue,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeIn,
    );
  }

  void setEmailError(bool show) {
    showEmailError = show;
    state = AuthInput();
  }

  void disableOnRegisterButton() {
    state = AuthLoading();
  }
}
