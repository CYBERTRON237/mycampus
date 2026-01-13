import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../widgets/edit_user_dialog.dart';
import '../widgets/complete_profile_edit_widget.dart';

class UserDetailPage extends StatelessWidget {
  final UserModel user;

  const UserDetailPage({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails utilisateur'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditUserDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 24),
            _buildPersonalInfo(context),
            SizedBox(height: 24),
            _buildRoleInfo(context),
            SizedBox(height: 24),
            _buildStatusInfo(context),
            SizedBox(height: 24),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  SizedBox(height: 8),
                  _buildStatusChip(context, user.accountStatus),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildDetailRow(context, 'Prénom', user.firstName),
            _buildDetailRow(context, 'Nom', user.lastName),
            _buildDetailRow(context, 'Email', user.email),
            _buildDetailRow(context, 'Matricule', user.matricule ?? 'N/A'),
            _buildDetailRow(context, 'Institution', user.institutionName ?? 'N/A'),
            _buildDetailRow(context, 'Département', user.departmentName ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rôles et permissions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildDetailRow(context, 'Rôle principal', user.primaryRole),
            _buildDetailRow(context, 'Niveau utilisateur', user.userLevel.toString()),
            if (user.roleDisplayName != null)
              _buildDetailRow(context, 'Affichage rôle', user.roleDisplayName!),
            if (user.userRoles.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                'Tous les rôles:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: user.userRoles.map((role) => Chip(
                  label: Text(role),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statut et activité',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            _buildDetailRow(context, 'Statut compte', user.accountStatus),
            _buildDetailRow(context, 'Actif', user.isActive ? 'Oui' : 'Non'),
            _buildDetailRow(context, 'Date création', _formatDate(user.createdAt)),
            _buildDetailRow(context, 'Dernière connexion', 
                user.lastLoginAt != null ? _formatDate(user.lastLoginAt!) : 'Jamais'),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions rapides',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showEditUserDialog(context),
                    icon: Icon(Icons.edit),
                    label: Text('Modifier'),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showCompleteEditDialog(context),
                    icon: Icon(Icons.edit_note),
                    label: Text('Édition complète'),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleUserStatus(context),
                    icon: Icon(user.isActive ? Icons.block : Icons.check_circle),
                    label: Text(user.isActive ? 'Désactiver' : 'Activer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: user.isActive ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back),
                    label: Text('Retour'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'suspended':
        return Colors.orange;
      case 'banned':
        return Colors.red;
      case 'pending_verification':
        return Colors.amber;
      case 'graduated':
        return Colors.blue;
      case 'withdrawn':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showEditUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(
        user: user,
        onSubmit: (userData) async {
          // Handle user update
        },
      ),
    );
  }

  void _showCompleteEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CompleteProfileEditWidget(
        user: user,
        onProfileUpdated: (updatedUser) {
          // Handle profile update
        },
      ),
    );
  }

  void _toggleUserStatus(BuildContext context) {
    // Handle user status toggle
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Statut utilisateur modifié'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
