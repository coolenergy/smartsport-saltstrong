import 'package:flutter/cupertino.dart';

abstract class SaltStrongKeyboard {
  static bool isOpen(BuildContext context) {
    final currentFocus = FocusScope.of(context);
    return !currentFocus.hasPrimaryFocus && currentFocus.hasFocus;
  }
}
