class Validators {
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return "Email is required.";
    final regex = RegExp(r"^[\w.+-]+@[\w-]+\.[\w.-]+$");
    if (!regex.hasMatch(v.trim())) return "Enter a valid email address.";
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.trim().isEmpty) return "Password is required.";
    if (v.trim().length < 6) return "Password must be at least 6 characters.";
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return "Phone number is required.";
    final digits = v.trim().replaceAll(RegExp(r"[^0-9]"), "");
    if (digits.length < 10) return "Enter a valid 10-digit phone number.";
    return null;
  }

  static String? required(String? v, [String label = "This field"]) {
    if (v == null || v.trim().isEmpty) return "$label is required.";
    return null;
  }
}
