// ignore_for_file: avoid_public_notifier_properties
import 'package:flutter/material.dart' show TextEditingController;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:salt_strong_poc/auth/auth_state.dart';

import '../utils/input_validation.dart';

final createNewPasswordControllerProvider = NotifierProvider //
    <CreateNewPasswordController, AuthState>(() {
  return CreateNewPasswordController();
});

class CreateNewPasswordController extends Notifier<AuthState> {
  CreateNewPasswordController();

  final password1Controller = TextEditingController();
  final password2Controller = TextEditingController();

  @override
  AuthState build() {
    return AuthInputInfo(PasswordValidator.minimumLengthMessage);
  }

  void onInputFieldFocusChange(bool focus) {
    final authState = _validateInput();

    // no focus -> user is done typing, so validation can occur as is
    if (!focus) {
      state = authState;
      return;
    }

    // focus state -> no error message because user is typing
    if (authState is AuthInputError) {
      state = AuthInput();
      return;
    }

    // user is typing and the state is not error
    state = authState;
  }

  AuthState _validateInput() {
    final p1 = password1Controller.text;
    final p2 = password2Controller.text;

    if (p1.isEmpty && p2.isEmpty) {
      return AuthInputInfo(PasswordValidator.minimumLengthMessage);
    }

    if (p1.isPasswordTooShort() || p2.isPasswordTooShort()) {
      return AuthInputError(PasswordValidator.minimumLengthMessage);
    }

    if (p1 != p2) {
      return AuthInputError(PasswordValidator.bothMustMatchMessage);
    }

    return AuthInputValid();
  }

  bool get isInputValid => _validateInput() is AuthInputValid;

  Future<void> onCreateNewPassword() async {
    // final password = password1Controller.text;
    state = AuthLoading();
    await Future.delayed(const Duration(seconds: 2));

    state = AuthSuccess();
  }
}
