import 'package:flutter/material.dart' show TextEditingController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/auth/auth_state.dart';

import '../../playground/services/http/http_service.dart';
import '../utils/input_validation.dart';
import 'models/forgot_password_query.dart';

final forgotPasswordControllerProvider = NotifierProvider //
    <ForgotPasswordController, AuthState>(() {
  return ForgotPasswordController();
});

class ForgotPasswordController extends Notifier<AuthState> {
  ForgotPasswordController();

  // ignore: avoid_public_notifier_properties
  final TextEditingController mailController = TextEditingController();

  @override
  AuthState build() {
    return AuthInput();
  }

  bool _isSending = false;

  Future<void> onSendResetEmail() async {
    if (_isSending) return;

    final valid = validate(mailController.text, onSendResetEmailRequest: true);
    if (!valid) return;

    _isSending = true;

    state = AuthLoading();
    final dioService = ref.read(httpServiceProvider);

    try {
      await dioService.request(
        ForgotPasswordRequest(email: mailController.text),
        converter: ForgotPasswordResponse.fromMap,
      );
      state = AuthSuccess();
    } catch (e) {
      // most presumably the case of unauthenticated user
      state = AuthInputError(EmailValidator.genericErrorMessage);
    } finally {
      _isSending = false;
    }
  }

  bool validate(String input, {bool onSendResetEmailRequest = false}) {
    if (input.isEmpty) {
      state = onSendResetEmailRequest //
          ? AuthInputError(EmailValidator.genericErrorMessage)
          : AuthInput(); // error for empty value is not shown unless "Send Reset Email" requested
      return false;
    }
    final error = customEmailValidator(input);
    state = error == null ? AuthInput() : AuthInputError(error);
    return state.isSuccess;
  }

  String? customEmailValidator(String value) {
    if (state is AuthInputError) return state.message; // api response message
    final validFormat = EmailValidator.validatorFunction(value) == null;

    // overwriting the validator error message when format invalid to show generic message
    if (!validFormat) return EmailValidator.genericErrorMessage;
    return null;
  }

  void onFocusChange(bool focus) {
    if (focus) {
      resetState();
      return;
    }
    validate(mailController.text);
  }

  void resetState() {
    state = AuthInput();
  }
}
