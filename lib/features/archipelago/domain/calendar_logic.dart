class CalendarLogic {
  // Center the PageView at index 10,000 to allow practically infinite backward/forward scrolling
  static const int kInitialPage = 10000;

  static DateTime getMonthFromIndex(int index) {
    final now = DateTime.now();
    // Offset from current month
    final monthOffset = index - kInitialPage;
    return DateTime(now.year, now.month + monthOffset);
  }

  static List<DateTime?> generateMonthGrid(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday; // 1=Mon, 7=Sun

    final List<DateTime?> grid = [];

    // Pad with empty slots for days before the 1st
    // Sunday Start (Sun=0, Mon=1...Sat=6)
    // DateTime.weekday: Mon=1...Sun=7
    // Padding = weekday % 7
    final paddingCount = firstWeekday % 7;
    
    for (int i = 0; i < paddingCount; i++) {
      grid.add(null);
    }

    // Add actual days
    for (int i = 1; i <= daysInMonth; i++) {
      grid.add(DateTime(month.year, month.month, i));
    }

    return grid;
  }
}
