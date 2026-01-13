import 'package:flutter/material.dart';
import 'package:mycampus/features/preinscription_validation/models/preinscription_validation_model.dart';

class PreinscriptionDetailPage extends StatelessWidget {
  final PreinscriptionValidationModel preinscription;

  const PreinscriptionDetailPage({
    super.key,
    required this.preinscription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '${preinscription.firstName} ${preinscription.lastName}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => _editPreinscription(context),
            tooltip: 'Modifier',
          ),
          IconButton(
            icon: const Icon(Icons.print_rounded),
            onPressed: () => _printPreinscription(context),
            tooltip: 'Imprimer',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec statut
            _buildHeader(context),
            
            const SizedBox(height: 24),
            
            // Informations personnelles
            _buildPersonalInfo(context),
            
            const SizedBox(height: 24),
            
            // Informations académiques
            _buildAcademicInfo(context),
            
            const SizedBox(height: 24),
            
            // Informations de contact
            _buildContactInfo(context),
            
            const SizedBox(height: 24),
            
            // Informations de paiement
            _buildPaymentInfo(context),
            
            const SizedBox(height: 24),
            
            // Documents
            _buildDocumentsInfo(context),
            
            const SizedBox(height: 24),
            
            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                child: Text(
                  preinscription.firstName.isNotEmpty
                      ? preinscription.firstName[0].toUpperCase()
                      : preinscription.lastName[0].toUpperCase(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${preinscription.firstName} ${preinscription.lastName}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      preinscription.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusText(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.qr_code,
                color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Code: ${preinscription.uniqueCode}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context) {
    return _buildSection(
      context,
      'Informations personnelles',
      Icons.person_rounded,
      [
        _buildInfoRow('Nom complet', '${preinscription.firstName} ${preinscription.lastName}'),
        _buildInfoRow('Nom', preinscription.lastName),
        _buildInfoRow('Prénom', preinscription.firstName),
        if (preinscription.middleName != null)
          _buildInfoRow('Post-nom', preinscription.middleName!),
        _buildInfoRow('Date de naissance', preinscription.dateOfBirth),
        _buildInfoRow('Lieu de naissance', preinscription.placeOfBirth),
        _buildInfoRow('Sexe', preinscription.gender),
        if (preinscription.cniNumber != null)
          _buildInfoRow('Numéro CNI', preinscription.cniNumber!),
        _buildInfoRow('Situation matrimoniale', preinscription.maritalStatus),
        _buildInfoRow('Adresse', preinscription.residenceAddress),
        _buildInfoRow('Première langue', preinscription.firstLanguage),
        _buildInfoRow('Situation professionnelle', preinscription.professionalSituation),
      ],
    );
  }

  Widget _buildAcademicInfo(BuildContext context) {
    return _buildSection(
      context,
      'Informations académiques',
      Icons.school_rounded,
      [
        _buildInfoRow('Faculté', preinscription.faculty),
        if (preinscription.desiredProgram != null)
          _buildInfoRow('Programme souhaité', preinscription.desiredProgram!),
        if (preinscription.studyLevel != null)
          _buildInfoRow('Niveau d\'étude', preinscription.studyLevel!),
        if (preinscription.specialization != null)
          _buildInfoRow('Spécialisation', preinscription.specialization!),
        if (preinscription.previousDiploma != null)
          _buildInfoRow('Diplôme précédent', preinscription.previousDiploma!),
        if (preinscription.previousInstitution != null)
          _buildInfoRow('Institution précédente', preinscription.previousInstitution!),
        if (preinscription.graduationYear != null)
          _buildInfoRow('Année d\'obtention', preinscription.graduationYear.toString()),
        if (preinscription.seriesBac != null)
          _buildInfoRow('Série Bac', preinscription.seriesBac!),
        if (preinscription.bacYear != null)
          _buildInfoRow('Année Bac', preinscription.bacYear.toString()),
        if (preinscription.gpaScore != null)
          _buildInfoRow('Moyenne', preinscription.gpaScore.toString()),
      ],
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return _buildSection(
      context,
      'Informations de contact',
      Icons.contact_phone_rounded,
      [
        _buildInfoRow('Email', preinscription.email),
        _buildInfoRow('Téléphone', preinscription.phoneNumber),
        if (preinscription.parentName != null)
          _buildInfoRow('Nom du parent', preinscription.parentName!),
        if (preinscription.parentPhone != null)
          _buildInfoRow('Téléphone parent', preinscription.parentPhone!),
        if (preinscription.parentEmail != null)
          _buildInfoRow('Email parent', preinscription.parentEmail!),
        if (preinscription.parentOccupation != null)
          _buildInfoRow('Profession parent', preinscription.parentOccupation!),
      ],
    );
  }

  Widget _buildPaymentInfo(BuildContext context) {
    return _buildSection(
      context,
      'Informations de paiement',
      Icons.payment_rounded,
      [
        _buildInfoRow('Méthode de paiement', preinscription.paymentMethod),
        if (preinscription.paymentReference != null)
          _buildInfoRow('Référence paiement', preinscription.paymentReference!),
        if (preinscription.paymentAmount != null)
          _buildInfoRow('Montant', '${preinscription.paymentAmount} ${preinscription.paymentCurrency}'),
        _buildInfoRow('Statut paiement', _getPaymentStatusText()),
        if (preinscription.paymentDate != null)
          _buildInfoRow('Date paiement', preinscription.paymentDate!),
        _buildInfoRow('Bourse demandée', preinscription.scholarshipRequested ? 'Oui' : 'Non'),
        if (preinscription.scholarshipType != null)
          _buildInfoRow('Type bourse', preinscription.scholarshipType!),
      ],
    );
  }

  Widget _buildDocumentsInfo(BuildContext context) {
    final documents = [
      if (preinscription.birthCertificatePath != null) 'Certificat de naissance',
      if (preinscription.cniPath != null) 'CNI',
      if (preinscription.diplomaPath != null) 'Diplôme',
      if (preinscription.transcriptPath != null) 'Relevé de notes',
      if (preinscription.photoPath != null) 'Photo',
      if (preinscription.paymentProofPath != null) 'Preuve de paiement',
    ];

    return _buildSection(
      context,
      'Documents',
      Icons.folder_rounded,
      documents.isEmpty
          ? [_buildInfoRow('Documents', 'Aucun document téléchargé')]
          : documents.map((doc) => _buildInfoRow('Document', doc)).toList(),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _validatePreinscription(context),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Valider'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _rejectPreinscription(context),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Rejeter'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getStatusText() {
    switch (preinscription.status) {
      case 'pending':
        return 'En attente';
      case 'under_review':
        return 'En examen';
      case 'accepted':
        return 'Acceptée';
      case 'rejected':
        return 'Rejetée';
      case 'waitlisted':
        return 'Liste d\'attente';
      default:
        return 'Inconnu';
    }
  }

  String _getPaymentStatusText() {
    switch (preinscription.paymentStatus) {
      case 'paid':
        return 'Payé';
      case 'confirmed':
        return 'Confirmé';
      case 'pending':
        return 'En attente';
      case 'failed':
        return 'Échec';
      default:
        return preinscription.paymentStatus;
    }
  }

  void _editPreinscription(BuildContext context) {
    // TODO: Implémenter l'édition
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité d\'édition bientôt disponible')),
    );
  }

  void _printPreinscription(BuildContext context) {
    // TODO: Implémenter l'impression
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité d\'impression bientôt disponible')),
    );
  }

  void _validatePreinscription(BuildContext context) {
    // TODO: Implémenter la validation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Validation en cours...')),
    );
  }

  void _rejectPreinscription(BuildContext context) {
    // TODO: Implémenter le rejet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rejet en cours...')),
    );
  }
}
