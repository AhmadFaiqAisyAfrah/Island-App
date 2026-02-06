import 'package:flutter/material.dart';
import '../../../../services/music_service.dart';

/// Dropdown music selector with None, Rainy Vibes, and Forest Vibes options.
/// 
/// CRITICAL: This widget ONLY updates the selected music state.
/// It does NOT start audio playback.
/// Audio is started by the parent when focus begins.
class MusicDropdown extends StatefulWidget {
  final Function(String) onMusicSelected;
  final String initialValue;

  const MusicDropdown({
    super.key,
    required this.onMusicSelected,
    this.initialValue = 'None',
  });

  @override
  State<MusicDropdown> createState() => _MusicDropdownState();
}

class _MusicDropdownState extends State<MusicDropdown> {
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
                ? Colors.white.withOpacity(0.15)
                : Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isPlaying
                  ? Colors.white.withOpacity(0.4)
                  : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedValue,
              isDense: true,
              icon: Icon(
                Icons.music_note,
                color: Colors.white.withOpacity(0.7),
                size: 18,
              ),
              dropdownColor: Colors.black.withOpacity(0.85),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
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
                        color: Colors.white.withOpacity(0.6),
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
                        color: Colors.white.withOpacity(0.8),
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
                        color: Colors.white.withOpacity(0.8),
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
                        color: Colors.white.withOpacity(0.8),
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
                        color: Colors.white.withOpacity(0.8),
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
                        color: Colors.white.withOpacity(0.8),
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
