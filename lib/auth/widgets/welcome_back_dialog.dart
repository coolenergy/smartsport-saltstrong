import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';
import 'package:salt_strong_poc/auth/widgets/filled_button.dart';

import '../../../../gen/assets.gen.dart';

class WelcomeBackDialog extends StatelessWidget {
  const WelcomeBackDialog({
    super.key,
    required this.userName,
  });

  final String userName;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        margin: EdgeInsetsDirectional.all(24.r),
        padding: EdgeInsetsDirectional.all(20.r),
        decoration: const BoxDecoration(
          color: SaltStrongColors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: const Icon(Icons.close))),
          Stack(
            alignment: Alignment.center,
            children: [
              const Divider(
                thickness: 1,
                color: SaltStrongColors.black,
              ),
              SvgPicture.asset(Assets.images.welcomeBackHands.path),
            ],
          ),
          SizedBox(
            height: 16.h,
          ),
          Text(
            'Welcome',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 24.sp,
            ),
          ),
          SizedBox(
            height: 12.h,
          ),
          Text(
            'Ready? Those fish won\'t catch themselves...',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(
            height: 12.h,
          ),
          SaltStrongFilledButton(
            text: 'Let\'s Go',
            onTap: () {
              Navigator.of(context).pop();
            },
            height: 42,
          ),
        ]),
      ),
    );
  }
}
