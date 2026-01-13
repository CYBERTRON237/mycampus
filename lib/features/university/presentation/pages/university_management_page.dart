import 'package:flutter/material.dart';
import '../../domain/models/university_model.dart';
import '../../domain/repositories/university_repository.dart';
import '../../data/repositories/university_repository_impl.dart';
import '../../data/datasources/university_remote_datasource.dart';
import '../widgets/university_card_widget.dart';
import '../widgets/university_form_widget.dart';
import 'package:http/http.dart' as http;
import '../../../../features/auth/services/auth_service.dart';
import '../../../../features/faculty/presentation/pages/faculty_management_page.dart';
import 'dart:math' as math;

class UniversityManagementPage extends StatefulWidget {
  const UniversityManagementPage({super.key});

  @override
  State<UniversityManagementPage> createState() =>
      _UniversityManagementPageState();
}

class _UniversityManagementPageState extends State<UniversityManagementPage>
    with TickerProviderStateMixin {
  late UniversityRepository _universityRepository;
  List<UniversityModel> _universities = [];
  List<UniversityModel> _filteredUniversities = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Filtres
  final TextEditingController _searchController = TextEditingController();
  UniversityType? _selectedType;
  UniversityStatus? _selectedStatus;
  String? _selectedRegion;
  List<String> _regions = [];

  // États
  bool _showCreateForm = false;
  UniversityModel? _editingUniversity;
  bool _isSubmitting = false;
  bool _showFilters = true;
  bool _isGridView = false;
  String _sortBy = 'name';
  bool _sortAscending = true;

  // Statistiques
  Map<String, int> _statistics = {
    'total': 0,
    'active': 0,
    'inactive': 0,
    'verified': 0,
    'public': 0,
    'private': 0,
  };

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _initializeAnimations();
    _loadUniversities();
    _loadRegions();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchChanged);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeRepository() {
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
    _slideController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreUniversities();
    }
  }

  void _onSearchChanged() {
    _filterUniversities();
  }

  Future<void> _loadRegions() async {
    final result = await _universityRepository.getRegions();
    result.fold(
      (error) => debugPrint('Error loading regions: $error'),
      (regions) => setState(() => _regions = regions),
    );
  }

  void _calculateStatistics() {
    setState(() {
      _statistics['total'] = _universities.length;
      _statistics['active'] = _universities
          .where((u) => u.status == UniversityStatus.active)
          .length;
      _statistics['inactive'] = _universities
          .where((u) => u.status == UniversityStatus.inactive)
          .length;
      _statistics['verified'] = _universities.where((u) => u.isVerified).length;
      _statistics['public'] =
          _universities.where((u) => u.type == UniversityType.public).length;
      _statistics['private'] =
          _universities.where((u) => u.type == UniversityType.private).length;
    });
  }

  Future<void> _loadUniversities({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    } else {
      setState(() => _isLoading = true);
    }

    final result = await _universityRepository.getUniversities(
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      type: _selectedType,
      status: _selectedStatus,
      region: _selectedRegion,
      page: refresh ? 1 : _currentPage,
      limit: 20,
    );

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(error);
      },
      (universities) {
        setState(() {
          if (refresh) {
            _universities = universities;
            _filteredUniversities = universities;
          } else {
            _universities.addAll(universities);
            _filteredUniversities = List.from(_universities);
          }
          _isLoading = false;
          _currentPage++;
          _sortUniversities();
          _calculateStatistics();
        });
      },
    );
  }

  Future<void> _loadMoreUniversities() async {
    if (_isLoadingMore || _currentPage > _totalPages) return;

    setState(() => _isLoadingMore = true);

    final result = await _universityRepository.getUniversities(
      search: _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim(),
      type: _selectedType,
      status: _selectedStatus,
      region: _selectedRegion,
      page: _currentPage,
      limit: 20,
    );

    result.fold(
      (error) {
        setState(() => _isLoadingMore = false);
        _showErrorSnackBar(error);
      },
      (universities) {
        setState(() {
          _universities.addAll(universities);
          _filteredUniversities = List.from(_universities);
          _isLoadingMore = false;
          _currentPage++;
          _sortUniversities();
          _calculateStatistics();
        });
      },
    );
  }

  void _sortUniversities() {
    _filteredUniversities.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case 'region':
          comparison = a.region.compareTo(b.region);
          break;
        case 'type':
          comparison = a.type.toString().compareTo(b.type.toString());
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  void _filterUniversities() {
    setState(() {
      _filteredUniversities = _universities.where((university) {
        final matchesSearch = _searchController.text.trim().isEmpty ||
            university.name
                .toLowerCase()
                .contains(_searchController.text.trim().toLowerCase()) ||
            university.shortName
                .toLowerCase()
                .contains(_searchController.text.trim().toLowerCase());

        final matchesType =
            _selectedType == null || university.type == _selectedType;
        final matchesStatus =
            _selectedStatus == null || university.status == _selectedStatus;
        final matchesRegion =
            _selectedRegion == null || university.region == _selectedRegion;

        return matchesSearch && matchesType && matchesStatus && matchesRegion;
      }).toList();
      _sortUniversities();
      _calculateStatistics();
    });
  }

  Future<void> _createUniversity(UniversityModel university) async {
    setState(() => _isSubmitting = true);

    final result = await _universityRepository.createUniversity(university);

    result.fold(
      (error) {
        setState(() => _isSubmitting = false);
        _showErrorSnackBar(error);
      },
      (createdUniversity) {
        setState(() {
          _isSubmitting = false;
          _showCreateForm = false;
          _universities.insert(0, createdUniversity);
          _filteredUniversities = List.from(_universities);
          _calculateStatistics();
        });
        _showSuccessSnackBar('Université créée avec succès');
        _clearForm();
      },
    );
  }

  Future<void> _updateUniversity(UniversityModel university) async {
    setState(() => _isSubmitting = true);

    final result =
        await _universityRepository.updateUniversity(university.id, university);

    result.fold(
      (error) {
        setState(() => _isSubmitting = false);
        _showErrorSnackBar(error);
      },
      (updatedUniversity) {
        setState(() {
          _isSubmitting = false;
          _editingUniversity = null;
          final index = _universities.indexWhere((u) => u.id == university.id);
          if (index != -1) {
            _universities[index] = updatedUniversity;
            _filteredUniversities = List.from(_universities);
          }
          _calculateStatistics();
        });
        _showSuccessSnackBar('Université mise à jour avec succès');
        _clearForm();
      },
    );
  }

  Future<void> _deleteUniversity(String id) async {
    final confirmed = await _showConfirmDialog(
      'Supprimer l\'université',
      'Êtes-vous sûr de vouloir supprimer cette université ? Cette action est irréversible.',
    );

    if (!confirmed) return;

    final result = await _universityRepository.deleteUniversity(id);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (_) {
        setState(() {
          _universities.removeWhere((u) => u.id == id);
          _filteredUniversities = List.from(_universities);
          _calculateStatistics();
        });
        _showSuccessSnackBar('Université supprimée avec succès');
      },
    );
  }

  Future<void> _toggleUniversityStatus(String id) async {
    final university = _universities.firstWhere((u) => u.id == id);
    UniversityStatus newStatus;

    switch (university.status) {
      case UniversityStatus.active:
        newStatus = UniversityStatus.inactive;
        break;
      case UniversityStatus.inactive:
        newStatus = UniversityStatus.active;
        break;
      case UniversityStatus.suspended:
        newStatus = UniversityStatus.active;
        break;
      case UniversityStatus.pending:
        newStatus = UniversityStatus.active;
        break;
    }

    final result =
        await _universityRepository.toggleUniversityStatus(id, newStatus);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (_) {
        setState(() {
          final index = _universities.indexWhere((u) => u.id == id);
          if (index != -1) {
            _universities[index] =
                _universities[index].copyWith(status: newStatus);
            _filteredUniversities = List.from(_universities);
          }
          _calculateStatistics();
        });
        _showSuccessSnackBar('Statut mis à jour avec succès');
      },
    );
  }

  Future<void> _verifyUniversity(String id) async {
    final result = await _universityRepository.verifyUniversity(id);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (_) {
        setState(() {
          final index = _universities.indexWhere((u) => u.id == id);
          if (index != -1) {
            _universities[index] =
                _universities[index].copyWith(isVerified: true);
            _filteredUniversities = List.from(_universities);
          }
          _calculateStatistics();
        });
        _showSuccessSnackBar('Université vérifiée avec succès');
      },
    );
  }

  Future<void> _exportData() async {
    // Simulation d'export
    await Future.delayed(const Duration(seconds: 2));
    _showSuccessSnackBar('Données exportées avec succès');
  }

  void _clearForm() {
    _editingUniversity = null;
    _showCreateForm = false;
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

  Future<bool> _showConfirmDialog(String title, String message) async {
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
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
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
      title: const Text('Gestion des Universités'),
      elevation: 0,
      backgroundColor: Colors.blue.shade600,
      foregroundColor: Colors.white,
    ),
    body: FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticsSection(),
              _buildToolbar(),
              if (_showFilters) _buildFiltersSection(),
              _buildContentSection(),
              if (_isLoadingMore) _buildLoadingMoreIndicator(),
            ],
          ),
        ),
      ),
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
                  'Total', _statistics['total']!, Icons.school, Colors.blue)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Actives', _statistics['active']!,
                  Icons.check_circle, Colors.green)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Vérifiées', _statistics['verified']!,
                  Icons.verified, Colors.purple)),
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
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
                hintText: 'Rechercher une université...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                borderRadius: BorderRadius.circular(12),
              ),
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
                  color: Colors.blue.shade700,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedType = null;
                    _selectedStatus = null;
                    _selectedRegion = null;
                    _filterUniversities();
                  });
                },
                child: const Text('Réinitialiser'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<UniversityType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tous')),
                    ...UniversityType.values.map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(_getTypeLabel(type)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                      _filterUniversities();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<UniversityStatus>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Tous')),
                    ...UniversityStatus.values.map(
                      (status) => DropdownMenuItem(
                        value: status,
                        child: Text(_getStatusLabel(status)),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                      _filterUniversities();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: InputDecoration(
                    labelText: 'Région',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Toutes')),
                    ..._regions.map(
                      (region) => DropdownMenuItem(
                        value: region,
                        child: Text(region),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRegion = value;
                      _filterUniversities();
                    });
                  },
                ),
              ),
            ],
          ),
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
                    DropdownMenuItem(
                        value: 'createdAt', child: Text('Date de création')),
                    DropdownMenuItem(value: 'region', child: Text('Région')),
                    DropdownMenuItem(value: 'type', child: Text('Type')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                      _sortUniversities();
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
                    _sortUniversities();
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
    if (_showCreateForm || _editingUniversity != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: UniversityFormWidget(
          university: _editingUniversity,
          onSubmit: _editingUniversity != null
              ? _updateUniversity
              : _createUniversity,
          isLoading: _isSubmitting,
        ),
      );
    }

    if (_isLoading && _universities.isEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue.shade600),
              const SizedBox(height: 16),
              Text('Chargement des universités...',
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    if (_filteredUniversities.isEmpty) {
      return _buildEmptyState();
    }

    return _isGridView ? _buildGridView() : _buildListView();
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredUniversities.length,
      itemBuilder: (context, index) {
        final university = _filteredUniversities[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 200 + (index * 50)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: UniversityCardWidget(
                  university: university,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FacultyManagementPage(
                          initialInstitutionId: university.id,
                          initialInstitutionName: university.name,
                        ),
                      ),
                    );
                  },
                  onEdit: () => setState(() => _editingUniversity = university),
                  onDelete: () => _deleteUniversity(university.id),
                  onToggleStatus: () => _toggleUniversityStatus(university.id),
                  onVerify: () => _verifyUniversity(university.id),
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
      itemCount: _filteredUniversities.length,
      itemBuilder: (context, index) {
        final university = _filteredUniversities[index];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 200 + (index * 50)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: value,
                child: UniversityCardWidget(
                  university: university,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FacultyManagementPage(
                          initialInstitutionId: university.id,
                          initialInstitutionName: university.name,
                        ),
                      ),
                    );
                  },
                  onEdit: () => setState(() => _editingUniversity = university),
                  onDelete: () => _deleteUniversity(university.id),
                  onToggleStatus: () => _toggleUniversityStatus(university.id),
                  onVerify: () => _verifyUniversity(university.id),
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
            Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucune université trouvée',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres ou ajoutez une nouvelle université',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() => _showCreateForm = true),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une université'),
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

  String _getTypeLabel(UniversityType type) {
    switch (type) {
      case UniversityType.public:
        return 'Publique';
      case UniversityType.private:
        return 'Privée';
      case UniversityType.confessional:
        return 'Confessionnelle';
    }
  }

  String _getStatusLabel(UniversityStatus status) {
    switch (status) {
      case UniversityStatus.active:
        return 'Active';
      case UniversityStatus.inactive:
        return 'Inactive';
      case UniversityStatus.suspended:
        return 'Suspendue';
      case UniversityStatus.pending:
        return 'En attente';
    }
  }
}
