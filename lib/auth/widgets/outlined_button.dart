import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';

class SaltStrongOutlinedButton extends StatelessWidget {
  const SaltStrongOutlinedButton({
    super.key,
    required this.text,
    required this.onTap,
    this.isSignInPage = false,
    this.height,
  });

  final String text;
  final Function() onTap;
  final bool isSignInPage;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final textStyle = isSignInPage //
        ? const TextStyle(fontSize: 21, fontWeight: FontWeight.w900)
        : const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    return OutlinedButton(
      onPressed: onTap,
      style: isSignInPage
          ? SaltStrongColors.outlineButtonStyle.copyWith(
              minimumSize: MaterialStateProperty.all(
                Size(double.infinity, height ?? 60),
              ),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                const RoundedRectangleBorder(
                  // side: BorderSide(color: SaltStrongColors.signInBtnRed, width: 4.w),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
              side: MaterialStateProperty.resolveWith<BorderSide>(
                (Set<MaterialState> states) {
                  return BorderSide(
                    color: SaltStrongColors.signInBtnRed,
                    width: 2.w,
                  );
                },
              ),
              shadowColor: null,
            )
          : SaltStrongColors.outlineButtonStyle,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: textStyle,
      ),
    );
  }
}
