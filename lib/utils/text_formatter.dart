import 'dart:convert';

String cleanProductDescription(String? rawDescription) {
  if (rawDescription == null || rawDescription.trim().isEmpty) {
    return 'Không có mô tả cho sản phẩm này.';
  }
  final text = rawDescription.trim();

  // Kiểm tra nếu chuỗi có định dạng mảng JSON (Delta JSON của Quill)
  if (text.startsWith('[') && text.endsWith(']')) {
    try {
      final List<dynamic> deltaList = jsonDecode(text);
      final StringBuffer buffer = StringBuffer();

      for (var item in deltaList) {
        if (item is Map && item.containsKey('insert')) {
          final insertVal = item['insert'];
          if (insertVal is String) {
            buffer.write(insertVal);
          }
        }
      }

      final cleaned = buffer.toString().trim();
      return cleaned.isNotEmpty ? cleaned : text;
    } catch (_) {
      // Nếu không parse được chuẩn thì trả về chuỗi gốc
      return text;
    }
  }

  return text;
}
