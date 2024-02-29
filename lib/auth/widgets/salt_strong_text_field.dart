// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:salt_strong_poc/gen/assets.gen.dart';

import '../../playground/constants/colors.dart';
import '../utils/input_validation.dart';
import '../utils/layout.dart';

class SaltStrongTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final bool errorState;
  final bool errorStyleAsValidator;
  final String? iconSource;
  final ValidatorFunction? validator;
  final AutovalidateMode autovalidateMode;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? errorMessage;
  final EdgeInsets padding;
  final void Function(bool)? onFocusChange;
  final void Function(String)? onTyping;

  const SaltStrongTextField({
    this.controller,
    this.hintText,
    this.iconSource,
    this.obscureText = false,
    this.errorState = false,
    this.errorStyleAsValidator = false,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.keyboardType ,
    this.errorMessage,
    this.onFocusChange,
    this.onTyping,
    this.padding = EdgeInsets.zero,
  });

  factory SaltStrongTextField.email({
    TextEditingController? controller,
    ValidatorFunction? validator = EmailValidator.validatorFunction,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    bool errorState = false,
    bool errorStyleAsValidator = false,
    TextInputAction? textInputAction,
    String? errorMessage,
    EdgeInsets padding = EdgeInsets.zero,
    void Function(bool)? onFocusChange,
    void Function(String)? onTyping,
  }) =>
      SaltStrongTextField(
        controller: controller,
        hintText: 'Email',
        iconSource: Assets.icons.letter.path,
        keyboardType: TextInputType.emailAddress,
        validator: validator,
        autovalidateMode: autovalidateMode,
        errorStyleAsValidator: errorStyleAsValidator,
        errorState: errorState,
        textInputAction: textInputAction,
        errorMessage: errorMessage,
        onFocusChange: onFocusChange,
        onTyping: onTyping,
        padding: padding,
      );

  factory SaltStrongTextField.password({
    TextEditingController? controller,
    String? hintText,
    ValidatorFunction? validator = PasswordValidator.validatorFunction,
    bool errorState = false,
    String? errorMessage,
    TextInputAction? textInputAction,
    EdgeInsets padding = EdgeInsets.zero,
    void Function(bool)? onFocusChange,
    void Function(String)? onTyping,
  }) =>
      SaltStrongTextField(
        controller: controller,
        hintText: hintText ?? 'Password',
        iconSource: Assets.icons.lock.path,
        validator: validator,
        obscureText: true,
        errorState: errorState,
        errorMessage: errorMessage,
        textInputAction: textInputAction,
        onFocusChange: onFocusChange,
        onTyping: onTyping,
        padding: padding,
      );

  factory SaltStrongTextField.name({
    TextEditingController? controller,
    String? hintText,
    ValidatorFunction? validator = AuthValidator.minimumRequirements,
    TextCapitalization textCapitalization = TextCapitalization.words,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
    bool errorState = false,
    String? errorMessage,
    TextInputAction? textInputAction,
    EdgeInsets padding = EdgeInsets.zero,
    void Function(bool)? onFocusChange,
    void Function(String)? onTyping,
  }) =>
      SaltStrongTextField(
        controller: controller,
        hintText: hintText ?? 'Name',
        keyboardType: TextInputType.name,
        iconSource: Assets.icons.user.path,
        textCapitalization: textCapitalization,
        autovalidateMode: autovalidateMode,
        validator: validator,
        errorState: errorState,
        errorMessage: errorMessage,
        textInputAction: textInputAction,
        onFocusChange: onFocusChange,
        onTyping: onTyping,
        padding: padding,
      );

  @override
  Widget build(BuildContext context) {
    // prefix icon view
    Widget? iconView;
    if (iconSource != null) {
      iconView = Padding(
        padding: const EdgeInsets.all(18),
        child: SvgGenImage(iconSource!).svg(
          height: 24,
          fit: BoxFit.fitHeight,
          colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
        ),
      );
    }

    const defaultBorderStyle = OutlineInputBorder(
      borderSide: BorderSide(color: SaltStrongColors.greyStroke, width: 1),
      borderRadius: BorderRadius.all(Radius.circular(8)),
    );

    final errorBorderStyle = defaultBorderStyle.copyWith(
      borderSide: const BorderSide(color: SaltStrongColors.errorRed),
    );

    const validationErrorStyle = TextStyle(color: SaltStrongColors.errorRed, fontSize: 13);

    Widget textFormField = Padding(
      padding: padding,
      child: TextFormField(
        controller: controller,
        validator: validator,
        obscureText: obscureText,
        autocorrect: false,
        autovalidateMode: autovalidateMode,
        textCapitalization: textCapitalization,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        onChanged: onTyping,
        decoration: InputDecoration(
          fillColor: Colors.white,
          filled: true,
          hintText: hintText,
          prefixIcon: iconView,
          focusedBorder: errorState ? errorBorderStyle : defaultBorderStyle,
          enabledBorder: errorState ? errorBorderStyle : defaultBorderStyle,
          border: defaultBorderStyle,
          errorBorder: errorBorderStyle,
          errorStyle: validationErrorStyle,
        ),
      ),
    );

    if (errorMessage != null) {
      const middleErrorStyle = TextStyle(color: SaltStrongColors.errorRed, fontSize: 14);
      var extraPadding = EdgeInsets.zero;
      if (errorStyleAsValidator) extraPadding = const EdgeInsets.only(left: 10, top: 4);

      textFormField = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textFormField,
          const SizedBox(height: AuthLayout.textFieldErrorMessageSpacing),
          Padding(
            padding: padding.add(extraPadding),
            child: Text(
              errorMessage!,
              style: errorStyleAsValidator ? validationErrorStyle : middleErrorStyle,
              textAlign: errorStyleAsValidator ? TextAlign.left : TextAlign.center,
            ),
          ),
        ],
      );
    }

    if (onFocusChange == null) return textFormField;
    return Focus(onFocusChange: onFocusChange, child: textFormField);
  }
}
