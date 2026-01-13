import 'package:flutter/material.dart';
import '../../domain/models/department_model.dart';

class DepartmentFormWidget extends StatefulWidget {
  final DepartmentModel? department;
  final Function(DepartmentModel) onSubmit;
  final String? initialFacultyId;
  final String? initialFacultyName;

  const DepartmentFormWidget({
    super.key,
    this.department,
    required this.onSubmit,
    this.initialFacultyId,
    this.initialFacultyName,
  });

  @override
  State<DepartmentFormWidget> createState() => _DepartmentFormWidgetState();
}

class _DepartmentFormWidgetState extends State<DepartmentFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _headOfDepartmentController = TextEditingController();
  final _hodEmailController = TextEditingController();
  final _hodPhoneController = TextEditingController();

  String? _selectedFacultyId;
  DepartmentLevel _selectedLevel = DepartmentLevel.undergraduate;
  DepartmentStatus _selectedStatus = DepartmentStatus.active;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.initialFacultyId != null) {
      _selectedFacultyId = widget.initialFacultyId;
    }
    
    if (widget.department != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final department = widget.department!;
    _codeController.text = department.code;
    _nameController.text = department.name;
    _shortNameController.text = department.shortName;
    _descriptionController.text = department.description ?? '';
    _headOfDepartmentController.text = department.headOfDepartment ?? '';
    _hodEmailController.text = department.hodEmail ?? '';
    _hodPhoneController.text = department.hodPhone ?? '';
    _selectedFacultyId = department.facultyId;
    _selectedLevel = department.level;
    _selectedStatus = department.status;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _shortNameController.dispose();
    _descriptionController.dispose();
    _headOfDepartmentController.dispose();
    _hodEmailController.dispose();
    _hodPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedFacultyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner une faculté')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final department = DepartmentModel(
        id: widget.department?.id ?? '',
        uuid: widget.department?.uuid ?? '',
        facultyId: _selectedFacultyId!,
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        shortName: _shortNameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        headOfDepartment: _headOfDepartmentController.text.trim().isEmpty 
            ? null 
            : _headOfDepartmentController.text.trim(),
        hodEmail: _hodEmailController.text.trim().isEmpty 
            ? null 
            : _hodEmailController.text.trim(),
        hodPhone: _hodPhoneController.text.trim().isEmpty 
            ? null 
            : _hodPhoneController.text.trim(),
        level: _selectedLevel,
        status: _selectedStatus,
        isActive: _selectedStatus == DepartmentStatus.active,
        createdAt: widget.department?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSubmit(department);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.department == null 
                  ? 'Département créé avec succès' 
                  : 'Département mis à jour avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.department == null ? 'Nouveau département' : 'Modifier le département',
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enregistrer'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations de base
              _buildSectionTitle('Informations de base'),
              const SizedBox(height: 16),
              
              if (widget.initialFacultyId == null) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'ID de la faculté *',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedFacultyId,
                  onChanged: (value) {
                    _selectedFacultyId = value.trim().isEmpty ? null : value.trim();
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'ID de la faculté est requis';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Faculté: ${widget.initialFacultyName ?? widget.initialFacultyId}',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Code *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le code est requis';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _shortNameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom court *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Le nom court est requis';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom complet *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom complet est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<DepartmentLevel>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'Niveau *',
                  border: OutlineInputBorder(),
                ),
                items: DepartmentLevel.values.map((level) {
                  return DropdownMenuItem<DepartmentLevel>(
                    value: level,
                    child: Text(level.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              
              // Description
              _buildSectionTitle('Description'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Chef de département
              _buildSectionTitle('Chef de département'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _headOfDepartmentController,
                decoration: const InputDecoration(
                  labelText: 'Nom du chef de département',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _hodEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email du chef de département',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Veuillez entrer une adresse email valide';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _hodPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone du chef de département',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              
              // Statut
              _buildSectionTitle('Statut'),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<DepartmentStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: DepartmentStatus.values.map((status) {
                  return DropdownMenuItem<DepartmentStatus>(
                    value: status,
                    child: Text(status.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
