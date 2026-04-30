abstract final class Validators {
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Invalid email address';
    return null;
  }

  static String? positiveNumber(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    final n = double.tryParse(v);
    if (n == null) return 'Must be a number';
    if (n < 0)    return 'Must be positive';
    return null;
  }

  static String? nonNegativeInt(String? v) {
    if (v == null || v.isEmpty) return 'Required';
    final n = int.tryParse(v);
    if (n == null) return 'Must be an integer';
    if (n < 0)     return 'Must be 0 or more';
    return null;
  }

  static String? slug(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(v.trim())) {
      return 'Use lowercase letters, numbers, and hyphens only';
    }
    return null;
  }

  static String? hexColor(String? v) {
    if (v == null || v.isEmpty) return null;
    if (!RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(v)) return 'Format: #RRGGBB';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }
}
