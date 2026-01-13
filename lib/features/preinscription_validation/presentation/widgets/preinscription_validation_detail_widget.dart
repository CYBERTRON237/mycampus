import 'package:flutter/material.dart';
import 'package:mycampus/features/preinscription_validation/models/preinscription_validation_model.dart';

class PreinscriptionValidationDetailWidget extends StatelessWidget {
  final PreinscriptionValidationModel preinscription;
  final Function(String) onValidate;
  final Function(String) onReject;

  const PreinscriptionValidationDetailWidget({
    super.key,
    required this.preinscription,
    required this.onValidate,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
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
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Text(
                      preinscription.firstName.isNotEmpty && preinscription.lastName.isNotEmpty
                          ? '${preinscription.firstName[0]}${preinscription.lastName[0]}'.toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preinscription.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          preinscription.email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statuts
                    _buildStatusSection(context),
                    const SizedBox(height: 16),
                    
                    // Informations personnelles
                    _buildPersonalInfoSection(context),
                    const SizedBox(height: 16),
                    
                    // Informations académiques
                    _buildAcademicInfoSection(context),
                    const SizedBox(height: 16),
                    
                    // Informations de paiement
                    _buildPaymentInfoSection(context),
                    const SizedBox(height: 16),
                    
                    // Documents
                    _buildDocumentsSection(context),
                    const SizedBox(height: 16),
                    
                    // Informations sur le compte utilisateur
                    if (preinscription.hasUserAccount)
                      _buildUserAccountSection(context),
                  ],
                ),
              ),
            ),
            
            // Actions
            if (preinscription.canBeValidated)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showRejectDialog(context),
                        icon: const Icon(Icons.cancel),
                        label: const Text('Rejeter'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showValidateDialog(context),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Valider'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statuts',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    context,
                    'Statut de la préinscription',
                    preinscription.statusDisplay,
                    preinscription.status,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusItem(
                    context,
                    'Statut du paiement',
                    preinscription.paymentStatusDisplay,
                    preinscription.paymentStatus,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatusItem(
                    context,
                    'Statut des documents',
                    _getDocumentsStatusDisplay(preinscription.documentsStatus),
                    preinscription.documentsStatus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusItem(
                    context,
                    'Priorité',
                    _getPriorityDisplay(preinscription.reviewPriority),
                    preinscription.reviewPriority,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(BuildContext context, String label, String value, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _getStatusColor(status).withOpacity(0.3),
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Nom complet', preinscription.fullName),
            _buildInfoRow('Date de naissance', preinscription.dateOfBirth),
            _buildInfoRow('Lieu de naissance', preinscription.placeOfBirth),
            _buildInfoRow('Genre', preinscription.gender),
            _buildInfoRow('Téléphone', preinscription.phoneNumber),
            _buildInfoRow('Email', preinscription.email),
            _buildInfoRow('Adresse', preinscription.residenceAddress),
            _buildInfoRow('Situation maritale', preinscription.maritalStatus),
            if (preinscription.cniNumber != null)
              _buildInfoRow('Numéro CNI/PI', preinscription.cniNumber!),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations académiques',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Faculté', preinscription.facultyDisplay),
            _buildInfoRow('Programme souhaité', preinscription.desiredProgram ?? 'Non spécifié'),
            _buildInfoRow('Niveau d\'études', preinscription.studyLevel ?? 'Non spécifié'),
            _buildInfoRow('Spécialisation', preinscription.specialization ?? 'Non spécifié'),
            if (preinscription.previousDiploma != null)
              _buildInfoRow('Diplôme précédent', preinscription.previousDiploma!),
            if (preinscription.previousInstitution != null)
              _buildInfoRow('Établissement précédent', preinscription.previousInstitution!),
            if (preinscription.graduationYear != null)
              _buildInfoRow('Année d\'obtention', preinscription.graduationYear.toString()),
            if (preinscription.seriesBac != null)
              _buildInfoRow('Série du BAC', preinscription.seriesBac!),
            if (preinscription.gpaScore != null)
              _buildInfoRow('Score GPA', preinscription.gpaScore.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations de paiement',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Méthode de paiement', _getPaymentMethodDisplay(preinscription.paymentMethod)),
            if (preinscription.paymentAmount != null)
              _buildInfoRow('Montant payé', '${preinscription.paymentAmount} ${preinscription.paymentCurrency}'),
            if (preinscription.paymentReference != null)
              _buildInfoRow('Référence', preinscription.paymentReference!),
            if (preinscription.paymentDate != null)
              _buildInfoRow('Date de paiement', preinscription.paymentDate!.split('T')[0]),
            _buildInfoRow('Bourse demandée', preinscription.scholarshipRequested ? 'Oui' : 'Non'),
            if (preinscription.scholarshipType != null)
              _buildInfoRow('Type de bourse', preinscription.scholarshipType!),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Documents',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDocumentItem(context, 'Certificat de naissance', preinscription.birthCertificatePath),
            _buildDocumentItem(context, 'CNI/PI', preinscription.cniPath),
            _buildDocumentItem(context, 'Diplôme', preinscription.diplomaPath),
            _buildDocumentItem(context, 'Relevé de notes', preinscription.transcriptPath),
            _buildDocumentItem(context, 'Photo d\'identité', preinscription.photoPath),
            _buildDocumentItem(context, 'Lettre de motivation', preinscription.motivationLetterPath),
            _buildDocumentItem(context, 'Certificat médical', preinscription.medicalCertificatePath),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAccountSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compte utilisateur',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compte utilisateur existant',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rôle actuel: ${preinscription.userRole}',
                          style: TextStyle(
                            color: Colors.green[600],
                          ),
                        ),
                        if (preinscription.userId != null)
                          Text(
                            'ID Utilisateur: ${preinscription.userId}',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, String label, String? path) {
    final hasDocument = path != null && path.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            hasDocument ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: hasDocument ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: hasDocument ? Colors.black87 : Colors.grey,
                decoration: hasDocument ? TextDecoration.underline : null,
              ),
            ),
          ),
          if (hasDocument)
            Icon(
              Icons.download,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }

  void _showValidateDialog(BuildContext context) {
    final TextEditingController commentsController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Valider la préinscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir valider cette préinscription ?\n\nCela mettra à jour le rôle de l\'utilisateur en "student" et générera un numéro d\'admission.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentsController,
              decoration: const InputDecoration(
                labelText: 'Commentaires (optionnel)',
                border: OutlineInputBorder(),
                hintText: 'Ajoutez des commentaires si nécessaire...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Fermer le dialogue de détails
              onValidate(commentsController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeter la préinscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir rejeter cette préinscription ?\n\nVeuillez indiquer la raison du rejet.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Raison du rejet *',
                border: OutlineInputBorder(),
                hintText: 'Expliquez pourquoi cette préinscription est rejetée...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Fermer le dialogue de détails
                onReject(reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rejeter'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'under_review':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'deferred':
        return Colors.purple;
      case 'waitlisted':
        return Colors.teal;
      case 'paid':
      case 'confirmed':
        return Colors.green;
      case 'refunded':
        return Colors.orange;
      case 'partial':
        return Colors.blue;
      case 'HIGH':
        return Colors.red;
      case 'NORMAL':
        return Colors.blue;
      case 'LOW':
        return Colors.grey;
      case 'URGENT':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDocumentsStatusDisplay(String status) {
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

  String _getPriorityDisplay(String priority) {
    switch (priority) {
      case 'LOW':
        return 'Faible';
      case 'NORMAL':
        return 'Normal';
      case 'HIGH':
        return 'Élevé';
      case 'URGENT':
        return 'Urgent';
      default:
        return priority;
    }
  }

  String _getPaymentMethodDisplay(String method) {
    switch (method) {
      case 'ORANGE_MONEY':
        return 'Orange Money';
      case 'MTN_MONEY':
        return 'MTN Money';
      case 'BANK_TRANSFER':
        return 'Virement bancaire';
      case 'CASH':
        return 'Espèces';
      case 'MOBILE_MONEY':
        return 'Mobile Money';
      case 'CHEQUE':
        return 'Chèque';
      case 'OTHER':
        return 'Autre';
      default:
        return method;
    }
  }
}
