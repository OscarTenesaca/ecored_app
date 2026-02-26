import 'package:intl/intl.dart';

class UtilsDate {
  static DateTime toLocal(String utcDate) {
    return DateTime.parse(utcDate).toLocal();
  }

  static String formatLocal(
    String utcDate, {
    String pattern = 'dd/MM/yyyy HH:mm',
  }) {
    return DateFormat(pattern).format(toLocal(utcDate));
  }
}
