soit les codes suivant corriger les en generant du code brut broullon a copier code brut le backend ne marche pas on dit erreur lord de la creation du groupe puis tu va aussi ameliorer le formulaire de creation du groupe en fonction de la BD pour que tout corresponde meme le php :import 'package:flutter/material.dart';
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
  
  GroupType _selectedGroupType = GroupType.chat;
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
      setState(() => _isLoading = false);
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

              // Type et visibilité
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

              // Paramètres
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

              // Règles du groupe
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

              // Ajout de membres
              _buildSectionTitle('Ajouter des membres'),
              const SizedBox(height: 16),
              
              Container(
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
      case GroupType.chat:
        return 'Chat de groupe';
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
puis :<?php

class Group {
    private $conn;
    private $table_name = "user_groups";
    
    public $id;
    public $uuid;
    public $institution_id;
    public $program_id;
    public $department_id;
    public $parent_group_id;
    public $group_type;
    public $visibility;
    public $name;
    public $slug;
    public $description;
    public $cover_image_url;
    public $cover_url;
    public $icon_url;
    public $avatar_url;
    public $academic_level;
    public $academic_year_id;
    public $is_official;
    public $is_verified;
    public $is_national;
    public $max_members;
    public $current_members_count;
    public $join_approval_required;
    public $allow_member_posts;
    public $allow_member_invites;
    public $rules;
    public $tags;
    public $settings;
    public $created_by;
    public $created_at;
    public $updated_at;
    
    public function __construct($db) {
        $this->conn = $db;
    }
    
    /**
     * Créer un nouveau groupe
     */
    public function create() {
        $query = "INSERT INTO " . $this->table_name . " (
            uuid, institution_id, program_id, department_id, parent_group_id,
            group_type, visibility, name, slug, description, cover_image_url,
            icon_url, avatar_url, academic_level, academic_year_id, is_official,
            is_verified, is_national, max_members, current_members_count,
            join_approval_required, allow_member_posts, allow_member_invites,
            rules, tags, settings, created_by
        ) VALUES (
            UUID(), :institution_id, :program_id, :department_id, :parent_group_id,
            :group_type, :visibility, :name, :slug, :description, :cover_image_url,
            :icon_url, :avatar_url, :academic_level, :academic_year_id, :is_official,
            :is_verified, :is_national, :max_members, 0,
            :join_approval_required, :allow_member_posts, :allow_member_invites,
            :rules, :tags, :settings, :created_by
        )";
        
        $stmt = $this->conn->prepare($query);
        
        // Nettoyer et lier les valeurs
        $this->institution_id = $this->institution_id ? htmlspecialchars(strip_tags($this->institution_id)) : null;
        $this->program_id = $this->program_id ? htmlspecialchars(strip_tags($this->program_id)) : null;
        $this->department_id = $this->department_id ? htmlspecialchars(strip_tags($this->department_id)) : null;
        $this->parent_group_id = $this->parent_group_id ? htmlspecialchars(strip_tags($this->parent_group_id)) : null;
        $this->group_type = htmlspecialchars(strip_tags($this->group_type));
        $this->visibility = htmlspecialchars(strip_tags($this->visibility));
        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->slug = htmlspecialchars(strip_tags($this->slug));
        $this->description = $this->description ? htmlspecialchars(strip_tags($this->description)) : null;
        $this->cover_image_url = $this->cover_image_url ? htmlspecialchars(strip_tags($this->cover_image_url)) : null;
        $this->icon_url = $this->icon_url ? htmlspecialchars(strip_tags($this->icon_url)) : null;
        $this->avatar_url = $this->avatar_url ? htmlspecialchars(strip_tags($this->avatar_url)) : null;
        $this->academic_level = $this->academic_level ? htmlspecialchars(strip_tags($this->academic_level)) : null;
        $this->academic_year_id = $this->academic_year_id ? htmlspecialchars(strip_tags($this->academic_year_id)) : null;
        $this->is_official = $this->is_official ? htmlspecialchars(strip_tags($this->is_official)) : 0;
        $this->is_verified = $this->is_verified ? htmlspecialchars(strip_tags($this->is_verified)) : 0;
        $this->is_national = $this->is_national ? htmlspecialchars(strip_tags($this->is_national)) : 0;
        $this->max_members = $this->max_members ? htmlspecialchars(strip_tags($this->max_members)) : null;
        $this->join_approval_required = $this->join_approval_required ? htmlspecialchars(strip_tags($this->join_approval_required)) : 0;
        $this->allow_member_posts = $this->allow_member_posts ? htmlspecialchars(strip_tags($this->allow_member_posts)) : 1;
        $this->allow_member_invites = $this->allow_member_invites ? htmlspecialchars(strip_tags($this->allow_member_invites)) : 1;
        $this->rules = $this->rules ? htmlspecialchars(strip_tags($this->rules)) : null;
        $this->created_by = htmlspecialchars(strip_tags($this->created_by));
        
        // Convertir les tableaux en JSON
        $tags_json = is_array($this->tags) ? json_encode($this->tags) : $this->tags;
        $settings_json = is_array($this->settings) ? json_encode($this->settings) : $this->settings;
        
        $stmt->bindParam(":institution_id", $this->institution_id);
        $stmt->bindParam(":program_id", $this->program_id);
        $stmt->bindParam(":department_id", $this->department_id);
        $stmt->bindParam(":parent_group_id", $this->parent_group_id);
        $stmt->bindParam(":group_type", $this->group_type);
        $stmt->bindParam(":visibility", $this->visibility);
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":slug", $this->slug);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":cover_image_url", $this->cover_image_url);
        $stmt->bindParam(":icon_url", $this->icon_url);
        $stmt->bindParam(":avatar_url", $this->avatar_url);
        $stmt->bindParam(":academic_level", $this->academic_level);
        $stmt->bindParam(":academic_year_id", $this->academic_year_id);
        $stmt->bindParam(":is_official", $this->is_official);
        $stmt->bindParam(":is_verified", $this->is_verified);
        $stmt->bindParam(":is_national", $this->is_national);
        $stmt->bindParam(":max_members", $this->max_members);
        $stmt->bindParam(":join_approval_required", $this->join_approval_required);
        $stmt->bindParam(":allow_member_posts", $this->allow_member_posts);
        $stmt->bindParam(":allow_member_invites", $this->allow_member_invites);
        $stmt->bindParam(":rules", $this->rules);
        $stmt->bindParam(":tags", $tags_json);
        $stmt->bindParam(":settings", $settings_json);
        $stmt->bindParam(":created_by", $this->created_by);
        
        if ($stmt->execute()) {
            return $this->conn->lastInsertId();
        }
        
        return false;
    }
    
    /**
     * Mettre à jour un groupe
     */
    public function update() {
        $query = "UPDATE " . $this->table_name . " SET
            name = :name,
            description = :description,
            cover_image_url = :cover_image_url,
            avatar_url = :avatar_url,
            rules = :rules,
            max_members = :max_members,
            join_approval_required = :join_approval_required,
            allow_member_posts = :allow_member_posts,
            allow_member_invites = :allow_member_invites,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        
        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->description = htmlspecialchars(strip_tags($this->description));
        $this->cover_image_url = htmlspecialchars(strip_tags($this->cover_image_url));
        $this->avatar_url = htmlspecialchars(strip_tags($this->avatar_url));
        $this->rules = htmlspecialchars(strip_tags($this->rules));
        $this->max_members = htmlspecialchars(strip_tags($this->max_members));
        $this->join_approval_required = htmlspecialchars(strip_tags($this->join_approval_required));
        $this->allow_member_posts = htmlspecialchars(strip_tags($this->allow_member_posts));
        $this->allow_member_invites = htmlspecialchars(strip_tags($this->allow_member_invites));
        $this->id = htmlspecialchars(strip_tags($this->id));
        
        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":cover_image_url", $this->cover_image_url);
        $stmt->bindParam(":avatar_url", $this->avatar_url);
        $stmt->bindParam(":rules", $this->rules);
        $stmt->bindParam(":max_members", $this->max_members);
        $stmt->bindParam(":join_approval_required", $this->join_approval_required);
        $stmt->bindParam(":allow_member_posts", $this->allow_member_posts);
        $stmt->bindParam(":allow_member_invites", $this->allow_member_invites);
        $stmt->bindParam(":id", $this->id);
        
        return $stmt->execute();
    }
    
    /**
     * Obtenir un groupe par son ID
     */
    public function getById($id = null) {
        $groupId = $id ?? $this->id;
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $groupId);
        $stmt->execute();
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($row) {
            // Décoder les champs JSON
            if ($row['tags']) {
                $row['tags'] = json_decode($row['tags'], true);
            }
            if ($row['settings']) {
                $row['settings'] = json_decode($row['settings'], true);
            }
            return $row;
        }
        
        return false;
    }
    
    /**
     * Obtenir les groupes d'un utilisateur
     */
    public function getUserGroups($userId) {
        $query = "SELECT g.*, gm.role as user_role, gm.status as member_status, gm.unread_count
                 FROM " . $this->table_name . " g
                 INNER JOIN group_members gm ON g.id = gm.group_id
                 WHERE gm.user_id = :user_id AND gm.status = 'active'
                 ORDER BY g.updated_at DESC";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $userId);
        $stmt->execute();
        
        $groups = [];
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Décoder les champs JSON
            if ($row['tags']) {
                $row['tags'] = json_decode($row['tags'], true);
            }
            if ($row['settings']) {
                $row['settings'] = json_decode($row['settings'], true);
            }
            $groups[] = $row;
        }
        
        return $groups;
    }
    
    /**
     * Vérifier si un slug existe déjà
     */
    public function slugExists($slug) {
        $query = "SELECT id FROM " . $this->table_name . " WHERE slug = :slug";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":slug", $slug);
        $stmt->execute();
        
        return $stmt->rowCount() > 0;
    }
    
    /**
     * Incrémenter le nombre de membres
     */
    public function incrementMemberCount($groupId) {
        $query = "UPDATE " . $this->table_name . " 
                 SET current_members_count = current_members_count + 1 
                 WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $groupId);
        
        return $stmt->execute();
    }
    
    /**
     * Décrémenter le nombre de membres
     */
    public function decrementMemberCount($groupId) {
        $query = "UPDATE " . $this->table_name . " 
                 SET current_members_count = GREATEST(current_members_count - 1, 0) 
                 WHERE id = :id";
        
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":id", $groupId);
        
        return $stmt->execute();
    }
    
    /**
     * Rechercher des groupes
     */
    public function search($searchTerm, $userId, $limit = 20, $offset = 0) {
        $query = "SELECT g.*, 
                        CASE WHEN gm.user_id IS NOT NULL THEN 1 ELSE 0 END as is_member,
                        gm.role as user_role
                 FROM " . $this->table_name . " g
                 LEFT JOIN group_members gm ON g.id = gm.group_id AND gm.user_id = :user_id
                 WHERE (g.name LIKE :search_term OR g.description LIKE :search_term)
                 AND g.visibility IN ('public', 'official')
                 ORDER BY g.is_official DESC, g.current_members_count DESC
                 LIMIT :limit OFFSET :offset";
        
        $stmt = $this->conn->prepare($query);
        
        $searchPattern = "%{$searchTerm}%";
        
        $stmt->bindParam(":user_id", $userId);
        $stmt->bindParam(":search_term", $searchPattern);
        $stmt->bindParam(":limit", $limit, PDO::PARAM_INT);
        $stmt->bindParam(":offset", $offset, PDO::PARAM_INT);
        
        $stmt->execute();
        
        $groups = [];
        
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            // Décoder les champs JSON
            if ($row['tags']) {
                $row['tags'] = json_decode($row['tags'], true);
            }
            if ($row['settings']) {
                $row['settings'] = json_decode($row['settings'], true);
            }
            $groups[] = $row;
        }
        
        return $groups;
    }
}
?>
 et :<?php

require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../models/Group.php';
require_once __DIR__ . '/../models/GroupMember.php';
require_once __DIR__ . '/../models/User.php';
require_once __DIR__ . '/../../../vendor/autoload.php';

use Firebase\JWT\JWT;
use Firebase\JWT\Key;

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With, X-User-Id');

class GroupController {
    private $db;
    private $group;
    private $groupMember;
    private $user;
    private $secret_key = "YOUR_SECRET_KEY";
    
    public function __construct($db = null) {
        if ($db) {
            $this->db = $db;
        } else {
            $database = new Database();
            $this->db = $database->getConnection();
        }
        $this->group = new Group($this->db);
        $this->groupMember = new GroupMember($this->db);
        $this->user = new User($this->db);
    }
    
    /**
     * Créer un nouveau groupe
     */
    public function createGroup() {
        try {
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($data['name']) || empty($data['name'])) {
                http_response_code(400);
                echo json_encode(['error' => 'Le nom du groupe est requis']);
                return;
            }
            
            $this->group->name = $data['name'];
            $this->group->slug = $this->generateSlug($data['name']);
            $this->group->description = $data['description'] ?? null;
            $this->group->group_type = $data['group_type'] ?? 'chat';
            $this->group->visibility = $data['visibility'] ?? 'private';
            $this->group->created_by = $data['created_by'] ?? $this->getCurrentUserId();
            $this->group->institution_id = $data['institution_id'] ?? null;
            $this->group->program_id = $data['program_id'] ?? null;
            $this->group->department_id = $data['department_id'] ?? null;
            $this->group->avatar_url = $data['avatar_url'] ?? null;
            $this->group->cover_image_url = $data['cover_image_url'] ?? null;
            $this->group->rules = $data['rules'] ?? null;
            $this->group->max_members = $data['max_members'] ?? null;
            $this->group->join_approval_required = $data['join_approval_required'] ?? false;
            $this->group->allow_member_posts = $data['allow_member_posts'] ?? true;
            $this->group->allow_member_invites = $data['allow_member_invites'] ?? false;
            
            $groupId = $this->group->create();
            
            if ($groupId) {
                // Ajouter le créateur comme admin du groupe
                $this->groupMember->group_id = $groupId;
                $this->groupMember->user_id = $this->group->created_by;
                $this->groupMember->role = 'admin';
                $this->groupMember->status = 'active';
                $this->groupMember->joined_at = date('Y-m-d H:i:s');
                $this->groupMember->approved_at = date('Y-m-d H:i:s');
                $this->groupMember->approved_by = $this->group->created_by;
                
                $memberId = $this->groupMember->create();
                
                if ($memberId) {
                    http_response_code(201);
                    echo json_encode([
                        'success' => true,
                        'message' => 'Groupe créé avec succès',
                        'group_id' => $groupId,
                        'member_id' => $memberId
                    ]);
                } else {
                    http_response_code(500);
                    echo json_encode(['error' => 'Erreur lors de l\'ajout du créateur au groupe']);
                }
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Erreur lors de la création du groupe']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Obtenir les groupes de l'utilisateur
     */
    public function getUserGroups() {
        try {
            $userId = $this->getCurrentUserId();
            
            if (!$userId) {
                http_response_code(401);
                echo json_encode(['error' => 'Utilisateur non authentifié']);
                return;
            }
            
            $groups = $this->group->getUserGroups($userId);
            
            http_response_code(200);
            echo json_encode([
                'success' => true,
                'groups' => $groups
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Obtenir les détails d'un groupe
     */
    public function getGroup($groupId) {
        try {
            $userId = $this->getCurrentUserId();
            
            // Vérifier si l'utilisateur est membre du groupe
            if (!$this->groupMember->isMember($groupId, $userId)) {
                http_response_code(403);
                echo json_encode(['error' => 'Vous n\'êtes pas membre de ce groupe']);
                return;
            }
            
            $group = $this->group->getById($groupId);
            
            if ($group) {
                // Obtenir les membres du groupe
                $members = $this->groupMember->getGroupMembers($groupId);
                $group['members'] = $members;
                
                http_response_code(200);
                echo json_encode([
                    'success' => true,
                    'group' => $group
                ]);
            } else {
                http_response_code(404);
                echo json_encode(['error' => 'Groupe non trouvé']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Rejoindre un groupe
     */
    public function joinGroup($groupId) {
        try {
            $userId = $this->getCurrentUserId();
            
            if (!$userId) {
                http_response_code(401);
                echo json_encode(['error' => 'Utilisateur non authentifié']);
                return;
            }
            
            // Vérifier si le groupe existe
            $group = $this->group->getById($groupId);
            if (!$group) {
                http_response_code(404);
                echo json_encode(['error' => 'Groupe non trouvé']);
                return;
            }
            
            // Vérifier si l'utilisateur est déjà membre
            if ($this->groupMember->isMember($groupId, $userId)) {
                http_response_code(400);
                echo json_encode(['error' => 'Vous êtes déjà membre de ce groupe']);
                return;
            }
            
            // Vérifier si le groupe est plein
            if ($group['max_members'] > 0 && $group['current_members_count'] >= $group['max_members']) {
                http_response_code(400);
                echo json_encode(['error' => 'Le groupe est plein']);
                return;
            }
            
            $this->groupMember->group_id = $groupId;
            $this->groupMember->user_id = $userId;
            $this->groupMember->role = 'member';
            $this->groupMember->status = $group['join_approval_required'] ? 'pending' : 'active';
            $this->groupMember->joined_at = date('Y-m-d H:i:s');
            
            if (!$group['join_approval_required']) {
                $this->groupMember->approved_at = date('Y-m-d H:i:s');
                $this->groupMember->approved_by = $group['created_by'];
            }
            
            $memberId = $this->groupMember->create();
            
            if ($memberId) {
                // Mettre à jour le nombre de membres si approuvé automatiquement
                if (!$group['join_approval_required']) {
                    $this->group->incrementMemberCount($groupId);
                }
                
                http_response_code(201);
                echo json_encode([
                    'success' => true,
                    'message' => $group['join_approval_required'] 
                        ? 'Demande d\'adhésion envoyée' 
                        : 'Vous avez rejoint le groupe',
                    'status' => $this->groupMember->status,
                    'member_id' => $memberId
                ]);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Erreur lors de l\'adhésion au groupe']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Quitter un groupe
     */
    public function leaveGroup($groupId) {
        try {
            $userId = $this->getCurrentUserId();
            
            if (!$userId) {
                http_response_code(401);
                echo json_encode(['error' => 'Utilisateur non authentifié']);
                return;
            }
            
            // Vérifier si l'utilisateur est membre du groupe
            if (!$this->groupMember->isMember($groupId, $userId)) {
                http_response_code(400);
                echo json_encode(['error' => 'Vous n\'êtes pas membre de ce groupe']);
                return;
            }
            
            // Vérifier si c'est le dernier admin
            $adminCount = $this->groupMember->getAdminCount($groupId);
            $userRole = $this->groupMember->getUserRole($groupId, $userId);
            
            if ($userRole === 'admin' && $adminCount <= 1) {
                http_response_code(400);
                echo json_encode(['error' => 'Vous ne pouvez pas quitter le groupe car vous êtes le seul administrateur']);
                return;
            }
            
            if ($this->groupMember->leaveGroup($groupId, $userId)) {
                $this->group->decrementMemberCount($groupId);
                
                http_response_code(200);
                echo json_encode([
                    'success' => true,
                    'message' => 'Vous avez quitté le groupe'
                ]);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Erreur lors du départ du groupe']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Ajouter des membres à un groupe
     */
    public function addMembers($groupId) {
        try {
            $userId = $this->getCurrentUserId();
            
            // Vérifier si l'utilisateur a les permissions (admin/moderator)
            if (!$this->groupMember->hasPermission($groupId, $userId, 'can_invite')) {
                http_response_code(403);
                echo json_encode(['error' => 'Vous n\'avez pas la permission d\'ajouter des membres']);
                return;
            }
            
            $data = json_decode(file_get_contents('php://input'), true);
            
            if (!isset($data['user_ids']) || !is_array($data['user_ids'])) {
                http_response_code(400);
                echo json_encode(['error' => 'La liste des utilisateurs est requise']);
                return;
            }
            
            $addedMembers = [];
            $errors = [];
            
            foreach ($data['user_ids'] as $targetUserId) {
                // Vérifier si l'utilisateur est déjà membre
                if ($this->groupMember->isMember($groupId, $targetUserId)) {
                    $errors[] = "L'utilisateur $targetUserId est déjà membre";
                    continue;
                }
                
                // Ajouter le membre
                $this->groupMember->group_id = $groupId;
                $this->groupMember->user_id = $targetUserId;
                $this->groupMember->role = 'member';
                $this->groupMember->status = 'active';
                $this->groupMember->joined_at = date('Y-m-d H:i:s');
                $this->groupMember->approved_at = date('Y-m-d H:i:s');
                $this->groupMember->approved_by = $userId;
                
                $memberId = $this->groupMember->create();
                
                if ($memberId) {
                    $addedMembers[] = [
                        'user_id' => $targetUserId,
                        'member_id' => $memberId
                    ];
                    $this->group->incrementMemberCount($groupId);
                } else {
                    $errors[] = "Erreur lors de l'ajout de l'utilisateur $targetUserId";
                }
            }
            
            http_response_code(200);
            echo json_encode([
                'success' => true,
                'message' => count($addedMembers) . ' membre(s) ajouté(s) avec succès',
                'added_members' => $addedMembers,
                'errors' => $errors
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Supprimer un membre d'un groupe
     */
    public function removeMember($groupId, $memberId) {
        try {
            $userId = $this->getCurrentUserId();
            
            // Vérifier si l'utilisateur a les permissions
            if (!$this->groupMember->hasPermission($groupId, $userId, 'can_remove_members')) {
                http_response_code(403);
                echo json_encode(['error' => 'Vous n\'avez pas la permission de supprimer des membres']);
                return;
            }
            
            if ($this->groupMember->removeMember($memberId)) {
                $this->group->decrementMemberCount($groupId);
                
                http_response_code(200);
                echo json_encode([
                    'success' => true,
                    'message' => 'Membre supprimé avec succès'
                ]);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Erreur lors de la suppression du membre']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Mettre à jour les informations d'un groupe
     */
    public function updateGroup($groupId) {
        try {
            $userId = $this->getCurrentUserId();
            
            // Vérifier si l'utilisateur est admin du groupe
            if (!$this->groupMember->isAdmin($groupId, $userId)) {
                http_response_code(403);
                echo json_encode(['error' => 'Vous n\'êtes pas administrateur de ce groupe']);
                return;
            }
            
            $data = json_decode(file_get_contents('php://input'), true);
            
            $this->group->id = $groupId;
            
            if (isset($data['name'])) $this->group->name = $data['name'];
            if (isset($data['description'])) $this->group->description = $data['description'];
            if (isset($data['avatar_url'])) $this->group->avatar_url = $data['avatar_url'];
            if (isset($data['cover_image_url'])) $this->group->cover_image_url = $data['cover_image_url'];
            if (isset($data['rules'])) $this->group->rules = $data['rules'];
            if (isset($data['max_members'])) $this->group->max_members = $data['max_members'];
            if (isset($data['join_approval_required'])) $this->group->join_approval_required = $data['join_approval_required'];
            if (isset($data['allow_member_posts'])) $this->group->allow_member_posts = $data['allow_member_posts'];
            if (isset($data['allow_member_invites'])) $this->group->allow_member_invites = $data['allow_member_invites'];
            
            if ($this->group->update()) {
                http_response_code(200);
                echo json_encode([
                    'success' => true,
                    'message' => 'Groupe mis à jour avec succès'
                ]);
            } else {
                http_response_code(500);
                echo json_encode(['error' => 'Erreur lors de la mise à jour du groupe']);
            }
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['error' => 'Erreur serveur: ' . $e->getMessage()]);
        }
    }
    
    /**
     * Obtenir l'ID de l'utilisateur actuel depuis le token JWT
     */
    private function getCurrentUserId() {
        // D'abord essayer depuis le header X-User-ID (compatibilité)
        if (isset($_SERVER['HTTP_X_USER_ID'])) {
            return (int)$_SERVER['HTTP_X_USER_ID'];
        }
        
        // Sinon, extraire depuis le token JWT
        $headers = getallheaders();
        $authHeader = null;
        
        foreach ($headers as $key => $value) {
            if (strtolower($key) === 'authorization') {
                $authHeader = $value;
                break;
            }
        }
        
        if (empty($authHeader) && isset($_SERVER['HTTP_AUTHORIZATION'])) {
            $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
        }
        
        if (empty($authHeader)) {
            return null;
        }
        
        if (preg_match('/^(Bearer|Token)[\s]+(.*)$/i', $authHeader, $matches)) {
            $token = trim($matches[2]);
            
            try {
                $decoded = JWT::decode($token, new Key($this->secret_key, 'HS256'));
                return $decoded->data->id ?? null;
            } catch (Exception $e) {
                error_log('Erreur JWT: ' . $e->getMessage());
                return null;
            }
        }
        
        return null;
    }
    
    /**
     * Générer un slug unique à partir du nom
     */
    private function generateSlug($name) {
        $slug = strtolower(trim(preg_replace('/[^A-Za-z0-9-]+/', '-', $name)));
        $originalSlug = $slug;
        $counter = 1;
        
        while ($this->group->slugExists($slug)) {
            $slug = $originalSlug . '-' . $counter;
            $counter++;
        }
        
        return $slug;
    }
}

// Router les requêtes
$controller = new GroupController();
$method = $_SERVER['REQUEST_METHOD'];
$requestUri = $_SERVER['REQUEST_URI'];
$uriParts = explode('/', trim($requestUri, '/'));

// Trouver l'index de 'groups' dans l'URL
$groupsIndex = array_search('groups', $uriParts);
if ($groupsIndex !== false) {
    $actionIndex = $groupsIndex + 1;
    $action = $uriParts[$actionIndex] ?? '';
    
    switch ($method) {
        case 'POST':
            if ($action === 'create') {
                $controller->createGroup();
            } elseif (is_numeric($action) && isset($uriParts[$actionIndex + 1]) && $uriParts[$actionIndex + 1] === 'members') {
                $groupId = (int)$action;
                $controller->addMembers($groupId);
            } elseif (is_numeric($action) && isset($uriParts[$actionIndex + 1]) && $uriParts[$actionIndex + 1] === 'join') {
                $groupId = (int)$action;
                $controller->joinGroup($groupId);
            }
            break;
            
        case 'GET':
            if ($action === 'my') {
                $controller->getUserGroups();
            } elseif (is_numeric($action)) {
                $groupId = (int)$action;
                $controller->getGroup($groupId);
            }
            break;
            
        case 'PUT':
            if (is_numeric($action)) {
                $groupId = (int)$action;
                $controller->updateGroup($groupId);
            }
            break;
            
        case 'DELETE':
            if (is_numeric($action) && isset($uriParts[$actionIndex + 1]) && $uriParts[$actionIndex + 1] === 'leave') {
                $groupId = (int)$action;
                $controller->leaveGroup($groupId);
            } elseif (is_numeric($action) && isset($uriParts[$actionIndex + 1]) && $uriParts[$actionIndex + 1] === 'members' && isset($uriParts[$actionIndex + 2])) {
                $groupId = (int)$action;
                $memberId = (int)$uriParts[$actionIndex + 2];
                $controller->removeMember($groupId, $memberId);
            }
            break;
    }
} else {
    http_response_code(404);
    echo json_encode(['error' => 'Endpoint non trouvé']);
}
?>
 voici la BD :-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : dim. 11 jan. 2026 à 06:43
-- Version du serveur : 8.4.7
-- Version de PHP : 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `mycampus`
--

-- --------------------------------------------------------

--
-- Structure de la table `user_groups`
--

DROP TABLE IF EXISTS `user_groups`;
CREATE TABLE IF NOT EXISTS `user_groups` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `uuid` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `institution_id` bigint UNSIGNED NOT NULL,
  `program_id` bigint UNSIGNED DEFAULT NULL,
  `department_id` bigint UNSIGNED DEFAULT NULL,
  `parent_group_id` bigint UNSIGNED DEFAULT NULL,
  `group_type` enum('program','filiere','level','year','club','association','project','sport','cultural','academic','department','faculty','national','inter_university','custom') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `visibility` enum('public','private','secret','restricted','official') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'public',
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `cover_image_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `cover_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `icon_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_url` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `academic_level` enum('licence1','licence2','licence3','master1','master2','doctorat','all','L1','L2','L3','M1','M2','D1','D2','D3') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `academic_year_id` bigint UNSIGNED DEFAULT NULL,
  `is_official` tinyint(1) NOT NULL DEFAULT '0',
  `is_verified` tinyint(1) NOT NULL DEFAULT '0',
  `is_national` tinyint(1) NOT NULL DEFAULT '0',
  `max_members` int UNSIGNED DEFAULT '0',
  `current_members_count` int UNSIGNED NOT NULL DEFAULT '0',
  `join_approval_required` tinyint(1) NOT NULL DEFAULT '0',
  `allow_member_posts` tinyint(1) NOT NULL DEFAULT '1',
  `allow_member_invites` tinyint(1) NOT NULL DEFAULT '0',
  `rules` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `tags` json DEFAULT NULL,
  `settings` json DEFAULT NULL,
  `status` enum('active','archived','suspended','deleted') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `created_by` bigint UNSIGNED NOT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uuid` (`uuid`),
  UNIQUE KEY `unique_uuid` (`uuid`),
  UNIQUE KEY `unique_slug_institution` (`slug`,`institution_id`),
  KEY `idx_institution` (`institution_id`),
  KEY `idx_program` (`program_id`),
  KEY `idx_department` (`department_id`),
  KEY `idx_parent_group` (`parent_group_id`),
  KEY `idx_group_type` (`group_type`),
  KEY `idx_visibility` (`visibility`),
  KEY `idx_is_official` (`is_official`),
  KEY `idx_is_national` (`is_national`),
  KEY `idx_status` (`status`),
  KEY `idx_created_by` (`created_by`),
  KEY `fk_user_groups_academic_year` (`academic_year_id`),
  KEY `idx_user_groups_institution_type_status` (`institution_id`,`group_type`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `user_groups`
--

INSERT INTO `user_groups` (`id`, `uuid`, `institution_id`, `program_id`, `department_id`, `parent_group_id`, `group_type`, `visibility`, `name`, `slug`, `description`, `cover_image_url`, `cover_url`, `icon_url`, `avatar_url`, `academic_level`, `academic_year_id`, `is_official`, `is_verified`, `is_national`, `max_members`, `current_members_count`, `join_approval_required`, `allow_member_posts`, `allow_member_invites`, `rules`, `tags`, `settings`, `status`, `created_by`, `deleted_at`, `created_at`, `updated_at`) VALUES
(3, 'cfcd4d28-d95e-11f0-b81e-68f728e7cdfb', 1, 19, 1, NULL, '', 'private', 'Groupe de Test API', 'groupe-test-api', 'Groupe de test pour l API messagerie', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 0, 0, 1, 0, NULL, NULL, NULL, 'active', 39, NULL, '2025-12-15 02:36:08', '2025-12-15 02:36:08'),
(4, 'dacef13d-d95e-11f0-b81e-68f728e7cdfb', 1, 19, 1, NULL, '', 'public', 'Groupe d Étude', 'groupe-etude', 'Groupe pour les sessions d étude', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 1, 0, 1, 0, NULL, NULL, NULL, 'active', 39, NULL, '2025-12-15 02:36:26', '2025-12-15 02:36:26'),
(5, 'dad68bef-d95e-11f0-b81e-68f728e7cdfb', 1, 19, 1, NULL, 'project', 'private', 'Groupe Projet', 'groupe-projet', 'Groupe de travail sur les projets', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 0, 1, 0, 1, 0, NULL, NULL, NULL, 'active', 39, NULL, '2025-12-15 02:36:27', '2025-12-15 02:36:27'),
(9, '050f610d-d995-11f0-b81e-68f728e7cdfb', 1, NULL, NULL, NULL, '', 'public', 'Groupe Test API', 'groupe-test-api-1', 'Un groupe de test pour verifier que l&#039;API fonctionne', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, 0, 0, 1, 1, NULL, NULL, NULL, 'active', 1, NULL, '2025-12-15 09:04:10', '2025-12-15 09:04:10'),
(10, '05261d8e-d995-11f0-b81e-68f728e7cdfb', 1, NULL, NULL, NULL, '', 'public', 'Groupe Test API', 'groupe-test-api-2', 'Un groupe de test pour verifier que l&#039;API fonctionne', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, 0, 0, 1, 1, NULL, NULL, NULL, 'active', 1, NULL, '2025-12-15 09:04:10', '2025-12-15 09:04:10'),
(11, '11209f73-d995-11f0-b81e-68f728e7cdfb', 1, NULL, NULL, NULL, '', 'public', 'Groupe Test API', 'groupe-test-api-3', 'Un groupe de test pour verifier que l&#039;API fonctionne', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, 1, 0, 1, 1, NULL, NULL, NULL, 'active', 1, NULL, '2025-12-15 09:04:30', '2025-12-15 09:04:30'),
(12, '1128b595-d995-11f0-b81e-68f728e7cdfb', 1, NULL, NULL, NULL, '', 'public', 'Groupe Test API', 'groupe-test-api-4', 'Un groupe de test pour verifier que l&#039;API fonctionne', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, 1, 0, 1, 1, NULL, NULL, NULL, 'active', 1, NULL, '2025-12-15 09:04:30', '2025-12-15 09:04:30');

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `user_groups`
--
ALTER TABLE `user_groups` ADD FULLTEXT KEY `ft_name_description` (`name`,`description`);

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `user_groups`
--
ALTER TABLE `user_groups`
  ADD CONSTRAINT `fk_user_groups_academic_year` FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_groups_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_groups_department` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_groups_institution` FOREIGN KEY (`institution_id`) REFERENCES `institutions` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_groups_parent` FOREIGN KEY (`parent_group_id`) REFERENCES `user_groups` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_user_groups_program` FOREIGN KEY (`program_id`) REFERENCES `programs` (`id`) ON DELETE SET NULL ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
et :-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : dim. 11 jan. 2026 à 06:32
-- Version du serveur : 8.4.7
-- Version de PHP : 8.3.28

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `mycampus`
--

-- --------------------------------------------------------

--
-- Structure de la table `group_members`
--

DROP TABLE IF EXISTS `group_members`;
CREATE TABLE IF NOT EXISTS `group_members` (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id` bigint UNSIGNED NOT NULL,
  `user_id` bigint UNSIGNED NOT NULL,
  `role` enum('admin','moderator','leader','member') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'member',
  `status` enum('active','pending','banned','left') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `invited_by` bigint UNSIGNED DEFAULT NULL,
  `joined_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `approved_at` timestamp NULL DEFAULT NULL,
  `approved_by` bigint UNSIGNED DEFAULT NULL,
  `left_at` timestamp NULL DEFAULT NULL,
  `banned_at` timestamp NULL DEFAULT NULL,
  `banned_by` bigint UNSIGNED DEFAULT NULL,
  `ban_reason` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci,
  `can_post` tinyint(1) NOT NULL DEFAULT '1',
  `can_comment` tinyint(1) NOT NULL DEFAULT '1',
  `can_invite` tinyint(1) NOT NULL DEFAULT '0',
  `notification_enabled` tinyint(1) NOT NULL DEFAULT '1',
  `muted_until` timestamp NULL DEFAULT NULL,
  `last_read_at` timestamp NULL DEFAULT NULL,
  `unread_count` int UNSIGNED NOT NULL DEFAULT '0',
  `metadata` json DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_group_user` (`group_id`,`user_id`),
  KEY `idx_group` (`group_id`),
  KEY `idx_user` (`user_id`),
  KEY `idx_role` (`role`),
  KEY `idx_status` (`status`),
  KEY `idx_joined_at` (`joined_at`),
  KEY `fk_group_members_invited_by` (`invited_by`),
  KEY `fk_group_members_approved_by` (`approved_by`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `group_members`
--

INSERT INTO `group_members` (`id`, `group_id`, `user_id`, `role`, `status`, `invited_by`, `joined_at`, `approved_at`, `approved_by`, `left_at`, `banned_at`, `banned_by`, `ban_reason`, `can_post`, `can_comment`, `can_invite`, `notification_enabled`, `muted_until`, `last_read_at`, `unread_count`, `metadata`, `created_at`, `updated_at`) VALUES
(1, 4, 39, 'admin', 'active', NULL, '2025-12-15 02:36:26', '2025-12-15 02:36:26', 39, NULL, NULL, NULL, NULL, 1, 1, 0, 1, NULL, NULL, 0, NULL, '2025-12-15 02:36:26', '2025-12-15 02:36:26'),
(2, 5, 39, 'admin', 'active', NULL, '2025-12-15 02:36:27', '2025-12-15 02:36:27', 39, NULL, NULL, NULL, NULL, 1, 1, 0, 1, NULL, NULL, 0, NULL, '2025-12-15 02:36:27', '2025-12-15 02:36:27'),
(5, 11, 1, 'admin', 'active', NULL, '2025-12-15 08:04:30', '2025-12-15 08:04:30', 1, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, NULL, 0, NULL, '2025-12-15 09:04:30', '2025-12-15 09:04:30'),
(6, 12, 1, 'admin', 'active', NULL, '2025-12-15 08:04:30', '2025-12-15 08:04:30', 1, NULL, NULL, NULL, NULL, 1, 1, 1, 1, NULL, NULL, 0, NULL, '2025-12-15 09:04:30', '2025-12-15 09:04:30');

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `group_members`
--
ALTER TABLE `group_members`
  ADD CONSTRAINT `fk_group_members_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_group_members_group` FOREIGN KEY (`group_id`) REFERENCES `user_groups` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_group_members_invited_by` FOREIGN KEY (`invited_by`) REFERENCES `users` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_group_members_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
 assure toi que la creation de groupe et tout marche stp