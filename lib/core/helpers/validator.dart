import 'package:mama_pill/core/resources/strings.dart';

class Validator {
  static String? validateField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationMessages.requiredField;
    }
    if (value.trim().length < 3) {
      return 'Field must be at least 3 characters long';
    }
    return null;
  }

  static String? validateEmail(String email) {
    final emailRegex = RegExp(ValidationRegex.emailRegex);

    if (email.trim().isEmpty) {
      return ValidationMessages.emailRequired;
    } else if (!emailRegex.hasMatch(email)) {
      return ValidationMessages.emailInvalid;
    }
    return null;
  }

  static String? validatePassword(String password) {
    RegExp regExp = RegExp(ValidationRegex.passwordRegex);
    if (password.isEmpty) {
      return ValidationMessages.passwordRequired;
    } else if (password.length < 8) {
      return ValidationMessages.passwordLength;
    } else if (!regExp.hasMatch(password)) {
      return ValidationMessages.passwordPattern;
    }
    return null;
  }

  static String? validateConfirmPassword(String value, String? password) {
    if (value.isEmpty) {
      return ValidationMessages.confirmPassword;
    }
    if (value != password) {
      return ValidationMessages.confirmPassword;
    }
    return null;
  }

  static String? validateUsername(String value) {
    if (value.trim().isEmpty) {
      return ValidationMessages.usernameRequired;
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters long';
    }
    if (value.trim().length > 30) {
      return 'Username must be less than 30 characters';
    }
    // Only allow letters, numbers, and underscores
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }
}
