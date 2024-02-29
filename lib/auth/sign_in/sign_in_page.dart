import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:salt_strong_poc/auth/widgets/filled_button.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/routing/router.dart';

import '../../gen/assets.gen.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  String errorMsg = '';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.images.signInBackground.path),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          SizedBox(
            // height: screenSize.height * 0.55,
            child: Padding(
              padding: EdgeInsets.only(bottom: 46.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Spacer(flex: 5),
                  Assets.icons.signInLargeTextPng.image(
                    width: screenSize.width * 0.85,
                  ),
                  const Spacer(flex: 2),
                  Assets.icons.signInIcons.image(
                    width: screenSize.width * 0.85,
                  ),
                  const SizedBox(height: 35),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.width * 0.07,
                    ),
                    child: Column(
                      children: [
                        SaltStrongFilledButton(
                          text: 'Sign In'.toUpperCase(),
                          isSignInPage: true,
                          height: 45,
                          onTap: () {
                            GoRouter.of(context).push(RoutePaths.welcomeBack);
                          },
                          hasShadow: false,
                        ),
                        const SizedBox(height: 23),
                        Text.rich(
                          TextSpan(children: [
                            const TextSpan(text: 'Don\'t have an account? '),
                            TextSpan(
                              text: 'Sign up for the Salt Strong membership.',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer() //
                                ..onTap = () => GoRouter.of(context).push(RoutePaths.registration),
                            ),
                          ]),
                          style: const TextStyle(color: SaltStrongColors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 46),
                  Assets.icons.ssPoweredBy.image(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
