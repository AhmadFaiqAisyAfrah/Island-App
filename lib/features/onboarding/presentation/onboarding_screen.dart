import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/presentation/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  static const int _totalPages = 8; // Updated for final flow
  String? _userName;
  String? _phoneUsageTime;
  String? _calculatedLifetimeHours;
  String? _calculatedLifetimeYears;
  String? _selectedEmotion;
  String? _selectedIntention;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_controller.hasClients) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOnboardingData();
  }

  void _skipToEntry() {
    if (_controller.hasClients) {
      _controller.animateToPage(
        _totalPages - 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onNameEntered(String name) {
    setState(() {
      _userName = name;
    });
    _saveOnboardingData();
    // NO automatic navigation - only save the name
  }

  void _onPhoneUsageSelected(String usage) {
    setState(() {
      _phoneUsageTime = usage;
      _calculateLifetimeImpact(usage);
      _saveOnboardingData();
    });
  }

  Future<void> _saveOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_userName', _userName ?? '');
    await prefs.setString('onboarding_phoneUsageTime', _phoneUsageTime ?? '');
    await prefs.setString('onboarding_lifetimeHours', _calculatedLifetimeHours ?? '');
    await prefs.setString('onboarding_lifetimeYears', _calculatedLifetimeYears ?? '');
    await prefs.setString('onboarding_selectedEmotion', _selectedEmotion ?? '');
    await prefs.setString('onboarding_selectedIntention', _selectedIntention ?? '');
  }

  Future<void> _loadOnboardingData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('onboarding_userName');
      _phoneUsageTime = prefs.getString('onboarding_phoneUsageTime');
      _calculatedLifetimeHours = prefs.getString('onboarding_lifetimeHours');
      _calculatedLifetimeYears = prefs.getString('onboarding_lifetimeYears');
      _selectedEmotion = prefs.getString('onboarding_selectedEmotion');
      _selectedIntention = prefs.getString('onboarding_selectedIntention');
    });
  }

  void _onEmotionSelected(int index) {
    setState(() {
      _selectedEmotion = index.toString();
      _saveOnboardingData();
    });
  }

  void _onIntentionSelected(String intention) {
    setState(() {
      _selectedIntention = intention;
      _saveOnboardingData();
    });
  }

  void _calculateLifetimeImpact(String dailyUsage) {
    int dailyHours = 0;
    
    // Correct mapping of selection to hours per day
    if (dailyUsage == "Less than 2 hours") {
      dailyHours = 1;
    } else if (dailyUsage == "2–4 hours") {
      dailyHours = 3;
    } else if (dailyUsage == "4–6 hours") {
      dailyHours = 5;
    } else if (dailyUsage == "More than 6 hours") {
      dailyHours = 7;
    }
    
    // Correct formula: hoursPerDay * 365 * 80
    final totalLifetimeHours = (dailyHours * 365 * 80).toDouble();
    
    // Correct formula: totalHours / 8760 (hours per year)
    final totalLifetimeYears = totalLifetimeHours / 8760;
    
    // Format hours with thousands separator
    _calculatedLifetimeHours = _formatNumber(totalLifetimeHours.round().toString());
    
    // Format years rounded to 1 decimal place
    _calculatedLifetimeYears = totalLifetimeYears.toStringAsFixed(1);
  }
  
  String _formatNumber(String number) {
    // Add comma separators for thousands
    if (number.length <= 3) return number;
    
    final buffer = StringBuffer();
    int count = 0;
    for (int i = number.length - 1; i >= 0; i--) {
      buffer.write(number[i]);
      count++;
      if (count == 3 && i != 0) {
        buffer.write(',');
        count = 0;
      }
    }
    return buffer.toString().split('').reversed.join('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            children: [
              _ArrivalPage(),
              _NameInputPage(
                onNameEntered: _onNameEntered,
                userName: _userName,
              ),
              _IntentionPage(userName: _userName),
              _PhoneUsagePage(
                userName: _userName,
                onUsageSelected: _onPhoneUsageSelected,
                selectedUsage: _phoneUsageTime,
              ),
              _ReflectionPage(
                calculatedLifetimeHours: _calculatedLifetimeHours,
                calculatedLifetimeYears: _calculatedLifetimeYears,
              ),
              _PomodoroExplanationPage(),
              _IslandFeaturesPage(),
              _FinalEntryPage(),
            ],
          ),
          // Skip button - visible on all pages except final entry page
          if (_currentIndex < _totalPages - 1)
            Positioned(
              top: 20,
              right: 20,
              child: TextButton(
                onPressed: _skipToEntry,
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          // Persistent page indicator - visible on all pages
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: _PageIndicator(
              currentIndex: _currentIndex,
              totalPages: _totalPages,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimplePage extends StatelessWidget {
  final String title;

  const _SimplePage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22),
      ),
    );
  }
}

class _ArrivalPage extends StatelessWidget {
  const _ArrivalPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Emoji
            const Text(
              '🏝️',
              style: TextStyle(fontSize: 30),
            ),
            
            const SizedBox(height: 40),
            
            // Main text
            const Text(
              "You've arrived. Meet your calm island.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _IntentionPage extends StatefulWidget {
  final String? userName;

  const _IntentionPage({this.userName});

  @override
  State<_IntentionPage> createState() => _IntentionPageState();
}

class _IntentionPageState extends State<_IntentionPage> {
  int? _selectedIndex;

  // Map options to their insights
  final Map<int, String> _insights = {
    0: "You're not alone.\nAround 60% of people worldwide report struggling\nto stay focused on a single task for long periods.",
    1: "This is more common than it seems.\nAbout 70% of adults say they feel constantly\ninterrupted by competing demands and notifications.",
    2: "You're feeling what many feel.\nNearly 65% of people describe their days as busy,\nyet emotionally unsatisfying or unfinished.",
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Emoji
            const Text(
              '❤️‍🩹',
              style: TextStyle(fontSize: 30),
            ),
            
            const SizedBox(height: 40),
            
            // Main text (personalized)
            Text(
              widget.userName != null && widget.userName!.isNotEmpty
                  ? "What feels heavy right now, ${widget.userName}?"
                  : "What feels heavy right now?",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Selectable options with insights
            _buildOptionWithInsight(
              text: "I can't stay focused, even when I try.",
              index: 0,
            ),
            
            const SizedBox(height: 20),
            
            _buildOptionWithInsight(
              text: "Too many things keep pulling my attention.",
              index: 1,
            ),
            
            const SizedBox(height: 20),
            
            _buildOptionWithInsight(
              text: "I feel busy all day, but nothing feels finished.",
              index: 2,
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionWithInsight({required String text, required int index}) {
    final isSelected = _selectedIndex == index;
    final hasInsight = isSelected && _insights.containsKey(index);
    
    return Column(
      children: [
        // Main option
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = index;
            });
            final parentState = context.findAncestorStateOfType<_OnboardingScreenState>();
            parentState?._onEmotionSelected(index);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? const Color(0xFFF1F5F9) 
                  : Colors.transparent,
              border: Border.all(
                color: isSelected 
                    ? const Color(0xFF64748B) 
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected 
                    ? const Color(0xFF334155) 
                    : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ),
        ),
        
        // Insight dropdown (appears only when selected)
        if (hasInsight) ...[
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAFBFC), // Distinct calm background
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _insights[index]!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalPages;

  const _PageIndicator({
    required this.currentIndex,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalPages, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _buildDot(index == currentIndex),
        );
      }),
    );
  }

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF64748B) : const Color(0xFFE2E8F0),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _NameInputPage extends StatefulWidget {
  final Function(String) onNameEntered;
  final String? userName;

  const _NameInputPage({
    required this.onNameEntered,
    this.userName,
  });

  @override
  State<_NameInputPage> createState() => _NameInputPageState();
}

class _NameInputPageState extends State<_NameInputPage> {
  late TextEditingController _controller;
  bool _canProceed = false;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final canProceed = _controller.text.trim().isNotEmpty;
    if (canProceed != _canProceed) {
      setState(() {
        _canProceed = canProceed;
      });
    }
  }

  void _onContinueTapped() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      // Dismiss keyboard first
      _focusNode.unfocus();
      
      // Save name only - NO automatic navigation
      widget.onNameEntered(name);
      
      // Navigate to NEXT PAGE ONLY - one page advance
      Future.delayed(const Duration(milliseconds: 100), () {
        final parentState = context.findAncestorStateOfType<_OnboardingScreenState>();
        parentState?._next();
      });
    }
  }

  void _onFieldSubmitted(String value) {
    // Only dismiss keyboard, don't trigger navigation
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Dismiss keyboard when tapping outside
        _focusNode.unfocus();
      },
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Main text
              const Text(
                "Before we begin,\nwhat should Island call you?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  height: 1.4,
                ),
              ),
              
              const SizedBox(height: 60),
              
              // Name input field
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF334155),
                  ),
                  decoration: const InputDecoration(
                    hintText: "Your name",
                    hintStyle: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: _onFieldSubmitted,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Continue button
              GestureDetector(
                onTap: _canProceed ? _onContinueTapped : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: _canProceed 
                        ? const Color(0xFF64748B) 
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    "Continue",
                    style: TextStyle(
                      color: _canProceed 
                          ? Colors.white 
                          : const Color(0xFF94A3B8),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneUsagePage extends StatefulWidget {
  final String? userName;
  final Function(String) onUsageSelected;
  final String? selectedUsage;

  const _PhoneUsagePage({
    this.userName,
    required this.onUsageSelected,
    this.selectedUsage,
  });

  @override
  State<_PhoneUsagePage> createState() => _PhoneUsagePageState();
}

class _PhoneUsagePageState extends State<_PhoneUsagePage> {
  String? _selectedUsage;

  @override
  void initState() {
    super.initState();
    _selectedUsage = widget.selectedUsage;
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.userName ?? "";
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Main text (personalized)
            Text(
              userName.isNotEmpty 
                  ? "About your phone, $userName…\nHow much time do you lose to distractions each day?"
                  : "About your phone…\nHow much time do you lose to distractions each day?",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Subtitle
            const Text(
              "This includes scrolling, switching apps,\nand checking without meaning to.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Options
            _buildUsageOption("Less than 2 hours"),
            const SizedBox(height: 16),
            _buildUsageOption("2–4 hours"),
            const SizedBox(height: 16),
            _buildUsageOption("4–6 hours"),
            const SizedBox(height: 16),
            _buildUsageOption("More than 6 hours"),
            
            const SizedBox(height: 40),
            
            // CTA button (only shows after selection)
            if (_selectedUsage != null) ...[
              GestureDetector(
                onTap: () {
                  if (_selectedUsage != null) {
                    widget.onUsageSelected(_selectedUsage!);
                    // Auto-advance after CTA
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted) {
                        final parentState = context.findAncestorStateOfType<_OnboardingScreenState>();
                        parentState?._next();
                      }
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF64748B),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Text(
                    "That sounds right",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUsageOption(String text) {
    final isSelected = _selectedUsage == text;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedUsage = text;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? const Color(0xFFF1F5F9) 
              : Colors.transparent,
          border: Border.all(
            color: isSelected 
                ? const Color(0xFF64748B) 
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
            color: isSelected 
                ? const Color(0xFF334155) 
                : const Color(0xFF64748B),
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _PomodoroExplanationPage extends StatelessWidget {
  const _PomodoroExplanationPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            
            // Centered emoji
            const Text(
              '🌿',
              style: TextStyle(fontSize: 32),
            ),
            
            const SizedBox(height: 40),
            
            // Headline
            const Column(
              children: [
                Text(
                  "You don't need more time.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "You need better intervals.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Body
            const Text(
              "Island is built around a method called Pomodoro.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF334155),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 12),
            
            const Text(
              "Work in short, focused sessions — usually 25 minutes —",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF334155),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 12),
            
            const Text(
              "then rest briefly before continuing.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF334155),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Closing line
            const Text(
              "Small cycles reduce overwhelm.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 8),
            
            const Text(
              "They make distractions quieter.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _IslandFeaturesPage extends StatelessWidget {
  const _IslandFeaturesPage();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            
            // Centered emoji
            const Text(
              '🌲',
              style: TextStyle(fontSize: 32),
            ),
            
            const SizedBox(height: 40),
            
            // Headline
            const Text(
              "Your island supports your rhythm.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 50),
            
            // Feature list
            const Column(
              children: [
                _FeatureItem(text: "• Focus sessions — your quiet Pomodoro space"),
                SizedBox(height: 12),
                _FeatureItem(text: "• Tag your intention — name what you're working on"),
                SizedBox(height: 12),
                _FeatureItem(text: "• Soft lofi ambience"),
                SizedBox(height: 12),
                _FeatureItem(text: "• Journal your focus patterns"),
                SizedBox(height: 12),
                _FeatureItem(text: "• Personal themes — shape your island"),
                SizedBox(height: 12),
                _FeatureItem(text: "• Gentle notifications — nothing urgent"),
                SizedBox(height: 12),
                _FeatureItem(text: "• Screen awareness — gently reflect on your daily phone usage"),
              ],
            ),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String text;

  const _FeatureItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Color(0xFF334155),
          height: 1.5,
        ),
      ),
    );
  }
}

class _FinalEntryPage extends StatefulWidget {
  const _FinalEntryPage();

  @override
  State<_FinalEntryPage> createState() => _FinalEntryPageState();
}

class _FinalEntryPageState extends State<_FinalEntryPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            
            // Headline
            const Text(
              "Begin.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w300,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Subtext
            const Text(
              "Your calm space is ready.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Primary button
            GestureDetector(
              onTap: _enterIsland,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF64748B),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Text(
                  "Enter Island",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  void _enterIsland() {
    // Navigate to Island dashboard and complete onboarding
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
    );
    
    // Mark onboarding as completed
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
  }
}

class _ReflectionPage extends StatelessWidget {
  final String? calculatedLifetimeHours;
  final String? calculatedLifetimeYears;

  const _ReflectionPage({
    required this.calculatedLifetimeHours,
    required this.calculatedLifetimeYears,
  });

  @override
  Widget build(BuildContext context) {
    // Only show reflection page with valid calculations
    if (calculatedLifetimeHours == null || calculatedLifetimeYears == null) {
      return const SafeArea(
        child: Center(
          child: Text(
            "Please complete the previous step first.",
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF64748B),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            
            // Line 1 (small, neutral)
            const Text(
              "Over about 80 years,",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Line 2
            const Text(
              "this could quietly take around",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Line 3 (slightly larger weight)
            Text(
              "$calculatedLifetimeHours hours",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: Color(0xFF334155),
                height: 1.3,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Line 4
            const Text(
              "— or about",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Line 5 (EMPHASIZED - BOLD)
            Text(
              "$calculatedLifetimeYears years",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
                height: 1.3,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Line 6
            const Text(
              "of your life.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Color(0xFF334155),
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}
