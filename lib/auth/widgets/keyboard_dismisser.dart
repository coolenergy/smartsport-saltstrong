import 'package:flutter/material.dart';

import '../utils/keyboard_manager.dart';

class KeyboardDismisser extends StatelessWidget {
  const KeyboardDismisser({required this.child, super.key});

  final Widget child;

  static void _dismissKeyboard(BuildContext context) {
    if (SaltStrongKeyboard.isOpen(context)) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _dismissKeyboard(context),
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}
