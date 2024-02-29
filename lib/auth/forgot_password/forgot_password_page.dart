// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:salt_strong_poc/auth/widgets/filled_button.dart';
import 'package:salt_strong_poc/auth/widgets/auth_state_ui_decider.dart';
import 'package:salt_strong_poc/auth/widgets/keyboard_dismisser.dart';
import 'package:salt_strong_poc/gen/assets.gen.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';

import '../utils/layout.dart';
import '../widgets/salt_strong_greeting.dart';
import '../widgets/salt_strong_text_field.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordPage extends HookConsumerWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: SaltStrongColors.greyFieldBackground,
      resizeToAvoidBottomInset: true,
      body: KeyboardDismisser(
        child: Column(children: [
          const SaltStrongGreeting('Forgot Password'),
          Expanded(
            child: Consumer(builder: (
              BuildContext context,
              WidgetRef ref,
              Widget? child,
            ) {
              final state = ref.watch(forgotPasswordControllerProvider);
              final controller = ref.read(forgotPasswordControllerProvider.notifier);
              return Padding(
                padding: AuthLayout.globalPadding,
                child: Column(children: [
                  const Spacer(),
                  Expanded(
                    flex: 4,
                    child: AuthStateUIDecider(
                      state: state,
                      inputStateWidget: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'What is your email address?',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(
                              height: AuthLayout.titleBottomSpacing,
                            ),
                            SaltStrongTextField.email(
                              controller: controller.mailController,
                              validator: null,
                              onTyping: (_) => controller.resetState(),
                              onFocusChange: controller.onFocusChange,
                            ),
                            const SizedBox(
                              height: AuthLayout.textFieldErrorMessageSpacing,
                            ),
                            Text(
                              state.message,
                              style: TextStyle(color: state.color, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      successStateWidget: Column(children: [
                        Assets.icons.newsletter.svg(),
                        SizedBox(height: 24.h),
                        const Text(
                          'Reset Email Sent',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: AuthLayout.titleAndTextSpacing),
                        const Text(
                          'If you are already a member, you will '
                          'receive reset instructions in your email.',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ]),
                      loadingStateWidget: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AuthStateUIDecider(
                    state: state,
                    inputStateWidget: SaltStrongFilledButton(
                      text: 'Send Reset Email',
                      onTap: controller.onSendResetEmail,
                    ),
                    successStateWidget: const SizedBox(),
                    loadingStateWidget: const SizedBox(),
                  ),
                  const SizedBox(height: AuthLayout.bottomSpace),
                ]),
              );
            }),
          ),
        ]),
      ),
    );
  }
}
