class PasswordValidator {
  static String? validate(String password) {
    if (password.length < 8) {
      return "Password must be at least 8 characters.";
    }
    if (!password.contains(RegExp(r"[0-9]"))) {
      return "Password must contain at least 1 number.";
    }
    if (!password.contains(RegExp(r"[A-Z]"))) {
      return "Password must contain at least 1 capital letter.";
    }
    if (!password.contains(RegExp(r"[!@#\$%^&*(),.?\x22:{}|<>_\-+=~`\[\]\\/;]"))) {
      return "Password must contain at least 1 symbol.";
    }
    return null;
  }
}
