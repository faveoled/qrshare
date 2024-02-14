extension StringExtensions on String {
  String withoutTrailingSlash() {
    if (endsWith('/') || endsWith('\\')) {
      return substring(0, length - 1);
    } else {
      return this;
    }
  }
}
