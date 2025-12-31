class StringUtils {
  StringUtils._();

  static String getInitials(String name) {
    if (name.isEmpty) return "";

    List<String> nameParts = name.trim().split(RegExp(r'\s+'));

    if (nameParts.isEmpty) return "";

    String firstInitial = nameParts[0][0].toUpperCase();

    if (nameParts.length > 1) {
      String lastInitial = nameParts.last[0].toUpperCase();
      return firstInitial + lastInitial;
    }

    return firstInitial;
  }
}
