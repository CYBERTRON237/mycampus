import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycampus/features/preinscription/presentation/preinscription_routes.dart';
import 'package:mycampus/features/preinscription/presentation/pages/faculty_selection_page.dart';
import 'package:mycampus/features/preinscription/presentation/pages/preinscription_fiche_page.dart';
import 'package:mycampus/features/preinscription/services/university_service.dart';
import 'package:mycampus/features/preinscription/models/university_model.dart';
import 'package:mycampus/features/preinscription/presentation/widgets/university_card_widget.dart';
import 'package:mycampus/constants/app_colors.dart';
import 'package:mycampus/core/providers/theme_provider.dart';

class PreinscriptionHomePage extends StatefulWidget {
  const PreinscriptionHomePage({Key? key}) : super(key: key);

  @override
  State<PreinscriptionHomePage> createState() => _PreinscriptionHomePageState();
}

class _PreinscriptionHomePageState extends State<PreinscriptionHomePage> {
  late UniversityService _universityService;
  List<UniversityModel> _universities = [];
  List<UniversityModel> _filteredUniversities = [];
  bool _isLoading = true;
  String? _error;

  // Contrôleurs pour la recherche
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Filtres
  String _selectedType = 'all';
  String _selectedRegion = 'all';
  String _selectedStatus = 'active';

  // Options de filtres
  final List<String> _types = ['all', 'public', 'private', 'confessional'];
  final List<String> _regions = ['all', 'Centre', 'Littoral', 'Ouest', 'Nord-Ouest', 'Sud-Ouest', 'Adamaoua', 'Extrême-Nord', 'Est', 'Nord'];
  final List<String> _statuses = ['all', 'active', 'inactive', 'pending', 'suspended'];

  @override
  void initState() {
    super.initState();
    _universityService = UniversityService();
    _loadUniversities();

    // Écouter les changements de recherche
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _universityService.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _filterUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final universities = await _universityService.getUniversities(
        status: _selectedStatus == 'all' ? null : _selectedStatus,
        limit: 100, // Augmenter la limite pour avoir plus de résultats
      );

      if (mounted) {
        setState(() {
          _universities = universities;
          _filteredUniversities = universities;
          _isLoading = false;
        });
        _filterUniversities();
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

  void _filterUniversities() {
    setState(() {
      _filteredUniversities = _universities.where((university) {
        // Filtre par nom de recherche
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            university.name.toLowerCase().contains(searchQuery) ||
            university.shortName.toLowerCase().contains(searchQuery) ||
            university.code.toLowerCase().contains(searchQuery) ||
            (university.city?.toLowerCase().contains(searchQuery) ?? false) ||
            (university.description?.toLowerCase().contains(searchQuery) ?? false);

        // Filtre par type
        final matchesType = _selectedType == 'all' || university.type.name == _selectedType;

        // Filtre par région
        final matchesRegion = _selectedRegion == 'all' || university.region == _selectedRegion;

        // Filtre par statut
        final matchesStatus = _selectedStatus == 'all' || university.status.name == _selectedStatus;

        return matchesSearch && matchesType && matchesRegion && matchesStatus;
      }).toList();
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = 'all';
      _selectedRegion = 'all';
      _selectedStatus = 'active';
    });
    _filterUniversities();
  }

  Future<void> _refreshUniversities() async {
    await _loadUniversities();
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
            const Text(
              'MyCampus',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
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
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: TextButton.icon(
              onPressed: () {
                // Changer la langue
              },
              icon: const Icon(Icons.language, color: Colors.white, size: 18),
              label: const Text('FR', style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
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
              // Bannière principale moderne
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDarkTheme
                        ? [const Color(0xFF1D1E33), const Color(0xFF2D2E4F), const Color(0xFF0A0E21)]
                        : [AppColors.primary, AppColors.primaryDark, AppColors.accent],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkTheme 
                          ? Colors.black.withOpacity(0.4)
                          : AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Text(
                        'PRÉINSCRIPTIONS 2025-2026',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Choisissez votre établissement',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Section de recherche et filtres
              _buildSearchAndFilterSection(isDarkTheme),
              
              const SizedBox(height: 20),
              
              // Cartes des universités dynamiques
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (_isLoading)
                      _buildLoadingState(isDarkTheme)
                    else if (_error != null)
                      _buildErrorState(_error!, isDarkTheme)
                    else if (_filteredUniversities.isEmpty)
                      _buildEmptyState(isDarkTheme)
                    else
                      ..._filteredUniversities.map((university) => UniversityCardWidget(
                        university: university,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FacultySelectionPage(
                                university: university,
                              ),
                            ),
                          );
                        },
                      )).toList(),
                    
                    const SizedBox(height: 40),
                    
                    // Section informations moderne
                    _buildModernInfoSection(context, isDarkTheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
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
                hintText: 'Rechercher une université...',
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
          
          // Filtres avancés
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  'Type',
                  _selectedType,
                  _types,
                  (value) {
                    setState(() {
                      _selectedType = value!;
                      _filterUniversities();
                    });
                  },
                  isDarkTheme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  'Région',
                  _selectedRegion,
                  _regions,
                  (value) {
                    setState(() {
                      _selectedRegion = value!;
                      _filterUniversities();
                    });
                  },
                  isDarkTheme,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
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
                      _filterUniversities();
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
          if (_filteredUniversities.isNotEmpty)
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
                    '${_filteredUniversities.length} université${_filteredUniversities.length > 1 ? 's' : ''} trouvée${_filteredUniversities.length > 1 ? 's' : ''}',
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
                      _getFilterIcon(label),
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
  
  IconData _getFilterIcon(String label) {
    switch (label.toLowerCase()) {
      case 'type':
        return Icons.category;
      case 'région':
        return Icons.location_on;
      case 'statut':
        return Icons.toggle_on;
      default:
        return Icons.filter_list;
    }
  }

  Widget _buildModernInfoSection(BuildContext context, bool isDarkTheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.primaryLight.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Guide de préinscription',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tout ce que vous devez savoir',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Cartes d'information modernes
          _buildModernInfoCard(
            'Documents requis',
            'Pièce d\'identité, diplômes, photos d\'identité, relevés de notes',
            Icons.folder_special,
            AppColors.info,
          ),
          
          const SizedBox(height: 16),
          
          _buildModernInfoCard(
            'Calendrier important',
            'Dates limites et périodes de préinscription par établissement',
            Icons.event_available,
            AppColors.warning,
          ),
          
          const SizedBox(height: 16),
          
          _buildModernInfoCard(
            'Support technique',
            'Contactez notre équipe pour toute question ou assistance',
            Icons.headset_mic,
            AppColors.success,
          ),
          
          const SizedBox(height: 28),
          
          // Boutons modernes
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    PreinscriptionRoutes.navigateToPreinscriptionInfo(context);
                  },
                  icon: const Icon(Icons.explore, size: 22),
                  label: const Text(
                    'Explorer le guide complet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade500, Colors.green.shade700],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PreinscriptionFichePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment_ind, size: 22),
                  label: const Text(
                    'Voir ma fiche de préinscription',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoCard(String title, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
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
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkTheme) {
    final hasActiveFilters = _searchController.text.isNotEmpty || 
                           _selectedType != 'all' || 
                           _selectedRegion != 'all' || 
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
            hasActiveFilters ? 'Aucune université trouvée' : 'Aucune université disponible',
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
                : 'Les universités seront bientôt disponibles. Veuillez réessayer plus tard.',
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
                    onPressed: _refreshUniversities,
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
              onPressed: _refreshUniversities,
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
            'Chargement des universités...',
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
            onPressed: _refreshUniversities,
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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0:
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed('/dashboard');
              });
              break;
            case 1:
              // Explorer - page temporaire
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed('/dashboard');
              });
              break;
            case 2:
              // Messages - page temporaire
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed('/dashboard');
              });
              break;
            case 3:
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed('/profile');
              });
              break;
            case 4:
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).pushReplacementNamed('/settings');
              });
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey.shade600,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            activeIcon: Icon(Icons.dashboard_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_rounded),
            activeIcon: Icon(Icons.explore_rounded),
            label: 'Explorer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_rounded),
            activeIcon: Icon(Icons.message_rounded),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Paramètres',
          ),
        ],
      ),
    );
  }
}