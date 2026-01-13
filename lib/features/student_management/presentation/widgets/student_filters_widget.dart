import 'package:flutter/material.dart';
import '../../data/models/student_model.dart';

class StudentFiltersWidget extends StatefulWidget {
  final StudentFilters filters;
  final Function(StudentFilters) onFiltersChanged;
  final VoidCallback onReset;

  const StudentFiltersWidget({
    Key? key,
    required this.filters,
    required this.onFiltersChanged,
    required this.onReset,
  }) : super(key: key);

  @override
  State<StudentFiltersWidget> createState() => _StudentFiltersWidgetState();
}

class _StudentFiltersWidgetState extends State<StudentFiltersWidget> {
  late TextEditingController _searchController;
  String? _selectedInstitution;
  String? _selectedFaculty;
  String? _selectedDepartment;
  String? _selectedProgram;
  String? _selectedLevel;
  String? _selectedStatus;
  String? _selectedRegion;
  String? _selectedGroup;

  final List<String> _levels = [
    'licence1',
    'licence2',
    'licence3',
    'master1',
    'master2',
    'doctorat1',
    'doctorat2',
    'doctorat3',
  ];

  final List<String> _statuses = [
    'enrolled',
    'graduated',
    'suspended',
    'withdrawn',
    'deferred',
  ];

  final Map<String, String> _levelLabels = {
    'licence1': 'Licence 1',
    'licence2': 'Licence 2',
    'licence3': 'Licence 3',
    'master1': 'Master 1',
    'master2': 'Master 2',
    'doctorat1': 'Doctorat 1',
    'doctorat2': 'Doctorat 2',
    'doctorat3': 'Doctorat 3',
  };

  final Map<String, String> _statusLabels = {
    'enrolled': 'Inscrit',
    'graduated': 'Diplômé',
    'suspended': 'Suspendu',
    'withdrawn': 'Retiré',
    'deferred': 'Reporté',
  };

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.filters.search ?? '');
    _selectedLevel = widget.filters.level;
    _selectedStatus = widget.filters.status;
    _selectedInstitution = widget.filters.institution;
    _selectedFaculty = widget.filters.faculty;
    _selectedDepartment = widget.filters.department;
    _selectedProgram = widget.filters.program;
    _selectedRegion = widget.filters.region;
    _selectedGroup = widget.filters.group;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 16),
        _buildSearchField(),
        const SizedBox(height: 16),
        _buildAcademicFilters(),
        const SizedBox(height: 16),
        _buildStatusFilters(),
        const SizedBox(height: 24),
        _buildActions(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filtres',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        TextButton.icon(
          onPressed: widget.onReset,
          icon: const Icon(Icons.refresh),
          label: const Text('Réinitialiser'),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: const InputDecoration(
        labelText: 'Rechercher un étudiant',
        hintText: 'Nom, prénom, email ou matricule...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        _applyFilters();
      },
    );
  }

  Widget _buildAcademicFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtres académiques',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              'Niveau',
              _selectedLevel,
              _levels.map((level) => _levelLabels[level] ?? level).toList(),
              _levels,
              (value) {
                setState(() {
                  _selectedLevel = value;
                });
                _applyFilters();
              },
            ),
            const SizedBox(height: 12),
            _buildInstitutionFilters(),
          ],
        ),
      ),
    );
  }

  Widget _buildInstitutionFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Institution',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildSimpleDropdown(
                'Université',
                _selectedInstitution,
                ['Université de Yaoundé I', 'Université de Douala', 'Université de Dschang', 'Université de Maroua', 'Université de Buéa', 'Université de Ngaoundéré'],
                (value) {
                  setState(() {
                    _selectedInstitution = value;
                  });
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSimpleDropdown(
                'Faculté',
                _selectedFaculty,
                ['FALSH', 'FS', 'FSE', 'IUT', 'ENSPY', 'FASA', 'FSHD'],
                (value) {
                  setState(() {
                    _selectedFaculty = value;
                  });
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSimpleDropdown(
                'Département',
                _selectedDepartment,
                ['Mathématiques', 'Physique', 'Chimie', 'Informatique', 'Histoire', 'Géographie', 'Sociologie', 'Économie'],
                (value) {
                  setState(() {
                    _selectedDepartment = value;
                  });
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSimpleDropdown(
                'Filière',
                _selectedProgram,
                ['Licence Math', 'Master Info', 'Doctorat Phys', 'BTS Compta', 'Licence Chimie', 'Master Éco'],
                (value) {
                  setState(() {
                    _selectedProgram = value;
                  });
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSimpleDropdown(
                'Région',
                _selectedRegion,
                ['Centre', 'Littoral', 'Ouest', 'Nord', 'Extrême-Nord', 'Nord-Ouest', 'Sud-Ouest', 'Adamaoua', 'Est', 'Sud'],
                (value) {
                  setState(() {
                    _selectedRegion = value;
                  });
                  _applyFilters();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSimpleDropdown(
                'Groupe',
                _selectedGroup,
                ['Groupe A', 'Groupe B', 'Groupe C', 'Groupe D', 'TD1', 'TD2', 'TP1', 'TP2'],
                (value) {
                  setState(() {
                    _selectedGroup = value;
                  });
                  _applyFilters();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut de l\'étudiant',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              'Statut',
              _selectedStatus,
              _statuses.map((status) => _statusLabels[status] ?? status).toList(),
              _statuses,
              (value) {
                setState(() {
                  _selectedStatus = value;
                });
                _applyFilters();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> displayItems,
    List<String> actualValues,
    Function(String?) onChanged,
  ) {
    final displayValue = value != null && actualValues.contains(value) 
        ? displayItems[actualValues.indexOf(value)] 
        : null;

    return DropdownButtonFormField<String>(
      value: displayValue,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Tous'),
        ),
        ...displayItems.asMap().entries.map((entry) {
          final index = entry.key;
          final display = entry.value;
          final actual = actualValues[index];
          return DropdownMenuItem<String>(
            value: display,
            child: Text(display),
          );
        }),
      ],
      onChanged: (displayValue) {
        if (displayValue == null) {
          onChanged(null);
        } else {
          final index = displayItems.indexOf(displayValue);
          if (index >= 0 && index < actualValues.length) {
            onChanged(actualValues[index]);
          }
        }
      },
    );
  }

  Widget _buildSimpleDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Tous'),
        ),
        ...items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }),
      ],
      onChanged: onChanged,
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filtres appliqués: ${_getActiveFiltersCount()}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Row(
          children: [
            OutlinedButton(
              onPressed: widget.onReset,
              child: const Text('Effacer'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _applyFilters,
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ],
    );
  }

  void _applyFilters() {
    final newFilters = StudentFilters(
      search: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      level: _selectedLevel,
      status: _selectedStatus,
      institution: _selectedInstitution,
      faculty: _selectedFaculty,
      department: _selectedDepartment,
      program: _selectedProgram,
      region: _selectedRegion,
      group: _selectedGroup,
      page: 1, // Reset to first page when applying filters
      limit: widget.filters.limit,
    );

    widget.onFiltersChanged(newFilters);
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (_searchController.text.trim().isNotEmpty) count++;
    if (_selectedLevel != null) count++;
    if (_selectedStatus != null) count++;
    if (_selectedInstitution != null) count++;
    if (_selectedFaculty != null) count++;
    if (_selectedDepartment != null) count++;
    if (_selectedProgram != null) count++;
    if (_selectedRegion != null) count++;
    if (_selectedGroup != null) count++;
    return count;
  }
}
