import 'package:flutter/material.dart';
import '../../domain/models/faculty_model.dart';
import '../../domain/repositories/faculty_repository.dart';
import '../../data/repositories/faculty_repository_impl.dart';
import '../../data/datasources/faculty_remote_datasource.dart';
import '../widgets/faculty_card_widget.dart';
import '../widgets/faculty_form_widget.dart';
import 'package:http/http.dart' as http;
import '../../../../features/auth/services/auth_service.dart';
import '../../../../features/university/domain/repositories/university_repository.dart';
import '../../../../features/university/data/repositories/university_repository_impl.dart';
import '../../../../features/university/data/datasources/university_remote_datasource.dart';
import '../../../../features/department/presentation/pages/department_management_page.dart';

class FacultyManagementPage extends StatefulWidget {
  final String? initialInstitutionId;
  final String? initialInstitutionName;

  const FacultyManagementPage({
    super.key,
    this.initialInstitutionId,
    this.initialInstitutionName,
  });

  @override
  State<FacultyManagementPage> createState() => _FacultyManagementPageState();
}

class _FacultyManagementPageState extends State<FacultyManagementPage>
    with TickerProviderStateMixin {
  late FacultyRepository _facultyRepository;
  late UniversityRepository _universityRepository;
  List<FacultyModel> _faculties = [];
  List<FacultyModel> _filteredFaculties = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Filtres
  final TextEditingController _searchController = TextEditingController();
  String? _selectedInstitutionId;
  FacultyStatus? _selectedStatus;
  List<Map<String, dynamic>> _institutions = [];

  // États
  bool _showCreateForm = false;
  FacultyModel? _editingFaculty;
  bool _showFilters = true;
  bool _isGridView = false;
  String _sortBy = 'name';
  bool _sortAscending = true;
  bool _isSubmitting = false;

  // Statistiques
  Map<String, int> _statistics = {
    'total': 0,
    'active': 0,
    'inactive': 0,
    'suspended': 0,
  };

  @override
  void initState() {
    super.initState();
    _initializeRepositories();
    _initializeAnimations();

    if (widget.initialInstitutionId != null) {
      _selectedInstitutionId = widget.initialInstitutionId;
    }

    _loadFaculties();
    _loadInstitutions();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  void _initializeRepositories() {
    _facultyRepository = FacultyRepositoryImpl(
      remoteDataSource: FacultyRemoteDataSource(
        client: http.Client(),
        authService: AuthService(),
      ),
    );

    _universityRepository = UniversityRepositoryImpl(
      remoteDataSource: UniversityRemoteDataSource(
        client: http.Client(),
        authService: AuthService(),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreFaculties();
    }
  }

  void _onSearchChanged() {
    _filterFaculties();
  }

  void _calculateStatistics() {
    setState(() {
      _statistics['total'] = _faculties.length;
      _statistics['active'] =
          _faculties.where((f) => f.status == FacultyStatus.active).length;
      _statistics['inactive'] =
          _faculties.where((f) => f.status == FacultyStatus.inactive).length;
      _statistics['suspended'] =
          _faculties.where((f) => f.status == FacultyStatus.suspended).length;
    });
  }

  Future<void> _loadInstitutions() async {
    try {
      final result = await _universityRepository.getUniversities();
      result.fold(
        (error) => debugPrint('Error loading institutions: $error'),
        (institutions) {
          setState(() {
            _institutions = institutions
                .map((inst) => {
                      'id': inst.id,
                      'name': inst.name,
                      'short_name': inst.shortName,
                    })
                .toList();

            if (widget.initialInstitutionName != null &&
                _selectedInstitutionId == null) {
              final matchingInstitution = _institutions.firstWhere(
                (inst) => inst['name'] == widget.initialInstitutionName,
                orElse: () => {},
              );
              if (matchingInstitution.isNotEmpty) {
                _selectedInstitutionId = matchingInstitution['id'];
              }
            }
          });
        },
      );
    } catch (e) {
      debugPrint('Exception loading institutions: $e');
    }
  }

  void _sortFaculties() {
    _filteredFaculties.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'code':
          comparison = a.code.compareTo(b.code);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  Future<void> _loadFaculties({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    } else {
      setState(() => _isLoading = true);
    }

    final result = await _facultyRepository.getFaculties(
      institutionId: _selectedInstitutionId,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      status: _selectedStatus,
      page: refresh ? 1 : _currentPage,
      limit: 20,
    );

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(error);
      },
      (faculties) {
        setState(() {
          if (refresh) {
            _faculties = faculties;
            _filteredFaculties = faculties;
          } else {
            _faculties.addAll(faculties);
            _filteredFaculties = List.from(_faculties);
          }
          _isLoading = false;
          _currentPage++;
          _sortFaculties();
          _calculateStatistics();
        });
      },
    );
  }

  Future<void> _loadMoreFaculties() async {
    if (_isLoadingMore || _currentPage > _totalPages) return;

    setState(() => _isLoadingMore = true);

    final result = await _facultyRepository.getFaculties(
      institutionId: _selectedInstitutionId,
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      status: _selectedStatus,
      page: _currentPage,
      limit: 20,
    );

    result.fold(
      (error) {
        setState(() => _isLoadingMore = false);
        _showErrorSnackBar(error);
      },
      (faculties) {
        setState(() {
          _faculties.addAll(faculties);
          _filteredFaculties = List.from(_faculties);
          _isLoadingMore = false;
          _currentPage++;
          _sortFaculties();
          _calculateStatistics();
        });
      },
    );
  }

  void _filterFaculties() {
    setState(() {
      _filteredFaculties = _faculties.where((faculty) {
        final matchesSearch = _searchController.text.trim().isEmpty ||
            faculty.name
                .toLowerCase()
                .contains(_searchController.text.trim().toLowerCase()) ||
            faculty.shortName
                .toLowerCase()
                .contains(_searchController.text.trim().toLowerCase()) ||
            faculty.code
                .toLowerCase()
                .contains(_searchController.text.trim().toLowerCase());

        final matchesInstitution = _selectedInstitutionId == null ||
            faculty.institutionId == _selectedInstitutionId;
        final matchesStatus =
            _selectedStatus == null || faculty.status == _selectedStatus;

        return matchesSearch && matchesInstitution && matchesStatus;
      }).toList();
      _sortFaculties();
      _calculateStatistics();
    });
  }

  Future<void> _createFaculty(FacultyModel faculty) async {
    setState(() => _isSubmitting = true);

    final result = await _facultyRepository.createFaculty(faculty);

    result.fold(
      (error) {
        setState(() => _isSubmitting = false);
        _showErrorSnackBar(error);
      },
      (createdFaculty) {
        setState(() {
          _isSubmitting = false;
          _showCreateForm = false;
          _faculties.insert(0, createdFaculty);
          _filteredFaculties = List.from(_faculties);
          _calculateStatistics();
        });
        _showSuccessSnackBar('Faculté créée avec succès');
        _clearForm();
      },
    );
  }

  Future<void> _updateFaculty(FacultyModel faculty) async {
    setState(() => _isSubmitting = true);

    final result = await _facultyRepository.updateFaculty(faculty.id, faculty);

    result.fold(
      (error) {
        setState(() => _isSubmitting = false);
        _showErrorSnackBar(error);
      },
      (updatedFaculty) {
        setState(() {
          _isSubmitting = false;
          _editingFaculty = null;
          final index = _faculties.indexWhere((f) => f.id == updatedFaculty.id);
          if (index != -1) {
            _faculties[index] = updatedFaculty;
            _filteredFaculties = List.from(_faculties);
          }
          _calculateStatistics();
        });
        _showSuccessSnackBar('Faculté mise à jour avec succès');
        _clearForm();
      },
    );
  }

  Future<void> _deleteFaculty(FacultyModel faculty) async {
    final confirmed = await _showConfirmationDialog(
      'Supprimer la faculté',
      'Êtes-vous sûr de vouloir supprimer "${faculty.name}" ? Cette action est irréversible.',
    );

    if (!confirmed) return;

    final result = await _facultyRepository.deleteFaculty(faculty.id);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (success) {
        setState(() {
          _faculties.removeWhere((f) => f.id == faculty.id);
          _filteredFaculties = List.from(_faculties);
          _calculateStatistics();
        });
        _showSuccessSnackBar('Faculté supprimée avec succès');
      },
    );
  }

  Future<void> _toggleFacultyStatus(FacultyModel faculty) async {
    final newStatus = faculty.status == FacultyStatus.active
        ? FacultyStatus.inactive
        : FacultyStatus.active;

    final result =
        await _facultyRepository.toggleFacultyStatus(faculty.id, newStatus);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (success) {
        setState(() {
          final index = _faculties.indexWhere((f) => f.id == faculty.id);
          if (index != -1) {
            _faculties[index] = faculty.copyWith(status: newStatus);
            _filteredFaculties = List.from(_faculties);
          }
          _calculateStatistics();
        });
        _showSuccessSnackBar('Statut de la faculté mis à jour avec succès');
      },
    );
  }

  Future<void> _exportData() async {
    await Future.delayed(const Duration(seconds: 2));
    _showSuccessSnackBar('Données exportées avec succès');
  }

  void _clearForm() {
    _editingFaculty = null;
    _showCreateForm = false;
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange.shade600),
            const SizedBox(width: 12),
            Text(title),
          ],
        ),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
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
      title: const Text('Gestion des Facultés'),
      elevation: 0,
      backgroundColor: Colors.blue.shade600,
      foregroundColor: Colors.white,
    ),
    body: FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            if (widget.initialInstitutionName != null) _buildBreadcrumb(),
            _buildStatisticsSection(),
            _buildToolbar(),
            if (_showFilters) _buildFiltersSection(),
            _buildContentSection(),
            if (_isLoadingMore) _buildLoadingMoreIndicator(),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildBreadcrumb() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.school, color: Colors.blue.shade600, size: 20),
          const SizedBox(width: 8),
          Text(
            widget.initialInstitutionName!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Text('Facultés', style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
              child: _buildStatCard(
                  'Total', _statistics['total']!, Icons.business, Colors.blue)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Actives', _statistics['active']!,
                  Icons.check_circle, Colors.green)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Inactives', _statistics['inactive']!,
                  Icons.cancel, Colors.orange)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Suspendues', _statistics['suspended']!,
                  Icons.block, Colors.red)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une faculté...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(
                _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () => setState(() => _showFilters = !_showFilters),
            tooltip: 'Filtres',
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade700,
            ),
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: 'Vue',
            style: IconButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade700,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportData,
            tooltip: 'Exporter',
            style: IconButton.styleFrom(
              backgroundColor: Colors.green.shade50,
              foregroundColor: Colors.green.shade700,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => setState(() => _showCreateForm = true),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Filtres avancés',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    if (widget.initialInstitutionId == null) {
                      _selectedInstitutionId = null;
                    }
                    _selectedStatus = null;
                    _filterFaculties();
                  });
                },
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.initialInstitutionId == null) ...[
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedInstitutionId,
                    decoration: InputDecoration(
                      labelText: 'Institution',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                          value: null, child: Text('Toutes les institutions')),
                      ..._institutions.map((institution) {
                        return DropdownMenuItem<String>(
                          value: institution['id'],
                          child: Text(institution['short_name']),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedInstitutionId = value;
                      });
                      _filterFaculties();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<FacultyStatus>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Statut',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    items: [
                      const DropdownMenuItem<FacultyStatus>(
                          value: null, child: Text('Tous les statuts')),
                      ...FacultyStatus.values.map((status) {
                        return DropdownMenuItem<FacultyStatus>(
                          value: status,
                          child: Text(_getStatusDisplayName(status)),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                      _filterFaculties();
                    },
                  ),
                ),
              ],
            ),
          ] else ...[
            DropdownButtonFormField<FacultyStatus>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Statut',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: [
                const DropdownMenuItem<FacultyStatus>(
                    value: null, child: Text('Tous les statuts')),
                ...FacultyStatus.values.map((status) {
                  return DropdownMenuItem<FacultyStatus>(
                    value: status,
                    child: Text(_getStatusDisplayName(status)),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value;
                });
                _filterFaculties();
              },
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    labelText: 'Trier par',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Nom')),
                    DropdownMenuItem(value: 'code', child: Text('Code')),
                    DropdownMenuItem(
                        value: 'createdAt', child: Text('Date de création')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                      _sortFaculties();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: Icon(
                  _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.blue.shade700,
                ),
                onPressed: () {
                  setState(() {
                    _sortAscending = !_sortAscending;
                    _sortFaculties();
                  });
                },
                tooltip:
                    _sortAscending ? 'Ordre croissant' : 'Ordre décroissant',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    if (_showCreateForm || _editingFaculty != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: FacultyFormWidget(
          faculty: _editingFaculty,
          onSubmit: (faculty) {
            if (_editingFaculty != null) {
              _updateFaculty(faculty);
            } else {
              _createFaculty(faculty);
            }
          },
        ),
      );
    }

    if (_isLoading && _faculties.isEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue.shade600),
              const SizedBox(height: 16),
              Text('Chargement des facultés...',
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    if (_faculties.isEmpty) {
      return _buildEmptyState();
    }

    return _isGridView ? _buildGridView() : _buildListView();
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredFaculties.length,
      itemBuilder: (context, index) {
        final faculty = _filteredFaculties[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 200 + (index * 50)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: FacultyCardWidget(
                  faculty: faculty,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepartmentManagementPage(
                          initialFacultyId: faculty.id,
                          initialFacultyName: faculty.name,
                          initialInstitutionId: widget.initialInstitutionId,
                          initialInstitutionName: widget.initialInstitutionName,
                        ),
                      ),
                    );
                  },
                  onEdit: () {
                    setState(() {
                      _editingFaculty = faculty;
                      _showCreateForm = true;
                    });
                  },
                  onDelete: () => _deleteFaculty(faculty),
                  onToggleStatus: () => _toggleFacultyStatus(faculty),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredFaculties.length,
      itemBuilder: (context, index) {
        final faculty = _filteredFaculties[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 200 + (index * 50)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: value,
                child: FacultyCardWidget(
                  faculty: faculty,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DepartmentManagementPage(
                          initialFacultyId: faculty.id,
                          initialFacultyName: faculty.name,
                          initialInstitutionId: widget.initialInstitutionId,
                          initialInstitutionName: widget.initialInstitutionName,
                        ),
                      ),
                    );
                  },
                  onEdit: () {
                    setState(() {
                      _editingFaculty = faculty;
                      _showCreateForm = true;
                    });
                  },
                  onDelete: () => _deleteFaculty(faculty),
                  onToggleStatus: () => _toggleFacultyStatus(faculty),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              widget.initialInstitutionName != null
                  ? 'Aucune faculté trouvée pour ${widget.initialInstitutionName}'
                  : 'Aucune faculté trouvée',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres ou ajoutez une nouvelle faculté',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showCreateForm = true;
                  _editingFaculty = null;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une faculté'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: CircularProgressIndicator(color: Colors.blue.shade600),
      ),
    );
  }

  String _getStatusDisplayName(FacultyStatus status) {
    switch (status) {
      case FacultyStatus.active:
        return 'Active';
      case FacultyStatus.inactive:
        return 'Inactive';
      case FacultyStatus.suspended:
        return 'Suspendue';
    }
  }
}
