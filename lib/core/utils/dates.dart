import 'package:intl/intl.dart';

/// `yyyy-MM-dd` key in local time, used to bucket counts per day.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime parseDayKey(String key) {
  final parts = key.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

final _number = NumberFormat.decimalPattern('vi');

/// 10000 -> "10.000"
String formatCount(int n) => _number.format(n);

String formatDate(DateTime d) => DateFormat('dd/MM/yyyy').format(d);

String formatDateTime(DateTime d) => DateFormat('HH:mm · dd/MM/yyyy').format(d);

String formatDuration(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  if (h > 0) return '$h giờ $m phút';
  if (m > 0) return '$m phút';
  return '${d.inSeconds} giây';
}
