import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../services/music_service.dart';

/// Dropdown music selector with None, Rainy Vibes, and Forest Vibes options.
/// 
/// CRITICAL: This widget ONLY updates the selected music state.
/// It does NOT start audio playback.
/// Audio is started by the parent when focus begins.
class MusicDropdown extends ConsumerWidget {
  final Function(String) onMusicSelected;
  final String initialValue;

  const MusicDropdown({
    super.key,
    required this.onMusicSelected,
    this.initialValue = 'None',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final isNight = themeState.mode == AppThemeMode.night;
    
    return _MusicDropdownContent(
      onMusicSelected: onMusicSelected,
      initialValue: initialValue,
      isNight: isNight,
    );
  }
}

class _MusicDropdownContent extends StatefulWidget {
  final Function(String) onMusicSelected;
  final String initialValue;
  final bool isNight;

  const _MusicDropdownContent({
    super.key,
    required this.onMusicSelected,
    required this.initialValue,
    required this.isNight,
  });

  @override
  State<_MusicDropdownContent> createState() => _MusicDropdownContentState();
}

class _MusicDropdownContentState extends State<_MusicDropdownContent> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: MusicService.instance.playingStream,
      initialData: MusicService.instance.isPlaying,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isPlaying
                ? Colors.white.withOpacity(widget.isNight ? 0.15 : 0.08)
                : Colors.white.withOpacity(widget.isNight ? 0.08 : 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPlaying
                  ? Colors.white.withOpacity(widget.isNight ? 0.4 : 0.2)
                  : Colors.white.withOpacity(widget.isNight ? 0.2 : 0.1),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedValue,
              isDense: true,
              icon: Icon(
                Icons.music_note,
                color: widget.isNight ? Colors.white.withOpacity(0.7) : Color(0xFF5F6B7A).withOpacity(0.7),
                size: 18,
              ),
              dropdownColor: Colors.black.withOpacity(0.85),
              style: TextStyle(
                color: widget.isNight ? Colors.white.withOpacity(0.9) : Color(0xFF5F6B7A).withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              items: [
                DropdownMenuItem(
                  value: 'None',
                  child: Row(
                    children: [
                      Icon(
                        Icons.music_off,
                        color: widget.isNight ? Colors.white.withOpacity(0.6) : Color(0xFF5F6B7A).withOpacity(0.6),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('None'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Rainy Vibes',
                  child: Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        color: widget.isNight ? Colors.white.withOpacity(0.8) : Color(0xFF5F6B7A).withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('Rainy Vibes'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Forest Vibes',
                  child: Row(
                    children: [
                      Icon(
                        Icons.forest,
                        color: widget.isNight ? Colors.white.withOpacity(0.8) : Color(0xFF5F6B7A).withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('Forest Vibes'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Night Vibes',
                  child: Row(
                    children: [
                      Icon(
                        Icons.nights_stay,
                        color: widget.isNight ? Colors.white.withOpacity(0.8) : Color(0xFF5F6B7A).withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('Night Vibes'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Snow Vibes',
                  child: Row(
                    children: [
                      Icon(
                        Icons.ac_unit,
                        color: widget.isNight ? Colors.white.withOpacity(0.8) : Color(0xFF5F6B7A).withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('Snow Vibes'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'Ocean Vibes',
                  child: Row(
                    children: [
                      Icon(
                        Icons.water,
                        color: widget.isNight ? Colors.white.withOpacity(0.8) : Color(0xFF5F6B7A).withOpacity(0.8),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Text('Ocean Vibes'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                
                setState(() {
                  _selectedValue = value;
                });

                // ONLY notify parent of selection change
                // DO NOT play audio here
                widget.onMusicSelected(value);
              },
            ),
          ),
        );
      },
    );
  }
}