import 'dart:math';

class QuotesRepository {
  static const List<String> _quotes = [
    "Inhale. Exhale. Focus.",
    "This moment is yours.",
    "Gently return to the task.",
    "One step is enough.",
    "Be here now.",
    "Quiet the mind.",
    "Progress, not perfection.",
    "Stay with the flow.",
    "Your island is growing.",
    "Deep work, deep rest."
  ];

  static String getRandomQuote() {
    return _quotes[Random().nextInt(_quotes.length)];
  }
}
