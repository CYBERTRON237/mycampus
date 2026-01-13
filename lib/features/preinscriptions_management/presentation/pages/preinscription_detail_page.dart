import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/preinscription_provider.dart';
import '../../models/preinscription_model.dart';
import 'preinscription_validation_page.dart';

class PreinscriptionDetailPage extends StatefulWidget {
  final int preinscriptionId;

  const PreinscriptionDetailPage({
    super.key,
    required this.preinscriptionId,
  });

  @override
  State<PreinscriptionDetailPage> createState() => _PreinscriptionDetailPageState();
}

class _PreinscriptionDetailPageState extends State<PreinscriptionDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PreinscriptionModel? _preinscription;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadPreinscription();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPreinscription() async {
    try {
      final provider = context.read<PreinscriptionProvider>();
      final preinscription = await provider.getPreinscriptionById(widget.preinscriptionId);
      setState(() {
        _preinscription = preinscription;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails Préinscription #${widget.preinscriptionId}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'Informations'),
            Tab(icon: Icon(Icons.school), text: 'Études'),
            Tab(icon: Icon(Icons.payment), text: 'Paiement'),
            Tab(icon: Icon(Icons.description), text: 'Documents'),
          ],
        ),
        actions: [
          if (_preinscription != null) ...[
            IconButton(
              icon: Icon(
                _preinscription!.status == 'pending' ? Icons.check_circle : Icons.edit,
              ),
              onPressed: () => _navigateToValidation(),
              tooltip: 'Valider/Modifier',
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadPreinscription,
              tooltip: 'Actualiser',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _preinscription == null
              ? const Center(child: Text('Préinscription non trouvée'))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Status header
        _buildStatusHeader(),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPersonalInfoTab(),
              _buildAcademicInfoTab(),
              _buildPaymentInfoTab(),
              _buildDocumentsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusHeader() {
    final status = _preinscription!.status;
    final statusColor = _getStatusColor(status);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(status),
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Statut: ${_getStatusText(status)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Code: ${_preinscription!.uniqueCode ?? "N/A"}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              Text(
                'Faculté: ${_preinscription!.faculty}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Soumission: ${_formatDate(_preinscription!.submissionDate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                'Dernière mise à jour: ${_formatDate(_preinscription!.lastUpdated)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Identité'),
          _buildInfoCard([
            _buildInfoRow('Nom', _preinscription!.lastName),
            _buildInfoRow('Prénom', _preinscription!.firstName),
            if (_preinscription!.middleName != null)
              _buildInfoRow('Autre nom', _preinscription!.middleName!),
            _buildInfoRow('Date de naissance', _formatDate(_preinscription!.dateOfBirth)),
            _buildInfoRow('Lieu de naissance', _preinscription!.placeOfBirth),
            _buildInfoRow('Sexe', _preinscription!.gender),
            if (_preinscription!.cniNumber != null)
              _buildInfoRow('N° CNI', _preinscription!.cniNumber!),
          ]),
          
          const SizedBox(height: 16),
          _buildSectionTitle('Contact'),
          _buildInfoCard([
            _buildInfoRow('Email', _preinscription!.email),
            _buildInfoRow('Téléphone', _preinscription!.phoneNumber),
            _buildInfoRow('Adresse', _preinscription!.residenceAddress),
            _buildInfoRow('Situation matrimoniale', _preinscription!.maritalStatus),
            _buildInfoRow('Langue principale', _preinscription!.firstLanguage),
            _buildInfoRow('Situation professionnelle', _preinscription!.professionalSituation),
          ]),

          if (_preinscription!.parentName != null) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('Informations Parentales'),
            _buildInfoCard([
              _buildInfoRow('Nom du parent', _preinscription!.parentName!),
              if (_preinscription!.parentPhone != null)
                _buildInfoRow('Téléphone parent', _preinscription!.parentPhone!),
              if (_preinscription!.parentEmail != null)
                _buildInfoRow('Email parent', _preinscription!.parentEmail!),
              if (_preinscription!.parentOccupation != null)
                _buildInfoRow('Profession parent', _preinscription!.parentOccupation!),
              if (_preinscription!.parentRelationship != null)
                _buildInfoRow('Relation', _preinscription!.parentRelationship!),
              if (_preinscription!.parentIncomeLevel != null)
                _buildInfoRow('Niveau de revenu', _preinscription!.parentIncomeLevel!),
            ]),
          ],

          if (_preinscription!.specialNeeds != null || _preinscription!.medicalConditions != null) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('Informations Médicales'),
            _buildInfoCard([
              if (_preinscription!.specialNeeds != null)
                _buildInfoRow('Besoins spéciaux', _preinscription!.specialNeeds!),
              if (_preinscription!.medicalConditions != null)
                _buildInfoRow('Conditions médicales', _preinscription!.medicalConditions!),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildAcademicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Formation Souhaitée'),
          _buildInfoCard([
            _buildInfoRow('Programme désiré', _preinscription!.desiredProgram ?? 'Non spécifié'),
            _buildInfoRow('Niveau d\'étude', _preinscription!.studyLevel ?? 'Non spécifié'),
            _buildInfoRow('Spécialisation', _preinscription!.specialization ?? 'Non spécifié'),
            _buildInfoRow('Faculté', _preinscription!.faculty),
          ]),

          if (_preinscription!.previousDiploma != null) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('Diplôme Antérieur'),
            _buildInfoCard([
              _buildInfoRow('Diplôme', _preinscription!.previousDiploma!),
              if (_preinscription!.previousInstitution != null)
                _buildInfoRow('Établissement', _preinscription!.previousInstitution!),
              if (_preinscription!.graduationYear != null)
                _buildInfoRow('Année d\'obtention', _preinscription!.graduationYear.toString()),
              if (_preinscription!.graduationMonth != null)
                _buildInfoRow('Mois d\'obtention', _preinscription!.graduationMonth!),
            ]),
          ],

          if (_preinscription!.seriesBac != null) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('Informations Baccalauréat'),
            _buildInfoCard([
              _buildInfoRow('Série', _preinscription!.seriesBac!),
              if (_preinscription!.bacYear != null)
                _buildInfoRow('Année', _preinscription!.bacYear.toString()),
              if (_preinscription!.bacCenter != null)
                _buildInfoRow('Centre d\'examen', _preinscription!.bacCenter!),
              if (_preinscription!.bacMention != null)
                _buildInfoRow('Mention', _preinscription!.bacMention!),
              if (_preinscription!.gpaScore != null)
                _buildInfoRow('Moyenne', _preinscription!.gpaScore.toString()),
              if (_preinscription!.rankInClass != null)
                _buildInfoRow('Rang en classe', _preinscription!.rankInClass.toString()),
            ]),
          ],

          if (_preinscription!.interviewRequired) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('Entretien'),
            _buildInfoCard([
              _buildInfoRow('Entretien requis', 'Oui'),
              if (_preinscription!.interviewDate != null)
                _buildInfoRow('Date', _formatDate(_preinscription!.interviewDate!)),
              if (_preinscription!.interviewLocation != null)
                _buildInfoRow('Lieu', _preinscription!.interviewLocation!),
              if (_preinscription!.interviewType != null)
                _buildInfoRow('Type', _preinscription!.interviewType!),
              if (_preinscription!.interviewResult != null)
                _buildInfoRow('Résultat', _preinscription!.interviewResult!),
              if (_preinscription!.interviewNotes != null)
                _buildInfoRow('Notes', _preinscription!.interviewNotes!),
            ]),
          ],

          if (_preinscription!.admissionNumber != null) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('Admission'),
            _buildInfoCard([
              _buildInfoRow('Numéro d\'admission', _preinscription!.admissionNumber!),
              if (_preinscription!.admissionDate != null)
                _buildInfoRow('Date d\'admission', _formatDate(_preinscription!.admissionDate!)),
              if (_preinscription!.registrationDeadline != null)
                _buildInfoRow('Date limite d\'inscription', _formatDate(_preinscription!.registrationDeadline!)),
              _buildInfoRow('Inscription complétée', _preinscription!.registrationCompleted ? 'Oui' : 'Non'),
              if (_preinscription!.studentId != null)
                _buildInfoRow('ID Étudiant', _preinscription!.studentId!),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informations de Paiement'),
          _buildInfoCard([
            _buildInfoRow('Statut du paiement', _preinscription!.paymentStatus),
            _buildInfoRow('Méthode de paiement', _preinscription!.paymentMethod ?? 'Non spécifié'),
            if (_preinscription!.paymentAmount != null)
              _buildInfoRow('Montant', '${_preinscription!.paymentAmount} ${_preinscription!.paymentCurrency}'),
            if (_preinscription!.paymentReference != null)
              _buildInfoRow('Référence', _preinscription!.paymentReference!),
            if (_preinscription!.paymentDate != null)
              _buildInfoRow('Date de paiement', _formatDate(_preinscription!.paymentDate!)),
          ]),

          if (_preinscription!.scholarshipRequested) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('Bourse d\'Études'),
            _buildInfoCard([
              _buildInfoRow('Bourse demandée', 'Oui'),
              if (_preinscription!.scholarshipType != null)
                _buildInfoRow('Type de bourse', _preinscription!.scholarshipType!),
              if (_preinscription!.financialAidAmount != null)
                _buildInfoRow('Montant aide financière', '${_preinscription!.financialAidAmount} ${_preinscription!.paymentCurrency}'),
            ]),
          ],

          if (_preinscription!.reviewComments != null || _preinscription!.rejectionReason != null) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('Notes de Révision'),
            _buildInfoCard([
              if (_preinscription!.reviewComments != null)
                _buildInfoRow('Commentaires', _preinscription!.reviewComments!),
              if (_preinscription!.rejectionReason != null)
                _buildInfoRow('Raison de rejet', _preinscription!.rejectionReason!),
              if (_preinscription!.adminNotes != null)
                _buildInfoRow('Notes admin', _preinscription!.adminNotes!),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    final documents = [
      if (_preinscription!.birthCertificatePath != null)
        {'name': 'Acte de naissance', 'path': _preinscription!.birthCertificatePath!},
      if (_preinscription!.cniPath != null)
        {'name': 'CNI', 'path': _preinscription!.cniPath!},
      if (_preinscription!.diplomaPath != null)
        {'name': 'Diplôme', 'path': _preinscription!.diplomaPath!},
      if (_preinscription!.transcriptPath != null)
        {'name': 'Relevé de notes', 'path': _preinscription!.transcriptPath!},
      if (_preinscription!.photoPath != null)
        {'name': 'Photo', 'path': _preinscription!.photoPath!},
      if (_preinscription!.recommendationLetterPath != null)
        {'name': 'Lettre de recommandation', 'path': _preinscription!.recommendationLetterPath!},
      if (_preinscription!.motivationLetterPath != null)
        {'name': 'Lettre de motivation', 'path': _preinscription!.motivationLetterPath!},
      if (_preinscription!.medicalCertificatePath != null)
        {'name': 'Certificat médical', 'path': _preinscription!.medicalCertificatePath!},
      if (_preinscription!.paymentProofPath != null)
        {'name': 'Preuve de paiement', 'path': _preinscription!.paymentProofPath!},
      if (_preinscription!.otherDocumentsPath != null)
        {'name': 'Autres documents', 'path': _preinscription!.otherDocumentsPath!},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Documents Soumis (${documents.length})'),
          if (documents.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Aucun document soumis'),
              ),
            )
          else
            ...documents.map((doc) => Card(
              margin: const EdgeInsets.only(bottom: 8.0),
              child: ListTile(
                leading: const Icon(Icons.description),
                title: Text(doc['name'] as String),
                subtitle: Text(doc['path'] as String),
                trailing: const Icon(Icons.open_in_new),
                onTap: () {
                  // TODO: Implement document viewing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ouverture du document bientôt disponible')),
                  );
                },
              ),
            )),

          if (_preinscription!.documentsStatus != null) ...[
            const SizedBox(height: 16),
            _buildSectionTitle('Statut des Documents'),
            _buildInfoCard([
              _buildInfoRow('Statut', _preinscription!.documentsStatus),
              _buildInfoRow('Priorité de révision', _preinscription!.reviewPriority),
            ]),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
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
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending;
      case 'under_review':
        return Icons.search;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'deferred':
        return Icons.schedule;
      case 'waitlisted':
        return Icons.hourglass_empty;
      default:
        return Icons.help;
    }
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _navigateToValidation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreinscriptionValidationPage(
          preinscription: _preinscription!,
        ),
      ),
    ).then((_) {
      // Refresh data after returning from validation
      _loadPreinscription();
    });
  }
}
