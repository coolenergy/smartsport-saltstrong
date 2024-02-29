// ignore_for_file: use_build_context_synchronously, avoid_public_notifier_properties

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:salt_strong_poc/auth/utils/input_validation.dart';
import 'package:salt_strong_poc/auth/widgets/salt_strong_greeting.dart';
import 'package:salt_strong_poc/playground/services/in_app_purchase/in_app_purchase_service.dart';
import 'package:salt_strong_poc/playground/services/user/user_service.dart';
import 'package:salt_strong_poc/playground/view/home_map/widgets/layer_modifier.dart';

import '../../playground/models/user/login_query.dart';
import '../../playground/models/user/registration_query.dart';
import '../../playground/models/user/user.dart';
import '../../routing/router.dart';
import '../registration/email_provider.dart';

final welcomeBackControllerProvider = NotifierProvider //
    <WelcomeBackController, AuthState>(() {
  return WelcomeBackController();
});

class WelcomeBackController extends Notifier<AuthState> {
  WelcomeBackController();

  final TextEditingController mailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String get _email => mailController.text.trim().toLowerCase();

  String get _password => passwordController.text;

  @override
  AuthState build() {
    return AuthSuccess();
  }

  void login({required BuildContext context, required WidgetRef ref}) async {
    final valid = _validate(showError: true);
    if (!valid) return;

    showLoadingDialog(context);
    try {
      final request = UserLoginRequest(email: _email, password: _password);
      await ref.read(userServiceProvider).login(request);
      ref.read(emailProvider.notifier).state = _email;
      GoRouter.of(context).pushReplacement(RoutePaths.home);
    } catch (e) {
      Navigator.of(context).pop();

      bool paymentRequired = false;
      if (e is DioException) {
        paymentRequired = e.response?.statusCode == 402;
      }

      if (paymentRequired) {
        state = AuthInputError(AuthValidator.paymentRequired);

        userData.accessData = await ref.read(userServiceProvider).getAccessKey();

        final purchaseOutcome = await InAppPurchaseService.openPaywall(context);

        if (purchaseOutcome.failed) {
          state = AuthInputError(purchaseOutcome.errorMessage!);
          Navigator.of(context).pop();
          return;
        }
        final customer = await InAppPurchaseService.getCustomerInfo();
        final renewalRequest = UserRenewalRequest(
            revenueCatId: customer.originalAppUserId, email: this._email, accessKey: userData.accessData!.accessKey2!);

        showLoadingDialog(context);
        try {
          await ref.read(userServiceProvider).renew(renewalRequest);
          final request = UserLoginRequest(email: _email, password: _password);
          await ref.read(userServiceProvider).login(request);
          Navigator.of(context).pop();
          GoRouter.of(context).pushReplacement(RoutePaths.home);
        } catch (e) {
          Navigator.of(context).pop();

          state = AuthInputError(AuthValidator.paymentRequired);
        }
      } else {
        state = AuthInputError(AuthValidator.invalidEmailOrPasswordMessage);
      }
    }
  }

  bool _validate({bool? showError}) {
    final error = AuthValidator.combined(_email, _password);
    showError ??= state.showError;
    state = error == null ? AuthSuccess() : AuthInputError(error, showError: showError);
    return state.isSuccess;
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
}
