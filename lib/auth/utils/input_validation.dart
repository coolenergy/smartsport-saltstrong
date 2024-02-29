typedef ValidatorFunction = String? Function(String? value);

extension EmailValidator on String {
  static const invalidEmailFormatMessage = '*Email format invalid';
  static const genericErrorMessage = '*Invalid email';

  bool isValidEmail() => RegExp(
        r'^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
      ).hasMatch(this);

  static String? validatorFunction(String? value) {
    if (value == null) return null;
    if (value.isValidEmail()) return null;
    return EmailValidator.invalidEmailFormatMessage;
  }
}

extension PasswordValidator on String {
  static const int minLength = 6;

  static const minimumLengthMessage = '*Password must be $minLength characters or more.';

  static const bothMustMatchMessage = '*Both passwords must match';

  bool isValidPassword() => isPasswordLongEnough();

  bool isPasswordLongEnough() => length >= minLength;

  bool isPasswordTooShort() => !isPasswordLongEnough();

  static String? validatorFunction(String? value) {
    final password = value ?? '';
    if (password.isPasswordLongEnough()) return null;
    return PasswordValidator.minimumLengthMessage;
  }
}

abstract class AuthValidator {
  static const emptyValueMessage = '*This field can not be empty';
  static const paymentRequired = '*Payment required';
  static const invalidEmailOrPasswordMessage = '*Incorrect email - password combination';

  static const networkConnectionErrorMessage =
      'Something went wrong. Check your internet connection and try again.';

  static const alreadyASaltStrongMember =
      'You are already a Salt Strong member. Please try to log in.';

  static String? minimumRequirements(String? value) {
    if (value != null && value.trim().isNotEmpty) return null;
    return emptyValueMessage;
  }

  static String? combined(String email, String password) {
    final m = EmailValidator.validatorFunction(email);
    final p = PasswordValidator.validatorFunction(password);
    if (m == null && p == null) return null; // both values valid
    return invalidEmailOrPasswordMessage;
  }
}
