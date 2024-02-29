// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

import '../auth_state.dart';

class AuthStateUIDecider extends StatelessWidget {
  const AuthStateUIDecider({
    required this.state,
    required this.inputStateWidget,
    required this.successStateWidget,
    this.loadingStateWidget,
  });

  final AuthState state;
  final Widget inputStateWidget;
  final Widget successStateWidget;
  final Widget? loadingStateWidget;

  @override
  Widget build(BuildContext context) {
    switch (state.runtimeType) {
      case AuthInput:
        return inputStateWidget;

      case AuthSuccess:
        return successStateWidget;

      case AuthLoading:
        return loadingStateWidget ?? inputStateWidget;

      default:
        return inputStateWidget;
    }
  }
}
