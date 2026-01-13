import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_styles.dart';
import '../../../auth/services/auth_service.dart';
import 'package:mycampus/features/profile/providers/profile_provider.dart';
import 'package:mycampus/features/profile/models/profile_model.dart';
import '../widgets/profile_completion_widget.dart';
import '../widgets/preinscription_status_widget.dart';
import '../widgets/academic_info_widget.dart';
import '../widgets/professional_info_widget.dart';
import '../widgets/profile_actions_widget.dart';
import '../widgets/student_profile_widget.dart';

class ProfessionalProfilePage extends StatefulWidget {
  const ProfessionalProfilePage({super.key});

  @override
  State<ProfessionalProfilePage> createState() => _ProfessionalProfilePageState();
}

class _ProfessionalProfilePageState extends State<ProfessionalProfilePage>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Load profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().initializeProfile();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();
    final authService = context.read<AuthService>();

    // Check if user is authenticated
    if (authService.currentUser == null) {
      return _buildNotAuthenticatedView(isDarkTheme);
    }

    return Scaffold(
      backgroundColor: isDarkTheme ? const Color(0xFF0A0E21) : AppColors.background,
      appBar: _buildAppBar(profileProvider),
      body: profileProvider.isLoading
          ? _buildLoadingView()
          : profileProvider.error != null
              ? _buildErrorView(profileProvider.error!)
              : _buildContentView(profileProvider, isDarkTheme),
    );
  }

  PreferredSizeWidget _buildAppBar(ProfileProvider provider) {

    // Always show tabs for better navigation
    final showTabs = provider.hasProfile;

    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: Column(
        children: [
          const Text(
            'Mon Profil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (provider.hasProfile)
            Text(
              provider.userDisplayName,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
      actions: [
        if (provider.hasProfile)
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, size: 18),
                    SizedBox(width: 8),
                    Text('Actualiser'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 8),
                    Text('Paramètres'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18),
                    SizedBox(width: 8),
                    Text('Déconnexion'),
                  ],
                ),
              ),
            ],
          ),
      ],
      bottom: showTabs
          ? TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.person), text: 'Profil'),
                Tab(icon: Icon(Icons.school), text: 'Académique'),
                Tab(icon: Icon(Icons.work), text: 'Professionnel'),
              ],
            )
          : null,
    );
  }

  Widget _buildNotAuthenticatedView(bool isDarkTheme) {
    return Scaffold(
      backgroundColor: isDarkTheme ? const Color(0xFF0A0E21) : AppColors.background,
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withAlpha(77),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.login,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Connexion requise',
                  style: AppStyles.heading2.copyWith(
                    color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Vous devez être connecté pour accéder à votre profil professionnel.',
                  style: AppStyles.bodyLarge.copyWith(
                    color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.login),
                    label: const Text('Se connecter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FE), Color(0xFFE8F5E9)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: 16),
            Text(
              'Chargement du profil...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FE), Color(0xFFE8F5E9)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur de chargement',
              style: AppStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProfileProvider>().initializeProfile();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentView(ProfileProvider provider, bool isDarkTheme) {
    debugPrint('=== BUILD CONTENT VIEW DEBUG ===');
    debugPrint('provider.hasProfile: ${provider.hasProfile}');
    debugPrint('provider.hasPreinscription: ${provider.hasPreinscription}');
    debugPrint('provider.isInvite: ${provider.isInvite}');
    debugPrint('provider.isUser: ${provider.isUser}');
    debugPrint('provider.isStudent: ${provider.isStudent}');
    debugPrint('provider.userRole: ${provider.userRole}');
    
    // Handle invite user without preinscription
    if (provider.isInvite && !provider.hasPreinscription) {
      debugPrint('Building invite view');
      return _buildInviteView(provider);
    }

    // Handle user with preinscription pending
    if (provider.isPreinscriptionPending) {
      debugPrint('Building pending preinscription view');
      return _buildPendingPreinscriptionView(provider);
    }

    // Handle case where profile is still loading or not available
    if (!provider.hasProfile) {
      debugPrint('Building no profile view');
      return _buildNoProfileView(provider, isDarkTheme);
    }

    debugPrint('Building full profile view with tabs');
    // Handle full profile view - show tabs for users with profile
    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: () => provider.initializeProfile(),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(provider, isDarkTheme),
            _buildAcademicTab(provider, isDarkTheme),
            _buildProfessionalTab(provider, isDarkTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildInviteView(ProfileProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FE), Color(0xFFE8F5E9)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(77),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.app_registration,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Complétez votre profil',
                style: AppStyles.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'En tant que nouvel utilisateur, vous devez compléter votre préinscription pour accéder à toutes les fonctionnalités.',
                style: AppStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/preinscription');
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Commencer la préinscription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoProfileView(ProfileProvider provider, bool isDarkTheme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkTheme 
              ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
              : [const Color(0xFFF8F9FE), const Color(0xFFE8F5E9)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Profile header with basic info
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withAlpha(26),
              child: Icon(
                Icons.person,
                size: 50,
                color: AppColors.primary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              provider.userDisplayName,
              style: AppStyles.heading2.copyWith(
                color: isDarkTheme ? Colors.white : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Chargement du profil...',
              style: AppStyles.bodyMedium.copyWith(
                color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 40),
            
            // Loading indicator or refresh button
            if (provider.isLoading)
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => provider.initializeProfile(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser le profil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPreinscriptionView(ProfileProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF8F9FE), Color(0xFFE8F5E9)],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // Profile header
            _buildProfileHeader(provider),
            
            const SizedBox(height: 32),
            
            // Preinscription status
            PreinscriptionStatusWidget(
              preinscription: provider.preinscription,
            ),
            
            const SizedBox(height: 32),
            
            // Profile completion
            ProfileCompletionWidget(
              completionPercentage: provider.profileCompletionPercentage,
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            ProfileActionsWidget(
              onViewPreinscription: () {
                Navigator.pushNamed(context, '/preinscription-detail');
              },
              onEditProfile: () {
                // Navigate to edit profile
              },
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ProfileProvider provider) {
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDarkTheme ? 77 : 26),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: provider.profilePhotoUrl != null
                ? ClipOval(
                    child: Image.network(
                      provider.profilePhotoUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar(provider);
                      },
                    ),
                  )
                : _buildDefaultAvatar(provider),
          ),
          
          const SizedBox(width: 20),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.userDisplayName,
                  style: AppStyles.heading2.copyWith(
                    color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.profile?.basicInfo.email ?? '',
                  style: AppStyles.bodyMedium.copyWith(
                    color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusBadge(provider, isDarkTheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ProfileProvider provider, bool isDarkTheme) {
    // Determine a human-readable status and associated color for the badge
    String status = 'Profil';
    Color color = AppColors.primary;

    // Prefer preinscription status if available
    if (provider.preinscription != null) {
      status = provider.preinscription!.status;
      switch (status.toLowerCase()) {
        case 'accepted':
          color = Colors.green;
          break;
        case 'pending':
        case 'en_attente':
          color = Colors.orange;
          break;
        case 'rejected':
        case 'rejetée':
          color = Colors.red;
          break;
        default:
          color = AppColors.primary;
      }
    } else if (provider.profile != null) {
      // Fall back to role-based status if no preinscription
      final role = provider.userRole;
      status = role;
      color = isDarkTheme ? Colors.white70 : AppColors.primary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withAlpha(77),
          width: 1,
        ),
      ),
      child: Text(
        status,
        style: AppStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(ProfileProvider provider) {
    final displayName = provider.userDisplayName;
    final initials = (displayName.isEmpty ? 'U' : displayName)
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
        .take(2)
        .join('');

    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFFF5F5F5),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? 'U' : initials,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(ProfileProvider provider, bool isDarkTheme) {
    // Return the complete StudentProfileWidget with all profile information
    return StudentProfileWidget(
      profile: provider.profile!,
      preinscription: provider.preinscription,
    );
  }

  Widget _buildAcademicTab(ProfileProvider provider, bool isDarkTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // University information
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDarkTheme ? 77 : 26),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.purple.withAlpha(26),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.purple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'UNIVERSITÉ',
                      style: AppStyles.heading3.copyWith(
                        color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildDetailRow(
                  'Université', 
                  provider.profile?.academicInfo.institutionName ?? 'Université de Yaoundé I',
                  isDarkTheme
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Academic information - always show widget even if data is incomplete
          AcademicInfoWidget(
            academicInfo: provider.academicProfile,
            profile: provider.profile,
          ),
          
          // Show preinscription details if available
          if (provider.preinscription != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkTheme ? 0.3 : 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Détails de la préinscription',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPreinscriptionDetails(provider.preinscription!, isDarkTheme),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPreinscriptionDetails(PreinscriptionDetail preinscription, bool isDarkTheme) {
    return Column(
      children: [
        _buildDetailRow('Faculté', preinscription.faculty, isDarkTheme),
        _buildDetailRow('Niveau d\'études', preinscription.studyLevel ?? 'Non spécifié', isDarkTheme),
        _buildDetailRow('Programme', preinscription.desiredProgram ?? 'Non spécifié', isDarkTheme),
        _buildDetailRow('Numéro d\'admission', preinscription.admissionNumber ?? 'Non attribué', isDarkTheme),
        _buildDetailRow('Statut', preinscription.status, isDarkTheme),
        if (preinscription.processedAt != null)
          _buildDetailRow('Date d\'admission', preinscription.processedAt!, isDarkTheme),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDarkTheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isDarkTheme ? Colors.white70 : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalTab(ProfileProvider provider, bool isDarkTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // Professional information - always show widget even if data is incomplete
          ProfessionalInfoWidget(
            professionalInfo: provider.professionalProfile,
            profile: provider.profile,
          ),
          
          // Show personal details from preinscription if available
          if (provider.preinscription != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDarkTheme ? 0.3 : 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Informations personnelles',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildPersonalDetails(provider.preinscription!, isDarkTheme),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails(PreinscriptionDetail preinscription, bool isDarkTheme) {
    return Column(
      children: [
        _buildDetailRow('Date de naissance', preinscription.dateOfBirth ?? 'Non spécifié', isDarkTheme),
        _buildDetailRow('Lieu de naissance', preinscription.placeOfBirth ?? 'Non spécifié', isDarkTheme),
        _buildDetailRow('Genre', preinscription.gender ?? 'Non spécifié', isDarkTheme),
        _buildDetailRow('Situation professionnelle', preinscription.professionalSituation ?? 'Non spécifié', isDarkTheme),
        _buildDetailRow('Première langue', preinscription.firstLanguage ?? 'Non spécifié', isDarkTheme),
        _buildDetailRow('Adresse', preinscription.residenceAddress ?? 'Non spécifié', isDarkTheme),
        _buildDetailRow('Téléphone', preinscription.phoneNumber ?? 'Non spécifié', isDarkTheme),
        if (preinscription.parentName != null) ...[
          _buildDetailRow('Nom du parent', preinscription.parentName!, isDarkTheme),
          _buildDetailRow('Téléphone parent', preinscription.parentPhone ?? 'Non spécifié', isDarkTheme),
        ],
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDarkTheme) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.caption.copyWith(
                  color: isDarkTheme ? Colors.white70 : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppStyles.bodyMedium.copyWith(
                  color: isDarkTheme ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        context.read<ProfileProvider>().refreshAllData();
        break;
      case 'settings':
        Navigator.pushNamed(context, '/settings');
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Afficher un indicateur de chargement
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const AlertDialog(
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

              // Fermer le dialog de chargement
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              
              if (success) {
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (Route<dynamic> route) => false,
                  );
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erreur lors de la déconnexion'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }  
              } catch (e) {
                // Fermer le dialog de chargement s'il est ouvert
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la déconnexion: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }
}
