import 'package:flutter/material.dart';
import 'package:salt_strong_poc/playground/constants/colors.dart';

import '../../../../gen/assets.gen.dart';

class SaltStrongSnackbar extends StatelessWidget {
  const SaltStrongSnackbar({
    super.key,
    required this.snackbarMessageVariable,
    required this.snackbarMessageFixed,
    required this.isForCalendar,
    this.textStyle,
   });

  final String snackbarMessageVariable;
  final String snackbarMessageFixed;
  final bool isForCalendar;
  final TextStyle? textStyle;

  @override
  Widget build(
    BuildContext context,
  ) {
    final fixedSpan = TextSpan(
      text: snackbarMessageFixed,
      style: textStyle ?? const TextStyle(
        color: Colors.black,
        fontSize: 12,
        fontFamily: 'Inter',
        fontWeight: FontWeight.normal,
        height: 1.5, // line height (flutter uses a ratio for line height)
      ),
    );
    final variableSpan = TextSpan(
      text: snackbarMessageVariable,
      style: textStyle ??
          const TextStyle(
            color: Colors.black,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.normal,
            height: 1.5,
            fontStyle: FontStyle.italic, // line height (flutter uses a ratio for line height)
          ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: SaltStrongColors.black),
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // stretch to fill the width
          children: [
            Container(
              color: SaltStrongColors.seaFoam.withOpacity(0.9), // top half light blue color
              padding: const EdgeInsets.symmetric(vertical: 12), // add vertical padding
              child: Center(
                child: Text.rich(
                  TextSpan(
                    children: isForCalendar ? [fixedSpan, variableSpan] : [variableSpan, fixedSpan],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            Container(
              color: SaltStrongColors.primaryBlue.withOpacity(0.6), // bottom half darker blue color
              padding: const EdgeInsets.symmetric(vertical: 12), // add vertical padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.icons.back.svg(),
                  const SizedBox(width: 8),
                  const Text(
                    'Close',
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: Colors.white,
                      // white color text
                      fontSize: 12,
                      // font size 12
                      fontFamily: 'Inter',
                      // Inter font
                      fontWeight: FontWeight.normal,
                      height: 1.5, // line height (flutter uses a ratio for line height)
                    ),
                    textAlign: TextAlign.center, // text align center
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
