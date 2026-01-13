import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';

class UserFiltersWidget extends StatefulWidget {
  final TextEditingController searchController;
  final Function(UserFilters) onFiltersChanged;
  final UserFilters currentFilters;

  const UserFiltersWidget({
    super.key,
    required this.searchController,
    required this.onFiltersChanged,
    required this.currentFilters,
  });

  @override
  State<UserFiltersWidget> createState() => _UserFiltersWidgetState();
}

class _UserFiltersWidgetState extends State<UserFiltersWidget> {
  String? _selectedRole;
  String? _selectedStatus;
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

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.currentFilters.role ?? 'Tous les rôles';
    _selectedStatus = widget.currentFilters.status ?? 'Tous les statuts';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        TextField(
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
        
        const SizedBox(height: 12),
        
        // Filter chips
        Row(
          children: [
            // Role filter
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Rôle',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            
            // Status filter
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
        
        const SizedBox(height: 8),
        
        // Active filters display
        _buildActiveFilters(),
      ],
    );
  }

  Widget _buildActiveFilters() {
    final List<Widget> chips = [];
    
    if (_selectedRole != null && _selectedRole != 'Tous les rôles') {
      chips.add(
        Chip(
          label: Text(_getRoleDisplayName(_selectedRole!)),
          onDeleted: () {
            setState(() {
              _selectedRole = 'Tous les rôles';
            });
            _applyFilters();
          },
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    }
    
    if (_selectedStatus != null && _selectedStatus != 'Tous les statuts') {
      chips.add(
        Chip(
          label: Text(_getStatusLabel(_selectedStatus!)),
          onDeleted: () {
            setState(() {
              _selectedStatus = 'Tous les statuts';
            });
            _applyFilters();
          },
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    }
    
    if (widget.searchController.text.isNotEmpty) {
      chips.add(
        Chip(
          label: Text('Recherche: ${widget.searchController.text}'),
          onDeleted: () {
            widget.searchController.clear();
          },
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    }
    
    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text(
          'Filtres actifs:',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: chips,
        ),
      ],
    );
  }

  void _applyFilters() {
    final filters = UserFilters(
      search: widget.searchController.text.isEmpty ? null : widget.searchController.text,
      role: _selectedRole == 'Tous les rôles' ? null : _selectedRole,
      status: _selectedStatus == 'Tous les statuts' ? null : _selectedStatus,
      page: 1, // Reset to first page when filters change
    );
    
    widget.onFiltersChanged(filters);
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
      case 'alumni':
        return 'Ancien Étudiant';
      case 'student':
        return 'Étudiant';
      case 'guest':
        return 'Invité';
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
}
