import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycampus/features/preinscription/services/faculty_service.dart';
import 'package:mycampus/features/preinscription/models/university_model.dart';
import 'package:mycampus/features/faculty/domain/models/faculty_model.dart';
import 'package:mycampus/features/preinscription/presentation/widgets/faculty_card_widget.dart';
import 'package:mycampus/constants/app_colors.dart';
import 'package:mycampus/core/providers/theme_provider.dart';
import 'package:mycampus/features/preinscription/presentation/pages/preinscription_complete_form_page.dart';
import 'package:mycampus/features/preinscription/presentation/pages/filiere_selection_page.dart';

class FacultySelectionPage extends StatefulWidget {
  final UniversityModel university;

  const FacultySelectionPage({
    Key? key,
    required this.university,
  }) : super(key: key);

  @override
  State<FacultySelectionPage> createState() => _FacultySelectionPageState();
}

class _FacultySelectionPageState extends State<FacultySelectionPage> {
  late FacultyService _facultyService;
  List<FacultyModel> _faculties = [];
  List<FacultyModel> _filteredFaculties = [];
  bool _isLoading = true;
  String? _error;

  // Contrôleurs pour la recherche
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Filtres
  String _selectedStatus = 'active';

  // Options de filtres
  final List<String> _statuses = ['all', 'active', 'inactive', 'suspended'];

  @override
  void initState() {
    super.initState();
    _facultyService = FacultyService();
    _loadFaculties();

    // Écouter les changements de recherche
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _facultyService.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterFaculties();
  }

  Future<void> _loadFaculties() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final faculties = await _facultyService.getFacultiesByUniversity(
        universityId: widget.university.id,
        status: _selectedStatus == 'all' ? null : FacultyStatus.fromString(_selectedStatus),
        limit: 100,
      );

      if (mounted) {
        setState(() {
          _faculties = faculties;
          _filteredFaculties = faculties;
          _isLoading = false;
        });
        _filterFaculties();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _filterFaculties() {
    setState(() {
      _filteredFaculties = _faculties.where((faculty) {
        // Filtre par nom de recherche
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            faculty.name.toLowerCase().contains(searchQuery) ||
            faculty.shortName.toLowerCase().contains(searchQuery) ||
            faculty.code.toLowerCase().contains(searchQuery) ||
            (faculty.deanName?.toLowerCase().contains(searchQuery) ?? false) ||
            (faculty.description?.toLowerCase().contains(searchQuery) ?? false);

        // Filtre par statut
        final matchesStatus = _selectedStatus == 'all' || faculty.status.value == _selectedStatus;

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedStatus = 'active';
    });
    _filterFaculties();
  }

  Future<void> _refreshFaculties() async {
    await _loadFaculties();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkTheme = themeProvider.isDarkTheme;

    return Scaffold(
      backgroundColor: isDarkTheme ? const Color(0xFF0A0E21) : Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isDarkTheme 
                    ? LinearGradient(colors: [Colors.cyan.shade400, Colors.blue.shade600])
                    : AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/icons/mycampus.png',
                height: 30,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Facultés',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    widget.university.shortName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDarkTheme
                  ? [const Color(0xFF1D1E33), const Color(0xFF2D2E4F)]
                  : [AppColors.primary, AppColors.primaryDark],
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkTheme
                ? [const Color(0xFF0A0E21), const Color(0xFF1D1E33)]
                : [Colors.grey.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              // Bannière d'information sur l'université
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkTheme
                        ? [const Color(0xFF1D1E33), const Color(0xFF2D2E4F)]
                        : [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkTheme 
                          ? Colors.black.withOpacity(0.3)
                          : AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.school,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.university.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Choisissez votre faculté',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.university.city != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white.withOpacity(0.7),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.university.city!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Section de recherche et filtres
              _buildSearchAndFilterSection(isDarkTheme),

              const SizedBox(height: 20),

              // Cartes des facultés
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (_isLoading)
                      _buildLoadingState(isDarkTheme)
                    else if (_error != null)
                      _buildErrorState(_error!, isDarkTheme)
                    else if (_filteredFaculties.isEmpty)
                      _buildEmptyState(isDarkTheme)
                    else
                      ..._filteredFaculties.map((faculty) => FacultyCardWidget(
                        faculty: faculty,
                        onTap: () async {
                          final selectedFiliere = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FiliereSelectionPage(
                                faculty: faculty.name,
                                facultyId: faculty.id,
                              ),
                            ),
                          );
                          
                          if (selectedFiliere != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CompletePreinscriptionFormPage(
                                  faculty: faculty.name,
                                  facultyId: faculty.id,
                                  selectedFiliere: selectedFiliere,
                                ),
                              ),
                            );
                          }
                        },
                      )).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterSection(bool isDarkTheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkTheme 
                ? Colors.black.withOpacity(0.3)
                : Colors.grey.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Champ de recherche principal
          Container(
            decoration: BoxDecoration(
              color: isDarkTheme ? const Color(0xFF2D2E4F) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkTheme 
                    ? Colors.white.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher une faculté...',
                hintStyle: TextStyle(
                  color: isDarkTheme 
                      ? Colors.white.withOpacity(0.5)
                      : Colors.grey.shade500,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkTheme 
                      ? Colors.white.withOpacity(0.7)
                      : Colors.grey.shade600,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: isDarkTheme 
                              ? Colors.white.withOpacity(0.7)
                              : Colors.grey.shade600,
                        ),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              style: TextStyle(
                color: isDarkTheme ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Filtres
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Statut',
                  _selectedStatus,
                  _statuses,
                  (value) {
                    setState(() {
                      _selectedStatus = value!;
                      _filterFaculties();
                    });
                  },
                  isDarkTheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Réinitialiser'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkTheme 
                        ? const Color(0xFF2D2E4F)
                        : Colors.grey.shade100,
                    foregroundColor: isDarkTheme 
                        ? Colors.white
                        : Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isDarkTheme 
                            ? Colors.white.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.3),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),

          // Résultats
          if (_filteredFaculties.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkTheme 
                    ? Colors.cyan.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: isDarkTheme ? Colors.cyan : Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_filteredFaculties.length} faculté${_filteredFaculties.length > 1 ? 's' : ''} trouvée${_filteredFaculties.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: isDarkTheme ? Colors.cyan : Colors.blue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> items,
    Function(String?) onChanged,
    bool isDarkTheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF2D2E4F) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkTheme 
              ? Colors.white.withOpacity(0.1)
              : Colors.grey.withOpacity(0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item == 'all' ? 'Tous' : item,
                style: TextStyle(
                  color: isDarkTheme ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            );
          }).toList(),
          selectedItemBuilder: (context) {
            return items.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.toggle_on,
                      size: 18,
                      color: isDarkTheme 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item == 'all' ? 'Tous' : item,
                        style: TextStyle(
                          color: isDarkTheme ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: isDarkTheme 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade600,
                    ),
                  ],
                ),
              );
            }).toList();
          },
          isExpanded: true,
          dropdownColor: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildLoadingState(bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDarkTheme ? Colors.cyan : AppColors.primary,
            ),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Chargement des facultés...',
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error, bool isDarkTheme) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: isDarkTheme ? Colors.red.shade400 : Colors.red.shade600,
          ),
          const SizedBox(height: 20),
          Text(
            'Erreur de chargement',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refreshFaculties,
            icon: const Icon(Icons.refresh),
            label: const Text('Réessayer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDarkTheme ? Colors.cyan : AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkTheme) {
    final hasActiveFilters = _searchController.text.isNotEmpty || 
                           _selectedStatus != 'all';
    
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            hasActiveFilters ? Icons.search_off : Icons.school_outlined,
            size: 64,
            color: isDarkTheme ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
          const SizedBox(height: 20),
          Text(
            hasActiveFilters ? 'Aucune faculté trouvée' : 'Aucune faculté disponible',
            style: TextStyle(
              color: isDarkTheme ? Colors.white : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasActiveFilters 
                ? 'Essayez de modifier vos critères de recherche ou de filtres.'
                : 'Cette université n\'a pas encore de facultés enregistrées.',
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          if (hasActiveFilters) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resetFilters,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Réinitialiser les filtres'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkTheme ? Colors.orange : Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _refreshFaculties,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Actualiser'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkTheme ? Colors.cyan : AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            ElevatedButton.icon(
              onPressed: _refreshFaculties,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualiser'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkTheme ? Colors.cyan : AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
