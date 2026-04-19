
import 'package:intl/intl.dart';

class CurrencyUtils {
  static String format(double amount) => '৳${NumberFormat('#,##0', 'en_US').format(amount)}';
  static String formatCompact(double amount) {
    if (amount >= 100000) return '৳${(amount/100000).toStringAsFixed(1)}L';
    if (amount >= 1000) return '৳${(amount/1000).toStringAsFixed(1)}K';
    return format(amount);
  }
}
