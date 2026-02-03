import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:island/core/theme/app_theme.dart';
import 'package:island/features/music/data/audio_service.dart';
import 'package:island/features/timer/domain/timer_logic.dart';

class MusicButton extends ConsumerWidget {
  const MusicButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEnabled = ref.watch(audioEnabledProvider);

    return PopupMenuButton<bool>(
      tooltip: 'Ambient Music',
      offset: const Offset(0, 40),
      // ... (keeping decoration logic same) ...
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.9),
      elevation: 4,
      onSelected: (value) {
        // Update Preference Logic
        ref.read(audioEnabledProvider.notifier).state = value;
        
        final service = ref.read(audioServiceProvider);
        final timerState = ref.read(timerProvider);
        
        if (value) {
           // Enable: Only play if we are CURRENTLY focusing.
           if (timerState.status == TimerStatus.running) {
             service.enable();
           }
           // Otherwise just stored as preference (will start when Focus starts)
        } else {
           // Disable: Stop immediately.
           service.disable();
        }
      },
      itemBuilder: (context) => [
         const PopupMenuItem(
          value: false,
          child: Row(
            children: [
              Icon(Icons.music_off_outlined, size: 20, color: Colors.grey),
               SizedBox(width: 12),
              Text("No Music", style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
         PopupMenuItem(
          value: true,
          child: Row(
            children: [
              Icon(Icons.music_note_rounded, size: 20, color: AppColors.oceanSurface),
               const SizedBox(width: 12),
              const Text("Rainy Lofi", style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isEnabled ? 0.3 : 0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(isEnabled ? 0.4 : 0.1),
            width: 1,
          ),
        ),
        child: Icon(
          isEnabled ? Icons.music_note_rounded : Icons.music_off_outlined,
          // Corrected color logic ref
          color: Colors.white.withOpacity(isEnabled ? 1.0 : 0.7),
          size: 22,
        ),
      ),
    );
  }
}
