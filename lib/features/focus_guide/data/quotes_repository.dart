import 'dart:math';

class QuotesRepository {
  // A. FOCUS SESSION (Encouraging, Gentle)
  static const List<String> _focusQuotes = [
    "Inhale. Exhale. Focus.",
    "Be here now.",
    "This moment is yours.",
    "Gently return to the task.",
    "One step is enough.",
    "Quiet the mind.",
    "Progress, not perfection.",
    "Stay with the flow.",
    "Nothing else matters right now.",
    "Settle into focus.",
    "Stay with this moment.",
  ];

  // B. DASHBOARD / IDLE (Welcoming, Passive)
  static const List<String> _dashboardHeadlines = [
    "Your quiet place.",
    "A space to focus.",
    "Begin when you’re ready.",
    "Take this moment.",
    "Focus, gently.",
    "Welcome back.",
    "Breathe.",
  ];

  static String _lastFocusQuote = "";
  static String _lastDashboardHeadline = "";

  static String getFocusQuote() {
    return _getRandomUnique(_focusQuotes, _lastFocusQuote, (val) => _lastFocusQuote = val);
  }

  static String getDashboardHeadline() {
    return _getRandomUnique(_dashboardHeadlines, _lastDashboardHeadline, (val) => _lastDashboardHeadline = val);
  }

  static String _getRandomUnique(List<String> pool, String last, Function(String) updateLast) {
    if (pool.isEmpty) return "";
    List<String> candidates = pool.where((q) => q != last).toList();
    if (candidates.isEmpty) candidates = pool; // Fallback if pool size 1
    final selected = candidates[Random().nextInt(candidates.length)];
    updateLast(selected);
    return selected;
  }
}
