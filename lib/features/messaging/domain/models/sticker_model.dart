class StickerModel {
  final String id;
  final String name;
  final String category;
  final String url;
  final String emoji;
  final bool isAnimated;
  final int size;

  StickerModel({
    required this.id,
    required this.name,
    required this.category,
    required this.url,
    required this.emoji,
    this.isAnimated = false,
    this.size = 150,
  });

  factory StickerModel.fromJson(Map<String, dynamic> json) {
    return StickerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
      isAnimated: json['is_animated'] ?? false,
      size: json['size'] ?? 150,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'url': url,
      'emoji': emoji,
      'is_animated': isAnimated,
      'size': size,
    };
  }
}

class StickerCategory {
  final String id;
  final String name;
  final String icon;
  final List<StickerModel> stickers;
  final bool isPremium;

  StickerCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.stickers,
    this.isPremium = false,
  });

  factory StickerCategory.fromJson(Map<String, dynamic> json) {
    return StickerCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      stickers: (json['stickers'] as List?)
          ?.map((s) => StickerModel.fromJson(s))
          .toList() ?? [],
      isPremium: json['is_premium'] ?? false,
    );
  }
}
