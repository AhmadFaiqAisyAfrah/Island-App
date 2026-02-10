import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../services/music_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Icon-only music selector button.
/// 
/// Opens a bottom sheet for music selection.
/// Displays only a music icon, no text labels.
/// Styled to match TagSelector for visual consistency.
class MusicIconButton extends ConsumerStatefulWidget {
  final Function(String) onMusicSelected;
  final String initialValue;

  const MusicIconButton({
    super.key,
    required this.onMusicSelected,
    this.initialValue = 'None',
  });

  @override
  ConsumerState<MusicIconButton> createState() => _MusicIconButtonState();
}

class _MusicIconButtonState extends ConsumerState<MusicIconButton> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  /// Maps ambience name to its representative emoji icon
  String _getAmbienceEmoji(String ambience) {
    switch (ambience) {
      case 'Rainy Vibes':
        return '\ud83d\udca7'; // 💧
      case 'Forest Vibes':
        return '\ud83c\udf32'; // 🌲
      case 'Night Vibes':
        return '\ud83c\udf19'; // 🌙
      case 'Snow Vibes':
        return '\u2744\ufe0f'; // ❄️
      case 'Ocean Vibes':
        return '\ud83c\udf0a'; // 🌊
      case 'None':
      default:
        return '\ud83d\udd07'; // 🔇
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDay = themeState.mode == AppThemeMode.day;
    
    return StreamBuilder<bool>(
      stream: MusicService.instance.playingStream,
      initialData: MusicService.instance.isPlaying,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data ?? false;
        final hasSelection = _selectedValue != 'None';
        // Get emoji based on selected ambience
        final ambienceEmoji = _getAmbienceEmoji(_selectedValue);

        // Match TagSelector day/night styling
        final dayDecoration = BoxDecoration(
          color: Colors.white.withOpacity(0.65),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );

        final nightDecoration = BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        );

        final decoration = isDay ? dayDecoration : nightDecoration;

        return GestureDetector(
          onTap: () => _showMusicSheet(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: decoration,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                 Text(
                   ambienceEmoji,
                   style: TextStyle(
                     fontSize: 18,
                     color: isDay ? AppColors.textMain.withOpacity(0.7) : Colors.white.withOpacity(0.7),
                   ),
                 ),
                const SizedBox(width: 6),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: isDay ? AppColors.textMain.withOpacity(0.7) : Colors.white.withOpacity(0.7),
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMusicSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _MusicSelectionSheet(
        selectedValue: _selectedValue,
        onMusicSelected: (value) {
          setState(() => _selectedValue = value);
          widget.onMusicSelected(value);
        },
      ),
    );
  }
}

class _MusicSelectionSheet extends StatelessWidget {
  final String selectedValue;
  final Function(String) onMusicSelected;

  const _MusicSelectionSheet({
    required this.selectedValue,
    required this.onMusicSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.skyBottom,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Select Ambience",
                      style: AppTextStyles.heading.copyWith(fontSize: 18),
                    ),
                  ),
                ),
                // Scrollable list
                Expanded(
                  child: Builder(
                    builder: (listContext) {
                      return ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        children: [
                           _buildMusicOption(listContext, 'None', '\ud83d\udd07', 'Silence'), // 🔇
                           _buildMusicOption(listContext, 'Rainy Vibes', '\ud83d\udca7', 'Gentle rain'), // 💧
                           _buildMusicOption(listContext, 'Forest Vibes', '\ud83c\udf32', 'Nature sounds'), // 🌲
                           _buildMusicOption(listContext, 'Night Vibes', '\ud83c\udf19', 'Night ambience'), // 🌙
                           _buildMusicOption(listContext, 'Snow Vibes', '\u2744\ufe0f', 'Winter calm'), // ❄️
                           _buildMusicOption(listContext, 'Ocean Vibes', '\ud83c\udf0a', 'Ocean waves'), // 🌊
                          // Bottom padding for safe area
                          SizedBox(height: MediaQuery.of(listContext).padding.bottom),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

   Widget _buildMusicOption(BuildContext context, String value, String emoji, String description) {
    final isSelected = selectedValue == value;

    return GestureDetector(
      onTap: () {
        onMusicSelected(value);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.islandGrass.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.islandGrass : Colors.black12,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
             Text(
               emoji,
               style: TextStyle(
                 fontSize: 22,
                 color: isSelected ? AppColors.islandCliff : AppColors.textMain,
               ),
             ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: AppTextStyles.body.copyWith(
                      color: isSelected ? AppColors.islandCliff : AppColors.textMain,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSub,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.islandGrass,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
