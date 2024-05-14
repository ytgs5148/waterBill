// ignore_for_file: file_names

String toCamelCase(String text) {
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}