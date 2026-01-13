import 'package:flutter/material.dart';
import '../../domain/models/program_model.dart';
import '../../domain/repositories/program_repository.dart';
import '../../data/repositories/program_repository_impl.dart';
import '../../data/datasources/program_remote_datasource.dart';
import '../widgets/program_card_widget.dart';
import '../widgets/program_form_widget.dart';
import 'package:http/http.dart' as http;
import '../../../../features/auth/services/auth_service.dart';
import '../../../../features/course/presentation/pages/course_management_page.dart';

class ProgramManagementPage extends StatefulWidget {
  final String? initialDepartmentId;
  final String? initialDepartmentName;
  final String? initialFacultyId;
  final String? initialFacultyName;
  final String? initialInstitutionId;
  final String? initialInstitutionName;

  const ProgramManagementPage({
    super.key,
    this.initialDepartmentId,
    this.initialDepartmentName,
    this.initialFacultyId,
    this.initialFacultyName,
    this.initialInstitutionId,
    this.initialInstitutionName,
  });

  @override
  State<ProgramManagementPage> createState() => _ProgramManagementPageState();
}

class _ProgramManagementPageState extends State<ProgramManagementPage> with TickerProviderStateMixin {
  late ProgramRepository _programRepository;
  List<ProgramModel> _programs = [];
  List<ProgramModel> _filteredPrograms = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _totalPages = 1;
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Filtres
  final TextEditingController _searchController = TextEditingController();
  DegreeLevel? _selectedDegreeLevel;
  ProgramStatus? _selectedStatus;

  // États
  bool _showCreateForm = false;
  ProgramModel? _editingProgram;
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
    'license': 0,
    'master': 0,
    'doctorate': 0,
    'total_students': 0,
  };

  // États d'affichage avancés
  bool _showDetailedStats = false;
  List<ProgramModel> _favoritePrograms = [];

  @override
  void initState() {
    super.initState();
    _initializeRepository();
    _initializeAnimations();
    _loadPrograms();
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
    _programRepository = ProgramRepositoryImpl(
      remoteDataSource: ProgramRemoteDataSource(
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
      _loadMorePrograms();
    }
  }

  void _onSearchChanged() {
    _filterPrograms();
  }

  void _calculateStatistics() {
    setState(() {
      _statistics['total'] = _programs.length;
      _statistics['active'] = _programs.where((p) => p.status == ProgramStatus.active).length;
      _statistics['inactive'] = _programs.where((p) => p.status == ProgramStatus.inactive).length;
     _statistics['license'] = _programs.where((p) => p.degreeLevel == DegreeLevel.licence1).length;
_statistics['master'] = _programs.where((p) => p.degreeLevel == DegreeLevel.master1).length;
_statistics['doctorate'] = _programs.where((p) => p.degreeLevel == DegreeLevel.doctorat).length;
_statistics['total_students'] =
    _programs.fold<int>(
      0, 
      (sum, p) => sum + (int.tryParse(p.studentCount?.toString() ?? '0') ?? 0)
    );

    });
  }

  void _sortPrograms() {
    _filteredPrograms.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'code':
          comparison = a.code.compareTo(b.code);
          break;
        case 'degree':
          comparison = a.degreeLevel.toString().compareTo(b.degreeLevel.toString());
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

  Future<void> _loadPrograms({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    } else {
      setState(() => _isLoading = true);
    }

    final result = await _programRepository.getPrograms(
      departmentId: widget.initialDepartmentId,
      facultyId: widget.initialFacultyId,
      institutionId: widget.initialInstitutionId,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      degreeLevel: _selectedDegreeLevel,
      status: _selectedStatus,
      page: refresh ? 1 : _currentPage,
      limit: 20,
    );

    result.fold(
      (error) {
        setState(() => _isLoading = false);
        _showErrorSnackBar(error);
      },
      (programs) {
        setState(() {
          if (refresh) {
            _programs = programs;
            _filteredPrograms = programs;
          } else {
            _programs.addAll(programs);
            _filteredPrograms = List.from(_programs);
          }
          _isLoading = false;
          _currentPage++;
          _sortPrograms();
          _calculateStatistics();
        });
      },
    );
  }

  Future<void> _loadMorePrograms() async {
    if (_isLoadingMore || _currentPage > _totalPages) return;

    setState(() => _isLoadingMore = true);

    final result = await _programRepository.getPrograms(
      departmentId: widget.initialDepartmentId,
      facultyId: widget.initialFacultyId,
      institutionId: widget.initialInstitutionId,
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      degreeLevel: _selectedDegreeLevel,
      status: _selectedStatus,
      page: _currentPage,
      limit: 20,
    );

    result.fold(
      (error) {
        setState(() => _isLoadingMore = false);
        _showErrorSnackBar(error);
      },
      (programs) {
        setState(() {
          _programs.addAll(programs);
          _filteredPrograms = List.from(_programs);
          _isLoadingMore = false;
          _currentPage++;
          _sortPrograms();
          _calculateStatistics();
        });
      },
    );
  }

  void _filterPrograms() {
    setState(() {
      _filteredPrograms = _programs.where((program) {
        final matchesSearch = _searchController.text.trim().isEmpty ||
            program.name.toLowerCase().contains(_searchController.text.trim().toLowerCase()) ||
            program.shortName.toLowerCase().contains(_searchController.text.trim().toLowerCase()) ||
            program.code.toLowerCase().contains(_searchController.text.trim().toLowerCase());
        
        final matchesDegreeLevel = _selectedDegreeLevel == null || program.degreeLevel == _selectedDegreeLevel;
        final matchesStatus = _selectedStatus == null || program.status == _selectedStatus;

        return matchesSearch && matchesDegreeLevel && matchesStatus;
      }).toList();
      _sortPrograms();
      _calculateStatistics();
    });
  }

  Future<void> _createProgram(ProgramModel program) async {
    setState(() => _isSubmitting = true);
    
    final result = await _programRepository.createProgram(program);

    result.fold(
      (error) {
        setState(() => _isSubmitting = false);
        _showErrorSnackBar(error);
      },
      (createdProgram) {
        setState(() {
          _isSubmitting = false;
          _showCreateForm = false;
          _programs.insert(0, createdProgram);
          _filteredPrograms = List.from(_programs);
          _calculateStatistics();
        });
        _showSuccessSnackBar('Filière créée avec succès');
        _clearForm();
      },
    );
  }

  Future<void> _updateProgram(ProgramModel program) async {
    setState(() => _isSubmitting = true);
    
    final result = await _programRepository.updateProgram(program.id, program);

    result.fold(
      (error) {
        setState(() => _isSubmitting = false);
        _showErrorSnackBar(error);
      },
      (updatedProgram) {
        setState(() {
          _isSubmitting = false;
          _editingProgram = null;
          final index = _programs.indexWhere((p) => p.id == updatedProgram.id);
          if (index != -1) {
            _programs[index] = updatedProgram;
            _filteredPrograms = List.from(_programs);
          }
          _calculateStatistics();
        });
        _showSuccessSnackBar('Filière mise à jour avec succès');
        _clearForm();
      },
    );
  }

  Future<void> _deleteProgram(ProgramModel program) async {
    final confirmed = await _showConfirmationDialog(
      'Supprimer la filière',
      'Êtes-vous sûr de vouloir supprimer "${program.name}" ? Cette action est irréversible.',
    );

    if (!confirmed) return;

    final result = await _programRepository.deleteProgram(program.id);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (success) {
        setState(() {
          _programs.removeWhere((p) => p.id == program.id);
          _filteredPrograms = List.from(_programs);
          _favoritePrograms.removeWhere((p) => p.id == program.id);
          _calculateStatistics();
        });
        _showSuccessSnackBar('Filière supprimée avec succès');
      },
    );
  }

  Future<void> _toggleProgramStatus(ProgramModel program) async {
    final newStatus = program.status == ProgramStatus.active 
        ? ProgramStatus.inactive 
        : ProgramStatus.active;

    final result = await _programRepository.toggleProgramStatus(program.id, newStatus);

    result.fold(
      (error) => _showErrorSnackBar(error),
      (success) {
        setState(() {
          final index = _programs.indexWhere((p) => p.id == program.id);
          if (index != -1) {
            _programs[index] = program.copyWith(status: newStatus);
            _filteredPrograms = List.from(_programs);
          }
          _calculateStatistics();
        });
        _showSuccessSnackBar('Statut de la filière mis à jour avec succès');
      },
    );
  }

  void _toggleFavorite(ProgramModel program) {
    setState(() {
      if (_favoritePrograms.any((p) => p.id == program.id)) {
        _favoritePrograms.removeWhere((p) => p.id == program.id);
        _showSuccessSnackBar('Retiré des favoris');
      } else {
        _favoritePrograms.add(program);
        _showSuccessSnackBar('Ajouté aux favoris');
      }
    });
  }

  bool _isFavorite(ProgramModel program) {
    return _favoritePrograms.any((p) => p.id == program.id);
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
    _editingProgram = null;
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

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            if (widget.initialDepartmentName != null) _buildBreadcrumb(),
            _buildStatisticsSection(),
            _buildToolbar(),
            if (_showFilters) _buildFiltersSection(),
            if (_favoritePrograms.isNotEmpty) _buildFavoritesSection(),
            _buildContentSection(),
            if (_isLoadingMore) _buildLoadingMoreIndicator(),
          ],
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
            if (widget.initialDepartmentName != null) ...[
              Text(
                widget.initialDepartmentName!,
                style: TextStyle(fontSize: 14, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
              const SizedBox(width: 8),
            ],
            Text('Filières', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
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
              Expanded(child: _buildStatCard('Total', _statistics['total'], Icons.school, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Actives', _statistics['active'], Icons.check_circle, Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Inactives', _statistics['inactive'], Icons.cancel, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showDetailedStats = !_showDetailedStats),
                  child: _buildStatCard('Étudiants', _statistics['total_students'], Icons.people, Colors.purple),
                ),
              ),
            ],
          ),
          if (_showDetailedStats) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStatCard('Licence', _statistics['license'], Colors.teal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStatCard('Master', _statistics['master'], Colors.indigo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStatCard('Doctorat', _statistics['doctorate'], Colors.deepOrange),
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
                hintText: 'Rechercher une filière...',
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
                    _selectedDegreeLevel = null;
                    _selectedStatus = null;
                    _filterPrograms();
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
                child: DropdownButtonFormField<DegreeLevel>(
                  value: _selectedDegreeLevel,
                  decoration: InputDecoration(
                    labelText: 'Niveau de diplôme',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<DegreeLevel>(value: null, child: Text('Tous les niveaux')),
                    ...DegreeLevel.values.map((level) {
                      return DropdownMenuItem<DegreeLevel>(
                        value: level,
                        child: Text(level.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDegreeLevel = value;
                    });
                    _filterPrograms();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<ProgramStatus>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem<ProgramStatus>(value: null, child: Text('Tous les statuts')),
                    ...ProgramStatus.values.map((status) {
                      return DropdownMenuItem<ProgramStatus>(
                        value: status,
                        child: Text(status.displayName),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    _filterPrograms();
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Nom')),
                    DropdownMenuItem(value: 'code', child: Text('Code')),
                    DropdownMenuItem(value: 'degree', child: Text('Niveau')),
                    DropdownMenuItem(value: 'students', child: Text('Nombre d\'étudiants')),
                    DropdownMenuItem(value: 'createdAt', child: Text('Date de création')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sortBy = value!;
                      _sortPrograms();
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
                    _sortPrograms();
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
                'Mes favoris (${_favoritePrograms.length})',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber.shade700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _favoritePrograms.length,
              itemBuilder: (context, index) {
                final program = _favoritePrograms[index];
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
                              program.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16),
                            onPressed: () => _toggleFavorite(program),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(program.code, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(program.degreeLevel.displayName, style: const TextStyle(fontSize: 9)),
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
    if (_showCreateForm || _editingProgram != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        child: ProgramFormWidget(
          program: _editingProgram,
          initialDepartmentId: widget.initialDepartmentId,
          initialDepartmentName: widget.initialDepartmentName,
          onSubmit: (program) {
            if (_editingProgram != null) {
              _updateProgram(program);
            } else {
              _createProgram(program);
            }
          },
        ),
      );
    }

    if (_isLoading && _programs.isEmpty) {
      return SizedBox(
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.blue.shade600),
              const SizedBox(height: 16),
              Text('Chargement des filières...', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    if (_programs.isEmpty) {
      return _buildEmptyState();
    }

    return _isGridView ? _buildGridView() : _buildListView();
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPrograms.length,
      itemBuilder: (context, index) {
        final program = _filteredPrograms[index];
        final isFavorite = _isFavorite(program);
        
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
                    ProgramCardWidget(
                      program: program,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseManagementPage(
                              initialProgramId: program.id,
                              initialProgramName: program.name,
                              initialDepartmentId: widget.initialDepartmentId,
                              initialDepartmentName: widget.initialDepartmentName,
                              initialFacultyId: widget.initialFacultyId,
                              initialFacultyName: widget.initialFacultyName,
                              initialInstitutionId: widget.initialInstitutionId,
                              initialInstitutionName: widget.initialInstitutionName,
                            ),
                          ),
                        );
                      },
                      onEdit: () {
                        setState(() {
                          _editingProgram = program;
                          _showCreateForm = true;
                        });
                      },
                      onDelete: () => _deleteProgram(program),
                      onToggleStatus: () => _toggleProgramStatus(program),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: Colors.red.shade600,
                        ),
                        onPressed: () => _toggleFavorite(program),
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
      itemCount: _filteredPrograms.length,
      itemBuilder: (context, index) {
        final program = _filteredPrograms[index];
        final isFavorite = _isFavorite(program);
        
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
                    ProgramCardWidget(
                      program: program,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseManagementPage(
                              initialProgramId: program.id,
                              initialProgramName: program.name,
                              initialDepartmentId: widget.initialDepartmentId,
                              initialDepartmentName: widget.initialDepartmentName,
                              initialFacultyId: widget.initialFacultyId,
                              initialFacultyName: widget.initialFacultyName,
                              initialInstitutionId: widget.initialInstitutionId,
                              initialInstitutionName: widget.initialInstitutionName,
                            ),
                          ),
                        );
                      },
                      onEdit: () {
                        setState(() {
                          _editingProgram = program;
                          _showCreateForm = true;
                        });
                      },
                      onDelete: () => _deleteProgram(program),
                      onToggleStatus: () => _toggleProgramStatus(program),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          color: Colors.red.shade600,
                        ),
                        onPressed: () => _toggleFavorite(program),
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
            Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateTitle(),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateMessage(),
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showCreateForm = true;
                  _editingProgram = null;
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une filière'),
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
    if (widget.initialDepartmentName != null) {
      return 'Aucune filière trouvée pour ${widget.initialDepartmentName}';
    } else if (widget.initialFacultyName != null) {
      return 'Aucune filière trouvée pour ${widget.initialFacultyName}';
    } else if (widget.initialInstitutionName != null) {
      return 'Aucune filière trouvée pour ${widget.initialInstitutionName}';
    }
    return 'Aucune filière trouvée';
  }

  String _getEmptyStateMessage() {
    return 'Essayez de modifier vos filtres ou d\'ajouter une nouvelle filière';
  }
}
