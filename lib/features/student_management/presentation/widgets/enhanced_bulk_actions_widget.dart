import 'package:flutter/material.dart';
import 'package:mycampus/features/student_management/data/models/enhanced_student_model.dart';

class EnhancedBulkActionsWidget extends StatelessWidget {
  final List<EnhancedStudentModel> selectedStudents;
  final Function(List<EnhancedStudentModel>)? onSelectionChanged;
  final VoidCallback? onExportSelected;
  final VoidCallback? onDeleteSelected;
  final VoidCallback? onActivateSelected;
  final VoidCallback? onDeactivateSelected;
  final VoidCallback? onVerifySelected;
  final VoidCallback? onPromoteSelected;
  final VoidCallback? onGraduateSelected;
  final VoidCallback? onAssignScholarshipSelected;
  final VoidCallback? onSendMessageSelected;

  const EnhancedBulkActionsWidget({
    super.key,
    required this.selectedStudents,
    this.onSelectionChanged,
    this.onExportSelected,
    this.onDeleteSelected,
    this.onActivateSelected,
    this.onDeactivateSelected,
    this.onVerifySelected,
    this.onPromoteSelected,
    this.onGraduateSelected,
    this.onAssignScholarshipSelected,
    this.onSendMessageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.checklist,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${selectedStudents.length} étudiant${selectedStudents.length > 1 ? 's' : ''} sélectionné${selectedStudents.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    onSelectionChanged?.call([]);
                  },
                  child: const Text('Désélectionner tout'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Quick actions
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Status actions
                if (onActivateSelected != null)
                  ActionChip(
                    avatar: const Icon(Icons.check_circle, size: 16),
                    label: const Text('Activer'),
                    onPressed: onActivateSelected,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    side: const BorderSide(color: Colors.green),
                  ),
                
                if (onDeactivateSelected != null)
                  ActionChip(
                    avatar: const Icon(Icons.block, size: 16),
                    label: const Text('Désactiver'),
                    onPressed: onDeactivateSelected,
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    side: const BorderSide(color: Colors.orange),
                  ),
                
                if (onVerifySelected != null)
                  ActionChip(
                    avatar: const Icon(Icons.verified, size: 16),
                    label: const Text('Vérifier'),
                    onPressed: onVerifySelected,
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    side: const BorderSide(color: Colors.blue),
                  ),
                
                // Academic actions
                if (onPromoteSelected != null)
                  ActionChip(
                    avatar: const Icon(Icons.arrow_upward, size: 16),
                    label: const Text('Promouvoir'),
                    onPressed: onPromoteSelected,
                    backgroundColor: Colors.purple.withOpacity(0.1),
                    side: const BorderSide(color: Colors.purple),
                  ),
                
                if (onGraduateSelected != null)
                  ActionChip(
                    avatar: const Icon(Icons.school, size: 16),
                    label: const Text('Diplômer'),
                    onPressed: onGraduateSelected,
                    backgroundColor: Colors.indigo.withOpacity(0.1),
                    side: const BorderSide(color: Colors.indigo),
                  ),
                
                // Scholarship action
                if (onAssignScholarshipSelected != null)
                  ActionChip(
                    avatar: const Icon(Icons.card_giftcard, size: 16),
                    label: const Text('Bourse'),
                    onPressed: onAssignScholarshipSelected,
                    backgroundColor: Colors.amber.withOpacity(0.1),
                    side: const BorderSide(color: Colors.amber),
                  ),
                
                // Communication action
                if (onSendMessageSelected != null)
                  ActionChip(
                    avatar: const Icon(Icons.message, size: 16),
                    label: const Text('Message'),
                    onPressed: onSendMessageSelected,
                    backgroundColor: Colors.teal.withOpacity(0.1),
                    side: const BorderSide(color: Colors.teal),
                  ),
                
                // Export action
                if (onExportSelected != null)
                  ActionChip(
                    avatar: const Icon(Icons.download, size: 16),
                    label: const Text('Exporter'),
                    onPressed: onExportSelected,
                    backgroundColor: Colors.cyan.withOpacity(0.1),
                    side: const BorderSide(color: Colors.cyan),
                  ),
                
                // Delete action
                if (onDeleteSelected != null)
                  ActionChip(
                    avatar: const Icon(Icons.delete, size: 16),
                    label: const Text('Supprimer'),
                    onPressed: () => _showDeleteConfirmation(context),
                    backgroundColor: Colors.red.withOpacity(0.1),
                    side: const BorderSide(color: Colors.red),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Advanced actions button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAdvancedActionsMenu(context),
                icon: const Icon(Icons.more_horiz),
                label: const Text('Actions avancées'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer ${selectedStudents.length} étudiant${selectedStudents.length > 1 ? 's' : ''}'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer les étudiants sélectionnés? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onDeleteSelected?.call();
            },
            child: const Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showAdvancedActionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions avancées',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Academic management
            Text(
              'Gestion académique',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            ListTile(
              leading: const Icon(Icons.arrow_upward),
              title: const Text('Promouvoir au niveau supérieur'),
              subtitle: const Text('Passer tous les étudiants au niveau académique suivant'),
              onTap: () {
                Navigator.of(context).pop();
                onPromoteSelected?.call();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Diplômer les étudiants'),
              subtitle: const Text('Marquer les étudiants comme diplômés'),
              onTap: () {
                Navigator.of(context).pop();
                onGraduateSelected?.call();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Mettre en congé'),
              subtitle: const Text('Placer les étudiants en congé académique'),
              onTap: () {
                Navigator.of(context).pop();
                _showLeaveDialog(context);
              },
            ),
            
            const Divider(),
            
            // Communication
            Text(
              'Communication',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Envoyer un email'),
              subtitle: const Text('Envoyer un email à tous les étudiants sélectionnés'),
              onTap: () {
                Navigator.of(context).pop();
                _showEmailDialog(context);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.sms),
              title: const Text('Envoyer un SMS'),
              subtitle: const Text('Envoyer un SMS à tous les étudiants sélectionnés'),
              onTap: () {
                Navigator.of(context).pop();
                _showSmsDialog(context);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Envoyer une notification'),
              subtitle: const Text('Envoyer une notification push aux étudiants'),
              onTap: () {
                Navigator.of(context).pop();
                _showNotificationDialog(context);
              },
            ),
            
            const Divider(),
            
            // Data management
            Text(
              'Gestion des données',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('Exporter les données'),
              subtitle: const Text('Exporter les informations des étudiants au format CSV/Excel'),
              onTap: () {
                Navigator.of(context).pop();
                onExportSelected?.call();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.content_copy),
              title: const Text('Dupliquer les étudiants'),
              subtitle: const Text('Créer des copies des étudiants sélectionnés'),
              onTap: () {
                Navigator.of(context).pop();
                _showDuplicateDialog(context);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.archive),
              title: const Text('Archiver les étudiants'),
              subtitle: const Text('Archiver les étudiants sélectionnés'),
              onTap: () {
                Navigator.of(context).pop();
                _showArchiveDialog(context);
              },
            ),
            
            const Divider(),
            
            // Financial
            Text(
              'Gestion financière',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Gérer les bourses'),
              subtitle: const Text('Attribuer ou modifier les bourses des étudiants'),
              onTap: () {
                Navigator.of(context).pop();
                onAssignScholarshipSelected?.call();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Gérer les frais'),
              subtitle: const Text('Gérer les frais de scolarité et autres paiements'),
              onTap: () {
                Navigator.of(context).pop();
                _showFeesDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mettre en congé'),
        content: const Text(
          'Êtes-vous sûr de vouloir mettre les étudiants sélectionnés en congé académique?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle leave action
            },
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
  }

  void _showEmailDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer un email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Sujet',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle email sending
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _showSmsDialog(BuildContext context) {
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer un SMS'),
        content: TextField(
          controller: messageController,
          decoration: const InputDecoration(
            labelText: 'Message',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle SMS sending
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer une notification'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
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
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle notification sending
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _showDuplicateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dupliquer les étudiants'),
        content: const Text(
          'Êtes-vous sûr de vouloir créer des copies des étudiants sélectionnés?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle duplication
            },
            child: const Text('Dupliquer'),
          ),
        ],
      ),
    );
  }

  void _showArchiveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archiver les étudiants'),
        content: const Text(
          'Êtes-vous sûr de vouloir archiver les étudiants sélectionnés? Ils ne seront plus visibles dans la liste active.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle archiving
            },
            child: const Text('Archiver'),
          ),
        ],
      ),
    );
  }

  void _showFeesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gérer les frais'),
        content: const Text(
          'Cette fonctionnalité vous permettra de gérer les frais de scolarité et autres paiements pour les étudiants sélectionnés.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
