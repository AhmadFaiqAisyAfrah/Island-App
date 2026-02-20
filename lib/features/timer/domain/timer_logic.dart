import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/notification_service.dart';
import '../../../services/ad_service.dart';

enum TimerStatus { idle, running, paused, completed }

class TimerState {
  final int remainingSeconds;
  final int initialDuration;
  final TimerStatus status;

  TimerState({
    required this.remainingSeconds,
    required this.initialDuration,
    required this.status,
  });

  TimerState copyWith({
    int? remainingSeconds,
    int? initialDuration,
    TimerStatus? status,
  }) {
    return TimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      initialDuration: initialDuration ?? this.initialDuration,
      status: status ?? this.status,
    );
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _ticker;
  
  // MVP Default: 25 minutes
  static const int defaultDuration = 25 * 60; 

  TimerNotifier() : super(TimerState(
    remainingSeconds: defaultDuration,
    initialDuration: defaultDuration,
    status: TimerStatus.idle,
  ));

  // MVP: Only allowed when Idle
  void setDuration(int minutes) {
    if (state.status == TimerStatus.idle) {
      final seconds = minutes * 60;
      state = state.copyWith(
        initialDuration: seconds, 
        remainingSeconds: seconds
      );
    }
  }

  void start() {
    if (state.status == TimerStatus.running) return;

    state = state.copyWith(status: TimerStatus.running);
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _complete();
      }
    });
  }

  void pause() {
    _ticker?.cancel();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void reset() {
    _ticker?.cancel();
    state = state.copyWith(
      remainingSeconds: state.initialDuration,
      status: TimerStatus.idle,
    );
  }
  
  void _complete() {
    _ticker?.cancel();
    state = state.copyWith(status: TimerStatus.completed);
    
    // Show focus completion notification if enabled
    NotificationService().showFocusCompleted();
    
    // Track focus session and reschedule daily reflection if needed
    NotificationService().incrementTodayFocusCount();
    NotificationService().rescheduleDailyReflectionIfNeeded();

    // Show interstitial ad (if not premium)
    AdService().showInterstitialAd();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});
