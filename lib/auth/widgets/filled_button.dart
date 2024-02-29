import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';

class SaltStrongFilledButton extends StatelessWidget {
  const SaltStrongFilledButton({
    super.key,
    required this.text,
    required this.onTap,
    this.disabled = false,
    this.height,
    this.hasShadow = true,
    this.isSignInPage = false,
  });

  final String text;
  final Function() onTap;
  final double? height;
  final bool? hasShadow;
  final bool disabled;
  final bool isSignInPage;

  @override
  Widget build(
    BuildContext context,
  ) {
    return isSignInPage
        ? ElevatedButton(
            onPressed: disabled ? null : onTap,
            style: SaltStrongColors.redBtnStyle.copyWith(
              backgroundColor: MaterialStateProperty.all(SaltStrongColors.signInBtnRed),
              minimumSize: MaterialStateProperty.all(
                Size(double.infinity, height!),
              ),
              shape: MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
                side: BorderSide(color: SaltStrongColors.white, width: 1.w),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              )),
              shadowColor: null,
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
            ),
          )
        : ElevatedButton(
            onPressed: disabled ? null : onTap,
            style: height == null
                ? SaltStrongColors.redBtnStyle
                : hasShadow == false
                    ? SaltStrongColors.redBtnStyle.copyWith(
                        shadowColor: null,
                      )
                    : SaltStrongColors.redBtnStyle.copyWith(
                        minimumSize: MaterialStateProperty.all(
                          Size(double.infinity, height!),
                        ),
                      ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          );
  }
}
