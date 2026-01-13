import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/models/user_model.dart';
import '../../data/models/institution_department_model.dart';

class AdvancedUserFiltersWidget extends StatefulWidget {
  final TextEditingController searchController;
  final Function(UserFilters) onFiltersChanged;
  final UserFilters currentFilters;
  final List<InstitutionModel>? institutions;
  final List<DepartmentModel>? departments;

  const AdvancedUserFiltersWidget({
    super.key,
    required this.searchController,
    required this.onFiltersChanged,
    required this.currentFilters,
    this.institutions,
    this.departments,
  });

  @override
  State<AdvancedUserFiltersWidget> createState() => _AdvancedUserFiltersWidgetState();
}

class _AdvancedUserFiltersWidgetState extends State<AdvancedUserFiltersWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // Basic filters
  String? _selectedRole;
  String? _selectedStatus;
  String? _selectedInstitution;
  String? _selectedDepartment;
  String? _selectedLevel;
  String? _selectedRegion;
  String? _selectedCity;
  String? _selectedSortBy;
  String? _selectedSortOrder;
  
  // Advanced filters
  DateTime? _createdAfter;
  DateTime? _createdBefore;
  DateTime? _lastLoginAfter;
  DateTime? _lastLoginBefore;
  bool? _isActive;
  int? _minUserLevel;
  int? _maxUserLevel;

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

  final List<String> _sortOptions = [
    'created_at',
    'last_login_at',
    'first_name',
    'last_name',
    'email',
    'user_level',
  ];

  final List<String> _sortOrders = ['desc', 'asc'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeFilters();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initializeFilters() {
    _selectedRole = widget.currentFilters.role ?? 'Tous les rôles';
    _selectedStatus = widget.currentFilters.status ?? 'Tous les statuts';
    _selectedInstitution = widget.currentFilters.institutionName ?? 'Toutes les institutions';
    _selectedDepartment = widget.currentFilters.departmentName ?? 'Tous les départements';
    _selectedLevel = widget.currentFilters.level ?? 'Tous les niveaux';
    _selectedRegion = widget.currentFilters.region ?? 'Toutes les régions';
    _selectedCity = widget.currentFilters.city;
    _selectedSortBy = widget.currentFilters.sortBy ?? 'created_at';
    _selectedSortOrder = widget.currentFilters.sortOrder ?? 'desc';
    _createdAfter = widget.currentFilters.createdAfter;
    _createdBefore = widget.currentFilters.createdBefore;
    _lastLoginAfter = widget.currentFilters.lastLoginAfter;
    _lastLoginBefore = widget.currentFilters.lastLoginBefore;
    _isActive = widget.currentFilters.isActive;
    _minUserLevel = widget.currentFilters.minUserLevel;
    _maxUserLevel = widget.currentFilters.maxUserLevel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: widget.searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, email ou matricule...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: widget.searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          widget.searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Tab bar for different filter categories
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Basic', icon: Icon(Icons.filter_list)),
              Tab(text: 'Avancé', icon: Icon(Icons.tune)),
              Tab(text: 'Navigation', icon: Icon(Icons.explore)),
            ],
          ),
          
          // Tab content
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicFilters(),
                _buildAdvancedFilters(),
                _buildNavigationFilters(),
              ],
            ),
          ),
          
          // Active filters display and actions
          _buildFilterActions(),
        ],
      ),
    );
  }

  Widget _buildBasicFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // First row: Role and Status
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
                      _applyFilters();
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
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Second row: Institution and Department
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
                        _selectedDepartment = 'Tous les départements'; // Reset department
                      });
                      _applyFilters();
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
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Third row: Level and Region
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedLevel,
                    decoration: const InputDecoration(
                      labelText: 'Niveau',
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
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
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
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Fourth row: City and Active status
            Row(
              children: [
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
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<bool>(
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
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Date range for creation
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
            
            // Date range for last login
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
            
            const Divider(),
            
            // User level range
            const Text(
              'Niveau d\'utilisateur',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Min',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: TextEditingController(
                      text: _minUserLevel?.toString() ?? '',
                    ),
                    onChanged: (value) {
                      _minUserLevel = int.tryParse(value);
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Max',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: TextEditingController(
                      text: _maxUserLevel?.toString() ?? '',
                    ),
                    onChanged: (value) {
                      _maxUserLevel = int.tryParse(value);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Navigation par institution',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            // Institution grid
            if (widget.institutions != null)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: widget.institutions!.length,
                itemBuilder: (context, index) {
                  final institution = widget.institutions![index];
                  final isSelected = _selectedInstitution == institution.name;
                  
                  return Card(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primaryContainer
                        : null,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedInstitution = isSelected ? 'Toutes les institutions' : institution.name;
                        });
                        _applyFilters();
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              institution.shortName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              institution.name,
                              style: const TextStyle(fontSize: 10),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Text(
                              institution.region,
                              style: TextStyle(
                                fontSize: 9,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Tri',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSortBy,
                    decoration: const InputDecoration(
                      labelText: 'Trier par',
                      border: OutlineInputBorder(),
                    ),
                    items: _sortOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(_getSortByDisplayName(option)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSortBy = value;
                      });
                      _applyFilters();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedSortOrder,
                    decoration: const InputDecoration(
                      labelText: 'Ordre',
                      border: OutlineInputBorder(),
                    ),
                    items: _sortOrders.map((order) {
                      return DropdownMenuItem<String>(
                        value: order,
                        child: Text(order == 'asc' ? 'Croissant' : 'Décroissant'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedSortOrder = value;
                      });
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Active filters display
          _buildActiveFilters(),
          
          const SizedBox(height: 12),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.search),
                  label: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    final List<Widget> chips = [];
    
    if (_selectedRole != null && _selectedRole != 'Tous les rôles') {
      chips.add(_buildFilterChip(_getRoleDisplayName(_selectedRole!), 'role'));
    }
    
    if (_selectedStatus != null && _selectedStatus != 'Tous les statuts') {
      chips.add(_buildFilterChip(_getStatusLabel(_selectedStatus!), 'status'));
    }
    
    if (_selectedInstitution != null && _selectedInstitution != 'Toutes les institutions') {
      chips.add(_buildFilterChip(_selectedInstitution!, 'institution'));
    }
    
    if (_selectedDepartment != null && _selectedDepartment != 'Tous les départements') {
      chips.add(_buildFilterChip(_selectedDepartment!, 'department'));
    }
    
    if (_selectedLevel != null && _selectedLevel != 'Tous les niveaux') {
      chips.add(_buildFilterChip(_getLevelDisplayName(_selectedLevel!), 'level'));
    }
    
    if (_selectedRegion != null && _selectedRegion != 'Toutes les régions') {
      chips.add(_buildFilterChip(_selectedRegion!, 'region'));
    }
    
    if (_selectedCity != null && _selectedCity!.isNotEmpty) {
      chips.add(_buildFilterChip(_selectedCity!, 'city'));
    }
    
    if (_isActive != null) {
      chips.add(_buildFilterChip(_isActive! ? 'Actif' : 'Inactif', 'active'));
    }
    
    if (_createdAfter != null) {
      chips.add(_buildFilterChip(
          'Créé après: ${_createdAfter!.day}/${_createdAfter!.month}/${_createdAfter!.year}', 
          'created_after'));
    }
    
    if (_createdBefore != null) {
      chips.add(_buildFilterChip(
          'Créé avant: ${_createdBefore!.day}/${_createdBefore!.month}/${_createdBefore!.year}', 
          'created_before'));
    }
    
    if (widget.searchController.text.isNotEmpty) {
      chips.add(_buildFilterChip('Recherche: ${widget.searchController.text}', 'search'));
    }
    
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtres actifs: ${chips.length}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: chips,
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String type) {
    return Chip(
      label: Text(label),
      onDeleted: () => _removeFilter(type),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
      // Filter departments by selected institution if applicable
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

  void _removeFilter(String type) {
    setState(() {
      switch (type) {
        case 'role':
          _selectedRole = 'Tous les rôles';
          break;
        case 'status':
          _selectedStatus = 'Tous les statuts';
          break;
        case 'institution':
          _selectedInstitution = 'Toutes les institutions';
          _selectedDepartment = 'Tous les départements';
          break;
        case 'department':
          _selectedDepartment = 'Tous les départements';
          break;
        case 'level':
          _selectedLevel = 'Tous les niveaux';
          break;
        case 'region':
          _selectedRegion = 'Toutes les régions';
          _selectedCity = null;
          break;
        case 'city':
          _selectedCity = null;
          break;
        case 'active':
          _isActive = null;
          break;
        case 'created_after':
          _createdAfter = null;
          break;
        case 'created_before':
          _createdBefore = null;
          break;
        case 'search':
          widget.searchController.clear();
          break;
      }
    });
    _applyFilters();
  }

  void _resetFilters() {
    setState(() {
      _selectedRole = 'Tous les rôles';
      _selectedStatus = 'Tous les statuts';
      _selectedInstitution = 'Toutes les institutions';
      _selectedDepartment = 'Tous les départements';
      _selectedLevel = 'Tous les niveaux';
      _selectedRegion = 'Toutes les régions';
      _selectedCity = null;
      _selectedSortBy = 'created_at';
      _selectedSortOrder = 'desc';
      _createdAfter = null;
      _createdBefore = null;
      _lastLoginAfter = null;
      _lastLoginBefore = null;
      _isActive = null;
      _minUserLevel = null;
      _maxUserLevel = null;
      widget.searchController.clear();
    });
    _applyFilters();
  }

  void _applyFilters() {
    final filters = UserFilters(
      search: widget.searchController.text.isEmpty ? null : widget.searchController.text,
      role: _selectedRole == 'Tous les rôles' ? null : _selectedRole,
      status: _selectedStatus == 'Tous les statuts' ? null : _selectedStatus,
      institutionName: _selectedInstitution == 'Toutes les institutions' ? null : _selectedInstitution,
      departmentName: _selectedDepartment == 'Tous les départements' ? null : _selectedDepartment,
      level: _selectedLevel == 'Tous les niveaux' ? null : _selectedLevel,
      region: _selectedRegion == 'Toutes les régions' ? null : _selectedRegion,
      city: _selectedCity,
      createdAfter: _createdAfter,
      createdBefore: _createdBefore,
      lastLoginAfter: _lastLoginAfter,
      lastLoginBefore: _lastLoginBefore,
      isActive: _isActive,
      minUserLevel: _minUserLevel,
      maxUserLevel: _maxUserLevel,
      sortBy: _selectedSortBy,
      sortOrder: _selectedSortOrder,
      page: 1, // Reset to first page when filters change
    );
    
    widget.onFiltersChanged(filters);
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
      _applyFilters();
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

  String _getSortByDisplayName(String sortBy) {
    switch (sortBy) {
      case 'created_at':
        return 'Date de création';
      case 'last_login_at':
        return 'Dernière connexion';
      case 'first_name':
        return 'Prénom';
      case 'last_name':
        return 'Nom';
      case 'email':
        return 'Email';
      case 'user_level':
        return 'Niveau utilisateur';
      default:
        return sortBy;
    }
  }
}
