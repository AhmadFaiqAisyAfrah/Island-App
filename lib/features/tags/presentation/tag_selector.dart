import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart'; // Import theme provider
import '../domain/tag_model.dart';
import 'tags_provider.dart';
import 'dart:io';

class TagSelector extends ConsumerWidget {
  final bool isFocusing; 
  
  const TagSelector({super.key, required this.isFocusing});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTag = ref.watch(selectedTagProvider);
    final themeState = ref.watch(themeProvider);
    final isDay = themeState.mode == AppThemeMode.day;

    // Day Mode: Glass-like, subtle border, shadow
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

    // Night Mode: Subtle dark (existing style essentially, but maybe slightly refined)
    final nightDecoration = BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
    );

    final textColor = isDay ? AppColors.textMain : Colors.white.withOpacity(0.95);
    final iconColor = isDay ? AppColors.textMain.withOpacity(0.7) : Colors.white.withOpacity(0.7);

    // Focus State: Slightly more transparent, no shadows (Calm)
    final focusDecoration = BoxDecoration(
      color: Colors.white.withOpacity(isDay ? 0.5 : 0.1), // Reduced opacity
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.0),
    );

    // Final selection
    final effectiveDecoration = isFocusing 
       ? focusDecoration 
       : (isDay ? dayDecoration : nightDecoration);

    return IgnorePointer(
      ignoring: isFocusing, // Interaction disabled during focus
      child: GestureDetector(
        onTap: () => _showTagSheet(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500), // Smooth transition
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: effectiveDecoration,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                selectedTag.emoji, 
                style: const TextStyle(fontSize: 16)
              ),
              const SizedBox(width: 8),
              Text(
                selectedTag.label,
                style: AppTextStyles.body.copyWith(
                  color: isFocusing ? textColor.withOpacity(0.9) : textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // Chevron only when NOT focusing
              if (!isFocusing) ...[
                 const SizedBox(width: 6),
                 Icon(
                   Icons.keyboard_arrow_down_rounded, 
                   color: iconColor, 
                   size: 18
                 ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  void _showTagSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allow full height if needed
      builder: (ctx) => const _TagSelectionSheet(),
    );
  }
}

class _TagSelectionSheet extends ConsumerWidget {
  const _TagSelectionSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTags = ref.watch(allTagsProvider);
    final selectedTag = ref.watch(selectedTagProvider);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.skyBottom, 
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2)
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("Set Intention", style: AppTextStyles.heading.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...allTags.map((tag) => _buildTagChip(context, ref, tag, tag == selectedTag)),
              _buildCustomTagButton(context, ref),
            ],
          ),
          // Safety padding for safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
        ],
      ),
    );
  }

  Widget _buildTagChip(BuildContext context, WidgetRef ref, Tag tag, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(selectedTagProvider.notifier).state = tag;
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.islandGrass.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.islandGrass : Colors.black12,
            width: 1.5
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag.emoji,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(width: 8),
            Text(
              tag.label,
              style: AppTextStyles.body.copyWith(
                color: isSelected ? AppColors.islandCliff : AppColors.textMain,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (!tag.isDefault) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  ref.read(customTagsProvider.notifier).deleteTag(tag);
                  if (ref.read(selectedTagProvider) == tag) {
                     ref.read(selectedTagProvider.notifier).state = defaultTags.first;
                  }
                },
                child: Icon(Icons.close, size: 16, color: AppColors.textSub),
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTagButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showAddCustomTagDialog(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black26, style: BorderStyle.solid),
        ),
        child: Text(
          "+ Custom...",
          style: AppTextStyles.body.copyWith(color: AppColors.textSub),
        ),
      ),
    );
  }

  void _showAddCustomTagDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => const _CustomTagDialog(),
    );
  }
}

class _CustomTagDialog extends StatefulWidget {
  const _CustomTagDialog();

  @override
  State<_CustomTagDialog> createState() => _CustomTagDialogState();
}

class _CustomTagDialogState extends State<_CustomTagDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _selectedEmoji; // Nullable to track "not selected" state

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show '😄' if none selected, otherwise show selected
    final displayEmoji = _selectedEmoji ?? "😄";
    final isEmojiSelected = _selectedEmoji != null;

    return AlertDialog(
        backgroundColor: AppColors.skyBottom,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("New Tag", style: AppTextStyles.heading.copyWith(fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              maxLength: 20,
              decoration: InputDecoration(
                hintText: "Tag name (e.g. Gym)",
                counterText: "",
                suffixIcon: GestureDetector(
                  onTap: () => _showEmojiPicker(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    alignment: Alignment.center,
                    width: 24,
                    height: 24,
                    child: Text(
                      displayEmoji, 
                      style: const TextStyle(fontSize: 18)
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          Consumer(
            builder: (context, ref, child) {
              return TextButton(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    // Default to ⚪ if nothing selected
                    final emojiToSave = _selectedEmoji ?? "⚪";
                    
                    ref.read(customTagsProvider.notifier).addTag(text, emojiToSave);
                    
                    ref.read(selectedTagProvider.notifier).state = Tag(
                      label: text, 
                      emoji: emojiToSave, 
                      isDefault: false
                    );
                  }
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: const Text("Save"),
              );
            }
          ),
        ],
      );
  }

  void _showEmojiPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return SizedBox(
          height: 350,
          child: EmojiPicker(
            onEmojiSelected: (category, emoji) {
              setState(() {
                _selectedEmoji = emoji.emoji;
              });
              Navigator.pop(ctx);
            },
            config: Config(
              emojiViewConfig: EmojiViewConfig(
                columns: 7,
                emojiSizeMax: 28 * (Platform.isIOS ? 1.30 : 1.0),
                verticalSpacing: 0,
                horizontalSpacing: 0,
                gridPadding: EdgeInsets.zero,
                backgroundColor: const Color(0xFFF2F2F2),
                noRecents: const Text(
                  'No Recent',
                  style: TextStyle(fontSize: 20, color: Colors.black26),
                  textAlign: TextAlign.center,
                ),
                buttonMode: ButtonMode.MATERIAL,
              ),
              categoryViewConfig: CategoryViewConfig(
                initCategory: Category.ACTIVITIES,
                indicatorColor: AppColors.islandGrass,
                iconColor: Colors.grey,
                iconColorSelected: AppColors.islandGrass,
                backspaceColor: AppColors.islandGrass,
                tabIndicatorAnimDuration: kTabScrollDuration,
                categoryIcons: const CategoryIcons(),
                recentTabBehavior: RecentTabBehavior.NONE,
              ),
              skinToneConfig: const SkinToneConfig(
                enabled: false,
              ),
            ),
          ),
        );
      }
    );
  }
}
