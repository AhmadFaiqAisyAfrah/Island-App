import 'dart:convert';

class Tag {
  final String label;
  final String emoji;
  final bool isDefault;

  const Tag({
    required this.label,
    required this.emoji,
    this.isDefault = false,
  });

  // Serialization
  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'emoji': emoji,
      'isDefault': isDefault,
    };
  }

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(
      label: map['label'] as String,
      emoji: map['emoji'] as String,
      isDefault: map['isDefault'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory Tag.fromJson(String source) => Tag.fromMap(json.decode(source));

  // Equality
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Tag &&
      other.label == label &&
      other.emoji == emoji;
  }

  @override
  int get hashCode => label.hashCode ^ emoji.hashCode;

  Tag copyWith({
    String? label,
    String? emoji,
    bool? isDefault,
  }) {
    return Tag(
      label: label ?? this.label,
      emoji: emoji ?? this.emoji,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
