import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../providers/preinscription_provider.dart';
import '../../models/preinscription_model.dart';

class PreinscriptionValidationPage extends StatefulWidget {
  final PreinscriptionModel preinscription;

  const PreinscriptionValidationPage({
    super.key,
    required this.preinscription,
  });

  @override
  State<PreinscriptionValidationPage> createState() => _PreinscriptionValidationPageState();
}

class _PreinscriptionValidationPageState extends State<PreinscriptionValidationPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentsController = TextEditingController();
  final _rejectionReasonController = TextEditingController();
  final _admissionNumberController = TextEditingController();
  final _adminNotesController = TextEditingController();
  
  String _selectedStatus = 'pending';
  String _selectedDocumentsStatus = 'pending';
  String _selectedPriority = 'NORMAL';
  bool _interviewRequired = false;
  final _interviewDateController = TextEditingController();
  final _interviewLocationController = TextEditingController();
  String _selectedInterviewType = 'PHYSICAL';
  final _interviewNotesController = TextEditingController();
  
  bool _isLoading = false;
  bool _showRejectionReason = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void dispose() {
    _commentsController.dispose();
    _rejectionReasonController.dispose();
    _admissionNumberController.dispose();
    _adminNotesController.dispose();
    _interviewDateController.dispose();
    _interviewLocationController.dispose();
    _interviewNotesController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    _selectedStatus = widget.preinscription.status;
    _selectedDocumentsStatus = widget.preinscription.documentsStatus;
    _selectedPriority = widget.preinscription.reviewPriority;
    _interviewRequired = widget.preinscription.interviewRequired;
    
    _commentsController.text = widget.preinscription.reviewComments ?? '';
    _rejectionReasonController.text = widget.preinscription.rejectionReason ?? '';
    _admissionNumberController.text = widget.preinscription.admissionNumber ?? '';
    _adminNotesController.text = widget.preinscription.adminNotes ?? '';
    _interviewDateController.text = widget.preinscription.interviewDate != null 
        ? '${widget.preinscription.interviewDate!.day}/${widget.preinscription.interviewDate!.month}/${widget.preinscription.interviewDate!.year}'
        : '';
    _interviewLocationController.text = widget.preinscription.interviewLocation ?? '';
    _selectedInterviewType = widget.preinscription.interviewType ?? 'PHYSICAL';
    _interviewNotesController.text = widget.preinscription.interviewNotes ?? '';
    
    _showRejectionReason = _selectedStatus == 'rejected';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Validation - ${widget.preinscription.firstName} ${widget.preinscription.lastName}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveValidation,
            tooltip: 'Sauvegarder',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildApplicantSummary(),
                    const SizedBox(height: 24),
                    _buildValidationSection(),
                    const SizedBox(height: 24),
                    _buildDocumentsSection(),
                    const SizedBox(height: 24),
                    _buildInterviewSection(),
                    const SizedBox(height: 24),
                    _buildAdmissionSection(),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                    const SizedBox(height: 32),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildApplicantSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations du Candidat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nom: ${widget.preinscription.lastName}'),
                      Text('Prénom: ${widget.preinscription.firstName}'),
                      Text('Email: ${widget.preinscription.email}'),
                      Text('Téléphone: ${widget.preinscription.phoneNumber}'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${widget.preinscription.uniqueCode ?? "N/A"}'),
                      Text('Faculté: ${widget.preinscription.faculty}'),
                      Text('Programme: ${widget.preinscription.desiredProgram ?? "Non spécifié"}'),
                      Text('Soumission: ${_formatDate(widget.preinscription.submissionDate)}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Décision de Validation',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Statut de la préinscription',
                border: OutlineInputBorder(),
              ),
              items: PreinscriptionConstants.statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                  _showRejectionReason = value == 'rejected';
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            if (_showRejectionReason) ...[
              TextFormField(
                controller: _rejectionReasonController,
                decoration: const InputDecoration(
                  labelText: 'Raison du rejet',
                  border: OutlineInputBorder(),
                  hintText: 'Expliquez pourquoi cette préinscription est rejetée',
                ),
                maxLines: 3,
                validator: (value) {
                  if (_showRejectionReason && (value == null || value.isEmpty)) {
                    return 'La raison du rejet est obligatoire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],
            
            TextFormField(
              controller: _commentsController,
              decoration: const InputDecoration(
                labelText: 'Commentaires de révision',
                border: OutlineInputBorder(),
                hintText: 'Ajoutez vos commentaires sur cette préinscription',
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              initialValue: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priorité de révision',
                border: OutlineInputBorder(),
              ),
              items: PreinscriptionConstants.reviewPriorities.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Validation des Documents',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              initialValue: _selectedDocumentsStatus,
              decoration: const InputDecoration(
                labelText: 'Statut des documents',
                border: OutlineInputBorder(),
              ),
              items: PreinscriptionConstants.documentsStatuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getDocumentsStatusText(status)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDocumentsStatus = value!;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            _buildDocumentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsList() {
    final documents = [
      {'name': 'Acte de naissance', 'path': widget.preinscription.birthCertificatePath},
      {'name': 'CNI', 'path': widget.preinscription.cniPath},
      {'name': 'Diplôme', 'path': widget.preinscription.diplomaPath},
      {'name': 'Relevé de notes', 'path': widget.preinscription.transcriptPath},
      {'name': 'Photo', 'path': widget.preinscription.photoPath},
      {'name': 'Lettre de motivation', 'path': widget.preinscription.motivationLetterPath},
      {'name': 'Preuve de paiement', 'path': widget.preinscription.paymentProofPath},
    ];

    return Column(
      children: documents.map((doc) {
        final hasDocument = doc['path'] != null;
        return CheckboxListTile(
          title: Text(doc['name'] as String),
          subtitle: hasDocument ? Text(doc['path'] as String) : const Text('Non soumis'),
          value: hasDocument,
          onChanged: null, // Read-only for now
          controlAffinity: ListTileControlAffinity.leading,
        );
      }).toList(),
    );
  }

  Widget _buildInterviewSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Entretien',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Entretien requis'),
              subtitle: const Text('Cochez si un entretien est nécessaire'),
              value: _interviewRequired,
              onChanged: (value) {
                setState(() {
                  _interviewRequired = value;
                });
              },
            ),
            
            if (_interviewRequired) ...[
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _interviewDateController,
                decoration: const InputDecoration(
                  labelText: 'Date de l\'entretien (JJ/MM/AAAA)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_interviewRequired && (value == null || value.isEmpty)) {
                    return 'La date est requise';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _interviewLocationController,
                decoration: const InputDecoration(
                  labelText: 'Lieu de l\'entretien',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_interviewRequired && (value == null || value.isEmpty)) {
                    return 'Le lieu est requis';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                initialValue: _selectedInterviewType,
                decoration: const InputDecoration(
                  labelText: 'Type d\'entretien',
                  border: OutlineInputBorder(),
                ),
                items: PreinscriptionConstants.interviewTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getInterviewTypeText(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedInterviewType = value!;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _interviewNotesController,
                decoration: const InputDecoration(
                  labelText: 'Notes d\'entretien',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdmissionSection() {
    if (_selectedStatus != 'accepted') return const SizedBox.shrink();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations d\'Admission',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _admissionNumberController,
              decoration: const InputDecoration(
                labelText: 'Numéro d\'admission',
                border: OutlineInputBorder(),
                hintText: 'Générez ou entrez un numéro d\'admission unique',
              ),
              validator: (value) {
                if (_selectedStatus == 'accepted' && (value == null || value.isEmpty)) {
                  return 'Le numéro d\'admission est requis pour une admission acceptée';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notes Administratives',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _adminNotesController,
              decoration: const InputDecoration(
                labelText: 'Notes administratives',
                border: OutlineInputBorder(),
                hintText: 'Notes internes pour l\'administration',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveValidation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Sauvegarder la validation'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Annuler'),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        if (_selectedStatus == 'accepted') ...[
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _generateAdmissionNumber,
            icon: const Icon(Icons.assignment),
            label: const Text('Générer numéro d\'admission'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _saveValidation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<PreinscriptionProvider>();
      
      final updatedPreinscription = widget.preinscription.copyWith(
        status: _selectedStatus,
        documentsStatus: _selectedDocumentsStatus,
        reviewPriority: _selectedPriority,
        reviewComments: _commentsController.text.isEmpty ? null : _commentsController.text,
        rejectionReason: _rejectionReasonController.text.isEmpty ? null : _rejectionReasonController.text,
        admissionNumber: _admissionNumberController.text.isEmpty ? null : _admissionNumberController.text,
        adminNotes: _adminNotesController.text.isEmpty ? null : _adminNotesController.text,
        interviewRequired: _interviewRequired,
        interviewDate: _interviewDateController.text.isEmpty 
            ? null 
            : _parseDate(_interviewDateController.text),
        interviewLocation: _interviewLocationController.text.isEmpty ? null : _interviewLocationController.text,
        interviewType: _selectedInterviewType,
        interviewNotes: _interviewNotesController.text.isEmpty ? null : _interviewNotesController.text,
        lastUpdated: DateTime.now(),
      );

      await provider.updatePreinscription(widget.preinscription.id!, updatedPreinscription);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Préinscription ${_selectedStatus == 'accepted' ? 'acceptée' : _selectedStatus == 'rejected' ? 'rejetée' : 'mise à jour'} avec succès'),
            backgroundColor: _selectedStatus == 'accepted' ? Colors.green : Colors.blue,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _generateAdmissionNumber() {
    final year = DateTime.now().year;
    final faculty = widget.preinscription.faculty.substring(0, 3).toUpperCase();
    final random = DateTime.now().millisecondsSinceEpoch % 10000;
    final admissionNumber = '$year-$faculty-$random';
    
    setState(() {
      _admissionNumberController.text = admissionNumber;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Numéro d\'admission généré'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  DateTime? _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
    } catch (e) {
      if (kDebugMode) print('Error parsing date: $e');
    }
    return null;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'under_review':
        return 'En cours de révision';
      case 'accepted':
        return 'Accepté(e)';
      case 'rejected':
        return 'Rejeté(e)';
      case 'cancelled':
        return 'Annulé(e)';
      case 'deferred':
        return 'Reporté(e)';
      case 'waitlisted':
        return 'Liste d\'attente';
      default:
        return status;
    }
  }

  String _getDocumentsStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'submitted':
        return 'Soumis';
      case 'verified':
        return 'Vérifiés';
      case 'incomplete':
        return 'Incomplets';
      case 'rejected':
        return 'Rejetés';
      default:
        return status;
    }
  }

  String _getInterviewTypeText(String type) {
    switch (type) {
      case 'PHYSICAL':
        return 'Physique';
      case 'ONLINE':
        return 'En ligne';
      case 'PHONE':
        return 'Téléphonique';
      default:
        return type;
    }
  }
}