import 'package:flutter/material.dart';
import '../../models/preinscription_model.dart';
import 'preinscription_validation_actions_widget.dart';
import 'validation_status_indicator_widget.dart';

class PreinscriptionDetailWidget extends StatelessWidget {
  final PreinscriptionModel preinscription;
  final VoidCallback onRefresh;
  final Function(String)? onValidationAction;

  const PreinscriptionDetailWidget({
    Key? key,
    required this.preinscription,
    required this.onRefresh,
    this.onValidationAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status cards
          _buildStatusCards(context),
          const SizedBox(height: 24.0),
          
          // Validation actions (if callback provided)
          if (onValidationAction != null) ...[
            PreinscriptionValidationActionsWidget(
              preinscription: preinscription,
              onAction: onValidationAction!,
            ),
            const SizedBox(height: 24.0),
          ],
          
          // Validation timeline
          ValidationTimelineWidget(preinscription: preinscription),
          const SizedBox(height: 24.0),
          
          // Progress indicator
          _buildSection(
            context,
            'Progression de Validation',
            Icons.trending_up,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValidationProgressBarWidget(preinscription: preinscription),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progression: ${(_calculateProgress(preinscription) * 100).toInt()}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    ValidationStatusBadgeWidget(preinscription: preinscription),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),
          
          // Personal information
          _buildSection(
            context,
            'Informations Personnelles',
            Icons.person,
            _buildPersonalInfo(),
          ),
          const SizedBox(height: 24.0),
          
          // Academic information
          _buildSection(
            context,
            'Informations Académiques',
            Icons.school,
            _buildAcademicInfo(),
          ),
          const SizedBox(height: 24.0),
          
          // Parent information
          if (preinscription.parentName != null) _buildSection(
            context,
            'Informations Parent/Tuteur',
            Icons.family_restroom,
            _buildParentInfo(),
          ),
          const SizedBox(height: 24.0),
          
          // Payment information
          _buildSection(
            context,
            'Informations de Paiement',
            Icons.payment,
            _buildPaymentInfo(),
          ),
          const SizedBox(height: 24.0),
          
          // Interview information
          if (preinscription.interviewRequired) _buildSection(
            context,
            'Informations d\'Entretien',
            Icons.calendar_today,
            _buildInterviewInfo(),
          ),
          const SizedBox(height: 24.0),
          
          // Documents
          _buildSection(
            context,
            'Documents',
            Icons.folder,
            _buildDocumentsInfo(),
          ),
          const SizedBox(height: 24.0),
          
          // Admission information
          if (preinscription.admissionNumber != null || 
              preinscription.admissionDate != null || 
              preinscription.registrationDeadline != null) _buildSection(
            context,
            'Informations d\'Admission',
            Icons.school,
            _buildAdmissionInfo(),
          ),
          const SizedBox(height: 24.0),
          
          // System information
          _buildSection(
            context,
            'Informations Système',
            Icons.computer,
            _buildSystemInfo(),
          ),
          const SizedBox(height: 24.0),
          
          // Preferences and consents
          _buildSection(
            context,
            'Préférences et Consentements',
            Icons.settings,
            _buildPreferencesInfo(),
          ),
          const SizedBox(height: 24.0),
          
          // Review information
          if (preinscription.reviewDate != null || 
              preinscription.reviewedBy != null || 
              preinscription.reviewPriority != 'NORMAL') _buildSection(
            context,
            'Informations de Révision',
            Icons.rate_review,
            _buildReviewInfo(),
          ),
          const SizedBox(height: 24.0),
          
          // Notes and comments
          if (preinscription.notes != null || 
              preinscription.adminNotes != null || 
              preinscription.reviewComments != null || 
              preinscription.internalComments != null) _buildSection(
            context,
            'Notes et Commentaires',
            Icons.note,
            _buildNotesInfo(),
          ),
          const SizedBox(height: 24.0),
          
          // Timestamps
          _buildSection(
            context,
            'Horodatages',
            Icons.schedule,
            _buildTimestampsInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatusCard(
            context,
            'Statut',
            preinscription.status,
            _getStatusColor(preinscription.status),
            _getStatusIcon(preinscription.status),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _buildStatusCard(
            context,
            'Paiement',
            preinscription.paymentStatus,
            _getPaymentStatusColor(preinscription.paymentStatus),
            _getPaymentStatusIcon(preinscription.paymentStatus),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: _buildStatusCard(
            context,
            'Documents',
            preinscription.documentsStatus,
            _getDocumentsStatusColor(preinscription.documentsStatus),
            _getDocumentsStatusIcon(preinscription.documentsStatus),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    String title,
    String status,
    Color color,
    IconData icon,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4.0),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatStatusName(status),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Widget content,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8.0),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Column(
      children: [
        _buildInfoRow('Nom complet', '${preinscription.firstName} ${preinscription.lastName}'),
        _buildInfoRow('Autre prénom', preinscription.middleName ?? ''),
        _buildInfoRow('Date de naissance', _formatDate(preinscription.dateOfBirth)),
        _buildInfoRow('Date conforme au certificat', preinscription.isBirthDateOnCertificate ? 'Oui' : 'Non'),
        _buildInfoRow('Lieu de naissance', preinscription.placeOfBirth),
        _buildInfoRow('Genre', preinscription.gender),
        _buildInfoRow('Numéro CNI/PI', preinscription.cniNumber ?? ''),
        _buildInfoRow('Adresse', preinscription.residenceAddress),
        _buildInfoRow('Situation maritale', preinscription.maritalStatus),
        _buildInfoRow('Téléphone', preinscription.phoneNumber),
        _buildInfoRow('Email', preinscription.email),
        _buildInfoRow('Première langue', preinscription.firstLanguage),
        _buildInfoRow('Situation professionnelle', preinscription.professionalSituation),
      ],
    );
  }

  Widget _buildAcademicInfo() {
    return Column(
      children: [
        _buildInfoRow('Faculté visée', preinscription.faculty),
        _buildInfoRow('Programme souhaité', preinscription.desiredProgram ?? ''),
        _buildInfoRow('Niveau d\'études', preinscription.studyLevel ?? ''),
        _buildInfoRow('Spécialisation', preinscription.specialization ?? ''),
        _buildInfoRow('Diplôme précédent', preinscription.previousDiploma ?? ''),
        _buildInfoRow('Établissement précédent', preinscription.previousInstitution ?? ''),
        _buildInfoRow('Année d\'obtention', preinscription.graduationYear?.toString() ?? ''),
        _buildInfoRow('Mois d\'obtention', preinscription.graduationMonth ?? ''),
        _buildInfoRow('Série du BAC', preinscription.seriesBac ?? ''),
        _buildInfoRow('Année du BAC', preinscription.bacYear?.toString() ?? ''),
        _buildInfoRow('Centre d\'examen BAC', preinscription.bacCenter ?? ''),
        _buildInfoRow('Mention au BAC', preinscription.bacMention ?? ''),
        _buildInfoRow('Score GPA', preinscription.gpaScore?.toString() ?? ''),
        _buildInfoRow('Rang dans la classe', preinscription.rankInClass?.toString() ?? ''),
      ],
    );
  }

  Widget _buildParentInfo() {
    return Column(
      children: [
        _buildInfoRow('Nom du parent/tuteur', preinscription.parentName ?? ''),
        _buildInfoRow('Téléphone', preinscription.parentPhone ?? ''),
        _buildInfoRow('Email', preinscription.parentEmail ?? ''),
        _buildInfoRow('Profession', preinscription.parentOccupation ?? ''),
        _buildInfoRow('Adresse', preinscription.parentAddress ?? ''),
        _buildInfoRow('Lien de parenté', preinscription.parentRelationship ?? ''),
        _buildInfoRow('Niveau de revenu', preinscription.parentIncomeLevel ?? ''),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Column(
      children: [
        _buildInfoRow('Statut de paiement', _formatPaymentStatusName(preinscription.paymentStatus)),
        _buildInfoRow('Méthode de paiement', preinscription.paymentMethod ?? ''),
        _buildInfoRow('Référence', preinscription.paymentReference ?? ''),
        _buildInfoRow('Montant', preinscription.paymentAmount != null ? '${preinscription.paymentAmount} ${preinscription.paymentCurrency}' : ''),
        _buildInfoRow('Date de paiement', preinscription.paymentDate != null ? _formatDate(preinscription.paymentDate!) : ''),
        _buildInfoRow('Bourse demandée', preinscription.scholarshipRequested ? 'Oui' : 'Non'),
        _buildInfoRow('Type de bourse', preinscription.scholarshipType ?? ''),
        _buildInfoRow('Montant aide financière', preinscription.financialAidAmount?.toString() ?? ''),
      ],
    );
  }

  Widget _buildInterviewInfo() {
    return Column(
      children: [
        _buildInfoRow('Entretien requis', preinscription.interviewRequired ? 'Oui' : 'Non'),
        _buildInfoRow('Date', preinscription.interviewDate != null ? _formatDateTime(preinscription.interviewDate!) : ''),
        _buildInfoRow('Lieu', preinscription.interviewLocation ?? ''),
        _buildInfoRow('Type', preinscription.interviewType ?? ''),
        _buildInfoRow('Résultat', preinscription.interviewResult != null ? _formatInterviewResult(preinscription.interviewResult!) : ''),
        _buildInfoRow('Notes', preinscription.interviewNotes ?? ''),
      ],
    );
  }

  Widget _buildDocumentsInfo() {
    final documents = <String, String?>{
      'Certificat de naissance': preinscription.birthCertificatePath,
      'CNI/PI': preinscription.cniPath,
      'Diplôme': preinscription.diplomaPath,
      'Relevé de notes': preinscription.transcriptPath,
      'Photo d\'identité': preinscription.photoPath,
      'Lettre de recommandation': preinscription.recommendationLetterPath,
      'Lettre de motivation': preinscription.motivationLetterPath,
      'Certificat médical': preinscription.medicalCertificatePath,
      'Preuve de paiement': preinscription.paymentProofPath,
      'Autres documents': preinscription.otherDocumentsPath,
    };

    return Column(
      children: documents.entries
          .where((entry) => entry.value != null && entry.value!.isNotEmpty)
          .map((entry) => _buildDocumentRow(entry.key, entry.value!))
          .toList(),
    );
  }

  Widget _buildAdmissionInfo() {
    return Column(
      children: [
        _buildInfoRow('Numéro d\'admission', preinscription.admissionNumber ?? ''),
        _buildInfoRow('Date d\'admission', preinscription.admissionDate != null ? _formatDateTime(preinscription.admissionDate!) : ''),
        _buildInfoRow('Date limite d\'inscription', preinscription.registrationDeadline != null ? _formatDateTime(preinscription.registrationDeadline!) : ''),
        _buildInfoRow('Inscription complétée', preinscription.registrationCompleted ? 'Oui' : 'Non'),
        _buildInfoRow('ID étudiant', preinscription.studentId ?? ''),
        _buildInfoRow('Numéro de batch', preinscription.batchNumber ?? ''),
      ],
    );
  }

  Widget _buildSystemInfo() {
    return Column(
      children: [
        _buildInfoRow('Adresse IP', preinscription.ipAddress ?? ''),
        _buildInfoRow('User Agent', preinscription.userAgent ?? ''),
        _buildInfoRow('Type d\'appareil', preinscription.deviceType ?? ''),
        _buildInfoRow('Navigateur', preinscription.browserInfo ?? ''),
        _buildInfoRow('Système d\'exploitation', preinscription.osInfo ?? ''),
        _buildInfoRow('Pays', preinscription.locationCountry ?? ''),
        _buildInfoRow('Ville', preinscription.locationCity ?? ''),
      ],
    );
  }

  Widget _buildPreferencesInfo() {
    return Column(
      children: [
        _buildInfoRow('Préférence de contact', preinscription.contactPreference ?? ''),
        _buildInfoRow('Consentement marketing', preinscription.marketingConsent ? 'Oui' : 'Non'),
        _buildInfoRow('Consentement traitement données', preinscription.dataProcessingConsent ? 'Oui' : 'Non'),
        _buildInfoRow('Abonnement newsletter', preinscription.newsletterSubscription ? 'Oui' : 'Non'),
      ],
    );
  }

  Widget _buildReviewInfo() {
    return Column(
      children: [
        _buildInfoRow('Révisé par', preinscription.reviewedBy?.toString() ?? ''),
        _buildInfoRow('Date de révision', preinscription.reviewDate != null ? _formatDateTime(preinscription.reviewDate!) : ''),
        _buildInfoRow('Priorité de révision', preinscription.reviewPriority),
        _buildInfoRow('Commentaires de révision', preinscription.reviewComments ?? ''),
      ],
    );
  }

  Widget _buildNotesInfo() {
    return Column(
      children: [
        _buildInfoRow('Notes générales', preinscription.notes ?? ''),
        _buildInfoRow('Notes administrateur', preinscription.adminNotes ?? ''),
        _buildInfoRow('Commentaires internes', preinscription.internalComments ?? ''),
        _buildInfoRow('Motif de rejet', preinscription.rejectionReason ?? ''),
        _buildInfoRow('Besoins spéciaux', preinscription.specialNeeds ?? ''),
        _buildInfoRow('Conditions médicales', preinscription.medicalConditions ?? ''),
      ],
    );
  }

  Widget _buildTimestampsInfo() {
    return Column(
      children: [
        _buildInfoRow('Code unique', preinscription.uniqueCode ?? 'N/A'),
        _buildInfoRow('UUID', preinscription.uuid ?? ''),
        _buildInfoRow('Date de soumission', _formatDateTime(preinscription.submissionDate)),
        _buildInfoRow('Dernière mise à jour', _formatDateTime(preinscription.lastUpdated)),
        _buildInfoRow('Créé le', _formatDateTime(preinscription.createdAt)),
        _buildInfoRow('Modifié le', _formatDateTime(preinscription.updatedAt)),
        _buildInfoRow('Supprimé le', preinscription.deletedAt != null ? _formatDateTime(preinscription.deletedAt!) : ''),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final displayValue = value.isEmpty ? 'Non renseigné' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
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
              displayValue,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: displayValue == 'Non renseigné' ? Colors.grey.shade600 : Colors.black87,
                fontStyle: displayValue == 'Non renseigné' ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentRow(String label, String path) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(Icons.insert_drive_file, size: 16, color: Colors.blue),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, size: 16),
            onPressed: () {
              // TODO: Implement document download
            },
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'under_review': return Colors.blue;
      case 'accepted': return Colors.green;
      case 'rejected': return Colors.red;
      case 'cancelled': return Colors.grey;
      case 'deferred': return Colors.purple;
      case 'waitlisted': return Colors.amber;
      default: return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'paid': return Colors.green;
      case 'confirmed': return Colors.blue;
      case 'refunded': return Colors.purple;
      case 'partial': return Colors.amber;
      default: return Colors.grey;
    }
  }

  Color _getDocumentsStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'submitted': return Colors.blue;
      case 'verified': return Colors.green;
      case 'incomplete': return Colors.amber;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.pending;
      case 'under_review': return Icons.visibility;
      case 'accepted': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      case 'cancelled': return Icons.block;
      case 'deferred': return Icons.schedule;
      case 'waitlisted': return Icons.hourglass_empty;
      default: return Icons.help;
    }
  }

  IconData _getPaymentStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.payment;
      case 'paid': return Icons.payment;
      case 'confirmed': return Icons.verified;
      case 'refunded': return Icons.money_off;
      case 'partial': return Icons.pie_chart;
      default: return Icons.help;
    }
  }

  IconData _getDocumentsStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Icons.folder_open;
      case 'submitted': return Icons.upload_file;
      case 'verified': return Icons.verified;
      case 'incomplete': return Icons.warning;
      case 'rejected': return Icons.cancel;
      default: return Icons.help;
    }
  }

  String _formatStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'En attente';
      case 'under_review': return 'En révision';
      case 'accepted': return 'Accepté';
      case 'rejected': return 'Rejeté';
      case 'cancelled': return 'Annulé';
      case 'deferred': return 'Reporté';
      case 'waitlisted': return 'Liste d\'attente';
      default: return status;
    }
  }

  String _formatPaymentStatusName(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return 'Paiement en attente';
      case 'paid': return 'Payé';
      case 'confirmed': return 'Confirmé';
      case 'refunded': return 'Remboursé';
      case 'partial': return 'Partiel';
      default: return status;
    }
  }

  String _formatInterviewResult(String result) {
    switch (result.toLowerCase()) {
      case 'pending': return 'En attente';
      case 'passed': return 'Réussi';
      case 'failed': return 'Échoué';
      case 'no_show': return 'Absent';
      default: return result;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  double _calculateProgress(PreinscriptionModel preinscription) {
    switch (preinscription.status.toLowerCase()) {
      case 'pending': return 0.25;
      case 'under_review': return 0.5;
      case 'accepted': return 1.0;
      case 'rejected': return 0.75;
      case 'cancelled': return 0.0;
      case 'deferred': return 0.6;
      case 'waitlisted': return 0.4;
      default: return 0.0;
    }
  }
}
