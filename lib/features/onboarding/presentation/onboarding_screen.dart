import 'dart:async';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {

  final PageController _controller = PageController();
  final TextEditingController _nameController = TextEditingController();

  int _currentIndex = 0;
  String _name = "";
  int? _selectedEmotion;

  AnimationController? _pulseController;

  final int _totalPages = 8;

int? _selectedDailyHours;
int _lifetimeHours = 0;
double _lifetimeYears = 0;

  @override
void initState() {
  super.initState();

  _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat(reverse: true);

  _nameController.addListener(() {
    setState(() {
      _name = _nameController.text.trim();
    });
  });
}


  @override
void dispose() {
  _pulseController?.dispose();
  _controller.dispose();
  _nameController.dispose();
  super.dispose();
}


  void _next() {
    if (_currentIndex < _totalPages - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut);
    }
  }

  void _skip() {
    _controller.animateToPage(
      _totalPages - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onEmotionSelected(int index) {
    setState(() {
      _selectedEmotion = index;
    });

    // Auto next after delay (3 seconds)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _next();
      }
    });
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_totalPages, (index) {
        final isActive = index == _currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 14 : 8,
          height: isActive ? 14 : 8,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF5F7C8A) : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }


  Widget _pageWelcome() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("🏝️", style: TextStyle(fontSize: 90)),
          SizedBox(height: 20),
          Text(
            "You've arrived.\nMeet your calm island.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22),
          ),
        ],
      ),
    );
  }

  Widget _pageName() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Before we begin,\nwhat should Island call you?",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Your name",
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _name.isNotEmpty ? _next : null,
          child: const Text("Continue"),
        )
      ],
    );
  }

  Widget _pageEmotion() {
    List<String> options = [
      "I can't stay focused.",
      "Too many distractions.",
      "I feel busy all day."
    ];

    List<String> insights = [
      "Around 60% struggle with focus.",
      "Average phone checks: 58/day.",
      "Nearly half feel busy but unfinished."
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("❤️‍🩹", style: TextStyle(fontSize: 60)),
        const SizedBox(height: 20),
        Text(
          "What feels heavy right now, $_name?",
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22),
        ),
        const SizedBox(height: 30),
        ...List.generate(options.length, (index) {
          bool selected = _selectedEmotion == index;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
            child: GestureDetector(
              onTap: () => _onEmotionSelected(index),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: selected
                              ? Colors.blueGrey
                              : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(options[index])),
                  ),
                  if (selected)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(insights[index]),
                    )
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  void _calculateLifetime(int hoursPerDay) {
    final totalHours = hoursPerDay * 365 * 80;
    final totalYears = totalHours / 8760;

    _lifetimeHours = totalHours;
    _lifetimeYears = totalYears;
  }

  Widget _buildHourOption(String label, int hours) {
    final isSelected = _selectedDailyHours == hours;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDailyHours = hours;
        });

        _calculateLifetime(hours);

        Future.delayed(const Duration(milliseconds: 1500), () {
          if (_controller.hasClients) {
            _controller.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blueGrey : Colors.grey.shade300,
            width: 1.5,
          ),
          color: isSelected
              ? Colors.blueGrey.withOpacity(0.08)
              : Colors.white,
        ),
        child: Center(
          child: Text(label),
        ),
      ),
    );
  }

  Widget _pagePhoneTime() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "How much time do you lose daily?",
            style: TextStyle(fontSize: 22),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildHourOption("Less than 2 hours", 1),
          _buildHourOption("2\u20134 hours", 3),
          _buildHourOption("4\u20136 hours", 5),
          _buildHourOption("More than 6 hours", 7),
        ],
      ),
    );
  }

  Widget _pageReflection() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Over 80 years,",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            const Text(
              "this could quietly become",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              "${_lifetimeHours.toString()} hours",
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              "\u2014 or about \u2014",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "${_lifetimeYears.toStringAsFixed(1)} years",
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              "of your life.",
              style: TextStyle(fontSize: 18, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pagePomodoro() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "A different rhythm\nis possible.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 30),
            Text(
              "Island is built around the Pomodoro method.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              "You focus for 25 minutes,\nthen rest briefly.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            Text(
              "Small cycles.\nLess overwhelm.\nMore clarity.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pageIslandFeatures() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Text(
                "Your island\nsupports you.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22),
              ),
            ),
            const SizedBox(height: 30),
            ..._featureItems(),
          ],
        ),
      ),
    );
  }

  List<Widget> _featureItems() {
    const features = [
      "Focus sessions \u2014 structured Pomodoro timer",
      "Intention tags \u2014 name what you're working on",
      "Soft lofi ambiance",
      "Focus journal \u2014 see your patterns",
      "Personal themes \u2014 shape your island",
      "Gentle notifications",
      "Screen-time awareness tracking",
    ];

    return features
        .map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("\u2022 ", style: TextStyle(fontSize: 15)),
                  Expanded(
                    child: Text(
                      f,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ))
        .toList();
  }

  Widget _pageFinal() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Begin.\nYour calm space is ready.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, "/dashboard");
          },
          child: const Text("Enter Island"),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _controller,
            physics: (_currentIndex == 1 && _name.isEmpty) ||
                    (_currentIndex == 3 && _selectedDailyHours == null)
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              _pageWelcome(),
              _pageName(),
              _pageEmotion(),
              _pagePhoneTime(),
              _pageReflection(),
              _pagePomodoro(),
              _pageIslandFeatures(),
              _pageFinal(),
            ],
          ),
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: _skip,
              child: const Text(
                "Skip",
                style: TextStyle(color: Colors.blueGrey),
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: _buildDots(),
          ),
        ],
      ),
    );
  }
}
