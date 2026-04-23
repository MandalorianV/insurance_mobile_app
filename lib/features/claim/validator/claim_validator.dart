import 'package:flutter/services.dart';

class ClaimValidators {
  /// gg.aa.yyyy ss:dd — tarih geçmişte, maks 1 yıl öncesi
  static String? incidentDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tarih ve saat zorunludur';
    }
    final pattern = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})\s(\d{2}):(\d{2})$');
    final match = pattern.firstMatch(value.trim());
    if (match == null) {
      return 'Format: gg.aa.yyyy ss:dd  (örn. 20.04.2025 14:30)';
    }
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    final hour = int.parse(match.group(4)!);
    final minute = int.parse(match.group(5)!);
    if (month < 1 || month > 12) return 'Geçersiz ay değeri';
    if (day < 1 || day > 31) return 'Geçersiz gün değeri';
    if (hour > 23 || minute > 59) return 'Geçersiz saat değeri';
    final entered = DateTime(year, month, day, hour, minute);
    if (entered.isAfter(DateTime.now())) return 'Olay tarihi gelecekte olamaz';
    final maxPast = DateTime.now().subtract(const Duration(days: 365));
    if (entered.isBefore(maxPast)) return 'Olay 1 yıldan daha eski olamaz';
    return null;
  }

  /// En az 10 karakter
  static String? location(String? value) {
    if (value == null || value.trim().isEmpty) return 'Olay yeri zorunludur';
    if (value.trim().length < 10) {
      return 'Lütfen daha ayrıntılı adres girin (min. 10 karakter)';
    }
    if (value.trim().length > 200)
      return 'Adres en fazla 200 karakter olabilir';
    return null;
  }

  /// Türk plaka formatı — opsiyonel
  static String? plate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.trim().replaceAll(' ', '').toUpperCase();
    final pattern = RegExp(r'^(0[1-9]|[1-7][0-9]|8[01])[A-Z]{1,3}\d{2,4}$');
    if (!pattern.hasMatch(cleaned)) {
      return 'Geçersiz plaka formatı (örn. 34ABC123)';
    }
    return null;
  }

  /// En az 30 karakter
  static String? description(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Olay açıklaması zorunludur';
    if (value.trim().length < 30) {
      return 'Lütfen daha ayrıntılı açıklama girin (min. 30 karakter)';
    }
    if (value.trim().length > 1000) return 'En fazla 1000 karakter girilebilir';
    return null;
  }

  /// Türk cep numarası
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty)
      return 'Telefon numarası zorunludur';
    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    final pattern = RegExp(r'^(\+90|0090|0)(5\d{9})$');
    if (!pattern.hasMatch(cleaned)) {
      return 'Geçerli bir Türk cep numarası girin (05XX XXX XX XX)';
    }
    return null;
  }

  /// E-posta — opsiyonel
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final pattern = RegExp(r'^[\w\.\+\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
    if (!pattern.hasMatch(value.trim()))
      return 'Geçerli bir e-posta adresi girin';
    return null;
  }
}

// ─────────────────────────────────────────────
// Input Formatters
// ─────────────────────────────────────────────
class DateTimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) {
    final digits = next.text.replaceAll(RegExp(r'[^\d]'), '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 12; i++) {
      if (i == 2 || i == 4) buf.write('.');
      if (i == 6) buf.write(' ');
      if (i == 8) buf.write(':');
      buf.write(digits[i]);
    }
    final text = buf.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class PlateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue old,
    TextEditingValue next,
  ) => next.copyWith(text: next.text.toUpperCase());
}
