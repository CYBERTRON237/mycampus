import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/group_model.dart';
import '../../data/repositories/group_repository.dart';
import '../widgets/search_user_widget.dart';
import '../../../../constants/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rulesController = TextEditingController();
  
  GroupType _selectedGroupType = GroupType.custom;
  GroupVisibility _selectedVisibility = GroupVisibility.private;
  bool _joinApprovalRequired = false;
  bool _allowMemberPosts = true;
  bool _allowMemberInvites = false;
  int? _maxMembers;
  
  List<int> _selectedMembers = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final groupRepository = Provider.of<GroupRepositoryImpl>(context, listen: false);
      
      final newGroup = GroupModel(
        name: _nameController.text.trim(),
        slug: _nameController.text.trim().toLowerCase().replaceAll(' ', '-'),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        groupType: _selectedGroupType,
        visibility: _selectedVisibility,
        rules: _rulesController.text.trim().isEmpty ? null : _rulesController.text.trim(),
        maxMembers: _maxMembers,
        joinApprovalRequired: _joinApprovalRequired,
        allowMemberPosts: _allowMemberPosts,
        allowMemberInvites: _allowMemberInvites,
        institutionId: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await groupRepository.createGroup(newGroup);

      result.fold(
        (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $error'),
              backgroundColor: AppColors.error,
            ),
          );
        },
        (GroupModel group) async {
          if (_selectedMembers.isNotEmpty && group.id != null) {
            await groupRepository.addMembers(group.id!, _selectedMembers);
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Groupe "${group.name}" créé avec succès!'),
                backgroundColor: AppColors.success,
              ),
            );
          }
          
          Navigator.of(context).pop(group);
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la création du groupe: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.primary,
        title: const Text(
          'Créer un groupe',
          style: TextStyle(color: AppColors.textOnPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textOnPrimary),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _createGroup,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                    ),
                  )
                : const Text(
                    'Créer',
                    style: TextStyle(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Informations de base'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom du groupe *',
                  hintText: 'Entrez le nom du groupe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
                style: TextStyle(
                  color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Le nom du groupe est requis';
                  }
                  if (value.trim().length < 3) {
                    return 'Le nom doit contenir au moins 3 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Décrivez le groupe (optionnel)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
                style: TextStyle(
                  color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Type et visibilité'),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<GroupType>(
                value: _selectedGroupType,
                decoration: InputDecoration(
                  labelText: 'Type de groupe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
                style: TextStyle(
                  color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                ),
                dropdownColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                items: GroupType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getGroupTypeDisplayName(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedGroupType = value!);
                },
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<GroupVisibility>(
                value: _selectedVisibility,
                decoration: InputDecoration(
                  labelText: 'Visibilité',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
                style: TextStyle(
                  color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                ),
                dropdownColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                items: GroupVisibility.values.map((visibility) {
                  return DropdownMenuItem(
                    value: visibility,
                    child: Text(_getVisibilityDisplayName(visibility)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => _selectedVisibility = value!);
                },
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Paramètres'),
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nombre maximum de membres',
                  hintText: 'Laissez vide pour illimité',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
                style: TextStyle(
                  color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _maxMembers = value.isEmpty ? null : int.tryParse(value);
                },
              ),
              const SizedBox(height: 16),
              
              SwitchListTile(
                title: Text(
                  'Approbation requise pour rejoindre',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Les nouveaux membres doivent être approuvés',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                ),
                value: _joinApprovalRequired,
                onChanged: (value) {
                  setState(() => _joinApprovalRequired = value);
                },
                activeColor: AppColors.primary,
              ),
              
              SwitchListTile(
                title: Text(
                  'Autoriser les membres à poster',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Tous les membres peuvent envoyer des messages',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                ),
                value: _allowMemberPosts,
                onChanged: (value) {
                  setState(() => _allowMemberPosts = value);
                },
                activeColor: AppColors.primary,
              ),
              
              SwitchListTile(
                title: Text(
                  'Autoriser les membres à inviter',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  'Les membres peuvent inviter d\'autres personnes',
                  style: TextStyle(
                    color: isDarkMode ? AppColors.textSecondary : AppColors.textSecondary,
                  ),
                ),
                value: _allowMemberInvites,
                onChanged: (value) {
                  setState(() => _allowMemberInvites = value);
                },
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Règles du groupe'),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _rulesController,
                decoration: InputDecoration(
                  labelText: 'Règles',
                  hintText: 'Définissez les règles du groupe (optionnel)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
                ),
                style: TextStyle(
                  color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
                ),
                maxLines: 5,
              ),
              const SizedBox(height: 24),

              _buildSectionTitle('Ajouter des membres'),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 300,
                child: SearchUserWidget(
                  onUserSelected: (user) {
                    if (!_selectedMembers.contains(int.parse(user.id))) {
                      setState(() {
                        _selectedMembers.add(int.parse(user.id));
                      });
                    }
                  },
                ),
              ),
              
              if (_selectedMembers.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedMembers.map((userId) {
                    return Chip(
                      label: Text('Utilisateur $userId'),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () {
                        setState(() {
                          _selectedMembers.remove(userId);
                        });
                      },
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: const TextStyle(color: AppColors.primary),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;

    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? AppColors.textPrimary : AppColors.textPrimary,
      ),
    );
  }
String _getGroupTypeDisplayName(GroupType type) {
  switch (type) {
    case GroupType.program:
      return 'Programme';
    case GroupType.filiere:
      return 'Filière';
    case GroupType.level:
      return 'Niveau';
    case GroupType.year:
      return 'Année';
    case GroupType.club:
      return 'Club';
    case GroupType.association:
      return 'Association';
    case GroupType.project:
      return 'Projet';
    case GroupType.sport:
      return 'Sport';
    case GroupType.cultural:
      return 'Culturel';
    case GroupType.academic:
      return 'Académique';
    case GroupType.department:
      return 'Département';
    case GroupType.faculty:
      return 'Faculté';
    case GroupType.national:
      return 'National';
    case GroupType.inter_university:
      return 'Inter-universitaire';
    case GroupType.custom:
      return 'Personnalisé';
    case GroupType.chat:
      return 'Discussion'; // <-- ici, plus d'erreur
    default:
      return 'Inconnu';
  }
}


  String _getVisibilityDisplayName(GroupVisibility visibility) {
    switch (visibility) {
      case GroupVisibility.public:
        return 'Public - Tout le monde peut voir et rejoindre';
      case GroupVisibility.private:
        return 'Privé - Visible sur invitation uniquement';
      case GroupVisibility.secret:
        return 'Secret - Invisible et sur invitation uniquement';
      case GroupVisibility.restricted:
        return 'Restreint - Visible mais approbation requise';
      case GroupVisibility.official:
        return 'Officiel - Groupe institutionnel';
    }
  }
}