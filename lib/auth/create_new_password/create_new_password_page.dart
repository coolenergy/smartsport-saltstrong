import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:salt_strong_poc/auth/auth_state.dart';
import 'package:salt_strong_poc/auth/create_new_password/create_new_password_controller.dart';
import 'package:salt_strong_poc/auth/utils/layout.dart';
import 'package:salt_strong_poc/auth/widgets/auth_state_ui_decider.dart';
import 'package:salt_strong_poc/auth/widgets/keyboard_dismisser.dart';

import '../../gen/assets.gen.dart';
import '../../playground/constants/colors.dart';
import '../../routing/router.dart';
import '../widgets/filled_button.dart';
import '../widgets/salt_strong_greeting.dart';
import '../widgets/salt_strong_text_field.dart';

class CreateNewPasswordPage extends HookConsumerWidget {
  const CreateNewPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: SaltStrongColors.greyFieldBackground,
      resizeToAvoidBottomInset: true,
      body: KeyboardDismisser(
        child: Column(children: [
          const SaltStrongGreeting('New Password'),
          Expanded(
            child: Consumer(builder: (
              BuildContext context,
              WidgetRef ref,
              Widget? child,
            ) {
              final state = ref.watch(createNewPasswordControllerProvider);
              final inputErrorState = state is AuthInputError;

              final controller = ref.read(
                createNewPasswordControllerProvider.notifier,
              );

              return Padding(
                padding: AuthLayout.globalPadding,
                child: Column(children: [
                  const Spacer(),
                  Expanded(
                    flex: 4,
                    child: AuthStateUIDecider(
                      state: state,
                      inputStateWidget: FocusScope(
                        child: Focus(
                          onFocusChange: controller.onInputFieldFocusChange,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Write your new password below.',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(
                                  height: AuthLayout.titleBottomSpacing,
                                ),
                                SaltStrongTextField.password(
                                  controller: controller.password1Controller,
                                  hintText: 'New Password',
                                  validator: null, // to disable error messages
                                  errorState: inputErrorState,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(
                                  height: AuthLayout.textFieldSpacing,
                                ),
                                SaltStrongTextField.password(
                                  controller: controller.password2Controller,
                                  hintText: 'Repeat Password',
                                  validator: null, // to disable error messages
                                  errorState: inputErrorState,
                                  textInputAction: TextInputAction.done,
                                ),
                                const SizedBox(
                                  height: AuthLayout.textFieldSpacing,
                                ),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: state.color),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      successStateWidget: Column(children: [
                        Assets.icons.passwordResetKey.svg(),
                        SizedBox(height: 24.h),
                        const Text(
                          'Password Reset',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AuthLayout.titleAndTextSpacing),
                        const Text(
                          'Great! Time to use your new password to '
                          'sign in to your account. ',
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
                      text: 'Create New Password',
                      onTap: () {
                        final valid = controller.isInputValid;
                        if (!valid) return;
                        ref //
                            .read(createNewPasswordControllerProvider.notifier)
                            .onCreateNewPassword();
                      },
                    ),
                    successStateWidget: SaltStrongFilledButton(
                      text: 'Return to Sing In',
                      onTap: () => GoRouter.of(context).push(
                        RoutePaths.welcomeBack,
                      ),
                    ),
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
