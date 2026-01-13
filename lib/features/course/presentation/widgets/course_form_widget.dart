import 'package:flutter/material.dart';
import '../../domain/models/course_model.dart';

class CourseFormWidget extends StatefulWidget {
  final CourseModel? course;
  final Function(CourseModel) onSubmit;
  final String? initialProgramId;
  final String? initialProgramName;

  const CourseFormWidget({
    super.key,
    this.course,
    required this.onSubmit,
    this.initialProgramId,
    this.initialProgramName,
  });

  @override
  State<CourseFormWidget> createState() => _CourseFormWidgetState();
}

class _CourseFormWidgetState extends State<CourseFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _shortNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _creditsController = TextEditingController();
  final _instructorController = TextEditingController();
  final _instructorEmailController = TextEditingController();
  final _instructorPhoneController = TextEditingController();

  String? _selectedProgramId;
  CourseLevel _selectedLevel = CourseLevel.undergraduate;
  CourseSemester _selectedSemester = CourseSemester.S1;
  CourseStatus _selectedStatus = CourseStatus.active;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.initialProgramId != null) {
      _selectedProgramId = widget.initialProgramId;
    }
    
    if (widget.course != null) {
      _populateForm();
    } else {
      _creditsController.text = '3';
    }
  }

  void _populateForm() {
    final course = widget.course!;
    _codeController.text = course.code;
    _nameController.text = course.name;
    _shortNameController.text = course.shortName;
    _descriptionController.text = course.description ?? '';
    _creditsController.text = course.credits.toString();
    _instructorController.text = course.instructor ?? '';
    _instructorEmailController.text = course.instructorEmail ?? '';
    _instructorPhoneController.text = course.instructorPhone ?? '';
    _selectedProgramId = course.programId;
    _selectedLevel = course.level;
    _selectedSemester = course.semester;
    _selectedStatus = course.status;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _shortNameController.dispose();
    _descriptionController.dispose();
    _creditsController.dispose();
    _instructorController.dispose();
    _instructorEmailController.dispose();
    _instructorPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedProgramId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un programme')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credits = int.tryParse(_creditsController.text) ?? 3;
      if (credits < 1 || credits > 10) {
        throw Exception('Le nombre de crédits doit être entre 1 et 10');
      }

      final course = CourseModel(
        id: widget.course?.id ?? '',
        uuid: widget.course?.uuid ?? '',
        programId: _selectedProgramId!,
        code: _codeController.text.trim(),
        name: _nameController.text.trim(),
        shortName: _shortNameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        credits: credits,
        semester: _selectedSemester,
        level: _selectedLevel,
        instructor: _instructorController.text.trim().isEmpty 
            ? null 
            : _instructorController.text.trim(),
        instructorEmail: _instructorEmailController.text.trim().isEmpty 
            ? null 
            : _instructorEmailController.text.trim(),
        instructorPhone: _instructorPhoneController.text.trim().isEmpty 
            ? null 
            : _instructorPhoneController.text.trim(),
        status: _selectedStatus,
        createdAt: widget.course?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      widget.onSubmit(course);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.course == null 
                  ? 'Cours créé avec succès' 
                  : 'Cours mis à jour avec succès',
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
          widget.course == null ? 'Nouveau cours' : 'Modifier le cours',
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
              
              if (widget.initialProgramId == null) ...[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'ID du programme *',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _selectedProgramId,
                  onChanged: (value) {
                    _selectedProgramId = value.trim().isEmpty ? null : value.trim();
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'L\'ID du programme est requis';
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
                          'Programme: ${widget.initialProgramName ?? widget.initialProgramId}',
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
              
              TextFormField(
                controller: _creditsController,
                decoration: const InputDecoration(
                  labelText: 'Crédits *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nombre de crédits est requis';
                  }
                  final credits = int.tryParse(value);
                  if (credits == null || credits < 1 || credits > 10) {
                    return 'Le nombre de crédits doit être entre 1 et 10';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<CourseLevel>(
                      value: _selectedLevel,
                      decoration: const InputDecoration(
                        labelText: 'Niveau *',
                        border: OutlineInputBorder(),
                      ),
                      items: CourseLevel.values.map((level) {
                        return DropdownMenuItem<CourseLevel>(
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<CourseSemester>(
                      value: _selectedSemester,
                      decoration: const InputDecoration(
                        labelText: 'Semestre *',
                        border: OutlineInputBorder(),
                      ),
                      items: CourseSemester.values.map((semester) {
                        return DropdownMenuItem<CourseSemester>(
                          value: semester,
                          child: Text(semester.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSemester = value!;
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
              
              // Enseignant
              _buildSectionTitle('Enseignant'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _instructorController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'enseignant',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _instructorEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email de l\'enseignant',
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
                controller: _instructorPhoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone de l\'enseignant',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              
              // Statut
              _buildSectionTitle('Statut'),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<CourseStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
                items: CourseStatus.values.map((status) {
                  return DropdownMenuItem<CourseStatus>(
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
