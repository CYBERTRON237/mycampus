import 'package:flutter/material.dart';
import '../../data/models/student_model.dart';

class StudentDetailWidget extends StatelessWidget {
  final StudentModel student;

  const StudentDetailWidget({
    Key? key,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(context),
          const SizedBox(height: 16),
          _buildPersonalInfoCard(context),
          const SizedBox(height: 16),
          _buildAcademicInfoCard(context),
          const SizedBox(height: 16),
          _buildContactInfoCard(context),
          const SizedBox(height: 16),
          _buildAccountStatusCard(context),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                student.firstName[0] + student.lastName[0],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.matricule ?? 'Non défini',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.email,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          student.email,
                          style: Theme.of(context).textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _buildStatusBadge(context, student.accountStatus),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // TODO: Implement edit functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Modification bientôt disponible')),
                    );
                  },
                  tooltip: 'Modifier',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Informations personnelles',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Date de naissance', 
                student.dateOfBirth != null ? _formatDate(student.dateOfBirth!) : 'Non renseignée'),
            _buildInfoRow('Lieu de naissance', student.placeOfBirth ?? 'Non renseigné'),
            _buildInfoRow('Nationalité', student.nationality ?? 'Non renseignée'),
            _buildInfoRow('Genre', student.gender ?? 'Non renseigné'),
            if (student.middleName != null && student.middleName!.isNotEmpty)
              _buildInfoRow('Nom du père', student.middleName!),
          ],
        ),
      ),
    );
  }

  Widget _buildAcademicInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Informations académiques',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Institution', student.institution.name),
            _buildInfoRow('Faculté', student.faculty.name),
            _buildInfoRow('Département', student.department.name),
            _buildInfoRow('Programme', student.program.name),
            _buildInfoRow('Année académique', student.academicYear.yearCode),
            const Divider(),
            _buildInfoRow('Niveau actuel', student.profile.currentLevel),
            _buildInfoRow('Statut académique', student.profile.studentStatus),
            _buildInfoRow('Type d\'admission', student.profile.admissionType),
            _buildInfoRow('Date d\'inscription', _formatDate(student.profile.enrollmentDate)),
            _buildInfoRow('Crédits obtenus', '${student.profile.totalCreditsEarned}'),
            if (student.profile.totalCreditsRequired != null)
              _buildInfoRow('Crédits requis', '${student.profile.totalCreditsRequired}'),
            if (student.profile.gpa != null)
              _buildInfoRow('Moyenne', student.profile.gpa!.toStringAsFixed(2)),
            if (student.profile.classRank != null)
              _buildInfoRow('Classement', '${student.profile.classRank!}'),
            if (student.profile.honors != null && student.profile.honors!.isNotEmpty)
              _buildInfoRow('Distinctions', student.profile.honors!),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.contact_mail, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Coordonnées',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Email', student.email),
            _buildInfoRow('Téléphone', student.phone ?? 'Non renseigné'),
            _buildInfoRow('Adresse', student.address ?? 'Non renseignée'),
            _buildInfoRow('Ville', student.city ?? 'Non renseignée'),
            _buildInfoRow('Région', student.region ?? 'Non renseignée'),
            _buildInfoRow('Pays', student.country ?? 'Non renseigné'),
            _buildInfoRow('Code postal', student.postalCode ?? 'Non renseigné'),
            const Divider(),
            Text(
              'Contact d\'urgence',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Nom', student.emergencyContactName ?? 'Non renseigné'),
            _buildInfoRow('Téléphone', student.emergencyContactPhone ?? 'Non renseigné'),
            _buildInfoRow('Relation', student.emergencyContactRelationship ?? 'Non renseigné'),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStatusCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_circle, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Statut du compte',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Statut', student.accountStatus),
            _buildInfoRow('Date de création', _formatDateTime(student.createdAt)),
            _buildInfoRow('Dernière connexion', 
                student.lastLoginAt != null ? _formatDateTime(student.lastLoginAt!) : 'Jamais'),
          ],
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
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    Color color;
    String text;
    
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        text = 'Actif';
        break;
      case 'inactive':
        color = Colors.grey;
        text = 'Inactif';
        break;
      case 'suspended':
        color = Colors.orange;
        text = 'Suspendu';
        break;
      case 'banned':
        color = Colors.red;
        text = 'Banni';
        break;
      case 'pending_verification':
        color = Colors.blue;
        text = 'En attente';
        break;
      case 'graduated':
        color = Colors.purple;
        text = 'Diplômé';
        break;
      case 'withdrawn':
        color = Colors.brown;
        text = 'Retiré';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} à ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
