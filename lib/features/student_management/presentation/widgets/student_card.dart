import 'package:flutter/material.dart';
import '../../data/models/simple_student_model.dart';

class StudentCard extends StatelessWidget {
  final SimpleStudentModel student;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StudentCard({
    Key? key,
    required this.student,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildInfo(),
              const SizedBox(height: 12),
              _buildAcademicInfo(context),
              const SizedBox(height: 12),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: _getStatusColor(),
          child: Text(
            student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : 'S',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.fullName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                student.displayMatricule,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (student.studentStatus) {
      case 'enrolled':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        text = 'Inscrit';
        break;
      case 'inactive':
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        text = 'Inactif';
        break;
      case 'graduated':
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        text = 'Diplômé';
        break;
      case 'suspended':
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        text = 'Suspendu';
        break;
      case 'withdrawn':
        backgroundColor = Colors.red;
        textColor = Colors.white;
        text = 'Retiré';
        break;
      default:
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        text = 'Inconnu';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfo() {
    return Column(
      children: [
        _buildInfoRow(Icons.email, student.email),
        if (student.phone != null && student.phone!.isNotEmpty)
          _buildInfoRow(Icons.phone, student.phone!),
        if (student.programName != null && student.programName!.isNotEmpty)
          _buildInfoRow(Icons.school, student.programName!),
        _buildInfoRow(Icons.grade, student.displayLevel),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildAcademicItem(
                  'Programme',
                  student.displayProgram,
                  Icons.school,
                  context,
                ),
              ),
              Expanded(
                child: _buildAcademicItem(
                  'Statut',
                  student.displayStatus,
                  Icons.info_outline,
                  context,
                ),
              ),
              Expanded(
                child: _buildAcademicItem(
                  'Moyenne',
                  student.displayGpa,
                  Icons.grade,
                  context,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicItem(String label, String value, IconData icon, BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Modifier'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete, size: 16),
          label: const Text('Supprimer'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    switch (student.studentStatus) {
      case 'enrolled':
        return Colors.green;
      case 'inactive':
        return Colors.grey;
      case 'suspended':
        return Colors.orange;
      case 'graduated':
        return Colors.blue;
      case 'withdrawn':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
