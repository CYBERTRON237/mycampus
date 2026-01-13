import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mycampus/features/preinscription_validation/providers/preinscription_validation_provider.dart';

class PreinscriptionValidationFiltersRedesigned extends StatefulWidget {
  final String searchQuery;
  final Function(String) onSearchChanged;

  const PreinscriptionValidationFiltersRedesigned({
    super.key,
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  State<PreinscriptionValidationFiltersRedesigned> createState() => _PreinscriptionValidationFiltersRedesignedState();
}

class _PreinscriptionValidationFiltersRedesignedState extends State<PreinscriptionValidationFiltersRedesigned>
    with SingleTickerProviderStateMixin {
  late TabController _filterTabController;
  bool _showAdvancedFilters = false;
  
  // Filtres par institution
  String _selectedInstitution = 'Toutes';
  final List<String> _institutions = [
    'Toutes',
    'Université de Yaoundé I',
    'Université de Yaoundé II', 
    'Université de Douala',
    'Université de Dschang',
    'Université de Buea',
    'Université de Maroua',
    'Université de Bamenda',
    'Université de Ngaoundéré',
  ];
  
  // Filtres par faculté
  String _selectedFaculty = 'Toutes';
  final List<String> _faculties = [
    'Toutes',
    'Faculté des Sciences',
    'Faculté des Arts, Lettres et Sciences Humaines',
    'Faculté de Médecine et Sciences Biomédicales',
    'École Nationale Supérieure Polytechnique',
    'Faculté des Sciences Juridiques et Politiques',
    'Faculté des Sciences Économiques et de Gestion',
    'Faculté de Droit et Sciences Politiques',
    'Faculté des Lettres et Sciences Humaines',
  ];
  
  // Filtres par département
  String _selectedDepartment = 'Tous';
  final List<String> _departments = [
    'Tous',
    'Département de Mathématiques',
    'Département de Physique',
    'Département de Chimie',
    'Département de Biologie',
    'Département d\'Informatique',
    'Département d\'Histoire',
    'Département de Géographie',
    'Département de Philosophie',
    'Département de Lettres Modernes',
    'Département de Droit',
    'Département de Science Politique',
    'Département d\'Économie',
    'Département de Management',
    'Génie Civil',
    'Génie Électrique',
    'Génie Informatique',
    'Génie Mécanique',
  ];
  
  // Filtres par statut
  String _selectedStatus = 'Tous';
  final List<String> _statuses = [
    'Tous',
    'pending',
    'under_review',
    'accepted',
    'rejected',
    'waitlisted',
  ];
  
  // Filtres par paiement
  String _selectedPaymentStatus = 'Tous';
  final List<String> _paymentStatuses = [
    'Tous',
    'pending',
    'paid',
    'unpaid',
    'confirmed',
    'failed',
  ];
  
  // Filtres par priorité
  String _selectedPriority = 'Toutes';
  final List<String> _priorities = [
    'Toutes',
    'high',
    'medium',
    'low',
  ];
  
  // Filtres par date
  String _selectedDateRange = 'Toutes';
  final List<String> _dateRanges = [
    'Toutes',
    'Aujourd\'hui',
    'Cette semaine',
    'Ce mois-ci',
    'Les 3 derniers mois',
    'Cette année',
  ];

  @override
  void initState() {
    super.initState();
    _filterTabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _filterTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header des filtres
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Filtres et recherche',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    setState(() => _showAdvancedFilters = !_showAdvancedFilters);
                  },
                  icon: Icon(
                    _showAdvancedFilters ? Icons.expand_less : Icons.expand_more,
                  ),
                  tooltip: 'Filtres avancés',
                ),
                IconButton(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all_rounded),
                  tooltip: 'Effacer tous les filtres',
                ),
              ],
            ),
          ),
          
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: TextEditingController(text: widget.searchQuery),
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, email, code...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: widget.searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () => widget.onSearchChanged(''),
                        icon: const Icon(Icons.clear_rounded),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              onChanged: widget.onSearchChanged,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filtres rapides
          if (!_showAdvancedFilters)
            _buildQuickFilters()
          else
            _buildAdvancedFilters(),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Institution', _selectedInstitution, (value) {
            setState(() => _selectedInstitution = value);
            _applyFilters();
          }, _institutions),
          const SizedBox(width: 12),
          _buildFilterChip('Faculté', _selectedFaculty, (value) {
            setState(() => _selectedFaculty = value);
            _applyFilters();
          }, _faculties),
          const SizedBox(width: 12),
          _buildFilterChip('Statut', _selectedStatus, (value) {
            setState(() => _selectedStatus = value);
            _applyFilters();
          }, _statuses),
          const SizedBox(width: 12),
          _buildFilterChip('Paiement', _selectedPaymentStatus, (value) {
            setState(() => _selectedPaymentStatus = value);
            _applyFilters();
          }, _paymentStatuses),
        ],
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Tabs pour les catégories de filtres
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _filterTabController,
              dividerColor: Colors.transparent,
              indicator: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              labelColor: Theme.of(context).colorScheme.onPrimary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(text: 'Académique'),
                Tab(text: 'Statut'),
                Tab(text: 'Date'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Contenu des tabs
          SizedBox(
            height: 200,
            child: TabBarView(
              controller: _filterTabController,
              children: [
                _buildAcademicFilters(),
                _buildStatusFilters(),
                _buildDateFilters(),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearAllFilters,
                  child: const Text('Réinitialiser'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Appliquer les filtres'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField('Institution', _selectedInstitution, _institutions, (value) {
          setState(() => _selectedInstitution = value);
        }),
        const SizedBox(height: 16),
        _buildDropdownField('Faculté', _selectedFaculty, _faculties, (value) {
          setState(() => _selectedFaculty = value);
        }),
        const SizedBox(height: 16),
        _buildDropdownField('Département', _selectedDepartment, _departments, (value) {
          setState(() => _selectedDepartment = value);
        }),
      ],
    );
  }

  Widget _buildStatusFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField('Statut', _selectedStatus, _statuses, (value) {
          setState(() => _selectedStatus = value);
        }),
        const SizedBox(height: 16),
        _buildDropdownField('Paiement', _selectedPaymentStatus, _paymentStatuses, (value) {
          setState(() => _selectedPaymentStatus = value);
        }),
        const SizedBox(height: 16),
        _buildDropdownField('Priorité', _selectedPriority, _priorities, (value) {
          setState(() => _selectedPriority = value);
        }),
      ],
    );
  }

  Widget _buildDateFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownField('Période', _selectedDateRange, _dateRanges, (value) {
          setState(() => _selectedDateRange = value);
        }),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectDateRange('custom'),
                child: const Text('Personnalisée'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectDateRange('recent'),
                child: const Text('Récentes'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String selectedValue, Function(String) onChanged, List<String> options) {
    return FilterChip(
      label: Text(label),
      selected: selectedValue != 'Toutes' && selectedValue != 'Tous',
      onSelected: (_) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Sélectionner $label'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options[index];
                  return ListTile(
                    title: Text(option),
                    trailing: selectedValue == option ? const Icon(Icons.check) : null,
                    onTap: () {
                      onChanged(option);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> options, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: options.map((option) {
            return DropdownMenuItem(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }

  void _applyFilters() {
    final provider = context.read<PreinscriptionValidationProvider>();
    
    // Appliquer les filtres au provider
    if (_selectedInstitution != 'Toutes') {
      // TODO: Implémenter le filtrage par institution
    }
    if (_selectedFaculty != 'Toutes') {
      provider.setFacultyFilter(_selectedFaculty);
    }
    if (_selectedStatus != 'Tous') {
      provider.setStatusFilter(_selectedStatus);
    }
    if (_selectedPaymentStatus != 'Tous') {
      provider.setPaymentStatusFilter(_selectedPaymentStatus);
    }
    
    // Rafraîchir les données
    provider.refresh();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedInstitution = 'Toutes';
      _selectedFaculty = 'Toutes';
      _selectedDepartment = 'Tous';
      _selectedStatus = 'Tous';
      _selectedPaymentStatus = 'Tous';
      _selectedPriority = 'Toutes';
      _selectedDateRange = 'Toutes';
    });
    
    final provider = context.read<PreinscriptionValidationProvider>();
    provider.clearFilters();
    widget.onSearchChanged('');
  }

  void _selectDateRange(String range) {
    setState(() => _selectedDateRange = range);
    _applyFilters();
  }
}
