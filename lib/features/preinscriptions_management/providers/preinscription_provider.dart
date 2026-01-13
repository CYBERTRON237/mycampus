import 'package:flutter/foundation.dart';
import '../models/preinscription_model.dart';
import '../repositories/preinscription_repository.dart';
import '../data/datasources/preinscription_remote_datasource.dart';

class PreinscriptionProvider extends ChangeNotifier {
  final PreinscriptionRepository _repository;
  
  PreinscriptionProvider() : _repository = PreinscriptionRemoteDataSource();

  // State variables
  List<PreinscriptionModel> _preinscriptions = [];
  bool _isLoading = false;
  String? _error;
  Map<String, int> _stats = {};
  List<Map<String, dynamic>> _facultyStats = [];
  List<Map<String, dynamic>> _recentPreinscriptions = [];
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  final int _limit = 20;
  
  // Filters
  String? _selectedFaculty;
  String? _selectedStatus;
  String? _selectedPaymentStatus;
  String _searchQuery = '';

  // Getters
  List<PreinscriptionModel> get preinscriptions => _preinscriptions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, int> get stats => _stats;
  List<Map<String, dynamic>> get facultyStats => _facultyStats;
  List<Map<String, dynamic>> get recentPreinscriptions => _recentPreinscriptions;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  String? get selectedFaculty => _selectedFaculty;
  String? get selectedStatus => _selectedStatus;
  String? get selectedPaymentStatus => _selectedPaymentStatus;
  String get searchQuery => _searchQuery;

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Set filters
  void setFacultyFilter(String? faculty) {
    if (kDebugMode) {
      print('🏫 [PROVIDER DEBUG] setFacultyFilter: $faculty');
    }
    _selectedFaculty = faculty;
    _currentPage = 1;
    fetchPreinscriptions();
  }

  void setStatusFilter(String? status) {
    if (kDebugMode) {
      print('📋 [PROVIDER DEBUG] setStatusFilter: $status');
    }
    _selectedStatus = status;
    _currentPage = 1;
    fetchPreinscriptions();
  }

  void setPaymentStatusFilter(String? paymentStatus) {
    if (kDebugMode) {
      print('💳 [PROVIDER DEBUG] setPaymentStatusFilter: $paymentStatus');
    }
    _selectedPaymentStatus = paymentStatus;
    _currentPage = 1;
    fetchPreinscriptions();
  }

  void setSearchQuery(String query) {
    if (kDebugMode) {
      print('🔎 [PROVIDER DEBUG] setSearchQuery: "$query"');
    }
    _searchQuery = query;
    _currentPage = 1;
    fetchPreinscriptions();
  }

  void clearFilters() {
    if (kDebugMode) {
      print('🧹 [PROVIDER DEBUG] clearFilters appelé');
    }
    _selectedFaculty = null;
    _selectedStatus = null;
    _selectedPaymentStatus = null;
    _searchQuery = '';
    _currentPage = 1;
    fetchPreinscriptions();
  }

  // Fetch preinscriptions
  Future<void> fetchPreinscriptions({bool refresh = false}) async {
    if (kDebugMode) {
      print('🚀 [PROVIDER DEBUG] fetchPreinscriptions appelé avec refresh=$refresh');
    }
    
    if (refresh) {
      _currentPage = 1;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('📋 [PROVIDER DEBUG] Appel au repository avec: page=$_currentPage, limit=$_limit, faculty=$_selectedFaculty, status=$_selectedStatus, paymentStatus=$_selectedPaymentStatus, search=$_searchQuery');
      }
      
      final result = await _repository.getPreinscriptions(
        page: _currentPage,
        limit: _limit,
        faculty: _selectedFaculty,
        status: _selectedStatus,
        paymentStatus: _selectedPaymentStatus,
        search: _searchQuery.isEmpty ? null : _searchQuery,
      );

      result.fold(
        (error) {
          if (kDebugMode) {
            print('❌ [PROVIDER DEBUG] Erreur du repository: $error');
          }
          _error = error;
          _isLoading = false;
          notifyListeners();
        },
        (preinscriptions) {
          if (kDebugMode) {
            print('✅ [PROVIDER DEBUG] Succès du repository: ${preinscriptions.length} préinscriptions reçues');
          }
          
          if (refresh || _currentPage == 1) {
            _preinscriptions = preinscriptions;
          } else {
            _preinscriptions.addAll(preinscriptions);
          }
          
          // Calculate pagination (assuming API returns total count)
          _totalCount = _preinscriptions.length;
          _totalPages = (_totalCount / _limit).ceil();
          
          if (kDebugMode) {
            print('📊 [PROVIDER DEBUG] Pagination: total=$_totalCount, pages=$_totalPages, current=$_currentPage');
          }
          
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('💥 [PROVIDER DEBUG] Exception dans fetchPreinscriptions: $e');
      }
      _error = 'Erreur inattendue: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load more preinscriptions
  Future<void> loadMore() async {
    if (_currentPage < _totalPages && !_isLoading) {
      _currentPage++;
      await fetchPreinscriptions();
    }
  }

  // Get preinscription by ID
  Future<PreinscriptionModel?> getPreinscriptionById(int id) async {
    if (kDebugMode) {
      print('🔍 [PROVIDER DEBUG] getPreinscriptionById appelé avec id: $id');
    }
    
    try {
      final result = await _repository.getPreinscriptionById(id);
      
      return result.fold(
        (error) {
          if (kDebugMode) {
            print('❌ [PROVIDER DEBUG] Erreur getPreinscriptionById: $error');
          }
          _error = error;
          notifyListeners();
          return null;
        },
        (preinscription) {
          if (kDebugMode) {
            print('✅ [PROVIDER DEBUG] Succès getPreinscriptionById: ${preinscription.uniqueCode}');
          }
          
          // Update in list if exists
          final index = _preinscriptions.indexWhere((p) => p.id == id);
          if (index != -1) {
            _preinscriptions[index] = preinscription;
            notifyListeners();
          }
          return preinscription;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('💥 [PROVIDER DEBUG] Exception getPreinscriptionById: $e');
      }
      _error = 'Erreur inattendue: $e';
      notifyListeners();
      return null;
    }
  }
  
  // Get preinscription by code (méthode principale pour les détails)
  Future<PreinscriptionModel?> getPreinscriptionByCode(String uniqueCode) async {
    if (kDebugMode) {
      print('🔍 [PROVIDER DEBUG] getPreinscriptionByCode appelé avec code: $uniqueCode');
    }
    
    try {
      final result = await _repository.getPreinscriptionByCode(uniqueCode);
      
      return result.fold(
        (error) {
          if (kDebugMode) {
            print('❌ [PROVIDER DEBUG] Erreur getPreinscriptionByCode: $error');
          }
          _error = error;
          notifyListeners();
          return null;
        },
        (preinscription) {
          if (kDebugMode) {
            print('✅ [PROVIDER DEBUG] Succès getPreinscriptionByCode: ${preinscription.uniqueCode}');
          }
          
          // Update in list if exists
          final index = _preinscriptions.indexWhere((p) => p.uniqueCode == uniqueCode);
          if (index != -1) {
            _preinscriptions[index] = preinscription;
            notifyListeners();
          }
          return preinscription;
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('💥 [PROVIDER DEBUG] Exception getPreinscriptionByCode: $e');
      }
      _error = 'Erreur inattendue: $e';
      notifyListeners();
      return null;
    }
  }

  // Create preinscription
  Future<bool> createPreinscription(PreinscriptionModel preinscription) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.createPreinscription(preinscription);
      
      return result.fold(
        (error) {
          _error = error;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (newPreinscription) {
          _preinscriptions.insert(0, newPreinscription);
          _totalCount++;
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = 'Erreur inattendue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update preinscription
  Future<bool> updatePreinscription(int id, PreinscriptionModel preinscription) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.updatePreinscription(id, preinscription);
      
      return result.fold(
        (error) {
          _error = error;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (updatedPreinscription) {
          final index = _preinscriptions.indexWhere((p) => p.id == id);
          if (index != -1) {
            _preinscriptions[index] = updatedPreinscription;
          }
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = 'Erreur inattendue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete preinscription
  Future<bool> deletePreinscription(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.deletePreinscription(id);
      
      return result.fold(
        (error) {
          _error = error;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (success) {
          _preinscriptions.removeWhere((p) => p.id == id);
          _totalCount--;
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = 'Erreur inattendue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update preinscription status
  Future<bool> updatePreinscriptionStatus(
    int id, 
    String status, {
    String? comments,
    String? rejectionReason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.updatePreinscriptionStatus(
        id, 
        status,
        comments: comments,
        rejectionReason: rejectionReason,
      );
      
      return result.fold(
        (error) {
          _error = error;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (success) {
          // Update in list
          final index = _preinscriptions.indexWhere((p) => p.id == id);
          if (index != -1) {
            _preinscriptions[index] = _preinscriptions[index].copyWith(
              status: status,
              reviewComments: comments,
              rejectionReason: rejectionReason,
              reviewDate: DateTime.now(),
            );
          }
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = 'Erreur inattendue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Batch validation methods
  Future<bool> batchValidatePreinscriptions(List<int> ids) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool allSuccess = true;
      
      for (final id in ids) {
        final success = await updatePreinscriptionStatus(id, 'accepted');
        if (!success) {
          allSuccess = false;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return allSuccess;
    } catch (e) {
      _error = 'Erreur lors de la validation en lot: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> batchRejectPreinscriptions(List<int> ids, {String? rejectionReason}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool allSuccess = true;
      
      for (final id in ids) {
        final success = await updatePreinscriptionStatus(id, 'rejected', rejectionReason: rejectionReason);
        if (!success) {
          allSuccess = false;
        }
      }
      
      _isLoading = false;
      notifyListeners();
      return allSuccess;
    } catch (e) {
      _error = 'Erreur lors du rejet en lot: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Advanced validation methods
  Future<bool> acceptPreinscriptionWithAdmission(
    int id, {
    required String admissionNumber,
    required DateTime registrationDeadline,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First update status to accepted
      final statusSuccess = await updatePreinscriptionStatus(id, 'accepted');
      
      if (statusSuccess) {
        // Update admission details
        final index = _preinscriptions.indexWhere((p) => p.id == id);
        if (index != -1) {
          _preinscriptions[index] = _preinscriptions[index].copyWith(
            admissionNumber: admissionNumber,
            registrationDeadline: registrationDeadline,
          );
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _error = 'Erreur lors de la mise à jour du statut';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur inattendue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Schedule interview
  Future<bool> scheduleInterview(
    int id, {
    required DateTime interviewDate,
    required String interviewLocation,
    required String interviewType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.scheduleInterview(
        id,
        interviewDate: interviewDate,
        interviewLocation: interviewLocation,
        interviewType: interviewType,
      );
      
      return result.fold(
        (error) {
          _error = error;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (success) {
          // Update in list
          final index = _preinscriptions.indexWhere((p) => p.id == id);
          if (index != -1) {
            _preinscriptions[index] = _preinscriptions[index].copyWith(
              interviewRequired: true,
              interviewDate: interviewDate,
              interviewLocation: interviewLocation,
              interviewType: interviewType,
            );
          }
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = 'Erreur inattendue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update interview result
  Future<bool> updateInterviewResult(int id, String result, {String? notes}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final resultResponse = await _repository.updateInterviewResult(id, result, notes: notes);
      
      return resultResponse.fold(
        (error) {
          _error = error;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (success) {
          // Update in list
          final index = _preinscriptions.indexWhere((p) => p.id == id);
          if (index != -1) {
            _preinscriptions[index] = _preinscriptions[index].copyWith(
              interviewResult: result,
              interviewNotes: notes,
            );
          }
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = 'Erreur inattendue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Accept preinscription
  Future<bool> acceptPreinscription(
    int id, {
    required String admissionNumber,
    required DateTime registrationDeadline,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.acceptPreinscription(
        id,
        admissionNumber: admissionNumber,
        registrationDeadline: registrationDeadline,
      );
      
      return result.fold(
        (error) {
          _error = error;
          _isLoading = false;
          notifyListeners();
          return false;
        },
        (success) {
          // Update in list
          final index = _preinscriptions.indexWhere((p) => p.id == id);
          if (index != -1) {
            _preinscriptions[index] = _preinscriptions[index].copyWith(
              status: 'accepted',
              admissionNumber: admissionNumber,
              registrationDeadline: registrationDeadline,
              admissionDate: DateTime.now(),
            );
          }
          _isLoading = false;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      _error = 'Erreur inattendue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fetch statistics
  Future<void> fetchStats() async {
    if (kDebugMode) {
      print('📊 [PROVIDER DEBUG] fetchStats appelé');
    }
    
    try {
      final result = await _repository.getPreinscriptionsStats();
      
      result.fold(
        (error) {
          if (kDebugMode) {
            print('❌ [PROVIDER DEBUG] Erreur fetchStats: $error');
          }
          _error = error;
          notifyListeners();
        },
        (stats) {
          if (kDebugMode) {
            print('✅ [PROVIDER DEBUG] Succès fetchStats: $stats');
          }
          _stats = stats;
          notifyListeners();
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('💥 [PROVIDER DEBUG] Exception fetchStats: $e');
      }
      _error = 'Erreur inattendue: $e';
      notifyListeners();
    }
  }

  // Fetch faculty statistics
  Future<void> fetchFacultyStats() async {
    try {
      final result = await _repository.getPreinscriptionsByFaculty();
      
      result.fold(
        (error) {
          _error = error;
          notifyListeners();
        },
        (facultyStats) {
          _facultyStats = facultyStats;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Erreur inattendue: $e';
      notifyListeners();
    }
  }

  // Fetch recent preinscriptions
  Future<void> fetchRecentPreinscriptions({int days = 7}) async {
    try {
      final result = await _repository.getRecentPreinscriptions(days: days);
      
      result.fold(
        (error) {
          _error = error;
          notifyListeners();
        },
        (recentPreinscriptions) {
          _recentPreinscriptions = recentPreinscriptions;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = 'Erreur inattendue: $e';
      notifyListeners();
    }
  }

  // Initialize data
  Future<void> initialize() async {
    if (kDebugMode) {
      print('🚀 [PROVIDER DEBUG] Initialisation du provider');
    }
    
    await Future.wait([
      fetchPreinscriptions(),
      fetchStats(),
      fetchFacultyStats(),
      fetchRecentPreinscriptions(),
    ]);
    
    if (kDebugMode) {
      print('✅ [PROVIDER DEBUG] Initialisation terminée');
    }
  }
}
