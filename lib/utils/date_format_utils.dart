import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatUtils {
  const DateFormatUtils._();

  static String formatMonthLabel(DateTime date, Locale locale) {
    final dateFormat = locale.languageCode == 'ja' || locale.languageCode == 'ko'
        ? DateFormat.M(locale.toString())
        : DateFormat.MMM(locale.toString());
    final baseLabel = dateFormat.format(date);

    if (locale.languageCode == 'ko') {
      return '${baseLabel}월';
    }
    if (locale.languageCode == 'ja') {
      return '${baseLabel}月';
    }

    return baseLabel.toUpperCase();
  }

  static String formatMonthYear(DateTime date, Locale locale) {
    final monthFormat = locale.languageCode == 'ja'
        ? DateFormat('yyyy年M月', locale.toString())
        : locale.languageCode == 'ko'
            ? DateFormat('yyyy년 M월', locale.toString())
            : DateFormat('MMM yyyy', locale.toString());

    return monthFormat.format(date);
  }

  static String formatFullDate(DateTime date, Locale locale) {
    final dateFormat = locale.languageCode == 'ja'
        ? DateFormat('yyyy年M月d日', locale.toString())
        : locale.languageCode == 'ko'
            ? DateFormat('yyyy년 M월 d일', locale.toString())
            : DateFormat('MMM dd, yyyy', locale.toString());

    return dateFormat.format(date);
  }
}
