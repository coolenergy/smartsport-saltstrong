import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:salt_strong_poc/auth/utils/layout.dart';
import 'package:salt_strong_poc/auth/welcome_back/welcome_back_controller.dart';
import 'package:salt_strong_poc/auth/widgets/keyboard_dismisser.dart';
import 'package:salt_strong_poc/auth/widgets/salt_strong_text_field.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/auth/widgets/filled_button.dart';
import 'package:salt_strong_poc/routing/router.dart';

import '../../gen/assets.gen.dart';
import '../../playground/view/home_map/widgets/smart_tides/filters/filters.dart';
import '../widgets/outlined_button.dart';
import '../widgets/salt_strong_greeting.dart';
import '../widgets/salt_strong_web_view.dart';

class WelcomeBackPage extends HookConsumerWidget {
  final Exception? pushedBecauseOfException;

  const WelcomeBackPage({super.key, this.pushedBecauseOfException});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = useMemoized(GlobalKey<ScaffoldState>.new, const []);

    // ignore: body_might_complete_normally_nullable
    useEffect(() {
      // ignore: dead_code
      if (kDebugMode && false) {}
    });
    useEffect(() {
      if (pushedBecauseOfException == null) return;
      Future(() {
        ScaffoldMessenger.of(scaffoldKey.currentContext!).showSnackBar(SnackBar(
          content: Text(
            pushedBecauseOfException?.toString() ?? "",
            style: const TextStyle(color: SaltStrongColors.white),
          ),
          backgroundColor: SaltStrongColors.primaryBlue,
        ));
      });
      return null;
    }, const []);
    return Scaffold(
      key: scaffoldKey,
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
                  final controller = ref.read(welcomeBackControllerProvider.notifier);
                  final state = ref.watch(welcomeBackControllerProvider);

                  return FocusScope(
                    child: Focus(
                      onFocusChange: (focus) => controller.handleKeyboard(context, isOpen: focus),
                      child: SingleChildScrollView(
                        controller: controller.scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SaltStrongGreeting('Welcome'),
                            const SizedBox(height: 108),

                            /// AuthSectionedState -> Email State View
                            SaltStrongTextField.email(
                              controller: controller.mailController,
                              errorState: state.showError,
                              textInputAction: TextInputAction.next,
                              validator: null,
                              padding: AuthLayout.globalPadding,
                              onTyping: (_) => controller.hideError(),
                            ),
                            const SizedBox(height: AuthLayout.textFieldSpacing),

                            /// AuthSectionedState -> Password State View
                            SaltStrongTextField.password(
                              controller: controller.passwordController,
                              errorState: state.showError,
                              textInputAction: TextInputAction.done,
                              validator: null,
                              padding: AuthLayout.globalPadding,
                              onTyping: (_) => controller.hideError(),
                            ),

                            /// AuthSectionedState -> Common State View
                            const SizedBox(height: AuthLayout.textFieldsWithErrorMessageSpacing),
                            Text(
                              state.message,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: state.color, fontSize: 16),
                            ),

                            const SizedBox(height: 350), // for scroll to work
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: AuthLayout.globalPadding,
              child: Column(children: [
                SaltStrongFilledButton(
                  text: 'Sign In',
                  onTap: () => ref //
                      .read(welcomeBackControllerProvider.notifier)
                      .login(context: context, ref: ref),
                ),
                const SizedBox(height: AuthLayout.buttonSpacing),
                SaltStrongOutlinedButton(
                  text: 'I forgot my password',
                  onTap: () {
                    GoRouter.of(context).push(RoutePaths.forgotPassword);
                  },
                ),
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
          ]),
        ),
      ),
    );
  }
}
