enum RelativeDay {today, tomorrow, yesterday, unknow}

extension DateHelpers on DateTime {
  bool get isToday {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  bool get isTomorrow {
    final yesterday = DateTime.now().add(const Duration(days: 1));
    return yesterday.day == day &&
        yesterday.month == month &&
        yesterday.year == year;
  }

  RelativeDay get relativeDay {
    if (isToday) return RelativeDay.today;
    if (isTomorrow) return RelativeDay.tomorrow;
    if (isYesterday) return RelativeDay.yesterday;
    return RelativeDay.unknow;
  }
}
