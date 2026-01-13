import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/announcement_model.dart';
import '../providers/announcement_provider.dart';

class CreateAnnouncementWidget extends StatefulWidget {
  const CreateAnnouncementWidget({super.key});

  @override
  State<CreateAnnouncementWidget> createState() => _CreateAnnouncementWidgetState();
}

class _CreateAnnouncementWidgetState extends State<CreateAnnouncementWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  
  AnnouncementCategory? _selectedCategory;
  AnnouncementPriority? _selectedPriority;
  AnnouncementScope _selectedScope = AnnouncementScope.institution;
  DateTime? _expirationDate;
  bool _isPublished = true;
  bool _allowComments = false;
  bool _sendNotification = true;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AnnouncementProvider>(
      builder: (context, provider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Créer une nouvelle annonce',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Titre
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre de l\'annonce',
                    hintText: 'Entrez un titre clair et concis',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le titre est obligatoire';
                    }
                    if (value.trim().length < 3) {
                      return 'Le titre doit contenir au moins 3 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Contenu
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Contenu de l\'annonce',
                    hintText: 'Rédigez le contenu détaillé de votre annonce',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Le contenu est obligatoire';
                    }
                    if (value.trim().length < 10) {
                      return 'Le contenu doit contenir au moins 10 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Portée (Scope)
                DropdownButtonFormField<AnnouncementScope>(
                  value: _selectedScope,
                  decoration: const InputDecoration(
                    labelText: 'Portée de l\'annonce',
                    border: OutlineInputBorder(),
                  ),
                  items: AnnouncementScope.values.map((scope) {
                    return DropdownMenuItem(
                      value: scope,
                      child: Row(
                        children: [
                          Icon(_getScopeIcon(scope), size: 20),
                          const SizedBox(width: 8),
                          Text(_getScopeLabel(scope)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedScope = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Catégorie et Priorité
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<AnnouncementCategory>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Catégorie',
                          border: OutlineInputBorder(),
                        ),
                        items: AnnouncementCategory.values.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(_getCategoryIcon(category), size: 20),
                                const SizedBox(width: 8),
                                Text(_getCategoryLabel(category)),
                              ],
                            ),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner une catégorie';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<AnnouncementPriority>(
                        value: _selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priorité',
                          border: OutlineInputBorder(),
                        ),
                        items: AnnouncementPriority.values.map((priority) {
                          return DropdownMenuItem(
                            value: priority,
                            child: Row(
                              children: [
                                Icon(_getPriorityIcon(priority), size: 20),
                                const SizedBox(width: 8),
                                Text(_getPriorityLabel(priority)),
                              ],
                            ),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Veuillez sélectionner une priorité';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          setState(() {
                            _selectedPriority = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Date d'expiration
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(
                    _expirationDate != null
                        ? 'Date d\'expiration: ${_formatDate(_expirationDate!)}'
                        : 'Date d\'expiration (optionnel)',
                  ),
                  trailing: _expirationDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _expirationDate = null;
                            });
                          },
                        )
                      : null,
                  onTap: _selectExpirationDate,
                ),
                const Divider(),
                const SizedBox(height: 16),
                
                // Options
                const Text(
                  'Options de publication',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                
                SwitchListTile(
                  title: const Text('Publier immédiatement'),
                  subtitle: const Text('L\'annonce sera visible par tous les utilisateurs'),
                  value: _isPublished,
                  onChanged: (value) {
                    setState(() {
                      _isPublished = value;
                    });
                  },
                ),
                
                SwitchListTile(
                  title: const Text('Autoriser les commentaires'),
                  subtitle: const Text('Les utilisateurs pourront commenter cette annonce'),
                  value: _allowComments,
                  onChanged: (value) {
                    setState(() {
                      _allowComments = value;
                    });
                  },
                ),
                
                SwitchListTile(
                  title: const Text('Envoyer une notification'),
                  subtitle: const Text('Les utilisateurs recevront une notification push'),
                  value: _sendNotification,
                  onChanged: (value) {
                    setState(() {
                      _sendNotification = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                
                // Boutons d'action
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _resetForm,
                        child: const Text('Réinitialiser'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _submitForm,
                        child: provider.isLoading
                            ? const CircularProgressIndicator()
                            : const Text('Créer l\'annonce'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _selectExpirationDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null && picked != _expirationDate) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedPriority = null;
      _selectedScope = AnnouncementScope.institution;
      _expirationDate = null;
      _isPublished = true;
      _allowComments = false;
      _sendNotification = true;
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final announcementData = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'scope': _selectedScope,
      'category': _selectedCategory!.name,
      'priority': _selectedPriority!.name,
      'expiration_date': _expirationDate?.toIso8601String(),
      'is_published': _isPublished,
      'allow_comments': _allowComments,
      'send_notification': _sendNotification,
    };

    final provider = context.read<AnnouncementProvider>();
    final success = await provider.createAnnouncement(announcementData);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Annonce créée avec succès!'),
          backgroundColor: Colors.green,
        ),
      );
      _resetForm();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Erreur lors de la création de l\'annonce'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  IconData _getCategoryIcon(AnnouncementCategory category) {
    switch (category) {
      case AnnouncementCategory.academic:
        return Icons.school;
      case AnnouncementCategory.administrative:
        return Icons.business;
      case AnnouncementCategory.event:
        return Icons.event;
      case AnnouncementCategory.urgent:
        return Icons.priority_high;
      case AnnouncementCategory.exam:
        return Icons.quiz;
      case AnnouncementCategory.registration:
        return Icons.app_registration;
      case AnnouncementCategory.scholarship:
        return Icons.card_giftcard;
      case AnnouncementCategory.alert:
        return Icons.warning;
      case AnnouncementCategory.general:
        return Icons.info;
      case AnnouncementCategory.emergency:
        return Icons.emergency;
    }
  }

  String _getCategoryLabel(AnnouncementCategory category) {
    switch (category) {
      case AnnouncementCategory.academic:
        return 'Académique';
      case AnnouncementCategory.administrative:
        return 'Administrative';
      case AnnouncementCategory.event:
        return 'Événement';
      case AnnouncementCategory.urgent:
        return 'Urgent';
      case AnnouncementCategory.exam:
        return 'Examen';
      case AnnouncementCategory.registration:
        return 'Inscription';
      case AnnouncementCategory.scholarship:
        return 'Bourse';
      case AnnouncementCategory.alert:
        return 'Alerte';
      case AnnouncementCategory.general:
        return 'Général';
      case AnnouncementCategory.emergency:
        return 'Urgence';
    }
  }

  IconData _getPriorityIcon(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return Icons.priority_high;
      case AnnouncementPriority.high:
        return Icons.arrow_upward;
      case AnnouncementPriority.normal:
        return Icons.remove;
      case AnnouncementPriority.low:
        return Icons.arrow_downward;
      case AnnouncementPriority.critical:
        return Icons.warning;
    }
  }

  String _getPriorityLabel(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.urgent:
        return 'Urgente';
      case AnnouncementPriority.high:
        return 'Haute';
      case AnnouncementPriority.normal:
        return 'Normale';
      case AnnouncementPriority.low:
        return 'Basse';
      case AnnouncementPriority.critical:
        return 'Critique';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  IconData _getScopeIcon(AnnouncementScope scope) {
    switch (scope) {
      case AnnouncementScope.institution:
        return Icons.business;
      case AnnouncementScope.local:
        return Icons.location_on;
      case AnnouncementScope.faculty:
        return Icons.school;
      case AnnouncementScope.department:
        return Icons.account_balance;
      case AnnouncementScope.program:
        return Icons.book;
      case AnnouncementScope.national:
        return Icons.public;
      case AnnouncementScope.interUniversity:
        return Icons.share;
      case AnnouncementScope.multiInstitutions:
        return Icons.domain;
    }
  }

  String _getScopeLabel(AnnouncementScope scope) {
    switch (scope) {
      case AnnouncementScope.institution:
        return 'Institution';
      case AnnouncementScope.local:
        return 'Local';
      case AnnouncementScope.faculty:
        return 'Faculté';
      case AnnouncementScope.department:
        return 'Département';
      case AnnouncementScope.program:
        return 'Programme/Filière';
      case AnnouncementScope.national:
        return 'National';
      case AnnouncementScope.interUniversity:
        return 'Inter-universitaire';
      case AnnouncementScope.multiInstitutions:
        return 'Multi-institutions';
    }
  }
}
