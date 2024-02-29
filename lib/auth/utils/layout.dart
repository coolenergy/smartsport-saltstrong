import 'package:flutter/material.dart';

abstract class AuthLayout {
  // spacing between buttons
  static const double buttonSpacing = 16;

  // spacing between input text fields
  static const double textFieldSpacing = 16;

  // space underneath screen title
  static const double titleBottomSpacing = 24;

  // spacing between bold state title and text
  static const double titleAndTextSpacing = 12;

  // auth screen horizontal padding
  static const globalPadding = EdgeInsets.symmetric(horizontal: 22);

  // bottom screen padding
  static const double bottomSpace = 32;

  // space between text field and a custom error message underneath
  static const double textFieldErrorMessageSpacing = 4;

  // spacing between input text fields when there is custom error message
  static const double textFieldsWithErrorMessageSpacing = 12;

  // space underneath sign in app name
  static const double bottomAppNameSpace = 94;
}
