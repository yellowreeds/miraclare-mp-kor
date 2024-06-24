import 'package:intl/intl.dart';

extension StringExtensions on String {
  String toFormatyyyyMMdd() {
    try {
      DateTime date = DateTime.parse(this);
      return DateFormat('yyyyMMdd').format(date);
    } catch (e) {
      throw FormatException('Invalid date format: $this');
    }
  }
}
