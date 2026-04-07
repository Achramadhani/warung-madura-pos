String normalizeBarcode(String input) {
  return input.trim().replaceAll(RegExp(r'[\r\n\t]'), '');
}
