import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models/sticker_model.dart';

class StickerService {
  static final StickerService _instance = StickerService._internal();
  factory StickerService() => _instance;
  StickerService._internal();

  List<StickerCategory> _categories = [];
  bool _isLoaded = false;

  List<StickerCategory> get categories => _categories;
  bool get isLoaded => _isLoaded;

  Future<void> loadStickers() async {
    if (_isLoaded) return;

    try {
      // Stickers par défaut intégrés dans l'app
      _categories = _getDefaultStickers();
      _isLoaded = true;
    } catch (e) {
      print('Erreur chargement stickers: $e');
      _categories = _getDefaultStickers();
      _isLoaded = true;
    }
  }

  List<StickerCategory> _getDefaultStickers() {
    return [
      // Émotions
      StickerCategory(
        id: 'emotions',
        name: 'Émotions',
        icon: '😊',
        stickers: [
          StickerModel(
            id: 'happy',
            name: 'Heureux',
            category: 'emotions',
            url: 'assets/stickers/emotions/happy.png',
            emoji: '😊',
          ),
          StickerModel(
            id: 'love',
            name: 'Amour',
            category: 'emotions',
            url: 'assets/stickers/emotions/love.png',
            emoji: '❤️',
          ),
          StickerModel(
            id: 'laugh',
            name: 'Rire',
            category: 'emotions',
            url: 'assets/stickers/emotions/laugh.png',
            emoji: '😂',
          ),
          StickerModel(
            id: 'sad',
            name: 'Triste',
            category: 'emotions',
            url: 'assets/stickers/emotions/sad.png',
            emoji: '😢',
          ),
          StickerModel(
            id: 'angry',
            name: 'En colère',
            category: 'emotions',
            url: 'assets/stickers/emotions/angry.png',
            emoji: '😠',
          ),
        ],
      ),
      // Réactions
      StickerCategory(
        id: 'reactions',
        name: 'Réactions',
        icon: '👍',
        stickers: [
          StickerModel(
            id: 'thumbs_up',
            name: 'Pouce en l\'air',
            category: 'reactions',
            url: 'assets/stickers/reactions/thumbs_up.png',
            emoji: '👍',
          ),
          StickerModel(
            id: 'thumbs_down',
            name: 'Pouce en bas',
            category: 'reactions',
            url: 'assets/stickers/reactions/thumbs_down.png',
            emoji: '👎',
          ),
          StickerModel(
            id: 'clap',
            name: 'Applaudir',
            category: 'reactions',
            url: 'assets/stickers/reactions/clap.png',
            emoji: '👏',
          ),
          StickerModel(
            id: 'fire',
            name: 'Feu',
            category: 'reactions',
            url: 'assets/stickers/reactions/fire.png',
            emoji: '🔥',
          ),
          StickerModel(
            id: '100',
            name: '100',
            category: 'reactions',
            url: 'assets/stickers/reactions/100.png',
            emoji: '💯',
          ),
        ],
      ),
      // Animaux
      StickerCategory(
        id: 'animals',
        name: 'Animaux',
        icon: '🐶',
        stickers: [
          StickerModel(
            id: 'dog',
            name: 'Chien',
            category: 'animals',
            url: 'assets/stickers/animals/dog.png',
            emoji: '🐶',
          ),
          StickerModel(
            id: 'cat',
            name: 'Chat',
            category: 'animals',
            url: 'assets/stickers/animals/cat.png',
            emoji: '🐱',
          ),
          StickerModel(
            id: 'monkey',
            name: 'Singe',
            category: 'animals',
            url: 'assets/stickers/animals/monkey.png',
            emoji: '🐵',
            isAnimated: true,
          ),
          StickerModel(
            id: 'lion',
            name: 'Lion',
            category: 'animals',
            url: 'assets/stickers/animals/lion.png',
            emoji: '🦁',
          ),
          StickerModel(
            id: 'elephant',
            name: 'Éléphant',
            category: 'animals',
            url: 'assets/stickers/animals/elephant.png',
            emoji: '🐘',
          ),
        ],
      ),
      // Célébrations
      StickerCategory(
        id: 'celebrations',
        name: 'Célébrations',
        icon: '🎉',
        stickers: [
          StickerModel(
            id: 'party',
            name: 'Fête',
            category: 'celebrations',
            url: 'assets/stickers/celebrations/party.png',
            emoji: '🎉',
          ),
          StickerModel(
            id: 'confetti',
            name: 'Confettis',
            category: 'celebrations',
            url: 'assets/stickers/celebrations/confetti.png',
            emoji: '🎊',
          ),
          StickerModel(
            id: 'birthday',
            name: 'Anniversaire',
            category: 'celebrations',
            url: 'assets/stickers/celebrations/birthday.png',
            emoji: '🎂',
          ),
          StickerModel(
            id: 'gift',
            name: 'Cadeau',
            category: 'celebrations',
            url: 'assets/stickers/celebrations/gift.png',
            emoji: '🎁',
          ),
        ],
      ),
    ];
  }

  StickerModel? getStickerById(String id) {
    for (var category in _categories) {
      try {
        return category.stickers.firstWhere((sticker) => sticker.id == id);
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  List<StickerModel> searchStickers(String query) {
    if (query.isEmpty) return _categories.expand((cat) => cat.stickers).toList();
    
    return _categories
        .expand((cat) => cat.stickers)
        .where((sticker) => 
            sticker.name.toLowerCase().contains(query.toLowerCase()) ||
            sticker.emoji.contains(query))
        .toList();
  }
}
