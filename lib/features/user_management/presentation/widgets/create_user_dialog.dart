import 'package:flutter/material.dart';

class CreateUserDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const CreateUserDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _matriculeController = TextEditingController();
  
  String _selectedRole = 'student';
  String _selectedStatus = 'pending_verification';
  int _selectedInstitution = 1; // Default institution
  bool _isLoading = false;

  final List<String> _roles = [
    'student',
    'teacher',
    'staff',
    'moderator',
    'leader',
    'admin_local',
    'admin_national',
    'superadmin',
  ];

  final List<Map<String, dynamic>> _institutions = [
    {'id': 1, 'name': 'Université de Yaoundé I'},
    {'id': 2, 'name': 'Université de Douala'},
    {'id': 3, 'name': 'Université de Dschang'},
    {'id': 4, 'name': 'Université de Buéa'},
  ];

  final List<String> _statuses = [
    'active',
    'inactive',
    'pending_verification',
    'suspended',
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _matriculeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person_add,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Créer un nouvel utilisateur',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Form
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionHeader('Informations de base'),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'Prénom *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Le prénom est requis';
                                }
                                if (value.length < 2) {
                                  return 'Le prénom doit contenir au moins 2 caractères';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Nom *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Le nom est requis';
                                }
                                if (value.length < 2) {
                                  return 'Le nom doit contenir au moins 2 caractères';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'email est requis';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Veuillez entrer un email valide';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Téléphone',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.phone),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value != null && value.isNotEmpty && value.length < 8) {
                                  return 'Le numéro de téléphone doit contenir au moins 8 chiffres';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _matriculeController,
                              decoration: const InputDecoration(
                                labelText: 'Matricule',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.badge),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty && value.length < 3) {
                                  return 'Le matricule doit contenir au moins 3 caractères';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Account Information Section
                      _buildSectionHeader('Informations du compte'),
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedRole,
                              decoration: const InputDecoration(
                                labelText: 'Rôle *',
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
                                  _selectedRole = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Statut *',
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
                                  _selectedStatus = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 12),
                      
                      DropdownButtonFormField<int>(
                        value: _selectedInstitution,
                        decoration: const InputDecoration(
                          labelText: 'Institution *',
                          border: OutlineInputBorder(),
                        ),
                        items: _institutions.map((institution) {
                          return DropdownMenuItem<int>(
                            value: institution['id'],
                            child: Text(institution['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedInstitution = value!;
                          });
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Password Section
                      _buildSectionHeader('Mot de passe'),
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Mot de passe *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Le mot de passe est requis';
                          }
                          if (value.length < 8) {
                            return 'Le mot de passe doit contenir au moins 8 caractères';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: const InputDecoration(
                          labelText: 'Confirmer le mot de passe *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'La confirmation du mot de passe est requise';
                          }
                          if (value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Créer l\'utilisateur'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final userData = {
      'email': _emailController.text.trim(),
      'first_name': _firstNameController.text.trim(),
      'last_name': _lastNameController.text.trim(),
      'password': _passwordController.text,
      'primary_role': _selectedRole,
      'account_status': _selectedStatus,
      'institution_id': _selectedInstitution,
      'phone': _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      'matricule': _matriculeController.text.trim().isEmpty ? null : _matriculeController.text.trim(),
    };

    await widget.onSubmit(userData);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'superadmin':
        return 'Super Administrateur';
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
      case 'active':
        return 'Actif';
      case 'inactive':
        return 'Inactif';
      case 'suspended':
        return 'Suspendu';
      case 'banned':
        return 'Banni';
      case 'pending_verification':
        return 'En attente de vérification';
      case 'graduated':
        return 'Diplômé';
      case 'withdrawn':
        return 'Retiré';
      default:
        return status;
    }
  }
}
