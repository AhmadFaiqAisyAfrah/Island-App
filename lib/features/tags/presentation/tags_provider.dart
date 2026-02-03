import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/tags_repository.dart';
import '../domain/tag_model.dart';

final tagsRepositoryProvider = Provider((ref) => TagsRepository());

// Default Tags - Fixed Emojis, Immutable
const List<Tag> defaultTags = [
  Tag(label: "None", emoji: "⚪", isDefault: true),
  Tag(label: "Study", emoji: "📘", isDefault: true),
  Tag(label: "Work", emoji: "💼", isDefault: true),
  Tag(label: "Reading", emoji: "📖", isDefault: true),
  Tag(label: "Writing", emoji: "✍️", isDefault: true),
  Tag(label: "Mindfulness", emoji: "🌿", isDefault: true),
];

// Stores the list of CUSTOM tags
final customTagsProvider = StateNotifierProvider<CustomTagsNotifier, List<Tag>>((ref) {
  return CustomTagsNotifier(ref.read(tagsRepositoryProvider));
});

class CustomTagsNotifier extends StateNotifier<List<Tag>> {
  final TagsRepository _repository;

  CustomTagsNotifier(this._repository) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _repository.loadCustomTags();
  }

  Future<void> addTag(String label, String emoji) async {
    final trimLabel = label.trim();
    if (trimLabel.isEmpty) return;

    // Check duplicates in default
    if (defaultTags.any((t) => t.label.toLowerCase() == trimLabel.toLowerCase())) return;
    
    // Check duplicates in custom
    if (state.any((t) => t.label.toLowerCase() == trimLabel.toLowerCase())) return;

    final newTag = Tag(label: trimLabel, emoji: emoji, isDefault: false);
    final newState = [...state, newTag];
    state = newState;
    await _repository.saveCustomTags(newState);
  }

  Future<void> deleteTag(Tag tag) async {
    final newState = state.where((t) => t != tag).toList();
    state = newState;
    await _repository.saveCustomTags(newState);
  }
}

// Stores the CURRENTLY SELECTED tag
final selectedTagProvider = StateProvider<Tag>((ref) => defaultTags.first);

// Helper to get ALL available tags (Defaults + Custom)
final allTagsProvider = Provider<List<Tag>>((ref) {
  final custom = ref.watch(customTagsProvider);
  return [...defaultTags, ...custom];
});
