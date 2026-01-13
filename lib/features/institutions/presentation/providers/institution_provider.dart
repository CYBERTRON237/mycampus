import 'package:flutter/foundation.dart';
import 'package:mycampus/core/utils/app_logger.dart';
import 'package:mycampus/features/institutions/domain/entities/institution.dart';
import 'package:mycampus/features/institutions/services/institution_service.dart';
import 'package:mycampus/features/institutions/data/mappers/institution_mapper.dart';

class InstitutionProvider with ChangeNotifier {
  static const String _tag = 'InstitutionProvider';
  final InstitutionService _institutionService;
  
  List<Institution> _institutions = [];
  bool _isLoading = false;
  String? _error;
  
  InstitutionProvider({InstitutionService? institutionService}) 
      : _institutionService = institutionService ?? InstitutionService() {
    AppLogger.info('Initialisation du Provider', tag: _tag);
  }
  
  // Getters
  List<Institution> get institutions => List.unmodifiable(_institutions);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  
  // Charger toutes les institutions
  Future<void> loadInstitutions() async {
    const methodName = 'loadInstitutions';
    final requestId = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    
    AppLogger.info('🔵 Début du chargement des institutions', 
        tag: '$_tag.$methodName',
        context: {'request_id': requestId});
    
    _setLoading(true);
    _error = null;
    
    try {
      AppLogger.debug('Appel de getAllInstitutions()', 
          tag: '$_tag.$methodName',
          context: {'request_id': requestId});
      
      final models = await _institutionService.getAllInstitutions();
      
      AppLogger.debug('Réponse reçue', 
          tag: '$_tag.$methodName',
          context: {
            'request_id': requestId,
            'count': models.length,
          });
      
      _institutions = InstitutionMapper.toEntityList(models);
      _error = null;
      
      AppLogger.info('✅ ${_institutions.length} institutions chargées avec succès', 
          tag: '$_tag.$methodName',
          context: {'request_id': requestId});
          
      notifyListeners();
    } catch (e, stackTrace) {
      _error = 'Erreur lors du chargement des institutions: $e';
      _institutions = [];
      
      AppLogger.error('❌ Erreur lors du chargement des institutions', 
          tag: '$_tag.$methodName',
          error: e,
          stackTrace: stackTrace,
          context: {
            'request_id': requestId,
            'error': e.toString(),
          });
          
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
      AppLogger.debug('Fin du chargement des institutions', 
          tag: '$_tag.$methodName',
          context: {'request_id': requestId});
    }
  }
  
  // Récupérer une institution par son ID
  Future<Institution?> getInstitutionById(String id) async {
    try {
      _setLoading(true);
      _error = null;
      
      final model = await _institutionService.getInstitutionById(id);
      final institution = InstitutionMapper.toEntity(model);
      
      // Mettre à jour la liste des institutions si nécessaire
      final index = _institutions.indexWhere((i) => i.id == id);
      if (index != -1) {
        _institutions[index] = institution;
        notifyListeners();
      }
      
      return institution;
    } catch (e) {
      _error = 'Erreur lors de la récupération de l\'institution: $e';
      return null;
    } finally {
      _setLoading(false);
    }
  }
  
  // Créer une nouvelle institution
  Future<bool> createInstitution(Institution institution) async {
    try {
      _setLoading(true);
      _error = null;
      
      final model = InstitutionMapper.toModel(institution);
      final createdModel = await _institutionService.createInstitution(model);
      final createdInstitution = InstitutionMapper.toEntity(createdModel);
      
      _institutions.add(createdInstitution);
      notifyListeners();
      
      return true;
    } catch (e) {
      _error = 'Erreur lors de la création de l\'institution: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Mettre à jour une institution existante
  Future<bool> updateInstitution(Institution institution) async {
    try {
      _setLoading(true);
      _error = null;
      
      final model = InstitutionMapper.toModel(institution);
      final updatedModel = await _institutionService.updateInstitution(model);
      final updatedInstitution = InstitutionMapper.toEntity(updatedModel);
      
      final index = _institutions.indexWhere((i) => i.id == institution.id);
      if (index != -1) {
        _institutions[index] = updatedInstitution;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _error = 'Erreur lors de la mise à jour de l\'institution: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Supprimer une institution
  Future<bool> deleteInstitution(String id) async {
    try {
      _setLoading(true);
      _error = null;
      
      final success = await _institutionService.deleteInstitution(id);
      
      if (success) {
        _institutions.removeWhere((i) => i.id == id);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _error = 'Erreur lors de la suppression de l\'institution: $e';
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Rechercher des institutions
  Future<List<Institution>> searchInstitutions(String query) async {
    try {
      _setLoading(true);
      _error = null;
      
      final models = await _institutionService.searchInstitutions(query);
      return InstitutionMapper.toEntityList(models);
    } catch (e) {
      _error = 'Erreur lors de la recherche d\'institutions: $e';
      return [];
    } finally {
      _setLoading(false);
    }
  }
  
  // Réinitialiser l'état d'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Méthode utilitaire pour gérer l'état de chargement
  void _setLoading(bool loading) {
    const methodName = '_setLoading';
    
    if (_isLoading != loading) {
      _isLoading = loading;
      AppLogger.debug('Changement d\'état de chargement: $loading', 
          tag: '$_tag.$methodName');
      notifyListeners();
    }
  }
}
