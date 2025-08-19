import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

class DateFormatter {
  static String formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      if (AppLocalizations.isEnglish) {
        return DateFormat('MMM dd, yyyy').format(date);
      } else {
        return DateFormat('yyyy年MM月dd日').format(date);
      }
    } catch (e) {
      return dateString;
    }
  }

  static String formatTime(String time) {
    // 时间格式为 "0", "300", "600" 等，表示0点，3点，6点
    try {
      int hour = int.parse(time) ~/ 100;
      if (AppLocalizations.isEnglish) {
        return '$hour:00';
      } else {
        return '$hour点';
      }
    } catch (e) {
      return time;
    }
  }

  static String getDayOfWeek(String dateString, [bool? isEnglish]) {
    try {
      final date = DateTime.parse(dateString);
      final weekday = date.weekday;
      final useEnglish = isEnglish ?? AppLocalizations.isEnglish;

      if (useEnglish) {
        switch (weekday) {
          case 1:
            return 'Monday';
          case 2:
            return 'Tuesday';
          case 3:
            return 'Wednesday';
          case 4:
            return 'Thursday';
          case 5:
            return 'Friday';
          case 6:
            return 'Saturday';
          case 7:
            return 'Sunday';
          default:
            return '';
        }
      } else {
        switch (weekday) {
          case 1:
            return '星期一';
          case 2:
            return '星期二';
          case 3:
            return '星期三';
          case 4:
            return '星期四';
          case 5:
            return '星期五';
          case 6:
            return '星期六';
          case 7:
            return '星期日';
          default:
            return '';
        }
      }
    } catch (e) {
      return '';
    }
  }
}
