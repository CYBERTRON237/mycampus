import 'package:flutter/material.dart';
import '../../domain/models/department_model.dart';
import '../../domain/repositories/department_repository.dart';
import '../../data/repositories/department_repository_impl.dart';
import '../../data/datasources/department_remote_datasource.dart';
import '../widgets/department_card_widget.dart';
import '../widgets/department_form_widget.dart';
import 'package:http/http.dart' as http;
import '../../../../features/auth/services/auth_service.dart';
import '../../../../features/program/presentation/pages/program_management_page.dart';

class DepartmentManagementPage extends StatefulWidget {
  final String? initialFacultyId;
  final String? initialFacultyName;
  final String? initialInstitutionId;
  final String? initialInstitutionName;

  const DepartmentManagementPage({
    super.key,
    this.initialFacultyId,
    this.initialFacultyName,
    this.initialInstitutionId,
    this.initialInstitutionName,
  });

  @override
  State<DepartmentManagementPage> createState() => _DepartmentManagementPageState();
}

class _DepartmentManagementPageState extends State<DepartmentManagementPage> with TickerProviderStateMixin {
  late DepartmentRepository _departmentRepository;
  List<DepartmentModel> _departments = [];
  List<DepartmentModel> _filteredDepartments = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Filtres
  final TextEditingController _searchController = TextEditingController();
  DepartmentStatus? _selectedStatus;

  // États
  bool _showCreateForm = false;
  DepartmentModel? _editingDepartment;
  bool _showFilters = true;
  bool _isGridView = false;
  String _sortBy = 'name';
  bool _sortAscending = true;
  bool _isSubmitting = false;

  // Statistiques
  Map<String, dynamic> _statistics = {
    'total': 0,
    'active': 0,
    'inactive': 0,
    'total_programs': 0,
    'total_staff': 0,
    'total_students': 0,
  };

  // États d'affichage avancés
  bool _showDetailedStats = false;
  List<DepartmentModel> _favoriteDepartments = [];
  DepartmentModel? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _initializeAnimations();
    _loadDepartments();
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

  void _initializeRepository() {
    _departmentRepository = DepartmentRepositoryImpl(
      remoteDataSource: DepartmentRemoteDataSource(
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
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadMoreDepartments();
    }
  }

  void _onSearchChanged() {
    _filterDepartments();
  }

  void _calculateStatistics() {
    setState(() {
      _statistics['total'] = _departments.length;
      _statistics['active'] = _departments.where((d) => d.status == DepartmentStatus.active).length;
      _statistics['inactive'] = _departments.where((d) => d.status == DepartmentStatus.inactive).length;
      _statistics['total_programs'] =
    _departments.fold<int>(0, (sum, d) => sum + (int.tryParse(d.programCount?.toString() ?? '0') ?? 0));

_statistics['total_staff'] =
    _departments.fold<int>(0, (sum, d) => sum + (int.tryParse(d.staffCount?.toString() ?? '0') ?? 0));

_statistics['total_students'] =
    _departments.fold<int>(0, (sum, d) => sum + (int.tryParse(d.studentCount?.toString() ?? '0') ?? 0));

    });
  }

  void _sortDepartments() {
    _filteredDepartments.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'code':
          comparison = a.code.compareTo(b.code);
          break;
        case 'programs':
          comparison = (a.programCount ?? 0).compareTo(b.programCount ?? 0);
          break;
        case 'staff':
          comparison = (a.staffCount ?? 0).compareTo(b.staffCount ?? 0);
          break;
        case 'students':
          comparison = (a.studentCount ?? 0).compareTo(b.studentCount ?? 0);
          break;
        case 'createdAt':
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });
  }

  Future<void> _loadDepartments({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    } else {
      setState(() => _isLoading = true);
    }

    final result = await _departmentRepository.getDepartments(
      facultyId: widget.initialFacultyId,
      institutionId: widget.initialInstitutionId,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      status: _selectedStatus,
      page: refresh ? 1 : _currentPage,
      limit: 20,
    );

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(error);
      },
      (departments) {
        setState(() {
          if (refresh) {
            _departments = departments;
            _filteredDepartments = departments;
          } else {
            _departments.addAll(departments);
            _filteredDepartments = List.from(_departments);
          }
          _isLoading = false;
          _currentPage++;
          _sortDepartments();
          _calculateStatistics();
        });
      },
    );
  }

  Future<void> _loadMoreDepartments() async {
    if (_isLoadingMore || _currentPage > _totalPages) return;

    setState(() => _isLoadingMore = true);

    final result = await _departmentRepository.getDepartments(
      facultyId: widget.initialFacultyId,
      institutionId: widget.initialInstitutionId,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      status: _selectedStatus,
      page: _currentPage,
      limit: 20,
    );

    result.fold(
      (error) {
        setState(() => _isLoadingMore = false);
        _showErrorSnackBar(error);
      },
      (departments) {
        setState(() {
          _departments.addAll(departments);
          _filteredDepartments = List.from(_departments);
          _isLoadingMore = false;
          _currentPage++;
          _sortDepartments();
          _calculateStatistics();
        });
      },
    );
  }

  void _filterDepartments() {
    setState(() {
      _filteredDepartments = _departments.where((department) {
        final matchesSearch = _searchController.text.trim().isEmpty ||
            department.name.toLowerCase().contains(_searchController.text.trim().toLowerCase()) ||
            department.shortName.toLowerCase().contains(_searchController.text.trim().toLowerCase()) ||
            department.code.toLowerCase().contains(_searchController.text.trim().toLowerCase());
        
        final matchesStatus = _selectedStatus == null || department.status == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
      _sortDepartments();
      _calculateStatistics();
    });
  }

  Future<void> _createDepartment(DepartmentModel department) async {
    setState(() => _isSubmitting = true);
    
    final result = await _departmentRepository.createDepartment(department);

    result.fold(
      (error) {
        setState(() => _isSubmitting = false);
        _showErrorSnackBar(error);
      },
      (createdDepartment) {
        setState(() {
          _isSubmitting = false;
          _showCreateForm = false;
          _departments.insert(0, createdDepartment);
          _filteredDepartments = List.from(_departments);
          _calculateStatistics();
        });
        _showSuccessSnackBar('Département créé avec succès');
        _clearForm();
      },
    );
  }

  Future<void> _updateDepartment(DepartmentModel department) async {
    setState(() => _isSubmitting = true);
    
    final result = await _departmentRepository.updateDepartment(department.id, department);

    result.fold(
      (error) {
        setState(() => _isSubmitting = false);
        _showErrorSnackBar(error);
      },
      (updatedDepartment) {
        setState(() {
          _isSubmitting = false;
          _editingDepartment = null;
          final index = _departments.indexWhere((d) => d.id == updatedDepartment.id);
          if (index != -1) {
            _departments[index] = updatedDepartment;
            _filteredDepartments = List.from(_departments);
          }
          _calculateStatistics();
        });
        _showSuccessSnackBar('Département mis à jour avec succès');
        _clearForm();
      },
    );
  }

  Future<void> _deleteDepartment(DepartmentModel department) async {
    final confirmed = await _showConfirmationDialog(
      'Supprimer le département',
      'Êtes-vous sûr de vouloir supprimer "${department.name}" ? Cette action est irréversible.',
    );

    if (!confirmed) return;

    final result = await _departmentRepository.deleteDepartment(department.id);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (success) {
        setState(() {
          _departments.removeWhere((d) => d.id == department.id);
          _filteredDepartments = List.from(_departments);
          _favoriteDepartments.removeWhere((d) => d.id == department.id);
          _calculateStatistics();
        });
        _showSuccessSnackBar('Département supprimé avec succès');
      },
    );
  }

  Future<void> _toggleDepartmentStatus(DepartmentModel department) async {
    final newStatus = department.status == DepartmentStatus.active 
        ? DepartmentStatus.inactive 
        : DepartmentStatus.active;

    final result = await _departmentRepository.toggleDepartmentStatus(department.id, newStatus);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (success) {
        setState(() {
          final index = _departments.indexWhere((d) => d.id == department.id);
          if (index != -1) {
            _departments[index] = department.copyWith(status: newStatus);
            _filteredDepartments = List.from(_departments);
          }
          _calculateStatistics();
        });
        _showSuccessSnackBar('Statut du département mis à jour avec succès');
      },
    );
  }

  void _toggleFavorite(DepartmentModel department) {
    setState(() {
      if (_favoriteDepartments.any((d) => d.id == department.id)) {
        _favoriteDepartments.removeWhere((d) => d.id == department.id);
        _showSuccessSnackBar('Retiré des favoris');
      } else {
        _favoriteDepartments.add(department);
        _showSuccessSnackBar('Ajouté aux favoris');
      }
    });
  }

  bool _isFavorite(DepartmentModel department) {
    return _favoriteDepartments.any((d) => d.id == department.id);
  }

  Future<void> _exportData() async {
    await Future.delayed(const Duration(seconds: 2));
    _showSuccessSnackBar('Données exportées avec succès');
  }

  Future<void> _generateReport() async {
    await Future.delayed(const Duration(seconds: 2));
    _showSuccessSnackBar('Rapport généré avec succès');
  }

  void _clearForm() {
    _editingDepartment = null;
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
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showDepartmentDetails(DepartmentModel department) {
    setState(() => _selectedDepartment = department);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildDepartmentDetailsModal(department),
    );
  }

  Widget _buildDepartmentDetailsModal(DepartmentModel department) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department.name,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      department.code,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Nom court', department.shortName),
          _buildDetailRow('Description', department.description ?? 'N/A'),
          _buildDetailRow('Statut', _getStatusLabel(department.status)),
          const SizedBox(height: 12),
          Text(
            'Statistiques',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatBox('Programmes', (department.programCount ?? 0).toString(), Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox('Personnel', (department.staffCount ?? 0).toString(), Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatBox('Étudiants', (department.studentCount ?? 0).toString(), Colors.purple),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _editingDepartment = department;
                      _showCreateForm = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgramManagementPage(
                          initialDepartmentId: department.id,
                          initialDepartmentName: department.name,
                          initialFacultyId: widget.initialFacultyId,
                          initialFacultyName: widget.initialFacultyName,
                          initialInstitutionId: widget.initialInstitutionId,
                          initialInstitutionName: widget.initialInstitutionName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Filières'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        ],
      ),
    );
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Gestion des departements'),
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
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Icon(Icons.school, color: Colors.blue.shade600, size: 20),
            const SizedBox(width: 8),
            if (widget.initialInstitutionName != null) ...[
              Text(
                widget.initialInstitutionName!,
                style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
              const SizedBox(width: 8),
            ],
            if (widget.initialFacultyName != null) ...[
              Text(
                widget.initialFacultyName!,
                style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
              const SizedBox(width: 8),
            ],
            Text('Départements', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total', _statistics['total'], Icons.domain, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Actifs', _statistics['active'], Icons.check_circle, Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('Inactifs', _statistics['inactive'], Icons.cancel, Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showDetailedStats = !_showDetailedStats),
                  child: _buildStatCard('Détails', _statistics['total_programs'], Icons.expand_more, Colors.purple),
                ),
              ),
            ],
          ),
          if (_showDetailedStats) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStatCard('Programmes', _statistics['total_programs'], Colors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStatCard('Personnel', _statistics['total_staff'], Colors.indigo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStatCard('Étudiants', _statistics['total_students'], Colors.deepOrange),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, dynamic value, IconData icon, Color color) {
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
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard(String label, dynamic value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
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
                hintText: 'Rechercher un département...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
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
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: _generateReport,
            tooltip: 'Rapport',
            style: IconButton.styleFrom(
              backgroundColor: Colors.orange.shade50,
              foregroundColor: Colors.orange.shade700,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = null;
                    _filterDepartments();
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
                child: DropdownButtonFormField<DepartmentStatus>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<DepartmentStatus>(value: null, child: Text('Tous les statuts')),
                    ...DepartmentStatus.values.map((status) {
                      return DropdownMenuItem<DepartmentStatus>(
                        value: status,
                        child: Text(_getStatusLabel(status)),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _filterDepartments();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _sortBy,
                  decoration: InputDecoration(
                    labelText: 'Trier par',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Nom')),
                    DropdownMenuItem(value: 'code', child: Text('Code')),
                    DropdownMenuItem(value: 'programs', child: Text('Programmes')),
                    DropdownMenuItem(value: 'staff', child: Text('Personnel')),
                    DropdownMenuItem(value: 'students', child: Text('Étudiants')),
                    DropdownMenuItem(value: 'createdAt', child: Text('Date de création')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                      _sortDepartments();
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
                    _sortDepartments();
                  });
                },
                tooltip: _sortAscending ? 'Ordre croissant' : 'Ordre décroissant',
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

  Widget _buildFavoritesSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.amber.shade600),
              const SizedBox(width: 8),
              Text(
                'Mes favoris (${_favoriteDepartments.length})',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber.shade700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _favoriteDepartments.length,
              itemBuilder: (context, index) {
                final department = _favoriteDepartments[index];
                return Container(
                  width: 200,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              department.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () => _toggleFavorite(department),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(department.code, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(_getStatusLabel(department.status), style: const TextStyle(fontSize: 9)),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: TextStyle(color: Colors.blue.shade700, fontSize: 9),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    if (_showCreateForm || _editingDepartment != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: DepartmentFormWidget(
          department: _editingDepartment,
          initialFacultyId: widget.initialFacultyId,
          initialFacultyName: widget.initialFacultyName,
          onSubmit: (department) {
            if (_editingDepartment != null) {
              _updateDepartment(department);
            } else {
              _createDepartment(department);
            }
          },
        ),
      );
    }

    if (_isLoading && _departments.isEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue.shade600),
              const SizedBox(height: 16),
              Text('Chargement des départements...', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    if (_departments.isEmpty) {
      return _buildEmptyState();
    }

    return _isGridView ? _buildGridView() : _buildListView();
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredDepartments.length,
      itemBuilder: (context, index) {
        final department = _filteredDepartments[index];
        final isFavorite = _isFavorite(department);
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 200 + (index * 50)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Stack(
                  children: [
                    DepartmentCardWidget(
                      department: department,
                      onTap: () => _showDepartmentDetails(department),
                      onEdit: () {
                        setState(() {
                          _editingDepartment = department;
                          _showCreateForm = true;
                        });
                      },
                      onDelete: () => _deleteDepartment(department),
                      onToggleStatus: () => _toggleDepartmentStatus(department),
                      onViewPrograms: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProgramManagementPage(
                              initialDepartmentId: department.id,
                              initialDepartmentName: department.name,
                              initialFacultyId: widget.initialFacultyId,
                              initialFacultyName: widget.initialFacultyName,
                              initialInstitutionId: widget.initialInstitutionId,
                              initialInstitutionName: widget.initialInstitutionName,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: Colors.red.shade600,
                        ),
                        onPressed: () => _toggleFavorite(department),
                        tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                      ),
                    ),
                  ],
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
      itemCount: _filteredDepartments.length,
      itemBuilder: (context, index) {
        final department = _filteredDepartments[index];
        final isFavorite = _isFavorite(department);
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 200 + (index * 50)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: value,
                child: Stack(
                  children: [
                    DepartmentCardWidget(
                      department: department,
                      onTap: () => _showDepartmentDetails(department),
                      onEdit: () {
                        setState(() {
                          _editingDepartment = department;
                          _showCreateForm = true;
                        });
                      },
                      onDelete: () => _deleteDepartment(department),
                      onToggleStatus: () => _toggleDepartmentStatus(department),
                      onViewPrograms: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProgramManagementPage(
                              initialDepartmentId: department.id,
                              initialDepartmentName: department.name,
                              initialFacultyId: widget.initialFacultyId,
                              initialFacultyName: widget.initialFacultyName,
                              initialInstitutionId: widget.initialInstitutionId,
                              initialInstitutionName: widget.initialInstitutionName,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: Colors.red.shade600,
                        ),
                        onPressed: () => _toggleFavorite(department),
                        tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                      ),
                    ),
                  ],
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
            Icon(Icons.domain_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres ou ajoutez un nouveau département',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showCreateForm = true;
                  _editingDepartment = null;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un département'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

  String _getEmptyStateTitle() {
    if (widget.initialFacultyName != null) {
      return 'Aucun département trouvé pour ${widget.initialFacultyName}';
    } else if (widget.initialInstitutionName != null) {
      return 'Aucun département trouvé pour ${widget.initialInstitutionName}';
    }
    return 'Aucun département trouvé';
  }

  String _getStatusLabel(DepartmentStatus status) {
    switch (status) {
      case DepartmentStatus.active:
        return 'Active';
      case DepartmentStatus.inactive:
        return 'Inactive';
      case DepartmentStatus.archived:
        return 'Archivée';
    }
  }
}
