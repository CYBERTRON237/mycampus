import 'package:flutter/foundation.dart';
import '../../models/announcement_model.dart';
import '../../repositories/announcement_repository.dart';

class AnnouncementProvider extends ChangeNotifier {
  final AnnouncementRepository _repository;
  
  List<AnnouncementModel> _announcements = [];
  List<AnnouncementModel> _filteredAnnouncements = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _statistics = {};
  String _selectedCategory = 'all';
  String _selectedPriority = 'all';
  String _searchQuery = '';

  AnnouncementProvider(this._repository);

  // Getters
  List<AnnouncementModel> get announcements => _filteredAnnouncements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get statistics => _statistics;
  String get selectedCategory => _selectedCategory;
  String get selectedPriority => _selectedPriority;
  String get searchQuery => _searchQuery;

  // Chargement des annonces
  Future<void> loadAnnouncements() async {
    _setLoading(true);
    try {
      final result = await _repository.getAnnouncements();
      result.fold(
        (error) {
          _error = error;
          _announcements = [];
        },
        (response) {
          _announcements = response.data ?? [];
          _error = null;
        }
      );
      _applyFilters();
    } catch (e) {
      _error = e.toString();
      _announcements = [];
      debugPrint('Error loading announcements: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Chargement des statistiques
  Future<void> loadStatistics() async {
    try {
      final result = await _repository.getStatistics();
      result.fold(
        (error) {
          debugPrint('Error loading statistics: $error');
        },
        (stats) {
          _statistics = {
            'total': stats.total,
            'published': stats.published,
            'draft': stats.draft,
            'scheduled': stats.scheduled,
            'pinned': stats.pinned,
            'requiresAck': stats.requiresAck,
            'expired': stats.expired,
          };
          notifyListeners();
        }
      );
    } catch (e) {
      debugPrint('Error loading statistics: $e');
    }
  }

  // Création d'une annonce
  Future<bool> createAnnouncement(Map<String, dynamic> announcementData) async {
    _setLoading(true);
    try {
      final result = await _repository.createAnnouncement(
        institutionId: announcementData['institution_id'],
        scope: _parseScope(announcementData['scope']),
        scopeIds: announcementData['scope_ids'],
        targetAudience: announcementData['target_audience'],
        targetLevels: announcementData['target_levels'],
        priority: _parsePriority(announcementData['priority']),
        category: _parseCategory(announcementData['category']),
        announcementType: _parseAnnouncementType(announcementData['announcement_type']),
        title: announcementData['title'],
        content: announcementData['content'],
        excerpt: announcementData['excerpt'],
        coverImageUrl: announcementData['cover_image_url'],
        attachments: announcementData['attachments'],
        attachmentsUrl: announcementData['attachments_url'],
        externalLink: announcementData['external_link'],
        isPinned: announcementData['is_pinned'] ?? false,
        isFeatured: announcementData['is_featured'] ?? false,
        showOnHomepage: announcementData['show_on_homepage'] ?? false,
        requiresAcknowledgment: announcementData['requires_acknowledgment'] ?? false,
        publishAt: announcementData['publish_at'],
        expireAt: announcementData['expire_at'],
        status: announcementData['status'] ?? AnnouncementStatus.draft,
        allowComments: announcementData['allow_comments'] ?? true,
        tags: announcementData['tags'],
        metadata: announcementData['metadata'],
      );
      
      result.fold(
        (error) {
          _error = error;
          return false;
        },
        (announcement) {
          _error = null;
          return true;
        }
      );
      
      await loadAnnouncements(); // Recharger la liste
      await loadStatistics(); // Recharger les statistiques
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error creating announcement: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mise à jour d'une annonce
  Future<bool> updateAnnouncement(int id, Map<String, dynamic> announcementData) async {
    _setLoading(true);
    try {
      final result = await _repository.updateAnnouncement(
        id: id,
        institutionId: announcementData['institution_id'],
        scope: announcementData['scope'],
        scopeIds: announcementData['scope_ids'],
        targetAudience: announcementData['target_audience'],
        targetLevels: announcementData['target_levels'],
        priority: announcementData['priority'],
        category: announcementData['category'],
        announcementType: announcementData['announcement_type'],
        title: announcementData['title'],
        content: announcementData['content'],
        excerpt: announcementData['excerpt'],
        coverImageUrl: announcementData['cover_image_url'],
        attachments: announcementData['attachments'],
        attachmentsUrl: announcementData['attachments_url'],
        externalLink: announcementData['external_link'],
        isPinned: announcementData['is_pinned'],
        isFeatured: announcementData['is_featured'],
        showOnHomepage: announcementData['show_on_homepage'],
        requiresAcknowledgment: announcementData['requires_acknowledgment'],
        publishAt: announcementData['publish_at'],
        expireAt: announcementData['expire_at'],
        status: announcementData['status'],
        allowComments: announcementData['allow_comments'],
        tags: announcementData['tags'],
        metadata: announcementData['metadata'],
      );
      
      result.fold(
        (error) {
          _error = error;
          return false;
        },
        (announcement) {
          _error = null;
          return true;
        }
      );
      
      await loadAnnouncements(); // Recharger la liste
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating announcement: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Suppression d'une annonce
  Future<bool> deleteAnnouncement(int id) async {
    _setLoading(true);
    try {
      final result = await _repository.deleteAnnouncement(id);
      
      result.fold(
        (error) {
          _error = error;
          return false;
        },
        (success) async {
          if (success) {
            _announcements.removeWhere((announcement) => announcement.id == id);
            _applyFilters();
            await loadStatistics(); // Recharger les statistiques
          }
          _error = null;
          return success;
        }
      );
      
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error deleting announcement: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Filtrage par catégorie
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  // Filtrage par priorité
  void filterByPriority(String priority) {
    _selectedPriority = priority;
    _applyFilters();
  }

  // Recherche
  void searchAnnouncements(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
  }

  // Application des filtres
  void _applyFilters() {
    _filteredAnnouncements = _announcements.where((announcement) {
      // Filtrage par catégorie
      if (_selectedCategory != 'all' && announcement.category?.name != _selectedCategory) {
        return false;
      }

      // Filtrage par priorité
      if (_selectedPriority != 'all' && announcement.priority?.name != _selectedPriority) {
        return false;
      }

      // Recherche
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery;
        if (!announcement.title.toLowerCase().contains(searchLower) &&
            !announcement.content.toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      return true;
    }).toList();
    
    notifyListeners();
  }

  // Réinitialisation des filtres
  void resetFilters() {
    _selectedCategory = 'all';
    _selectedPriority = 'all';
    _searchQuery = '';
    _applyFilters();
  }

  // Gestion du chargement
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Effacer les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Rafraîchir les données
  Future<void> refresh() async {
    await Future.wait([
      loadAnnouncements(),
      loadStatistics(),
    ]);
  }

  // Helper methods to parse enums from strings
  AnnouncementScope _parseScope(dynamic scope) {
    if (scope is AnnouncementScope) return scope;
    if (scope is String) {
      return AnnouncementScope.values.firstWhere(
        (e) => e.name == scope,
        orElse: () => AnnouncementScope.institution,
      );
    }
    return AnnouncementScope.institution;
  }

  AnnouncementPriority _parsePriority(dynamic priority) {
    if (priority is AnnouncementPriority) return priority;
    if (priority is String) {
      return AnnouncementPriority.values.firstWhere(
        (e) => e.name == priority,
        orElse: () => AnnouncementPriority.normal,
      );
    }
    return AnnouncementPriority.normal;
  }

  AnnouncementCategory _parseCategory(dynamic category) {
    if (category is AnnouncementCategory) return category;
    if (category is String) {
      return AnnouncementCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => AnnouncementCategory.general,
      );
    }
    return AnnouncementCategory.general;
  }

  AnnouncementType _parseAnnouncementType(dynamic type) {
    if (type is AnnouncementType) return type;
    if (type is String) {
      return AnnouncementType.values.firstWhere(
        (e) => e.name == type,
        orElse: () => AnnouncementType.general,
      );
    }
    return AnnouncementType.general;
  }
}
