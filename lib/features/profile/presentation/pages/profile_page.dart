import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../../auth/services/auth_service.dart';
import '../../../auth/services/api_service.dart';
import '../../../auth/models/user_model.dart' as auth_models;

class ProfilePage extends StatefulWidget {
  final auth_models.UserModel? user;
  
  const ProfilePage({super.key, this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  // Clés pour les widgets
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  
  // États de l'interface
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  
  // Contrôleurs d'animation
  late final AnimationController _fadeController;
  late final AnimationController _slideController;
  
  // Données utilisateur
  auth_models.UserModel? _currentUser;
  final Map<String, String> _formData = <String, String>{};
  
  // Gestion de la photo de profil
  File? _profileImage;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;
  
  // Contrôleurs pour les champs de formulaire
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  
  // Contrôleur d'animation
  AnimationController? _animationController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialisation des données du formulaire
    _formData.clear();
    _formData.addAll({
      'first_name': '',
      'last_name': '',
      'email': '',
      'phone': '',
      'address': '',
      'bio': '',
    });
    
    // Initialisation des contrôleurs d'animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Si un utilisateur est fourni, on l'utilise directement
    if (widget.user != null) {
      _currentUser = widget.user;
      _updateControllers(_currentUser!);
      _isLoading = false;
      _fadeController.forward();
      _slideController.forward();
    } else {
      // Sinon, on charge les données depuis l'API
      _loadUserData();
    }
  }

  @override
  void dispose() {
    // Libération des contrôleurs
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _usernameController.dispose();
    
    _animationController?.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    
    // Si un utilisateur est déjà fourni via le constructeur, on l'utilise directement
    if (widget.user != null) {
      if (!mounted) return;
      setState(() {
        _currentUser = widget.user;
        _updateControllers(_currentUser!);
        _isLoading = false;
      });
      _animationController?.forward();
      return;
    }
    
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Utiliser l'API get_user_profile pour récupérer les données utilisateur avec l'avatar
      final apiService = ApiService();
      final userId = await _getCurrentUserId();
      
      try {
      
      if (userId == null) {
        throw Exception('User ID not found');
      }
      
      // Appeler l'API get_user_profile
      final response = await http.get(
        Uri.parse('http://127.0.0.1/mycampus/api/get_user_profile.php?user_id=$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      if (!mounted) return;
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['user'] != null) {
          if (!mounted) return;
          setState(() {
            _currentUser = auth_models.UserModel.fromJson(responseData['user']);
            _updateControllers(_currentUser!);
            _isLoading = false;
          });
          
          _fadeController.forward();
          _slideController.forward();
        } else {
          throw Exception(responseData['message'] ?? 'Erreur lors du chargement des données');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
      
      } catch (e) {
      if (!mounted) return;
      
      debugPrint('Erreur lors du chargement des données utilisateur: $e');
      setState(() {
        _isLoading = false;
      });
      
      // Fallback: utiliser l'ancienne méthode si la nouvelle API échoue
      try {
        final dashboardData = await apiService.fetchDashboardData();
        
        if (!mounted) return;
        
        if (dashboardData['success'] == true && dashboardData['user'] != null) {
          if (!mounted) return;
          setState(() {
            _currentUser = auth_models.UserModel.fromJson(dashboardData['user']);
            _updateControllers(_currentUser!);
            _isLoading = false;
          });
          
          _fadeController.forward();
          _slideController.forward();
        }
      } catch (fallbackError) {
        debugPrint('Fallback error: $fallbackError');
      }
    }
  }

  Future<String?> _getCurrentUserId() async {
    try {
      // Récupérer l'ID utilisateur depuis le service d'authentification
      final authService = Provider.of<AuthService>(context, listen: false);
      final user = authService.currentUser;
      return user?.id;
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
      return null;
    }
  }

  void _updateControllers(auth_models.UserModel user) {
    _firstNameController.text = user.firstName;
    _lastNameController.text = user.lastName;
    _emailController.text = user.email;
    _phoneController.text = user.phone ?? '';
    _addressController.text = user.address ?? '';
    _bioController.text = user.bio ?? '';
    _locationController.text = '';
    _websiteController.text = '';
    _usernameController.text = '${user.firstName.toLowerCase()}${user.lastName.toLowerCase()}';
  }

  void _shareProfile() {
    if (!mounted) return;
    // Note: Ce lien est un exemple pour la démonstration
    final profileLink = 'mycampus://profile/${_usernameController.text.replaceFirst('@', '')}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profil partagé (démo): $profileLink'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Choisir la source'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Appareil photo'),
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Galerie'),
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
              ],
            ),
          );
        },
      );

      if (source != null) {
        final XFile? pickedFile = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
          maxWidth: 800,
          maxHeight: 800,
        );

        if (pickedFile != null && mounted) {
          setState(() {
            _profileImage = File(pickedFile.path);
          });
          await _uploadProfileImage();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la sélection de l\'image: $e');
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null || !mounted) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Créer une requête multipart pour l'upload
      final request = await _createMultipartRequest(_profileImage!);
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final Map<String, dynamic> data = {};
        
        // Analyser la réponse JSON
        try {
          if (responseData.isNotEmpty) {
            data.addAll(Map<String, dynamic>.from(
              // Parser simple pour la réponse
              Uri.splitQueryString(responseData)
            ));
          }
        } catch (e) {
          debugPrint('Erreur parsing response: $e');
        }

        if (data['success'] == true || response.statusCode == 200) {
          // Mettre à jour l'URL de l'avatar dans le modèle utilisateur
          final avatarUrl = data['avatar_url'] ?? '/uploads/avatars/${_currentUser!.id}_avatar.jpg';
          final updatedUser = _currentUser!.copyWith(avatarUrl: avatarUrl);
          
          if (mounted) {
            setState(() {
              _currentUser = updatedUser;
              _isUploadingImage = false;
            });
            _showSuccessSnackBar('Photo de profil mise à jour avec succès');
          }
        } else {
          throw Exception(data['message'] ?? 'Erreur lors de l\'upload');
        }
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de l\'upload: $e');
        setState(() {
          _profileImage = null;
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<http.MultipartRequest> _createMultipartRequest(File imageFile) async {
    final uri = Uri.parse('http://127.0.0.1/mycampus/api/upload_avatar.php');
    final request = http.MultipartRequest('POST', uri);
    
    // Ajouter les champs
    request.fields['user_id'] = _currentUser?.id ?? '0';
    request.fields['action'] = 'upload_avatar';
    
    // Ajouter le fichier
    final stream = http.ByteStream(imageFile.openRead());
    final length = await imageFile.length();
    final multipartFile = http.MultipartFile(
      'avatar',
      stream,
      length,
      filename: '${_currentUser?.id ?? 'user'}_avatar.jpg',
    );
    request.files.add(multipartFile);
    
    // Ajouter les headers
    request.headers.addAll({
      'Content-Type': 'multipart/form-data',
      'Accept': 'application/json',
    });
    
    return request;
  }

  Widget _buildAvatarImage() {
    // Si une image locale est sélectionnée (pendant l'upload)
    if (_profileImage != null) {
      return Image.file(
        _profileImage!,
        width: 74,
        height: 74,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }
    
    // Si l'utilisateur a une URL d'avatar
    if (_currentUser?.avatarUrl != null && _currentUser!.avatarUrl!.isNotEmpty) {
      final avatarUrl = _currentUser!.avatarUrl!;
      
      // Vérifier si c'est une URL complète ou un chemin relatif
      final fullUrl = avatarUrl.startsWith('http') 
          ? avatarUrl 
          : 'http://127.0.0.1/mycampus$avatarUrl';
      
      return Image.network(
        fullUrl,
        width: 74,
        height: 74,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildDefaultAvatar();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }
    
    // Avatar par défaut avec initiales
    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 74,
      height: 74,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF5F5F5),
      ),
      child: Center(
        child: Text(
          _getInitials(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
          String _getInitials() {
    final firstName = _firstNameController.text.isNotEmpty 
        ? _firstNameController.text[0].toUpperCase() 
        : '';
    final lastName = _lastNameController.text.isNotEmpty 
        ? _lastNameController.text[0].toUpperCase() 
        : '';
    return '$firstName$lastName';
  }

  Future<void> _toggleEdit() async {
    if (_isSaving) return;
    
    setState(() {
      _isEditing = !_isEditing;
      
      if (_isEditing) {
        // Activer le mode édition
        _animationController?.forward();
      } else {
        // Désactiver le mode édition et réinitialiser
        _animationController?.reverse();
        if (_currentUser != null) {
          _updateControllers(_currentUser as dynamic);
        }
      }
    });
  }

  Future<void> _saveProfile() async {
    if (!mounted) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Récupérer les données du formulaire
      final firstName = _formData['first_name']!.trim();
      final lastName = _formData['last_name']!.trim();
      final email = _formData['email']!.trim();
      final phone = _formData['phone']!.trim();
      final address = _formData['address']!.trim();
      final bio = _formData['bio']!.trim();
      
      if (!mounted) return;
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Créer un nouveau UserModel avec les données mises à jour
      final updatedUser = auth_models.UserModel(
        id: _currentUser?.id.toString() ?? '0',
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone.isNotEmpty ? phone : null,
        address: address.isNotEmpty ? address : null,
        bio: bio.isNotEmpty ? bio : null,
        role: _currentUser?.role ?? 'user',
        avatarUrl: _currentUser?.avatarUrl,
      );
      
      await authService.updateUserData(updatedUser);
      
      if (mounted) {
        setState(() {
          _currentUser = updatedUser;
          _isEditing = false;
          // Mettre à jour les contrôleurs avec les nouvelles valeurs
          _updateControllers(updatedUser);
          _isSaving = false;
        });
        _showSuccessSnackBar('Profil mis à jour avec succès');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Erreur lors de la mise à jour: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    
    // Si les données sont en cours de chargement
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0.5,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkTheme 
                ? [const Color(0xFF0A0E21), const Color(0xFF1D1E33)]
                : [const Color(0xFFF8F9FE), const Color(0xFFE8F5E9)],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }

    // Si une erreur s'est produite
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0.5,
        ),
        body: _buildErrorView(),
      );
    }

    // Affichage normal du profil avec style professionnel
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkTheme ? const Color(0xFF0A0E21) : AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isEditing)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: TextButton.icon(
                    onPressed: _isSaving ? null : _saveProfile,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.save, size: 18),
                    label: const Text(
                      'Enregistrer',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    onPressed: _toggleEdit,
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Modifier le profil',
                    style: IconButton.styleFrom(
                      minimumSize: const Size(40, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      drawer: null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkTheme 
              ? [const Color(0xFF0A0E21), const Color(0xFF1D1E33), const Color(0xFF0A0E21)]
              : [const Color(0xFFF8F9FE), const Color(0xFFE8F5E9), const Color(0xFFF8F9FE)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              
              // En-tête du profil
              _buildProfileHeader(),
              
              const SizedBox(height: 32),
              
              // Informations personnelles
              _buildProfileForm(),
              
              const SizedBox(height: 32),
              
              // Statistiques
              _buildStatsSection(),
              
              const SizedBox(height: 32),
              
              // Paramètres
              _buildSettingsSection(),
              
              const SizedBox(height: 32),
              
              // Bouton déconnexion
              _buildLogoutButton(),
              
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Impossible de charger les informations du profil',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserData,
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkTheme ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar cliquable comme Facebook/WhatsApp
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
                        ),
                        child: ClipOval(
                          child: _buildAvatarImage(),
                        ),
                      ),
                      // Icône caméra en bas à droite
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary,
                            border: Border.all(
                              color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: _isUploadingImage
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 14,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Informations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_firstNameController.text} ${_lastNameController.text}'.trim(),
                      style: AppStyles.heading2.copyWith(
                        color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _emailController.text,
                      style: AppStyles.bodyMedium.copyWith(
                        color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildRoleChip(),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Boutons d'action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.edit,
                label: 'Modifier',
                onTap: () => setState(() => _isEditing = !_isEditing),
                isDarkTheme: isDarkTheme,
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Partager',
                onTap: _shareProfile,
                isDarkTheme: isDarkTheme,
              ),
              _buildActionButton(
                icon: Icons.message,
                label: 'Message',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Messagerie en cours de développement'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                },
                isDarkTheme: isDarkTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip() {
    if (_currentUser == null) return const SizedBox.shrink();
    
    final role = _currentUser!.role.toLowerCase();
    final roleColor = AppColors.getRoleColor(role);
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: roleColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: roleColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        role.toUpperCase(),
        style: AppStyles.caption.copyWith(
          color: roleColor,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDarkTheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDarkTheme 
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: AppColors.primary, 
              size: 20
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileForm() {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkTheme ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations personnelles',
              style: AppStyles.heading3.copyWith(
                color: isDarkTheme ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            _buildNameFields(),
            const SizedBox(height: 16),
            _buildEmailField(),
            const SizedBox(height: 16),
            _buildPhoneField(),
            const SizedBox(height: 16),
            _buildAddressField(),
            const SizedBox(height: 16),
            _buildBioField(),
            const SizedBox(height: 24),
            
            // Bouton de modification en bas des informations personnelles
            if (!_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _toggleEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier les informations'),
                  style: AppStyles.elevatedButtonStyle,
                ),
              ),
            
            // Actions de sauvegarde uniquement en mode édition
            if (_isEditing) ...[
              const SizedBox(height: 16),
              _buildFormActions(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNameFields() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        TextFormField(
          controller: _firstNameController,
          decoration: AppStyles.inputDecoration.copyWith(
            labelText: 'Prénom',
            fillColor: isDarkTheme ? const Color(0xFF2D2E4F) : Colors.white,
          ),
          style: AppStyles.bodyText1.copyWith(
            color: isDarkTheme ? Colors.white : AppColors.textPrimary,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre prénom';
            }
            return null;
          },
          onSaved: (value) => _formData['first_name'] = value ?? '',
          readOnly: !_isEditing,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _lastNameController,
          decoration: AppStyles.inputDecoration.copyWith(
            labelText: 'Nom',
            fillColor: isDarkTheme ? const Color(0xFF2D2E4F) : Colors.white,
          ),
          style: AppStyles.bodyText1.copyWith(
            color: isDarkTheme ? Colors.white : AppColors.textPrimary,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre nom';
            }
            return null;
          },
          onSaved: (value) => _formData['last_name'] = value ?? '',
          readOnly: !_isEditing,
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: _emailController,
      decoration: AppStyles.inputDecoration.copyWith(
        labelText: 'Email',
        fillColor: isDarkTheme ? const Color(0xFF2D2E4F) : Colors.white,
      ),
      keyboardType: TextInputType.emailAddress,
      style: AppStyles.bodyText1.copyWith(
        color: isDarkTheme ? Colors.white : AppColors.textPrimary,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Veuillez entrer votre email';
        }
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
          return 'Veuillez entrer un email valide';
        }
        return null;
      },
      onSaved: (value) => _formData['email'] = value ?? '',
      readOnly: !_isEditing,
    );
  }

  Widget _buildPhoneField() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: _phoneController,
      decoration: AppStyles.inputDecoration.copyWith(
        labelText: 'Téléphone',
        fillColor: isDarkTheme ? const Color(0xFF2D2E4F) : Colors.white,
      ),
      keyboardType: TextInputType.phone,
      style: AppStyles.bodyText1.copyWith(
        color: isDarkTheme ? Colors.white : AppColors.textPrimary,
      ),
      validator: (value) => null, // Pas de validation spécifique pour le téléphone
      onSaved: (value) => _formData['phone'] = value ?? '',
      readOnly: !_isEditing,
    );
  }

  Widget _buildAddressField() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: _addressController,
      decoration: AppStyles.inputDecoration.copyWith(
        labelText: 'Adresse',
        fillColor: isDarkTheme ? const Color(0xFF2D2E4F) : Colors.white,
      ),
      style: AppStyles.bodyText1.copyWith(
        color: isDarkTheme ? Colors.white : AppColors.textPrimary,
      ),
      validator: (value) => null, // Pas de validation spécifique pour l'adresse
      onSaved: (value) => _formData['address'] = value ?? '',
      maxLines: 2,
      readOnly: !_isEditing,
    );
  }

  Widget _buildBioField() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;
    
    return TextFormField(
      controller: _bioController,
      decoration: AppStyles.inputDecoration.copyWith(
        labelText: 'À propos de moi',
        alignLabelWithHint: true,
        fillColor: isDarkTheme ? const Color(0xFF2D2E4F) : Colors.white,
      ),
      style: AppStyles.bodyText1.copyWith(
        color: isDarkTheme ? Colors.white : AppColors.textPrimary,
      ),
      enabled: _isEditing,
      maxLines: 4,
      validator: (value) => null, // Pas de validation spécifique pour la bio
      onSaved: (value) => _formData['bio'] = value ?? '',
    );
  }


  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      if (_currentUser != null) {
        _updateControllers(_currentUser as dynamic);
      }
    });
  }

  Widget _buildFormActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _cancelEdit,
          style: AppStyles.textButtonStyle,
          child: const Text('Annuler'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isSaving ? null : _saveProfile,
          style: AppStyles.elevatedButtonStyle,
          child: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Enregistrer'),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkTheme ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques',
            style: AppStyles.heading3.copyWith(
              color: isDarkTheme ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                icon: Icons.school,
                color: Colors.blue,
                title: 'Cours suivis',
                value: '12',
                onTap: () => _navigateToCourses(),
                isDarkTheme: isDarkTheme,
              ),
              _buildStatCard(
                icon: Icons.assignment,
                color: Colors.green,
                title: 'Devoirs rendus',
                value: '24',
                onTap: () => _navigateToAssignments(),
                isDarkTheme: isDarkTheme,
              ),
              _buildStatCard(
                icon: Icons.grade,
                color: Colors.orange,
                title: 'Moyenne générale',
                value: '15.5/20',
                onTap: () => _navigateToGrades(),
                isDarkTheme: isDarkTheme,
              ),
              _buildStatCard(
                icon: Icons.event_available,
                color: Colors.purple,
                title: 'Présence',
                value: '92%',
                onTap: () => _navigateToAttendance(),
                isDarkTheme: isDarkTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onTap,
    required bool isDarkTheme,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkTheme 
            ? const Color(0xFF2D2E4F)
            : AppColors.border,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: AppStyles.heading6.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: AppStyles.caption.copyWith(
                  color: isDarkTheme ? Colors.white70 : AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDarkTheme ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paramètres',
            style: AppStyles.heading3.copyWith(
              color: isDarkTheme ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Gérer les préférences de notification',
            onTap: () => _navigateToNotifications(),
            isDarkTheme: isDarkTheme,
          ),
          _buildSettingItem(
            icon: Icons.lock,
            title: 'Sécurité',
            subtitle: 'Mot de passe et authentification',
            onTap: () => _navigateToSecurity(),
            isDarkTheme: isDarkTheme,
          ),
          _buildSettingItem(
            icon: Icons.palette,
            title: 'Thème',
            subtitle: 'Personnaliser l\'apparence',
            onTap: () => _navigateToTheme(),
            isDarkTheme: isDarkTheme,
          ),
          _buildSettingItem(
            icon: Icons.help,
            title: 'Aide',
            subtitle: 'Centre d\'aide et support',
            onTap: () => _navigateToHelp(),
            isDarkTheme: isDarkTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDarkTheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon, 
                color: AppColors.primary, 
                size: 24
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.bodyLarge.copyWith(
                      color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppStyles.bodyMedium.copyWith(
                      color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: isDarkTheme ? Colors.white54 : AppColors.textLight,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout),
        label: const Text('Se déconnecter'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  // Méthodes de navigation
  void _navigateToCourses() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers les cours'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _navigateToAssignments() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers les devoirs'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _navigateToGrades() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers les notes'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _navigateToAttendance() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers la présence'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _navigateToNotifications() {
    if (!mounted) return;
    Navigator.of(context).pushNamed('/notifications');
  }

  void _navigateToSecurity() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers la sécurité'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _navigateToTheme() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers les thèmes'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  void _navigateToHelp() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navigation vers l\'aide'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

 void _confirmLogout() {
  if (!mounted) return;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Confirmer la déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop(); // fermer confirmation

              if (!mounted) return;

              // afficher loader avec le context de la page
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const AlertDialog(
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text('Déconnexion en cours...'),
                    ],
                  ),
                ),
              );

              try {
                final authService = context.read<AuthService>();
                final success = await authService.logout();

                if (!mounted) return;

                Navigator.of(context).maybePop(); // fermer loader (safe)

                if (success) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de la déconnexion'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;

                Navigator.of(context).maybePop(); // fermer loader

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur lors de la déconnexion: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      );
    },
  );
}

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
