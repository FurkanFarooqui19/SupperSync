import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date formatting utilities for SupperSync
extension AppDateUtils on DateTime {
  /// Returns a human-readable expiry description, e.g. "Expires in 3 days"
  String get expiryLabel {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(year, month, day);
    final diff = expiry.difference(today).inDays;

    if (diff < 0) return 'Expired ${diff.abs()} ${diff.abs() == 1 ? 'day' : 'days'} ago';
    if (diff == 0) return 'Expires today';
    if (diff == 1) return 'Expires tomorrow';
    if (diff <= 7) return 'Expires in $diff days';
    if (diff <= 30) return 'Expires in ${(diff / 7).round()} weeks';
    return DateFormat('MMM d, yyyy').format(this);
  }

  /// Returns expiry urgency level: 0=fresh, 1=soon (≤7d), 2=urgent (≤2d or expired)
  int get expiryUrgency {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(year, month, day);
    final diff = expiry.difference(today).inDays;

    if (diff <= 2) return 2;
    if (diff <= 7) return 1;
    return 0;
  }

  /// Short date format: "Oct 12"
  String get shortDate => DateFormat('MMM d').format(this);

  /// Medium date: "Oct 12, 2025"
  String get mediumDate => DateFormat('MMM d, yyyy').format(this);

  /// Full date + time: "Oct 12, 2025 at 7:30 PM"
  String get fullDateTime =>
      DateFormat("MMM d, yyyy 'at' h:mm a").format(this);

  /// Time only: "7:30 PM"
  String get timeOnly => DateFormat('h:mm a').format(this);

  /// Day of week + short date: "Sat, Oct 12"
  String get dayShortDate => DateFormat('EEE, MMM d').format(this);

  /// Relative time: "2 hours ago", "3 days ago", "just now"
  String get relative {
    final diff = DateTime.now().difference(this);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return shortDate;
  }

  /// Whether this date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Whether this date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether this date is within the next N days
  bool isWithinDays(int days) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    return isAfter(now.subtract(const Duration(days: 1))) && isBefore(future);
  }
}

/// String utilities
extension StringUtils on String {
  String get capitalize =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  String get titleCase => split(' ')
      .map((word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
      .join(' ');

  bool get isValidEmail =>
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(this);

  /// Truncate with ellipsis
  String truncate(int maxLength) =>
      length > maxLength ? '${substring(0, maxLength)}...' : this;
}

/// Double/num formatting
extension NumUtils on num {
  /// Format as currency: "₹ 1,234.50"
  String get asCurrency =>
      NumberFormat.currency(symbol: '₹ ', decimalDigits: 0).format(this);

  /// Format as weight: "1.2 kg"
  String get asKg => '${toStringAsFixed(1)} kg';

  /// Format as CO2: "2.3 kg CO₂"
  String get asCo2 => '${toStringAsFixed(1)} kg CO₂';

  /// Compact format: "1.2K", "3.4M"
  String get compact => NumberFormat.compact().format(this);
}

/// Color helper for expiry urgency
extension ExpiryColor on int {
  Color get expiryColor {
    switch (this) {
      case 2:
        return const Color(0xFFEF4444); // urgent
      case 1:
        return const Color(0xFFF59E0B); // soon
      default:
        return const Color(0xFF22C55E); // fresh
    }
  }
}
