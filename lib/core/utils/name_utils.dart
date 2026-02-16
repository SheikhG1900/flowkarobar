class NameUtils {
  /// Returns the initials of a name (single character).
  /// If the name is empty, it returns a default character (default is '?').
  static String getInitials(String name, {String defaultChar = '?'}) {
    if (name.trim().isEmpty) return defaultChar;
    
    return name.trim()[0].toUpperCase();
  }
}
