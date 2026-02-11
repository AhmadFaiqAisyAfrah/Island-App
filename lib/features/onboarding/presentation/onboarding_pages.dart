// Onboarding page order and structure definition
// This file provides a clean structure for the onboarding flow
// without modifying the existing implementation

enum _OnboardingPageType {
  arrival,
  intentionSelection,
  distractionSelection,
  reflection,
  quietPlace,
  notifications,
  invitation,
  entry,
}

class _OnboardingPageConfig {
  final _OnboardingPageType type;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final _OnboardingVisualType visualType;
  final List<Color> gradient;

  const _OnboardingPageConfig({
    required this.type,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    required this.visualType,
    required this.gradient,
  });
}

// Page order in the correct sequence
final List<_OnboardingPageConfig> _onboardingPages = [
  // Page 1: Arrival
  _OnboardingPageConfig(
    type: _OnboardingPageType.arrival,
    title: "You've arrived. Meet your calm island.",
    subtitle: 'We spend more time on our phones than we mean to.\nNot because we\'re weak — but because the world keeps asking.',
    ctaLabel: 'I feel this',
    visualType: _OnboardingVisualType.arrival,
    gradient: const [
      Color(0xFFF2E6D8),
      Color(0xFFCBD9DF),
    ],
  ),
  
  // Page 2: Intention Selection
  _OnboardingPageConfig(
    type: _OnboardingPageType.intentionSelection,
    title: "What do you need right now?",
    subtitle: '',
    ctaLabel: null,
    visualType: _OnboardingVisualType.intention,
    gradient: const [
      Color(0xFFF2E6D8),
      Color(0xFFCBD9DF),
      Color(0xFFD4E0E6),
    ],
  ),
  
  // Page 3: Distraction Duration Selection
  _OnboardingPageConfig(
    type: _OnboardingPageType.distractionSelection,
    title: "About how much time is lost to phone distractions each day?",
    subtitle: "Scrolling, checking, switching — not your main work.",
    ctaLabel: null,
    visualType: _OnboardingVisualType.phoneUsage,
    gradient: const [
      Color(0xFFF0E6D8),
      Color(0xFFE2EBEE),
      Color(0xFFCBD9DF),
    ],
  ),
  
  // Page 4: Reflection
  _OnboardingPageConfig(
    type: _OnboardingPageType.reflection,
    title: "Over a lifetime, this adds up.",
    subtitle: '',  // Will be filled dynamically
    ctaLabel: null,
    visualType: _OnboardingVisualType.phoneReflection,
    gradient: const [
      Color(0xFFE8E6F3),
      Color(0xFFE2EBEE),
      Color(0xFFD4E0E6),
    ],
  ),
  
  // Page 5: Quiet Place Preview
  _OnboardingPageConfig(
    type: _OnboardingPageType.quietPlace,
    title: "This is your quiet place.",
    subtitle: "Nothing demands you here.",
    ctaLabel: null,
    visualType: _OnboardingVisualType.quietPlace,
    gradient: const [
      Color(0xFFE8E6F3),
      Color(0xFFE2EBEE),
      Color(0xFFD4E0E6),
    ],
  ),
  
  // Page 6: Notification Permission
  _OnboardingPageConfig(
    type: _OnboardingPageType.notifications,
    title: "Gentle Notifications",
    subtitle: 'Island can quietly let you know\nwhen a session ends,\nor softly reflect at night.\n\nNothing urgent. Just presence.',
    ctaLabel: null,
    visualType: _OnboardingVisualType.notification,
    gradient: const [
      Color(0xFFE8E6F3),
      Color(0xFFE2EBEE),
      Color(0xFFD4E0E6),
    ],
  ),
  
  // Page 7: Entry
  _OnboardingPageConfig(
    type: _OnboardingPageType.entry,
    title: 'Enter Island',
    subtitle: 'Your calm space is ready.',
    ctaLabel: 'Enter Island',
    visualType: _OnboardingVisualType.invitation,
    gradient: const [
      CalmPalette.skyTop,
      Color(0xFFE8EEF2),
      CalmPalette.skyMist,
      CalmPalette.deepWater,
    ],
  ),
];