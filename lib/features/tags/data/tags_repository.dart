import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/tag_model.dart';

class TagsRepository {
  static const String _keyCustomTags = 'custom_tags_list';

  Future<List<Tag>> loadCustomTags() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_keyCustomTags) ?? [];
    
    // Migration: If we encounter strings that aren't JSON, we ignore or migrate them?
    // Since this is dev environment, we'll try to parse. If fail, we skip.
    // Ideally we would map old strings to Tag(label: str, emoji: '?').
    
    return jsonList.map((str) {
      try {
        return Tag.fromJson(str);
      } catch (e) {
        // Fallback for migration of legacy string tags if any
        return Tag(label: str, emoji: "⚪"); 
      }
    }).toList();
  }

  Future<void> saveCustomTags(List<Tag> tags) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = tags.map((t) => t.toJson()).toList();
    await prefs.setStringList(_keyCustomTags, jsonList);
  }
}
