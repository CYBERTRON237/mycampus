import 'package:flutter/foundation.dart';
import 'package:mycampus/features/auth/services/auth_service.dart';
import 'package:mycampus/features/auth/models/user_model.dart';
import 'package:mycampus/features/student_management/data/models/enhanced_student_model.dart';
import 'package:mycampus/features/student_management/data/repositories/enhanced_student_repository.dart';

class EnhancedStudentProvider extends ChangeNotifier {
  final EnhancedStudentRepository _repository;
  final AuthService _authService;
  UserModel? _currentUser;

  // State variables
  List<EnhancedStudentModel> _students = [];
  List<EnhancedStudentModel> _selectedStudents = [];
  StudentStatistics? _statistics;
  StudentFilters _filters = const StudentFilters();
  
  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;
  int _limit = 20;
  
  // Loading and error states
  bool _isLoading = false;
  bool _isLoadingStatistics = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  String? _error;
  
  // Selection mode
  bool _isSelectionMode = false;
  
  // View modes
  StudentViewMode _viewMode = StudentViewMode.list;
  StudentSortBy _sortBy = StudentSortBy.createdAt;
  StudentSortOrder _sortOrder = StudentSortOrder.descending;
  
  // Search state
  String _searchQuery = '';
  bool _isSearchVisible = false;
  
  // Filter states
  Map<String, dynamic> _activeFilters = {};
  
  // Advanced features
  bool _showAdvancedFilters = false;
  bool _showStatistics = false;

  EnhancedStudentProvider({
    required EnhancedStudentRepository repository,
    required AuthService authService,
  }) : _repository = repository, _authService = authService {
    _currentUser = _authService.currentUser;
  }

  // Getters
  List<EnhancedStudentModel> get students => List.unmodifiable(_students);
  List<EnhancedStudentModel> get selectedStudents => List.unmodifiable(_selectedStudents);
  StudentStatistics? get statistics => _statistics;
  StudentFilters get filters => _filters;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  int get limit => _limit;
  bool get isLoading => _isLoading;
  bool get isLoadingStatistics => _isLoadingStatistics;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  String? get error => _error;
  bool get isSelectionMode => _isSelectionMode;
  StudentViewMode get viewMode => _viewMode;
  StudentSortBy get sortBy => _sortBy;
  StudentSortOrder get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;
  bool get isSearchVisible => _isSearchVisible;
  Map<String, dynamic> get activeFilters => Map.unmodifiable(_activeFilters);
  bool get showAdvancedFilters => _showAdvancedFilters;
  bool get showStatistics => _showStatistics;

  // Computed properties
  bool get hasError => _error != null;
  bool get isEmpty => _students.isEmpty && !_isLoading;
  bool get canCreateStudent => _currentUser?.role != null && ['admin', 'superadmin', 'admin_local', 'admin_national', 'faculty_admin', 'manager'].contains(_currentUser!.role);
  bool get canEditStudent => _currentUser?.role != null && ['admin', 'superadmin', 'admin_local', 'admin_national', 'faculty_admin', 'manager'].contains(_currentUser!.role);
  bool get canDeleteStudent => _currentUser?.role != null && ['admin', 'superadmin', 'admin_local', 'admin_national'].contains(_currentUser!.role);
  bool get canViewStatistics => _currentUser?.role != null && ['admin', 'superadmin', 'admin_local', 'admin_national', 'faculty_admin', 'manager'].contains(_currentUser!.role);
  bool get canExportStudents => _currentUser?.role != null && ['admin', 'superadmin', 'admin_local', 'admin_national', 'faculty_admin'].contains(_currentUser!.role);
  bool get canImportStudents => _currentUser?.role != null && ['admin', 'superadmin', 'admin_local', 'admin_national', 'faculty_admin'].contains(_currentUser!.role);
  bool get canManageStudents => _currentUser?.role != null && ['admin', 'superadmin', 'admin_local', 'admin_national', 'faculty_admin', 'manager'].contains(_currentUser!.role);

  double get averageGpa {
    if (_students.isEmpty) return 0.0;
    final studentsWithGpa = _students.where((s) => s.gpa != null);
    if (studentsWithGpa.isEmpty) return 0.0;
    final total = studentsWithGpa.fold<double>(0.0, (sum, student) => sum + student.gpa!);
    return total / studentsWithGpa.length;
  }

  int get activeStudentsCount {
    return _students.where((s) => s.isActive).length;
  }

  int get verifiedStudentsCount {
    return _students.where((s) => s.isVerified).length;
  }

  Map<StudentStatus, int> get studentsByStatus {
    final Map<StudentStatus, int> statusCount = {};
    for (final status in StudentStatus.values) {
      statusCount[status] = _students.where((s) => s.status == status).length;
    }
    return statusCount;
  }

  Map<AcademicLevel, int> get studentsByLevel {
    final Map<AcademicLevel, int> levelCount = {};
    for (final level in AcademicLevel.values) {
      levelCount[level] = _students.where((s) => s.currentLevel == level).length;
    }
    return levelCount;
  }

  // Core methods
  Future<void> loadStudents({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _students.clear();
    }

    _setLoading(true);
    _clearError();

    try {
      final students = await _repository.getStudents(
        filters: _filters,
        page: _currentPage,
        limit: _limit,
      );

      if (refresh) {
        _students = students;
      } else {
        _students.addAll(students);
      }

      // Update pagination info (mock for now)
      _totalCount = _students.length;
      _totalPages = (_totalCount / _limit).ceil();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadNextPage() async {
    if (_currentPage < _totalPages && !_isLoading) {
      _currentPage++;
      await loadStudents();
    }
  }

  Future<void> loadPreviousPage() async {
    if (_currentPage > 1 && !_isLoading) {
      _currentPage--;
      await loadStudents(refresh: true);
    }
  }

  Future<void> goToPage(int page) async {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      _currentPage = page;
      await loadStudents(refresh: true);
    }
  }

  Future<void> refreshStudents() async {
    await loadStudents(refresh: true);
  }

  Future<void> loadStatistics() async {
    _setLoadingStatistics(true);
    _clearError();

    try {
      _statistics = await _repository.getStudentStatistics();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoadingStatistics(false);
    }
  }

  // CRUD operations
  Future<Map<String, dynamic>> createStudent(EnhancedStudentModel student) async {
    _setCreating(true);
    _clearError();

    try {
      // Validate student data
      final isValid = await _repository.validateStudentData(student);
      if (!isValid) {
        final errors = await _repository.getStudentValidationErrors(student);
        throw Exception(errors.join(', '));
      }

      final createdStudent = await _repository.createStudent(student);
      _students.insert(0, createdStudent);
      _totalCount++;

      notifyListeners();
      return {'success': true, 'message': 'Étudiant créé avec succès', 'data': createdStudent};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    } finally {
      _setCreating(false);
    }
  }

  Future<Map<String, dynamic>> updateStudent(int studentId, EnhancedStudentModel student) async {
    _setUpdating(true);
    _clearError();

    try {
      // Validate student data
      final isValid = await _repository.validateStudentData(student);
      if (!isValid) {
        final errors = await _repository.getStudentValidationErrors(student);
        throw Exception(errors.join(', '));
      }

      final updatedStudent = await _repository.updateStudent(studentId, student);
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        _students[index] = updatedStudent;
      }

      notifyListeners();
      return {'success': true, 'message': 'Étudiant mis à jour avec succès', 'data': updatedStudent};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    } finally {
      _setUpdating(false);
    }
  }

  Future<Map<String, dynamic>> deleteStudent(int studentId) async {
    _setDeleting(true);
    _clearError();

    try {
      final success = await _repository.deleteStudent(studentId);
      if (success) {
        _students.removeWhere((s) => s.id == studentId);
        _selectedStudents.removeWhere((s) => s.id == studentId);
        _totalCount--;
      }

      notifyListeners();
      return {'success': success, 'message': success ? 'Étudiant supprimé avec succès' : 'Échec de la suppression'};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    } finally {
      _setDeleting(false);
    }
  }

  Future<Map<String, dynamic>> restoreStudent(int studentId) async {
    _clearError();

    try {
      final success = await _repository.restoreStudent(studentId);
      if (success) {
        await refreshStudents();
      }

      notifyListeners();
      return {'success': success, 'message': success ? 'Étudiant restauré avec succès' : 'Échec de la restauration'};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  // Bulk operations
  Future<Map<String, dynamic>> deleteSelectedStudents() async {
    if (_selectedStudents.isEmpty) {
      return {'success': false, 'message': 'Aucun étudiant sélectionné'};
    }

    _setDeleting(true);
    _clearError();

    try {
      final studentIds = _selectedStudents.map((s) => s.id).toList();
      final success = await _repository.deleteStudents(studentIds);
      
      if (success) {
        _students.removeWhere((s) => studentIds.contains(s.id));
        _selectedStudents.clear();
        _totalCount -= studentIds.length;
      }

      notifyListeners();
      return {'success': success, 'message': success ? '${studentIds.length} étudiants supprimés' : 'Échec de la suppression'};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    } finally {
      _setDeleting(false);
    }
  }

  Future<Map<String, dynamic>> activateSelectedStudents() async {
    if (_selectedStudents.isEmpty) {
      return {'success': false, 'message': 'Aucun étudiant sélectionné'};
    }

    _clearError();

    try {
      final studentIds = _selectedStudents.map((s) => s.id).toList();
      final success = await _repository.activateStudents(studentIds);
      
      if (success) {
        await refreshStudents();
        _selectedStudents.clear();
      }

      notifyListeners();
      return {'success': success, 'message': success ? '${studentIds.length} étudiants activés' : 'Échec de l\'activation'};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deactivateSelectedStudents() async {
    if (_selectedStudents.isEmpty) {
      return {'success': false, 'message': 'Aucun étudiant sélectionné'};
    }

    _clearError();

    try {
      final studentIds = _selectedStudents.map((s) => s.id).toList();
      final success = await _repository.deactivateStudents(studentIds);
      
      if (success) {
        await refreshStudents();
        _selectedStudents.clear();
      }

      notifyListeners();
      return {'success': success, 'message': success ? '${studentIds.length} étudiants désactivés' : 'Échec de la désactivation'};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> verifySelectedStudents() async {
    if (_selectedStudents.isEmpty) {
      return {'success': false, 'message': 'Aucun étudiant sélectionné'};
    }

    _clearError();

    try {
      final studentIds = _selectedStudents.map((s) => s.id).toList();
      final success = await _repository.verifyStudents(studentIds);
      
      if (success) {
        await refreshStudents();
        _selectedStudents.clear();
      }

      notifyListeners();
      return {'success': success, 'message': success ? '${studentIds.length} étudiants vérifiés' : 'Échec de la vérification'};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  // Search and filtering
  Future<void> searchStudents(String query) async {
    _searchQuery = query;
    _isSearchVisible = query.isNotEmpty;
    
    if (query.isEmpty) {
      await clearFilters();
    } else {
      _filters = _filters.copyWith(search: query);
      await loadStudents(refresh: true);
    }
  }

  Future<void> applyFilters(StudentFilters filters) async {
    _filters = filters;
    _activeFilters = filters.toJson();
    await loadStudents(refresh: true);
  }

  Future<void> clearFilters() async {
    _filters = const StudentFilters();
    _activeFilters.clear();
    _searchQuery = '';
    _isSearchVisible = false;
    await loadStudents(refresh: true);
  }

  Future<void> filterByStatus(StudentStatus status) async {
    _filters = _filters.copyWith(status: status);
    await loadStudents(refresh: true);
  }

  Future<void> filterByLevel(AcademicLevel level) async {
    _filters = _filters.copyWith(level: level);
    await loadStudents(refresh: true);
  }

  Future<void> filterByInstitution(int institutionId) async {
    _filters = _filters.copyWith(institutionId: institutionId);
    await loadStudents(refresh: true);
  }

  // Selection methods
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedStudents.clear();
    }
    notifyListeners();
  }

  void toggleStudentSelection(EnhancedStudentModel student) {
    if (_selectedStudents.contains(student)) {
      _selectedStudents.remove(student);
    } else {
      _selectedStudents.add(student);
    }
    notifyListeners();
  }

  void selectAllStudents() {
    if (_selectedStudents.length == _students.length) {
      _selectedStudents.clear();
    } else {
      _selectedStudents = List.from(_students);
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedStudents.clear();
    notifyListeners();
  }

  // View mode methods
  void setViewMode(StudentViewMode mode) {
    _viewMode = mode;
    notifyListeners();
  }

  void setSortBy(StudentSortBy sortBy) {
    _sortBy = sortBy;
    _sortStudents();
    notifyListeners();
  }

  void setSortOrder(StudentSortOrder order) {
    _sortOrder = order;
    _sortStudents();
    notifyListeners();
  }

  void _sortStudents() {
    switch (_sortBy) {
      case StudentSortBy.name:
        _students.sort((a, b) => _sortOrder == StudentSortOrder.ascending
            ? a.fullName.compareTo(b.fullName)
            : b.fullName.compareTo(a.fullName));
        break;
      case StudentSortBy.matricule:
        _students.sort((a, b) => _sortOrder == StudentSortOrder.ascending
            ? a.matricule.compareTo(b.matricule)
            : b.matricule.compareTo(a.matricule));
        break;
      case StudentSortBy.level:
        _students.sort((a, b) => _sortOrder == StudentSortOrder.ascending
            ? a.currentLevel.value.compareTo(b.currentLevel.value)
            : b.currentLevel.value.compareTo(a.currentLevel.value));
        break;
      case StudentSortBy.status:
        _students.sort((a, b) => _sortOrder == StudentSortOrder.ascending
            ? a.status.value.compareTo(b.status.value)
            : b.status.value.compareTo(a.status.value));
        break;
      case StudentSortBy.gpa:
        _students.sort((a, b) {
          final aGpa = a.gpa ?? 0.0;
          final bGpa = b.gpa ?? 0.0;
          return _sortOrder == StudentSortOrder.ascending
              ? aGpa.compareTo(bGpa)
              : bGpa.compareTo(aGpa);
        });
        break;
      case StudentSortBy.createdAt:
        _students.sort((a, b) => _sortOrder == StudentSortOrder.ascending
            ? a.createdAt.compareTo(b.createdAt)
            : b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  // UI state methods
  void toggleAdvancedFilters() {
    _showAdvancedFilters = !_showAdvancedFilters;
    notifyListeners();
  }

  void toggleStatistics() {
    _showStatistics = !_showStatistics;
    if (_showStatistics && _statistics == null) {
      loadStatistics();
    }
    notifyListeners();
  }

  void toggleSearchVisibility() {
    _isSearchVisible = !_isSearchVisible;
    if (!_isSearchVisible) {
      _searchQuery = '';
      clearFilters();
    }
    notifyListeners();
  }

  // Academic operations
  Future<Map<String, dynamic>> updateStudentLevel(int studentId, AcademicLevel newLevel) async {
    _clearError();

    try {
      final updatedStudent = await _repository.updateStudentLevel(studentId, newLevel);
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        _students[index] = updatedStudent;
      }

      notifyListeners();
      return {'success': true, 'message': 'Niveau mis à jour avec succès', 'data': updatedStudent};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateStudentStatus(int studentId, StudentStatus newStatus) async {
    _clearError();

    try {
      final updatedStudent = await _repository.updateStudentStatus(studentId, newStatus);
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        _students[index] = updatedStudent;
      }

      notifyListeners();
      return {'success': true, 'message': 'Statut mis à jour avec succès', 'data': updatedStudent};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> updateStudentGpa(int studentId, double gpa) async {
    _clearError();

    try {
      final updatedStudent = await _repository.updateStudentGpa(studentId, gpa);
      final index = _students.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        _students[index] = updatedStudent;
      }

      notifyListeners();
      return {'success': true, 'message': 'GPA mis à jour avec succès', 'data': updatedStudent};
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  // Export operations
  Future<Map<String, dynamic>> exportStudents({String format = 'csv'}) async {
    _clearError();

    try {
      final data = await _repository.exportStudents(filters: _filters, format: format);
      
      return {
        'success': true,
        'message': 'Export réussi',
        'data': data,
        'format': format,
        'count': data.length,
      };
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> exportSelectedStudents({String format = 'csv'}) async {
    if (_selectedStudents.isEmpty) {
      return {'success': false, 'message': 'Aucun étudiant sélectionné'};
    }

    _clearError();

    try {
      // Create filters for selected students
      final selectedIds = _selectedStudents.map((s) => s.id).toList();
      // Note: This would need to be implemented in the repository
      final data = await _repository.exportStudents(
        filters: _filters,
        format: format,
      );
      
      // Filter data to only include selected students
      final filteredData = data.where((item) => 
        selectedIds.contains(item['id'] as int)
      ).toList();

      return {
        'success': true,
        'message': '${filteredData.length} étudiants exportés',
        'data': filteredData,
        'format': format,
        'count': filteredData.length,
      };
    } catch (e) {
      _setError(e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  // Validation methods
  Future<bool> validateStudentData(EnhancedStudentModel student) async {
    try {
      return await _repository.validateStudentData(student);
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<List<String>> getStudentValidationErrors(EnhancedStudentModel student) async {
    try {
      return await _repository.getStudentValidationErrors(student);
    } catch (e) {
      _setError(e.toString());
      return [e.toString()];
    }
  }

  // Utility methods
  void clearError() {
    _error = null;
    notifyListeners();
  }

  EnhancedStudentModel? getStudentById(int id) {
    try {
      return _students.firstWhere((student) => student.id == id);
    } catch (e) {
      return null;
    }
  }

  EnhancedStudentModel? getStudentByMatricule(String matricule) {
    try {
      return _students.firstWhere((student) => student.matricule == matricule);
    } catch (e) {
      return null;
    }
  }

  List<EnhancedStudentModel> getStudentsByStatus(StudentStatus status) {
    return _students.where((student) => student.status == status).toList();
  }

  List<EnhancedStudentModel> getStudentsByLevel(AcademicLevel level) {
    return _students.where((student) => student.currentLevel == level).toList();
  }

  List<EnhancedStudentModel> getActiveStudents() {
    return _students.where((student) => student.isActive).toList();
  }

  List<EnhancedStudentModel> getVerifiedStudents() {
    return _students.where((student) => student.isVerified).toList();
  }

  List<EnhancedStudentModel> getStudentsWithScholarships() {
    return _students.where((student) => student.hasScholarship).toList();
  }

  List<EnhancedStudentModel> getGraduatedStudents() {
    return _students.where((student) => student.isGraduated).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingStatistics(bool loading) {
    _isLoadingStatistics = loading;
    notifyListeners();
  }

  void _setCreating(bool creating) {
    _isCreating = creating;
    notifyListeners();
  }

  void _setUpdating(bool updating) {
    _isUpdating = updating;
    notifyListeners();
  }

  void _setDeleting(bool deleting) {
    _isDeleting = deleting;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void dispose() {
    _students.clear();
    _selectedStudents.clear();
    _activeFilters.clear();
    super.dispose();
  }
}

// Enums for view modes and sorting
enum StudentViewMode {
  list,
  grid,
  compact,
  cards,
}

enum StudentSortBy {
  name,
  matricule,
  level,
  status,
  gpa,
  createdAt,
}

enum StudentSortOrder {
  ascending,
  descending,
}
