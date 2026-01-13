import 'package:flutter/material.dart';
import '../../data/models/institution_department_model.dart';

class AdvancedSearchWidget extends StatefulWidget {
  final Function(AdvancedSearchCriteria) onSearch;
  final List<InstitutionModel>? institutions;
  final List<DepartmentModel>? departments;

  const AdvancedSearchWidget({
    super.key,
    required this.onSearch,
    this.institutions,
    this.departments,
  });

  @override
  State<AdvancedSearchWidget> createState() => _AdvancedSearchWidgetState();
}

class _AdvancedSearchWidgetState extends State<AdvancedSearchWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Search criteria
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _matriculeController = TextEditingController();
  final _minUserLevelController = TextEditingController();
  final _maxUserLevelController = TextEditingController();
  
  String? _selectedRole;
  String? _selectedStatus;
  String? _selectedInstitution;
  String? _selectedDepartment;
  String? _selectedLevel;
  String? _selectedRegion;
  String? _selectedCity;
  bool? _isActive;
  bool? _hasRecentLogin;
  DateTime? _createdAfter;
  DateTime? _createdBefore;
  DateTime? _lastLoginAfter;
  DateTime? _lastLoginBefore;
  
  // Advanced options
  bool _searchInName = true;
  bool _searchInEmail = true;
  bool _searchInMatricule = false;
  bool _exactMatch = false;
  bool _caseSensitive = false;

  final List<String> _roles = [
    'Tous les rôles',
    'student',
    'teacher', 
    'staff',
    'moderator',
    'leader',
    'admin_local',
    'admin_national',
    'superadmin',
  ];
  
  final List<String> _statuses = [
    'Tous les statuts',
    'active',
    'inactive',
    'suspended',
    'banned',
    'pending_verification',
    'graduated',
    'withdrawn',
  ];

  final List<String> _levels = [
    'Tous les niveaux',
    'undergraduate',
    'graduate',
    'postgraduate',
  ];

  final List<String> _regions = [
    'Toutes les régions',
    'Centre',
    'Littoral',
    'Ouest',
    'Nord',
    'Extrême-Nord',
    'Adamaoua',
    'Est',
    'Sud',
    'Nord-Ouest',
    'Sud-Ouest',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _matriculeController.dispose();
    _minUserLevelController.dispose();
    _maxUserLevelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche Avancée'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Critères', icon: Icon(Icons.search)),
            Tab(text: 'Options', icon: Icon(Icons.tune)),
            Tab(text: 'Rapide', icon: Icon(Icons.flash_on)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _resetAllFields,
            tooltip: 'Réinitialiser',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _performSearch,
            tooltip: 'Rechercher',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCriteriaTab(),
          _buildOptionsTab(),
          _buildQuickSearchTab(),
        ],
      ),
    );
  }

  Widget _buildCriteriaTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text search section
          _buildSectionTitle('Recherche Texte'),
          const SizedBox(height: 12),
          _buildTextSearchFields(),
          
          const SizedBox(height: 24),
          
          // User attributes section
          _buildSectionTitle('Attributs Utilisateur'),
          const SizedBox(height: 12),
          _buildUserAttributesFields(),
          
          const SizedBox(height: 24),
          
          // Location section
          _buildSectionTitle('Localisation'),
          const SizedBox(height: 12),
          _buildLocationFields(),
          
          const SizedBox(height: 24),
          
          // Date ranges section
          _buildSectionTitle('Plages de Dates'),
          const SizedBox(height: 12),
          _buildDateRangeFields(),
        ],
      ),
    );
  }

  Widget _buildOptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search options
          _buildSectionTitle('Options de Recherche'),
          const SizedBox(height: 12),
          _buildSearchOptions(),
          
          const SizedBox(height: 24),
          
          // User level range
          _buildSectionTitle('Niveau d\'Utilisateur'),
          const SizedBox(height: 12),
          _buildUserLevelRange(),
          
          const SizedBox(height: 24),
          
          // Activity filters
          _buildSectionTitle('Filtres d\'Activité'),
          const SizedBox(height: 12),
          _buildActivityFilters(),
        ],
      ),
    );
  }

  Widget _buildQuickSearchTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick search templates
          _buildQuickSearchTemplate(
            'Étudiants actifs',
            Icons.school,
            () => _applyQuickSearch(
              role: 'student',
              status: 'active',
            ),
          ),
          
          _buildQuickSearchTemplate(
            'Enseignants par institution',
            Icons.person,
            () => _showInstitutionSelector('teacher'),
          ),
          
          _buildQuickSearchTemplate(
            'Utilisateurs inactifs',
            Icons.person_off,
            () => _applyQuickSearch(
              isActive: false,
            ),
          ),
          
          _buildQuickSearchTemplate(
            'Nouveaux utilisateurs (30 jours)',
            Icons.person_add,
            () => _applyQuickSearch(
              createdAfter: DateTime.now().subtract(const Duration(days: 30)),
            ),
          ),
          
          _buildQuickSearchTemplate(
            'Administrateurs',
            Icons.admin_panel_settings,
            () => _applyQuickSearch(
              roles: ['admin_local', 'admin_national', 'superadmin'],
            ),
          ),
          
          _buildQuickSearchTemplate(
            'Utilisateurs par région',
            Icons.location_on,
            () => _showRegionSelector(),
          ),
          
          _buildQuickSearchTemplate(
            'Connexions récentes (7 jours)',
            Icons.access_time,
            () => _applyQuickSearch(
              lastLoginAfter: DateTime.now().subtract(const Duration(days: 7)),
            ),
          ),
          
          _buildQuickSearchTemplate(
            'Personnel administratif',
            Icons.work,
            () => _applyQuickSearch(
              role: 'staff',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextSearchFields() {
    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Nom complet',
            hintText: 'Rechercher par nom...',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            hintText: 'Rechercher par email...',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _matriculeController,
          decoration: const InputDecoration(
            labelText: 'Matricule',
            hintText: 'Rechercher par matricule...',
            prefixIcon: Icon(Icons.badge),
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildUserAttributesFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Rôle',
                  border: OutlineInputBorder(),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(_getRoleDisplayName(role)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: _statuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(_getStatusLabel(status)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
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
                value: _selectedInstitution,
                decoration: const InputDecoration(
                  labelText: 'Institution',
                  border: OutlineInputBorder(),
                ),
                items: _buildInstitutionItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedInstitution = value;
                    _selectedDepartment = null; // Reset department
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: const InputDecoration(
                  labelText: 'Département',
                  border: OutlineInputBorder(),
                ),
                items: _buildDepartmentItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartment = value;
                  });
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _selectedLevel,
          decoration: const InputDecoration(
            labelText: 'Niveau d\'étude',
            border: OutlineInputBorder(),
          ),
          items: _levels.map((level) {
            return DropdownMenuItem<String>(
              value: level,
              child: Text(_getLevelDisplayName(level)),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedLevel = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLocationFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedRegion,
                decoration: const InputDecoration(
                  labelText: 'Région',
                  border: OutlineInputBorder(),
                ),
                items: _regions.map((region) {
                  return DropdownMenuItem<String>(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRegion = value;
                    _selectedCity = null; // Reset city when region changes
                  });
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  border: OutlineInputBorder(),
                ),
                items: _buildCityItems(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeFields() {
    return Column(
      children: [
        // Creation date range
        const Text(
          'Période de création',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Après'),
                subtitle: Text(_createdAfter != null 
                    ? '${_createdAfter!.day}/${_createdAfter!.month}/${_createdAfter!.year}'
                    : 'Sélectionner'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'created_after'),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('Avant'),
                subtitle: Text(_createdBefore != null 
                    ? '${_createdBefore!.day}/${_createdBefore!.month}/${_createdBefore!.year}'
                    : 'Sélectionner'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'created_before'),
              ),
            ),
          ],
        ),
        
        const Divider(),
        
        // Last login date range
        const Text(
          'Dernière connexion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ListTile(
                title: const Text('Après'),
                subtitle: Text(_lastLoginAfter != null 
                    ? '${_lastLoginAfter!.day}/${_lastLoginAfter!.month}/${_lastLoginAfter!.year}'
                    : 'Sélectionner'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'last_login_after'),
              ),
            ),
            Expanded(
              child: ListTile(
                title: const Text('Avant'),
                subtitle: Text(_lastLoginBefore != null 
                    ? '${_lastLoginBefore!.day}/${_lastLoginBefore!.month}/${_lastLoginBefore!.year}'
                    : 'Sélectionner'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, 'last_login_before'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchOptions() {
    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Rechercher dans le nom'),
          value: _searchInName,
          onChanged: (value) {
            setState(() {
              _searchInName = value ?? false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Rechercher dans l\'email'),
          value: _searchInEmail,
          onChanged: (value) {
            setState(() {
              _searchInEmail = value ?? false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Rechercher dans le matricule'),
          value: _searchInMatricule,
          onChanged: (value) {
            setState(() {
              _searchInMatricule = value ?? false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Correspondance exacte'),
          subtitle: const Text('Recherche uniquement les correspondances exactes'),
          value: _exactMatch,
          onChanged: (value) {
            setState(() {
              _exactMatch = value ?? false;
            });
          },
        ),
        CheckboxListTile(
          title: const Text('Sensible à la casse'),
          subtitle: const Text('Tenir compte des majuscules/minuscules'),
          value: _caseSensitive,
          onChanged: (value) {
            setState(() {
              _caseSensitive = value ?? false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildUserLevelRange() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _minUserLevelController,
            decoration: const InputDecoration(
              labelText: 'Niveau minimum',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _maxUserLevelController,
            decoration: const InputDecoration(
              labelText: 'Niveau maximum',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityFilters() {
    return Column(
      children: [
        DropdownButtonFormField<bool>(
          value: _isActive,
          decoration: const InputDecoration(
            labelText: 'Statut actif',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem<bool>(
              value: null,
              child: Text('Tous'),
            ),
            DropdownMenuItem<bool>(
              value: true,
              child: Text('Actif'),
            ),
            DropdownMenuItem<bool>(
              value: false,
              child: Text('Inactif'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _isActive = value;
            });
          },
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<bool>(
          value: _hasRecentLogin,
          decoration: const InputDecoration(
            labelText: 'Connexion récente',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem<bool>(
              value: null,
              child: Text('Tous'),
            ),
            DropdownMenuItem<bool>(
              value: true,
              child: Text('Avec connexion récente'),
            ),
            DropdownMenuItem<bool>(
              value: false,
              child: Text('Sans connexion récente'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _hasRecentLogin = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuickSearchTemplate(
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildInstitutionItems() {
    final items = <DropdownMenuItem<String>>[];
    items.add(const DropdownMenuItem<String>(
      value: 'Toutes les institutions',
      child: Text('Toutes les institutions'),
    ));
    
    if (widget.institutions != null) {
      for (final institution in widget.institutions!) {
        items.add(DropdownMenuItem<String>(
          value: institution.name,
          child: Text(institution.name),
        ));
      }
    }
    
    return items;
  }

  List<DropdownMenuItem<String>> _buildDepartmentItems() {
    final items = <DropdownMenuItem<String>>[];
    items.add(const DropdownMenuItem<String>(
      value: 'Tous les départements',
      child: Text('Tous les départements'),
    ));
    
    if (widget.departments != null) {
      var filteredDepartments = widget.departments!;
      if (_selectedInstitution != null && 
          _selectedInstitution != 'Toutes les institutions' &&
          widget.institutions != null) {
        
        final selectedInstitution = widget.institutions!
            .where((inst) => inst.name == _selectedInstitution)
            .firstOrNull;
        
        if (selectedInstitution != null) {
          filteredDepartments = widget.departments!
              .where((dept) => dept.institutionId == selectedInstitution.id)
              .toList();
        }
      }
      
      for (final department in filteredDepartments) {
        items.add(DropdownMenuItem<String>(
          value: department.name,
          child: Text(department.name),
        ));
      }
    }
    
    return items;
  }

  List<DropdownMenuItem<String>> _buildCityItems() {
    final items = <DropdownMenuItem<String>>[];
    items.add(const DropdownMenuItem<String>(
      value: null,
      child: Text('Toutes les villes'),
    ));
    
    if (widget.institutions != null) {
      final cities = widget.institutions!
          .where((inst) => _selectedRegion == null || 
                         _selectedRegion == 'Toutes les régions' ||
                         inst.region == _selectedRegion)
          .map((inst) => inst.city)
          .toSet()
          .toList();
      
      for (final city in cities) {
        items.add(DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        ));
      }
    }
    
    return items;
  }

  void _resetAllFields() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _matriculeController.clear();
      _minUserLevelController.clear();
      _maxUserLevelController.clear();
      
      _selectedRole = null;
      _selectedStatus = null;
      _selectedInstitution = null;
      _selectedDepartment = null;
      _selectedLevel = null;
      _selectedRegion = null;
      _selectedCity = null;
      _isActive = null;
      _hasRecentLogin = null;
      _createdAfter = null;
      _createdBefore = null;
      _lastLoginAfter = null;
      _lastLoginBefore = null;
      
      _searchInName = true;
      _searchInEmail = true;
      _searchInMatricule = false;
      _exactMatch = false;
      _caseSensitive = false;
    });
  }

  void _performSearch() {
    final criteria = AdvancedSearchCriteria(
      name: _nameController.text.isNotEmpty ? _nameController.text : null,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      matricule: _matriculeController.text.isNotEmpty ? _matriculeController.text : null,
      role: _selectedRole == 'Tous les rôles' ? null : _selectedRole,
      status: _selectedStatus == 'Tous les statuts' ? null : _selectedStatus,
      institution: _selectedInstitution == 'Toutes les institutions' ? null : _selectedInstitution,
      department: _selectedDepartment == 'Tous les départements' ? null : _selectedDepartment,
      level: _selectedLevel == 'Tous les niveaux' ? null : _selectedLevel,
      region: _selectedRegion == 'Toutes les régions' ? null : _selectedRegion,
      city: _selectedCity,
      isActive: _isActive,
      hasRecentLogin: _hasRecentLogin,
      createdAfter: _createdAfter,
      createdBefore: _createdBefore,
      lastLoginAfter: _lastLoginAfter,
      lastLoginBefore: _lastLoginBefore,
      minUserLevel: int.tryParse(_minUserLevelController.text),
      maxUserLevel: int.tryParse(_maxUserLevelController.text),
      searchInName: _searchInName,
      searchInEmail: _searchInEmail,
      searchInMatricule: _searchInMatricule,
      exactMatch: _exactMatch,
      caseSensitive: _caseSensitive,
    );
    
    widget.onSearch(criteria);
    Navigator.of(context).pop();
  }

  void _applyQuickSearch({
    String? role,
    String? status,
    bool? isActive,
    DateTime? createdAfter,
    DateTime? lastLoginAfter,
    List<String>? roles,
    String? institutionName,
    String? regionName,
  }) {
    final criteria = AdvancedSearchCriteria(
      role: role,
      status: status,
      isActive: isActive,
      createdAfter: createdAfter,
      lastLoginAfter: lastLoginAfter,
      roles: roles,
      institution: institutionName,
      region: regionName,
    );
    
    widget.onSearch(criteria);
    Navigator.of(context).pop();
  }

  void _showInstitutionSelector(String role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner une institution'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: widget.institutions != null
              ? ListView.builder(
                  itemCount: widget.institutions!.length,
                  itemBuilder: (context, index) {
                    final institution = widget.institutions![index];
                    return ListTile(
                      title: Text(institution.name),
                      subtitle: Text('${institution.region} • ${institution.city}'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _applyQuickSearch(
                          role: role,
                          institutionName: institution.name,
                        );
                      },
                    );
                  },
                )
              : const Center(child: Text('Aucune institution disponible')),
        ),
      ),
    );
  }

  void _showRegionSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner une région'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: _regions.where((r) => r != 'Toutes les régions').map((region) {
              return ListTile(
                title: Text(region),
                onTap: () {
                  Navigator.of(context).pop();
                  _applyQuickSearch(regionName: region,);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, String fieldType) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        switch (fieldType) {
          case 'created_after':
            _createdAfter = picked;
            break;
          case 'created_before':
            _createdBefore = picked;
            break;
          case 'last_login_after':
            _lastLoginAfter = picked;
            break;
          case 'last_login_before':
            _lastLoginBefore = picked;
            break;
        }
      });
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'tous les rôles':
        return 'Tous les rôles';
      case 'superadmin':
        return 'Super Admin';
      case 'admin_national':
        return 'Admin National';
      case 'admin_local':
        return 'Admin Local';
      case 'leader':
        return 'Leader';
      case 'teacher':
        return 'Enseignant';
      case 'staff':
        return 'Personnel';
      case 'moderator':
        return 'Modérateur';
      case 'student':
        return 'Étudiant';
      default:
        return role;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'tous les statuts':
        return 'Tous les statuts';
      case 'active':
        return 'Actif';
      case 'inactive':
        return 'Inactif';
      case 'suspended':
        return 'Suspendu';
      case 'banned':
        return 'Banni';
      case 'pending_verification':
        return 'En attente';
      case 'graduated':
        return 'Diplômé';
      case 'withdrawn':
        return 'Retiré';
      default:
        return status;
    }
  }

  String _getLevelDisplayName(String level) {
    switch (level.toLowerCase()) {
      case 'tous les niveaux':
        return 'Tous les niveaux';
      case 'undergraduate':
        return 'Licence';
      case 'graduate':
        return 'Master';
      case 'postgraduate':
        return 'Doctorat';
      default:
        return level;
    }
  }
}

class AdvancedSearchCriteria {
  final String? name;
  final String? email;
  final String? matricule;
  final String? role;
  final String? status;
  final String? institution;
  final String? department;
  final String? level;
  final String? region;
  final String? city;
  final bool? isActive;
  final bool? hasRecentLogin;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final DateTime? lastLoginAfter;
  final DateTime? lastLoginBefore;
  final int? minUserLevel;
  final int? maxUserLevel;
  final bool searchInName;
  final bool searchInEmail;
  final bool searchInMatricule;
  final bool exactMatch;
  final bool caseSensitive;
  final List<String>? roles;

  AdvancedSearchCriteria({
    this.name,
    this.email,
    this.matricule,
    this.role,
    this.status,
    this.institution,
    this.department,
    this.level,
    this.region,
    this.city,
    this.isActive,
    this.hasRecentLogin,
    this.createdAfter,
    this.createdBefore,
    this.lastLoginAfter,
    this.lastLoginBefore,
    this.minUserLevel,
    this.maxUserLevel,
    this.searchInName = true,
    this.searchInEmail = true,
    this.searchInMatricule = false,
    this.exactMatch = false,
    this.caseSensitive = false,
    this.roles,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'matricule': matricule,
      'role': role,
      'status': status,
      'institution': institution,
      'department': department,
      'level': level,
      'region': region,
      'city': city,
      'is_active': isActive,
      'has_recent_login': hasRecentLogin,
      'created_after': createdAfter?.toIso8601String(),
      'created_before': createdBefore?.toIso8601String(),
      'last_login_after': lastLoginAfter?.toIso8601String(),
      'last_login_before': lastLoginBefore?.toIso8601String(),
      'min_user_level': minUserLevel,
      'max_user_level': maxUserLevel,
      'search_in_name': searchInName,
      'search_in_email': searchInEmail,
      'search_in_matricule': searchInMatricule,
      'exact_match': exactMatch,
      'case_sensitive': caseSensitive,
      'roles': roles,
    };
  }

  bool get hasAnyCriteria =>
      name != null ||
      email != null ||
      matricule != null ||
      role != null ||
      status != null ||
      institution != null ||
      department != null ||
      level != null ||
      region != null ||
      city != null ||
      isActive != null ||
      hasRecentLogin != null ||
      createdAfter != null ||
      createdBefore != null ||
      lastLoginAfter != null ||
      lastLoginBefore != null ||
      minUserLevel != null ||
      maxUserLevel != null ||
      (roles != null && roles!.isNotEmpty);

  @override
  String toString() {
    final parts = <String>[];
    
    if (name != null) parts.add('Nom: $name');
    if (email != null) parts.add('Email: $email');
    if (matricule != null) parts.add('Matricule: $matricule');
    if (role != null) parts.add('Rôle: $role');
    if (status != null) parts.add('Statut: $status');
    if (institution != null) parts.add('Institution: $institution');
    if (department != null) parts.add('Département: $department');
    if (level != null) parts.add('Niveau: $level');
    if (region != null) parts.add('Région: $region');
    if (city != null) parts.add('Ville: $city');
    if (isActive != null) parts.add('Actif: $isActive');
    if (createdAfter != null) parts.add('Créé après: $createdAfter');
    if (createdBefore != null) parts.add('Créé avant: $createdBefore');
    if (lastLoginAfter != null) parts.add('Connexion après: $lastLoginAfter');
    if (lastLoginBefore != null) parts.add('Connexion avant: $lastLoginBefore');
    if (minUserLevel != null) parts.add('Niveau min: $minUserLevel');
    if (maxUserLevel != null) parts.add('Niveau max: $maxUserLevel');
    
    return parts.join(' • ');
  }
}
