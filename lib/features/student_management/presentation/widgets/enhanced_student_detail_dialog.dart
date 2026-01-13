import 'package:flutter/material.dart';
import 'package:mycampus/features/student_management/data/models/enhanced_student_model.dart';

class EnhancedStudentDetailDialog extends StatelessWidget {
  final EnhancedStudentModel student;

  const EnhancedStudentDetailDialog({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information
                    _buildBasicInfoSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // Academic Information
                    _buildAcademicInfoSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // Contact Information
                    _buildContactInfoSection(context),
                    
                    const SizedBox(height: 24),
                    
                    // Emergency Contact
                    if (student.emergencyContactName != null) ...[
                      _buildEmergencyContactSection(context),
                      const SizedBox(height: 24),
                    ],
                    
                    // Scholarship Information
                    if (student.scholarshipStatus != ScholarshipStatus.none) ...[
                      _buildScholarshipSection(context),
                      const SizedBox(height: 24),
                    ],
                    
                    // Medical Information
                    if (student.bloodGroup != null || 
                        student.medicalConditions != null ||
                        student.allergies != null) ...[
                      _buildMedicalSection(context),
                      const SizedBox(height: 24),
                    ],
                    
                    // Skills and Interests
                    if (student.languages != null || 
                        student.hobbies != null ||
                        student.skills != null) ...[
                      _buildSkillsSection(context),
                      const SizedBox(height: 24),
                    ],
                    
                    // Timeline
                    _buildTimelineSection(context),
                  ],
                ),
              ),
            ),
            
            // Actions
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: student.profilePhotoUrl != null
                ? NetworkImage(student.profilePhotoUrl!)
                : null,
            backgroundColor: Colors.white,
            child: student.profilePhotoUrl == null
                ? Text(
                    student.firstName.isNotEmpty 
                        ? student.firstName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : null,
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
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  student.matricule,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusChip(context, student.status),
                    const SizedBox(width: 8),
                    if (student.isVerified)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified, size: 14, color: Colors.green),
                            const SizedBox(width: 4),
                            Text(
                              'Vérifié',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return _buildSection(
      context,
      'Informations personnelles',
      Icons.person,
      [
        _buildInfoRow('Matricule', student.matricule),
        _buildInfoRow('Nom', student.lastName),
        _buildInfoRow('Prénom', student.firstName),
        if (student.middleName != null)
          _buildInfoRow('Autre prénom', student.middleName!),
        _buildInfoRow('Email', student.email),
        if (student.phone != null)
          _buildInfoRow('Téléphone', student.phone!),
        if (student.alternativePhone != null)
          _buildInfoRow('Téléphone alternatif', student.alternativePhone!),
        if (student.dateOfBirth != null)
          _buildInfoRow('Date de naissance', '${student.dateOfBirth!.day}/${student.dateOfBirth!.month}/${student.dateOfBirth!.year}'),
        if (student.placeOfBirth != null)
          _buildInfoRow('Lieu de naissance', student.placeOfBirth!),
        _buildInfoRow('Genre', _getGenderLabel(student.gender)),
        _buildInfoRow('Nationalité', student.nationality),
      ],
    );
  }

  Widget _buildAcademicInfoSection(BuildContext context) {
    return _buildSection(
      context,
      'Informations académiques',
      Icons.school,
      [
        _buildInfoRow('Statut', student.statusLabel),
        _buildInfoRow('Niveau actuel', student.levelLabel),
        _buildInfoRow('Type d\'admission', student.admissionTypeLabel),
        _buildInfoRow('Date d\'inscription', '${student.enrollmentDate.day}/${student.enrollmentDate.month}/${student.enrollmentDate.year}'),
        if (student.expectedGraduationDate != null)
          _buildInfoRow('Date de diplomation prévue', '${student.expectedGraduationDate!.day}/${student.expectedGraduationDate!.month}/${student.expectedGraduationDate!.year}'),
        if (student.actualGraduationDate != null)
          _buildInfoRow('Date de diplomation réelle', '${student.actualGraduationDate!.day}/${student.actualGraduationDate!.month}/${student.actualGraduationDate!.year}'),
        if (student.gpa != null)
          _buildInfoRow('GPA', student.gpaDisplay),
        _buildInfoRow('Crédits obtenus', '${student.totalCreditsEarned}'),
        if (student.totalCreditsRequired != null)
          _buildInfoRow('Crédits requis', '${student.totalCreditsRequired}'),
        if (student.classRank != null)
          _buildInfoRow('Classement', '${student.classRank}'),
        if (student.honors != null)
          _buildInfoRow('Distinctions', student.honors!),
        _buildInfoRow('Institution', student.institutionDisplay),
        _buildInfoRow('Progression', '${student.progressPercentage.toStringAsFixed(1)}%'),
      ],
    );
  }

  Widget _buildContactInfoSection(BuildContext context) {
    return _buildSection(
      context,
      'Coordonnées',
      Icons.contact_page,
      [
        _buildInfoRow('Adresse', student.address),
        _buildInfoRow('Ville', student.city),
        _buildInfoRow('Région', student.region),
        _buildInfoRow('Pays', student.country),
        if (student.postalCode != null)
          _buildInfoRow('Code postal', student.postalCode!),
      ],
    );
  }

  Widget _buildEmergencyContactSection(BuildContext context) {
    return _buildSection(
      context,
      'Contact d\'urgence',
      Icons.emergency,
      [
        _buildInfoRow('Nom', student.emergencyContactName!),
        if (student.emergencyContactPhone != null)
          _buildInfoRow('Téléphone', student.emergencyContactPhone!),
        if (student.emergencyContactRelationship != null)
          _buildInfoRow('Relation', student.emergencyContactRelationship!),
        if (student.emergencyContactEmail != null)
          _buildInfoRow('Email', student.emergencyContactEmail!),
      ],
    );
  }

  Widget _buildScholarshipSection(BuildContext context) {
    return _buildSection(
      context,
      'Bourse d\'études',
      Icons.card_giftcard,
      [
        _buildInfoRow('Statut', student.scholarshipStatusLabel),
        if (student.scholarshipDetails != null)
          _buildInfoRow('Détails', student.scholarshipDetails!),
        if (student.scholarshipAmount != null)
          _buildInfoRow('Montant', '${student.scholarshipAmount!.toStringAsFixed(0)} FCFA'),
      ],
    );
  }

  Widget _buildMedicalSection(BuildContext context) {
    return _buildSection(
      context,
      'Informations médicales',
      Icons.medical_services,
      [
        if (student.bloodGroup != null)
          _buildInfoRow('Groupe sanguin', student.bloodGroup!),
        if (student.medicalConditions != null)
          _buildInfoRow('Conditions médicales', student.medicalConditions!),
        if (student.allergies != null)
          _buildInfoRow('Allergies', student.allergies!),
        if (student.dietaryRestrictions != null)
          _buildInfoRow('Restrictions alimentaires', student.dietaryRestrictions!),
        if (student.physicalDisabilities != null)
          _buildInfoRow('Handicaps physiques', student.physicalDisabilities!),
        if (student.needsSpecialAccommodation != null)
          _buildInfoRow('Besoin d\'aménagement spécial', student.needsSpecialAccommodation! ? 'Oui' : 'Non'),
      ],
    );
  }

  Widget _buildSkillsSection(BuildContext context) {
    return _buildSection(
      context,
      'Compétences et centres d\'intérêt',
      Icons.psychology,
      [
        if (student.languages != null)
          _buildInfoRow('Langues', student.languages!),
        if (student.hobbies != null)
          _buildInfoRow('Centres d\'intérêt', student.hobbies!),
        if (student.skills != null)
          _buildInfoRow('Compétences', student.skills!),
        if (student.previousEducation != null)
          _buildInfoRow('Éducation précédente', student.previousEducation!),
        if (student.workExperience != null)
          _buildInfoRow('Expérience professionnelle', student.workExperience!),
        if (student.references != null)
          _buildInfoRow('Références', student.references!),
      ],
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    return _buildSection(
      context,
      'Chronologie',
      Icons.timeline,
      [
        _buildInfoRow('Date de création', '${student.createdAt.day}/${student.createdAt.month}/${student.createdAt.year}'),
        if (student.updatedAt != null)
          _buildInfoRow('Dernière mise à jour', '${student.updatedAt!.day}/${student.updatedAt!.month}/${student.updatedAt!.year}'),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, StudentStatus status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case StudentStatus.enrolled:
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case StudentStatus.graduated:
        color = Colors.blue;
        icon = Icons.school;
        break;
      case StudentStatus.suspended:
        color = Colors.orange;
        icon = Icons.pause_circle;
        break;
      case StudentStatus.withdrawn:
        color = Colors.red;
        icon = Icons.exit_to_app;
        break;
      case StudentStatus.deferred:
        color = Colors.purple;
        icon = Icons.schedule;
        break;
      case StudentStatus.onLeave:
        color = Colors.teal;
        icon = Icons.beach_access;
        break;
      case StudentStatus.expelled:
        color = Colors.red.shade900;
        icon = Icons.block;
        break;
      case StudentStatus.deceased:
        color = Colors.grey;
        icon = Icons.memory;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            student.statusLabel,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getGenderLabel(String gender) {
    switch (gender) {
      case 'male':
        return 'Masculin';
      case 'female':
        return 'Féminin';
      case 'other':
        return 'Autre';
      default:
        return gender;
    }
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Fermer'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to edit page
              },
              icon: const Icon(Icons.edit),
              label: const Text('Modifier'),
            ),
          ),
        ],
      ),
    );
  }
}
