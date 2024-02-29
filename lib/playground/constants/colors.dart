import 'package:flutter/material.dart';

class SaltStrongColors {
  static const primaryBlue = Color(0xFF295EC5);
  static const checkmark = Color(0xFF4987FF);
  static const seaFoam = Color(0xFFC6D7F8);
  static const greyStroke = Color(0xFFCCCCCC);
  static const greyFieldBackground = Color(0xFFF8F8FD);
  static const sliderInactive = Color(0xFFD9D9D9);
  static const weatherGrey = Color(0xFFECEFFA);
  static const white = Color(0xFFFFFFFF);
  static const barChartGreen = Color(0xFF338051);
  static const verticalGraphPointer = Color(0xFF00D1FF);
  static const black = Color(0xFF000000);
  static const appBarBlue = Color(0x66162E59);
  static const errorRed = Color(0xFFFF005C);
  static const btnRed = Color(0xFFCC2027);
  static const signInBtnRed = Color(0xFFC42027);

  ///-------------- gradients ------------------

  static const markerPopupGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      white,
      weatherGrey,
    ],
  );

  static const weatherCardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      weatherGrey,
      white,
    ],
  );

  static LinearGradient barChartGradient(Color primaryColor) => LinearGradient(
        colors: [
          primaryColor.withOpacity(.91 * 0.3),
          // const Color(0x00D9D9D9),  not in use
          // greyFieldBackground
          primaryColor.withOpacity(.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );

  static LinearGradient smartTideFilterGradient = LinearGradient(
    colors: [
      Colors.transparent,
      checkmark.withOpacity(.08),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient searchPopupGradient = LinearGradient(
    colors: [
      primaryBlue.withOpacity(0.2),
      Colors.transparent,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );

  static LinearGradient heroGradient = const LinearGradient(
    colors: [
      Colors.transparent,
      black,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ------------------- btn styles

  static ButtonStyle redBtnStyle = ElevatedButton.styleFrom(
    foregroundColor: white,
    backgroundColor: btnRed,
    minimumSize: const Size(double.infinity, 60),
    padding: const EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
    shadowColor: btnRed,
  );

  static ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: black,
    backgroundColor: white,
    minimumSize: const Size(double.infinity, 60),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
    ),
  ).copyWith(
    side: MaterialStateProperty.resolveWith<BorderSide>(
      (Set<MaterialState> states) {
        return const BorderSide(
          color: greyStroke,
          width: 1,
        );
      },
    ),
  );
}
