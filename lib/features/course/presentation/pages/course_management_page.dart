import 'package:flutter/material.dart';
import '../../domain/models/course_model.dart';
import '../../domain/repositories/course_repository.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../data/datasources/course_remote_datasource.dart';
import '../widgets/course_card_widget.dart';
import '../widgets/course_form_widget.dart';
import 'package:http/http.dart' as http;
import '../../../../features/auth/services/auth_service.dart';
import '../../../../features/auth/presentation/widgets/app_bar.dart';

class CourseManagementPage extends StatefulWidget {
  final String? initialProgramId;
  final String? initialProgramName;
  final String? initialDepartmentId;
  final String? initialDepartmentName;
  final String? initialFacultyId;
  final String? initialFacultyName;
  final String? initialInstitutionId;
  final String? initialInstitutionName;

  const CourseManagementPage({
    super.key,
    this.initialProgramId,
    this.initialProgramName,
    this.initialDepartmentId,
    this.initialDepartmentName,
    this.initialFacultyId,
    this.initialFacultyName,
    this.initialInstitutionId,
    this.initialInstitutionName,
  });

  @override
  State<CourseManagementPage> createState() => _CourseManagementPageState();
}

class _CourseManagementPageState extends State<CourseManagementPage> {
  late CourseRepository _courseRepository;
  List<CourseModel> _courses = [];
  List<CourseModel> _filteredCourses = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();

  // Filtres
  final TextEditingController _searchController = TextEditingController();
  CourseLevel? _selectedLevel;
  CourseSemester? _selectedSemester;
  CourseStatus? _selectedStatus;

  // États
  bool _showCreateForm = false;
  CourseModel? _editingCourse;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _loadCourses();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeRepository() {
    _courseRepository = CourseRepositoryImpl(
      remoteDataSource: CourseRemoteDataSource(
        client: http.Client(),
        authService: AuthService(),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreCourses();
    }
  }

  void _onSearchChanged() {
    _filterCourses();
  }

  Future<void> _loadCourses({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    } else {
      setState(() => _isLoading = true);
    }

    final result = await _courseRepository.getCourses(
      programId: widget.initialProgramId,
      departmentId: widget.initialDepartmentId,
      facultyId: widget.initialFacultyId,
      institutionId: widget.initialInstitutionId,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      level: _selectedLevel,
      semester: _selectedSemester,
      status: _selectedStatus,
      page: refresh ? 1 : _currentPage,
      limit: 20,
    );

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(error);
      },
      (courses) {
        setState(() {
          if (refresh) {
            _courses = courses;
            _filteredCourses = courses;
          } else {
            _courses.addAll(courses);
            _filteredCourses = List.from(_courses);
          }
          _isLoading = false;
          _currentPage++;
        });
      },
    );
  }

  Future<void> _loadMoreCourses() async {
    if (_isLoadingMore || _currentPage > _totalPages) return;

    setState(() => _isLoadingMore = true);

    final result = await _courseRepository.getCourses(
      programId: widget.initialProgramId,
      departmentId: widget.initialDepartmentId,
      facultyId: widget.initialFacultyId,
      institutionId: widget.initialInstitutionId,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      level: _selectedLevel,
      semester: _selectedSemester,
      status: _selectedStatus,
      page: _currentPage,
      limit: 20,
    );

    result.fold(
      (error) {
        setState(() => _isLoadingMore = false);
        _showErrorSnackBar(error);
      },
      (courses) {
        setState(() {
          _courses.addAll(courses);
          _filteredCourses = List.from(_courses);
          _isLoadingMore = false;
          _currentPage++;
        });
      },
    );
  }

  void _filterCourses() {
    setState(() {
      _filteredCourses = _courses.where((course) {
        final matchesSearch = _searchController.text.trim().isEmpty ||
            course.name
                .toLowerCase()
                .contains(_searchController.text.trim().toLowerCase()) ||
            course.shortName
                .toLowerCase()
                .contains(_searchController.text.trim().toLowerCase()) ||
            course.code
                .toLowerCase()
                .contains(_searchController.text.trim().toLowerCase());

        final matchesLevel =
            _selectedLevel == null || course.level == _selectedLevel;
        final matchesSemester =
            _selectedSemester == null || course.semester == _selectedSemester;
        final matchesStatus =
            _selectedStatus == null || course.status == _selectedStatus;

        return matchesSearch &&
            matchesLevel &&
            matchesSemester &&
            matchesStatus;
      }).toList();
    });
  }

  Future<void> _createCourse(CourseModel course) async {
    final result = await _courseRepository.createCourse(course);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (createdCourse) {
        setState(() {
          _showCreateForm = false;
          _courses.insert(0, createdCourse);
          _filteredCourses = List.from(_courses);
        });
        _showSuccessSnackBar('Cours créé avec succès');
        _clearForm();
      },
    );
  }

  Future<void> _updateCourse(CourseModel course) async {
    final result = await _courseRepository.updateCourse(course.id, course);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (updatedCourse) {
        setState(() {
          _editingCourse = null;
          final index = _courses.indexWhere((c) => c.id == updatedCourse.id);
          if (index != -1) {
            _courses[index] = updatedCourse;
            _filteredCourses = List.from(_courses);
          }
        });
        _showSuccessSnackBar('Cours mis à jour avec succès');
        _clearForm();
      },
    );
  }

  Future<void> _deleteCourse(CourseModel course) async {
    final confirmed = await _showConfirmationDialog(
      'Supprimer le cours',
      'Êtes-vous sûr de vouloir supprimer "${course.name}" ? Cette action est irréversible.',
    );

    if (!confirmed) return;

    final result = await _courseRepository.deleteCourse(course.id);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (success) {
        setState(() {
          _courses.removeWhere((c) => c.id == course.id);
          _filteredCourses = List.from(_courses);
        });
        _showSuccessSnackBar('Cours supprimé avec succès');
      },
    );
  }

  Future<void> _toggleCourseStatus(CourseModel course) async {
    final newStatus = course.status == CourseStatus.active
        ? CourseStatus.inactive
        : CourseStatus.active;

    final result =
        await _courseRepository.toggleCourseStatus(course.id, newStatus);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (success) {
        setState(() {
          final index = _courses.indexWhere((c) => c.id == course.id);
          if (index != -1) {
            _courses[index] = course.copyWith(status: newStatus);
            _filteredCourses = List.from(_courses);
          }
        });
        _showSuccessSnackBar('Statut du cours mis à jour avec succès');
      },
    );
  }

  void _clearForm() {
    _editingCourse = null;
    _showCreateForm = false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Cours'),
        elevation: 0,
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          _buildMainContent(),
          if (_showCreateForm) _buildFormOverlay(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Filtres
          _buildFiltersSection(),
          const SizedBox(height: 16),

          // Liste des cours
          Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  200, // Approximate height for filters
            ),
            child: _isLoading && _courses.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _courses.isEmpty
                    ? _buildEmptyState()
                    : SizedBox(
                        height: MediaQuery.of(context).size.height -
                            200, // Give explicit height
                        child: _buildCoursesList(),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un cours...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),

          // Filtres par niveau, semestre et statut
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<CourseLevel>(
                  value: _selectedLevel,
                  decoration: InputDecoration(
                    labelText: 'Niveau',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<CourseLevel>(
                      value: null,
                      child: Text('Tous les niveaux'),
                    ),
                    ...CourseLevel.values.map((level) {
                      return DropdownMenuItem<CourseLevel>(
                        value: level,
                        child: Text(level.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedLevel = value;
                    });
                    _filterCourses();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<CourseSemester>(
                  value: _selectedSemester,
                  decoration: InputDecoration(
                    labelText: 'Semestre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<CourseSemester>(
                      value: null,
                      child: Text('Tous les semestres'),
                    ),
                    ...CourseSemester.values.map((semester) {
                      return DropdownMenuItem<CourseSemester>(
                        value: semester,
                        child: Text(semester.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSemester = value;
                    });
                    _filterCourses();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<CourseStatus>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<CourseStatus>(
                      value: null,
                      child: Text('Tous les statuts'),
                    ),
                    ...CourseStatus.values.map((status) {
                      return DropdownMenuItem<CourseStatus>(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _filterCourses();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesList() {
    return RefreshIndicator(
      onRefresh: () => _loadCourses(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: _filteredCourses.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _filteredCourses.length && _isLoadingMore) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final course = _filteredCourses[index];

          return CourseCardWidget(
            course: course,
            onTap: () {
              // Navigation vers les détails du cours
            },
            onEdit: () {
              setState(() {
                _editingCourse = course;
                _showCreateForm = true;
              });
            },
            onDelete: () => _deleteCourse(course),
            onToggleStatus: () => _toggleCourseStatus(course),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyStateTitle(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _getEmptyStateMessage(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _showCreateForm = true;
                _editingCourse = null;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un cours'),
          ),
        ],
      ),
    );
  }

  String _getEmptyStateTitle() {
    if (widget.initialProgramName != null) {
      return 'Aucun cours trouvé pour ${widget.initialProgramName}';
    } else if (widget.initialDepartmentName != null) {
      return 'Aucun cours trouvé pour ${widget.initialDepartmentName}';
    } else if (widget.initialFacultyName != null) {
      return 'Aucun cours trouvé pour ${widget.initialFacultyName}';
    } else if (widget.initialInstitutionName != null) {
      return 'Aucun cours trouvé pour ${widget.initialInstitutionName}';
    }
    return 'Aucun cours trouvé';
  }

  String _getEmptyStateMessage() {
    if (widget.initialProgramName != null ||
        widget.initialDepartmentName != null ||
        widget.initialFacultyName != null ||
        widget.initialInstitutionName != null) {
      return 'Essayez de modifier vos filtres ou d\'ajouter un nouveau cours';
    }
    return 'Essayez de modifier vos filtres ou d\'ajouter un nouveau cours';
  }

  // Afficher le formulaire de création/modification
  Widget _buildFormOverlay() {
    if (!_showCreateForm) return const SizedBox.shrink();

    return CourseFormWidget(
      course: _editingCourse,
      initialProgramId: widget.initialProgramId,
      initialProgramName: widget.initialProgramName,
      onSubmit: (course) {
        if (_editingCourse != null) {
          _updateCourse(course);
        } else {
          _createCourse(course);
        }
      },
    );
  }
}
