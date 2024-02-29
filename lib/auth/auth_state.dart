import 'package:flutter/material.dart' show Color;

import '../playground/constants/colors.dart';

sealed class AuthState {
  String get message => '';

  Color? get color => null;

  bool get showError => false;

  bool get isSuccess => false;
}

class AuthInput extends AuthState {
  @override
  bool get isSuccess => true;
}

class AuthInputInfo extends AuthState {
  @override
  final String message;

  AuthInputInfo(this.message);

  @override
  Color get color => SaltStrongColors.primaryBlue;
}

class AuthInputError extends AuthState {
  AuthInputError(this._message, {this.showError = true});

  final String _message;

  @override
  String get message => showError ? _message : '';

  @override
  final bool showError;

  @override
  Color get color => SaltStrongColors.errorRed;

  @override
  bool get isSuccess => false;

  AuthInputError copyWith({String? message, bool? showError}) {
    return AuthInputError(message ?? _message, showError: showError ?? this.showError);
  }
}

class AuthInputValid extends AuthState {
  @override
  bool get isSuccess => true;
}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  @override
  bool get isSuccess => true;
}
