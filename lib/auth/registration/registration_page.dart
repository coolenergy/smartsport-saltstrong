import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:salt_strong_poc/auth/auth_state.dart';
import 'package:salt_strong_poc/auth/utils/layout.dart';
import 'package:salt_strong_poc/auth/widgets/keyboard_dismisser.dart';
import 'package:salt_strong_poc/auth/widgets/salt_strong_text_field.dart';
import 'package:salt_strong_poc/auth/widgets/salt_strong_web_view.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/auth/widgets/filled_button.dart';

import '../../gen/assets.gen.dart';
import '../../playground/view/home_map/widgets/smart_tides/filters/filters.dart';
import '../utils/input_validation.dart';
import '../widgets/salt_strong_greeting.dart';
import 'registration_controller.dart';

class RegistrationPage extends HookConsumerWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    return Scaffold(
      backgroundColor: SaltStrongColors.greyFieldBackground,
      resizeToAvoidBottomInset: true,
      body: KeyboardDismisser(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(Assets.images.bottomPatternPng.path),
              alignment: Alignment.bottomCenter,
              fit: BoxFit.fitWidth,
            ),
          ),
          child: Column(children: [
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final controller = ref.read(registrationControllerProvider.notifier);
                  final state = ref.watch(registrationControllerProvider);

                  var showEmailError = ref.watch(registrationControllerProvider.notifier).showEmailError;

                  final emailErrorMessage = EmailValidator.validatorFunction(controller.email);
                  showEmailError = emailErrorMessage == null ? false : showEmailError;

                  return Form(
                    key: formKey,
                    child: FocusScope(
                      child: Focus(
                        onFocusChange: (focus) => controller.handleKeyboard(context, isOpen: focus),
                        child: SingleChildScrollView(
                          controller: controller.scrollController,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SaltStrongGreeting('Become a member'),
                              const SizedBox(height: 108),

                              /// First name input view
                              SaltStrongTextField.name(
                                controller: controller.firstNameController,
                                hintText: 'First Name',
                                textInputAction: TextInputAction.next,
                                padding: AuthLayout.globalPadding,
                              ),
                              const SizedBox(height: AuthLayout.textFieldSpacing),

                              /// Last name input view
                              SaltStrongTextField.name(
                                controller: controller.lastNameController,
                                hintText: 'Last Name',
                                textInputAction: TextInputAction.next,
                                padding: AuthLayout.globalPadding,
                              ),
                              const SizedBox(height: AuthLayout.textFieldSpacing),

                              /// Email input view
                              SaltStrongTextField.email(
                                controller: controller.emailController,
                                textInputAction: TextInputAction.done,
                                padding: AuthLayout.globalPadding,
                                errorMessage: showEmailError ? emailErrorMessage : '',
                                errorState: showEmailError,
                                errorStyleAsValidator: true,
                                validator: null,
                                onTyping: (_) => controller.setEmailError(false),
                              ),
                              const SizedBox(height: AuthLayout.textFieldSpacing),

                              /// Common error text view
                              const SizedBox(height: AuthLayout.textFieldsWithErrorMessageSpacing),
                              Padding(
                                padding: AuthLayout.globalPadding,
                                child: Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: state.color, fontSize: 16),
                                ),
                              ),

                              const SizedBox(height: 350), // for scroll to work
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: AuthLayout.globalPadding,
              child: SaltStrongFilledButton(
                  text: 'Sign Up',
                  disabled: ref.watch(registrationControllerProvider) is AuthLoading,
                  onTap: () {
                    ref.read(registrationControllerProvider.notifier).setEmailError(true);
                    final valid = formKey.currentState?.validate() ?? false;
                    if (!valid) return;
                    ref.read(registrationControllerProvider.notifier).disableOnRegisterButton();
                    ref //
                        .read(registrationControllerProvider.notifier)
                        .onRegister(context: context, ref: ref);
                  }),
            ),
            const SizedBox(height: AuthLayout.bottomSpace / 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => openUrl(context, Links.privacyPolicy),
                  child: const Text('Privacy Policy', style: textButtonStyle),
                ),
                TextButton(
                  onPressed: () => openUrl(context, Links.termsOfUse),
                  child: const Text('Terms of Use', style: textButtonStyle),
                ),
              ],
            ),
            const SizedBox(height: AuthLayout.bottomSpace / 1.2),
          ]),
        ),
      ),
    );
  }
}
