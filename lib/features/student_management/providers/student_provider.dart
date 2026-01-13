import 'package:flutter/material.dart';
import 'dart:convert';
import '../data/models/student_model_simple.dart';
import '../data/models/simple_student_model.dart';
import '../data/models/student_model.dart';
import '../data/models/university_model.dart';
import '../data/repositories/student_repository.dart';
import '../data/datasources/student_remote_datasource.dart';
import 'package:http/http.dart' as http;

class StudentProvider extends ChangeNotifier {
  final StudentRepository repository;
  
  List<SimpleStudentModel> _students = [];
  List<UniversityModel> _universities = [];
  UniversityModel? _selectedUniversity;
  StudentStats? _stats;
  StudentFilters _filters = StudentFilters();
  bool _isLoading = false;
  bool _isLoadingUniversities = false;
  bool _isLoadingStats = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalCount = 0;

  StudentProvider({required this.repository}) {
    _loadUniversities();
  }

  // Getters
  List<SimpleStudentModel> get students => _students;
  List<UniversityModel> get universities {
    if (_universities.isEmpty) return [];
    return _universities.whereType<UniversityModel>().toList();
  }
  UniversityModel? get selectedUniversity => _selectedUniversity;
  StudentStats? get stats => _stats;
  StudentFilters get filters => _filters;
  bool get isLoading => _isLoading;
  bool get isLoadingUniversities => _isLoadingUniversities;
  bool get isLoadingStats => _isLoadingStats;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalCount => _totalCount;
  
  bool get hasError => _error != null;
  bool get isEmpty => _students.isEmpty && !_isLoading;
  bool get isNotEmpty => _students.isNotEmpty;
  bool get hasUniversities => universities.isNotEmpty;

  // Charger les universités
  Future<void> _loadUniversities() async {
    _isLoadingUniversities = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1/mycampus/api/universities'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('Universities API response: $jsonData'); // Debug
        if (jsonData['success'] == true && jsonData['data'] is List) {
          _universities = (jsonData['data'] as List)
              .map((uni) => UniversityModel.fromJson(uni))
              .toList();
          print('Loaded ${_universities.length} universities'); // Debug
        } else {
          _error = jsonData['error'] ?? 'Erreur lors du chargement des universités';
        }
      } else {
        _error = 'Erreur serveur: ${response.statusCode}';
        _universities = []; // Reset to empty list on error
      }
    } catch (e) {
      _error = 'Erreur: $e';
      _universities = []; // Reset to empty list on error
    } finally {
      _isLoadingUniversities = false;
      notifyListeners();
    }
  }

  // Sélectionner une université et charger ses étudiants
  void selectUniversity(UniversityModel? university) {
    _selectedUniversity = university;
    _students.clear(); // Vider la liste des étudiants
    notifyListeners();
    
    if (university != null) {
      _filters = _filters.copyWith(institutionId: university.id);
      _loadStudents();
      _loadStats();
    }
  }

  // Recharger les universités (méthode publique)
  Future<void> refreshUniversities() async {
    await _loadUniversities();
  }

  // Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Charger les étudiants
  Future<void> _loadStudents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await repository.getStudents(
        institutionId: _filters.institutionId,
        facultyId: _filters.facultyId,
        departmentId: _filters.departmentId,
        programId: _filters.programId,
        level: _filters.level,
        status: _filters.status,
        search: _filters.search,
        page: _filters.page,
        limit: _filters.limit,
      );

      if (response.success) {
        _students = response.data;
        _currentPage = response.pagination?.currentPage ?? 1;
        _totalPages = response.pagination?.totalPages ?? 1;
        _totalCount = response.pagination?.total ?? 0;
      } else {
        _error = response.error ?? 'Erreur lors du chargement des étudiants';
      }
    } catch (e) {
      _error = 'Erreur: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les statistiques
  Future<void> _loadStats() async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      _stats = await repository.getStudentStats(
        institutionId: _filters.institutionId,
        facultyId: _filters.facultyId,
        departmentId: _filters.departmentId,
        programId: _filters.programId,
      );
    } catch (e) {
      // Les statistiques ne sont pas critiques, on ne lève pas d'erreur
      print('Erreur lors du chargement des statistiques: $e');
    } finally {
      _isLoadingStats = false;
      notifyListeners();
    }
  }

  // Rafraîchir la liste
  Future<void> refreshStudents() async {
    await _loadStudents();
    await _loadStats();
  }

  // Mettre à jour les filtres
  void updateFilters(StudentFilters newFilters) {
    _filters = newFilters.copyWith(page: 1); // Reset à la première page
    _loadStudents();
    _loadStats(); // Recharger les stats avec les nouveaux filtres
  }

  // Rechercher des étudiants
  void searchStudents(String query) {
    final newFilters = _filters.copyWith(
      search: query.isEmpty ? null : query,
      page: 1,
    );
    updateFilters(newFilters);
  }

  // Filtrer par institution
  void filterByInstitution(int? institutionId) {
    final newFilters = _filters.copyWith(
      institutionId: institutionId,
      page: 1,
    );
    updateFilters(newFilters);
  }

  // Filtrer par faculté
  void filterByFaculty(int? facultyId) {
    final newFilters = _filters.copyWith(
      facultyId: facultyId,
      page: 1,
    );
    updateFilters(newFilters);
  }

  // Filtrer par département
  void filterByDepartment(int? departmentId) {
    final newFilters = _filters.copyWith(
      departmentId: departmentId,
      page: 1,
    );
    updateFilters(newFilters);
  }

  // Filtrer par programme
  void filterByProgram(int? programId) {
    final newFilters = _filters.copyWith(
      programId: programId,
      page: 1,
    );
    updateFilters(newFilters);
  }

  // Filtrer par niveau
  void filterByLevel(String? level) {
    final newFilters = _filters.copyWith(
      level: level?.isEmpty == true ? null : level,
      page: 1,
    );
    updateFilters(newFilters);
  }

  // Filtrer par statut
  void filterByStatus(String? status) {
    final newFilters = _filters.copyWith(
      status: status?.isEmpty == true ? null : status,
      page: 1,
    );
    updateFilters(newFilters);
  }

  // Charger la page suivante
  void loadNextPage() {
    if (_currentPage < _totalPages && !_isLoading) {
      final newFilters = _filters.copyWith(page: _currentPage + 1);
      updateFilters(newFilters);
    }
  }

  // Charger la page précédente
  void loadPreviousPage() {
    if (_currentPage > 1 && !_isLoading) {
      final newFilters = _filters.copyWith(page: _currentPage - 1);
      updateFilters(newFilters);
    }
  }

  // Aller à une page spécifique
  void goToPage(int page) {
    if (page >= 1 && page <= _totalPages && page != _currentPage) {
      final newFilters = _filters.copyWith(page: page);
      updateFilters(newFilters);
    }
  }

  // Créer un étudiant
  Future<Map<String, dynamic>> createStudent(Map<String, dynamic> studentData) async {
    try {
      final result = await repository.createStudent(studentData);
      
      if (result['success']) {
        await refreshStudents(); // Rafraîchir la liste
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Mettre à jour un étudiant
  Future<Map<String, dynamic>> updateStudent(int id, Map<String, dynamic> studentData) async {
    try {
      final result = await repository.updateStudent(id, studentData);
      
      if (result['success']) {
        await refreshStudents(); // Rafraîchir la liste
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Supprimer un étudiant
  Future<Map<String, dynamic>> deleteStudent(int id) async {
    try {
      final result = await repository.deleteStudent(id);
      
      if (result['success']) {
        await refreshStudents(); // Rafraîchir la liste
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  // Récupérer un étudiant par ID
  Future<StudentModelSimple?> getStudentById(int id) async {
    try {
      return await repository.getStudentById(id);
    } catch (e) {
      _error = 'Erreur: $e';
      notifyListeners();
      return null;
    }
  }

  // Exporter les étudiants
  Future<List<Map<String, dynamic>>> exportStudents() async {
    try {
      return await repository.exportStudents(
        institutionId: _filters.institutionId,
        facultyId: _filters.facultyId,
        departmentId: _filters.departmentId,
        programId: _filters.programId,
        level: _filters.level,
        status: _filters.status,
      );
    } catch (e) {
      _error = 'Erreur lors de l\'export: $e';
      notifyListeners();
      return [];
    }
  }

  // Réinitialiser les filtres
  void resetFilters() {
    _filters = StudentFilters();
    _loadStudents();
    _loadStats();
  }

  // Obtenir les étudiants par niveau
  List<SimpleStudentModel> getStudentsByLevel(String level) {
    return _students.where((student) => student.currentLevel == level).toList();
  }

  // Obtenir les étudiants par statut
  List<SimpleStudentModel> getStudentsByStatus(String status) {
    return _students.where((student) => student.studentStatus == status).toList();
  }

  // Obtenir les étudiants actifs
  List<SimpleStudentModel> get activeStudents {
    return _students.where((student) => student.studentStatus == 'enrolled').toList();
  }

  // Obtenir les étudiants diplômés
  List<SimpleStudentModel> get graduatedStudents {
    return _students.where((student) => student.studentStatus == 'graduated').toList();
  }

  // Obtenir les étudiants avec bourse
  List<SimpleStudentModel> get scholarshipStudents {
    return _students.where((student) => student.honors != null && student.honors!.contains('scholarship')).toList();
  }

  // Obtenir les excellents étudiants (GPA >= 3.5)
  List<SimpleStudentModel> get excellentStudents {
    return _students.where((student) {
      final gpaValue = double.tryParse(student.gpa ?? '0') ?? 0.0;
      return gpaValue >= 3.5;
    }).toList();
  }

  // Statistiques locales
  double get averageGpa {
    if (_students.isEmpty) return 0.0;
    
    double totalGpa = 0.0;
    int count = 0;
    
    for (final student in _students) {
      final gpaValue = double.tryParse(student.gpa ?? '0');
      if (gpaValue != null && gpaValue > 0) {
        totalGpa += gpaValue;
        count++;
      }
    }
    
    return count > 0 ? totalGpa / count : 0.0;
  }

  Map<String, int> get studentsByLevelCount {
    final Map<String, int> counts = {};
    
    for (final student in _students) {
      final level = student.displayLevel;
      counts[level] = (counts[level] ?? 0) + 1;
    }
    
    return counts;
  }

  Map<String, int> get studentsByStatusCount {
    final Map<String, int> counts = {};
    
    for (final student in _students) {
      final status = student.displayStatus;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    
    return counts;
  }
}

// Factory pour créer le provider avec la configuration par défaut
class StudentProviderFactory {
  static StudentProvider create() {
    final repository = StudentRemoteDataSource(
      baseUrl: 'http://127.0.0.1/mycampus/api',
      client: http.Client(),
    );
    
    print('StudentProviderFactory: baseUrl = http://127.0.0.1/mycampus/api');
    return StudentProvider(repository: repository);
  }
}
