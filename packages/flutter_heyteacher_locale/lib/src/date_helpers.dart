/// Provides extension methods on [DateTime] to determine its relation
/// to the current day (e.g., today, yesterday, tomorrow).
///
/// This library uses the `clock` package to allow for testable date 
/// comparisons.
library;

import 'package:clock/clock.dart';

/// Represents the relationship of a [DateTime] object to the current day.
enum RelativeDay {
  /// The date is the same as the current day.
  today,

  /// The date is the day after the current day.
  tomorrow,

  /// The date is the day before the current day.
  yesterday,

  /// The date's relationship to the current day is not today, tomorrow, or
  /// yesterday.
  unknow,
}

/// Extension methods for [DateTime] to facilitate common date comparisons.
extension DateHelpers on DateTime {
  /// Returns `true` if this [DateTime] instance represents the current day.
  ///
  /// Compares day, month, and year against `clock.now()`.
  bool get isToday {
    final now = clock.now();
    return now.day == day && now.month == month && now.year == year;
  }

  /// Returns `true` if this [DateTime] instance represents yesterday.
  ///
  /// Compares day, month, and year against 
  /// `clock.now().subtract(const Duration(days: 1))`.
  bool get isYesterday {
    final yesterday = clock.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  /// Returns `true` if this [DateTime] instance represents tomorrow.
  ///
  /// Compares day, month, and year against 
  /// `clock.now().add(const Duration(days: 1))`.
  bool get isTomorrow {
    final yesterday = clock.now().add(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  /// Determines the [RelativeDay] for this [DateTime] instance.
  ///
  /// Returns:
  /// - [RelativeDay.today] if [isToday] is true.
  /// - [RelativeDay.tomorrow] if [isTomorrow] is true.
  /// - [RelativeDay.yesterday] if [isYesterday] is true.
  /// - [RelativeDay.unknow] otherwise.
  RelativeDay get relativeDay {
    if (isToday) return RelativeDay.today;
    if (isTomorrow) return RelativeDay.tomorrow;
    if (isYesterday) return RelativeDay.yesterday;
    return RelativeDay.unknow;
  }
}
