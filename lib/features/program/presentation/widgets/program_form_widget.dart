import 'package:flutter/material.dart';
import '../../domain/models/program_model.dart';

class ProgramFormWidget extends StatefulWidget {
  final ProgramModel? program;
  final Function(ProgramModel) onSubmit;
  final String? initialDepartmentId;
  final String? initialDepartmentName;

  const ProgramFormWidget({
    super.key,
    this.program,
    required this.onSubmit,
    this.initialDepartmentId,
    this.initialDepartmentName,
  });

  @override
  State<ProgramFormWidget> createState() => _ProgramFormWidgetState();
}

class _ProgramFormWidgetState extends State<ProgramFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _admissionRequirementsController = TextEditingController();
  final _careerProspectsController = TextEditingController();

  String? _selectedDepartmentId;
  DegreeLevel _selectedDegreeLevel = DegreeLevel.licence1;
  int _durationYears = 3;
  ProgramStatus _selectedStatus = ProgramStatus.active;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.initialDepartmentId != null) {
      _selectedDepartmentId = widget.initialDepartmentId;
    }
    
    if (widget.program != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final program = widget.program!;
    _codeController.text = program.code;
    _nameController.text = program.name;
    _shortNameController.text = program.shortName;
    _descriptionController.text = program.description ?? '';
    _admissionRequirementsController.text = program.admissionRequirements ?? '';
    _careerProspectsController.text = program.careerProspects ?? '';
    _selectedDepartmentId = program.departmentId;
    _selectedDegreeLevel = program.degreeLevel;
    _durationYears = program.durationYears;
    _selectedStatus = program.status;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _shortNameController.dispose();
    _descriptionController.dispose();
    _admissionRequirementsController.dispose();
    _careerProspectsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un département')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final program = ProgramModel(
        id: widget.program?.id ?? '',
        departmentId: _selectedDepartmentId!,
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        shortName: _shortNameController.text.trim(),
        degreeLevel: _selectedDegreeLevel,
        durationYears: _durationYears,
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        admissionRequirements: _admissionRequirementsController.text.trim().isEmpty 
            ? null 
            : _admissionRequirementsController.text.trim(),
        careerProspects: _careerProspectsController.text.trim().isEmpty 
            ? null 
            : _careerProspectsController.text.trim(),
        status: _selectedStatus,
        createdAt: widget.program?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSubmit(program);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.program == null 
                  ? 'Filière créée avec succès' 
                  : 'Filière mise à jour avec succès',
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
          widget.program == null ? 'Nouvelle filière' : 'Modifier la filière',
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
              
              if (widget.initialDepartmentId == null) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'ID du département *',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedDepartmentId,
                  onChanged: (value) {
                    _selectedDepartmentId = value.trim().isEmpty ? null : value.trim();
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'ID du département est requis';
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
                          'Département: ${widget.initialDepartmentName ?? widget.initialDepartmentId}',
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
              
              DropdownButtonFormField<DegreeLevel>(
                value: _selectedDegreeLevel,
                decoration: const InputDecoration(
                  labelText: 'Niveau de diplôme *',
                  border: OutlineInputBorder(),
                ),
                items: DegreeLevel.values.map((level) {
                  return DropdownMenuItem<DegreeLevel>(
                    value: level,
                    child: Text(level.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDegreeLevel = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _durationYears,
                      decoration: const InputDecoration(
                        labelText: 'Durée (années) *',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(10, (index) => index + 1).map((years) {
                        return DropdownMenuItem<int>(
                          value: years,
                          child: Text('$years an${years > 1 ? 's' : ''}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _durationYears = value!;
                        });
                      },
                    ),
                  ),
                ],
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
              
              // Admission
              _buildSectionTitle('Admission'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _admissionRequirementsController,
                decoration: const InputDecoration(
                  labelText: 'Conditions d\'admission',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Carrière
              _buildSectionTitle('Carrière'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _careerProspectsController,
                decoration: const InputDecoration(
                  labelText: 'Perspectives de carrière',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              
              // Statut
              _buildSectionTitle('Statut'),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<ProgramStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: ProgramStatus.values.map((status) {
                  return DropdownMenuItem<ProgramStatus>(
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
