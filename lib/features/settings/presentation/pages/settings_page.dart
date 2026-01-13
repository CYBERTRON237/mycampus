import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mycampus/features/auth/services/api_service.dart';
import 'package:mycampus/features/auth/services/auth_service.dart';
import 'package:mycampus/models/user_model.dart';
import 'package:mycampus/core/providers/theme_provider.dart';
import '../widgets/setting_switch_tile.dart';
import '../../controllers/settings_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final dashboardData = await ApiService().fetchDashboardData();
      
      if (dashboardData['success'] == true && mounted) {
        setState(() {
          _user = UserModel.fromJson(dashboardData['user']);
          _isLoading = false;
        });

        // Synchroniser le thème entre SettingsController et ThemeProvider
        if (mounted) {
          final settingsController = context.read<SettingsController>();
          final themeProvider = context.read<ThemeProvider>();
          
          // Charger les settings d'abord
          await settingsController.loadSettings();
          
          // Synchroniser les états de thème
          if (settingsController.darkMode != themeProvider.isDarkTheme) {
            // Utiliser l'état du ThemeProvider comme source de vérité
            // car il est connecté directement au MaterialApp
            settingsController.toggleDarkMode(themeProvider.isDarkTheme);
          }
        }
      } else {
        throw Exception(dashboardData['message'] ?? 'Erreur lors du chargement');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Erreur de chargement',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.red,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadUserData,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : Consumer<SettingsController>(
                  builder: (context, settings, child) {
                    // S'assurer que les settings sont chargés
                    if (!settings.isInitialized) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        settings.loadSettings();
                      });
                    }
                    
                    return Material(
                      child: ListView(
                      children: [
                        // Bouton de retour au dashboard
                        Container(
                          margin: const EdgeInsets.only(bottom: 20, left: 8, right: 8),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 28,
                                ),
                              ),
                              const Text(
                                'Retour au tableau de bord',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildAccountSection(context),
                        const SizedBox(height: 32),
                        _buildHeader('Confidentialité'),
                        _buildPrivacySection(context),
                        const SizedBox(height: 32),
                        _buildHeader('Sécurité'),
                        _buildSecuritySection(context),
                        const SizedBox(height: 32),
                        _buildHeader('Stockage et Données'),
                        _buildStorageSection(context),
                        const SizedBox(height: 32),
                        _buildHeader('Notifications'),
                        _buildNotificationSection(context),
                        const SizedBox(height: 32),
                        _buildHeader('Apparence'),
                        _buildAppearanceSection(context),
                        const SizedBox(height: 32),
                        _buildHeader('Paramètres de Chat'),
                        _buildChatSettingsSection(context),
                        const SizedBox(height: 32),
                        _buildHeader('Aide'),
                        _buildHelpSection(context),
                        const SizedBox(height: 32),
                        _buildHeader('À propos'),
                        _buildAboutSection(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
                )
              ;
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    if (_user == null) {
      return const SizedBox.shrink();
    }
    
    return Consumer<SettingsController>(
      builder: (context, settings, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                backgroundImage: _user!.avatarUrl != null ? NetworkImage(_user!.avatarUrl!) : null,
                child: _user!.avatarUrl == null
                    ? Text(
                        _user!.firstName.isNotEmpty ? _user!.firstName[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(
                '${_user!.firstName} ${_user!.lastName}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              subtitle: Text(
                _user!.phone ?? _user!.email,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              ),
              trailing: Icon(
                Icons.qr_code_scanner,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () => _showQRCode(context),
            ),
            const Divider(height: 1, indent: 88),
            _buildSettingItem(
              context,
              title: 'Compte',
              subtitle: 'Confidentialité, sécurité, changer de numéro',
              icon: Icons.key,
              iconColor: Colors.blue,
              onTap: () => _navigateToAccountSettings(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSettingItem(
            context,
            title: 'Dernière vue & en ligne',
            subtitle: 'Tout le monde',
            icon: Icons.access_time,
            iconColor: Colors.green,
            onTap: () => _showLastSeenOptions(context),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'Photo de profil',
            subtitle: 'Tout le monde',
            icon: Icons.camera_alt,
            iconColor: Colors.green,
            onTap: () => _showProfilePhotoOptions(context),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'About',
            subtitle: 'Everyone',
            icon: Icons.info,
            iconColor: Colors.green,
            onTap: () => _showAboutOptions(context),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'Status',
            subtitle: 'My contacts',
            icon: Icons.update,
            iconColor: Colors.green,
            onTap: () => _showStatusOptions(context),
          ),
          const Divider(height: 1, indent: 72),
          Consumer<SettingsController>(
            builder: (context, settings, _) => SettingSwitchTile(
              title: 'Read receipts',
              subtitle: 'If turned off, you won\'t send or receive read receipts',
              value: settings.readReceipts,
              onChanged: (value) => settings.toggleReadReceipts(value),
              icon: Icons.done_all,
              iconColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<SettingsController>(
            builder: (context, settings, _) => SettingSwitchTile(
              title: 'Screen security',
              subtitle: 'Show screen notification and security alerts',
              value: settings.screenSecurity,
              onChanged: (value) => settings.toggleScreenSecurity(value),
              icon: Icons.security,
              iconColor: Colors.blue,
            ),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'Two-step verification',
            subtitle: 'Not enabled',
            icon: Icons.verified_user,
            iconColor: Colors.blue,
            onTap: () => _setupTwoStepVerification(context),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'Change password',
            subtitle: 'Change your account password',
            icon: Icons.lock,
            iconColor: Colors.blue,
            onTap: () => _changePassword(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStorageSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSettingItem(
            context,
            title: 'Manage storage',
            subtitle: '2.3 GB used',
            icon: Icons.storage,
            iconColor: Colors.orange,
            onTap: () => _manageStorage(context),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'Network usage',
            subtitle: '2.1 GB sent, 5.8 GB received',
            icon: Icons.data_usage,
            iconColor: Colors.orange,
            onTap: () => _showNetworkUsage(context),
          ),
          const Divider(height: 1, indent: 72),
          Consumer<SettingsController>(
            builder: (context, settings, _) => SettingSwitchTile(
              title: 'Auto-download media',
              subtitle: 'When using mobile data',
              value: settings.autoDownload,
              onChanged: (value) => settings.toggleAutoDownload(value),
              icon: Icons.download,
              iconColor: Colors.orange,
            ),
          ),
          const Divider(height: 1, indent: 72),
          Consumer<SettingsController>(
            builder: (context, settings, _) => SettingSwitchTile(
              title: 'Upload quality',
              subtitle: 'Auto (recommended)',
              value: settings.highQualityUpload,
              onChanged: (value) => settings.toggleUploadQuality(value),
              icon: Icons.cloud_upload,
              iconColor: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<SettingsController>(
            builder: (context, settings, _) => SettingSwitchTile(
              title: 'Notifications',
              subtitle: 'Message notifications, group notifications',
              value: settings.notificationsEnabled,
              onChanged: (value) => settings.updateNotifications(value),
              icon: Icons.notifications,
              iconColor: Colors.red,
            ),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'Notification tone',
            subtitle: 'Default',
            icon: Icons.music_note,
            iconColor: Colors.red,
            onTap: () => _selectNotificationTone(context),
          ),
          const Divider(height: 1, indent: 72),
          Consumer<SettingsController>(
            builder: (context, settings, _) => SettingSwitchTile(
              title: 'Vibrate',
              subtitle: 'Vibrate when notifications arrive',
              value: settings.vibrate,
              onChanged: (value) => settings.toggleVibrate(value),
              icon: Icons.vibration,
              iconColor: Colors.red,
            ),
          ),
          const Divider(height: 1, indent: 72),
          Consumer<SettingsController>(
            builder: (context, settings, _) => SettingSwitchTile(
              title: 'Popup notification',
              subtitle: 'Show popup notification when app is closed',
              value: settings.popupNotification,
              onChanged: (value) => settings.togglePopupNotification(value),
              icon: Icons.notifications,
              iconColor: Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    return Consumer2<SettingsController, ThemeProvider>(
      builder: (context, settings, themeProvider, _) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSettingItem(
              context,
              title: 'Thème',
              subtitle: themeProvider.isDarkTheme ? 'Sombre' : 'Clair',
              icon: themeProvider.isDarkTheme ? Icons.dark_mode : Icons.light_mode,
              iconColor: Colors.purple,
              onTap: () => _showThemeOptions(context, settings),
            ),
            const Divider(height: 1, indent: 72),
            _buildSettingItem(
              context,
              title: 'Fond d\'écran',
              subtitle: 'Par défaut',
              icon: Icons.wallpaper,
              iconColor: Colors.purple,
              onTap: () => _selectWallpaper(context),
            ),
            const Divider(height: 1, indent: 72),
            Consumer<SettingsController>(
              builder: (context, settings, _) => _buildSettingItem(
                context,
                title: 'Fond d\'écran du chat',
                subtitle: settings.chatWallpaper ?? 'Par défaut',
                icon: Icons.chat,
                iconColor: Colors.purple,
                onTap: () => _selectChatWallpaper(context, settings),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatSettingsSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Consumer<SettingsController>(
            builder: (context, settings, _) => _buildSettingItem(
              context,
              title: 'Font size',
              subtitle: settings.fontSize,
              icon: Icons.text_fields,
              iconColor: Colors.teal,
              onTap: () => _showFontSizeOptions(context, settings),
            ),
          ),
          const Divider(height: 1, indent: 72),
          Consumer<SettingsController>(
            builder: (context, settings, _) => SettingSwitchTile(
              title: 'Enter key sends',
              subtitle: 'Enter key will send your message',
              value: settings.enterKeySends,
              onChanged: (value) => settings.toggleEnterKeySends(value),
              icon: Icons.send,
              iconColor: Colors.teal,
            ),
          ),
          const Divider(height: 1, indent: 72),
          Consumer<SettingsController>(
            builder: (context, settings, _) => SettingSwitchTile(
              title: 'Back up to Google Drive',
              subtitle: 'Daily at 2:00 AM',
              value: settings.backupEnabled,
              onChanged: (value) => settings.toggleBackup(value),
              icon: Icons.backup,
              iconColor: Colors.teal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSettingItem(
            context,
            title: 'Help center',
            subtitle: 'Find answers to your questions',
            icon: Icons.help,
            iconColor: Colors.blueGrey,
            onTap: () => _launchHelpCenter(),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'Contact us',
            subtitle: 'Questions or feedback? We\'d love to hear from you',
            icon: Icons.contact_support,
            iconColor: Colors.blueGrey,
            onTap: () => _contactSupport(),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'Terms of service',
            subtitle: 'Read our terms of service',
            icon: Icons.description,
            iconColor: Colors.blueGrey,
            onTap: () => _launchTermsOfService(),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'Privacy policy',
            subtitle: 'Read our privacy policy',
            icon: Icons.privacy_tip,
            iconColor: Colors.blueGrey,
            onTap: () => _launchPrivacyPolicy(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSettingItem(
            context,
            title: 'Version',
            subtitle: '2.24.18.36',
            icon: Icons.info,
            iconColor: Colors.blueGrey,
            onTap: () => _showVersionInfo(context),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'Share',
            subtitle: 'Share MyCampus with friends',
            icon: Icons.share,
            iconColor: Colors.blueGrey,
            onTap: () => _shareApp(),
          ),
          const Divider(height: 1, indent: 72),
          _buildSettingItem(
            context,
            title: 'Rate us',
            subtitle: 'Rate MyCampus on app stores',
            icon: Icons.star_rate,
            iconColor: Colors.blueGrey,
            onTap: () => _rateApp(),
          ),
          const Divider(height: 1, indent: 72),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).hintColor,
            ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // Action Methods
  void _showQRCode(BuildContext context) {
    if (_user == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('QR Code - ${_user!.firstName} ${_user!.lastName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_2,
                size: 100,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${_user!.firstName} ${_user!.lastName}\n${_user!.email}\nID: ${_user!.id}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text('Les autres peuvent scanner ce code pour vous ajouter comme contact.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Share QR code
              Navigator.pop(context);
            },
            child: const Text('Partager'),
          ),
        ],
      ),
    );
  }

  void _navigateToAccountSettings(BuildContext context) {
    // TODO: Navigate to account settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account settings coming soon')),
    );
  }

  void _showLastSeenOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Last seen & online'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Everyone'),
              value: 'everyone',
              groupValue: 'everyone',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('My contacts'),
              value: 'contacts',
              groupValue: 'everyone',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Nobody'),
              value: 'nobody',
              groupValue: 'everyone',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showProfilePhotoOptions(BuildContext context) {
    _showLastSeenOptions(context);
  }

  void _showAboutOptions(BuildContext context) {
    _showLastSeenOptions(context);
  }

  void _showStatusOptions(BuildContext context) {
    _showLastSeenOptions(context);
  }

  void _setupTwoStepVerification(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Two-step verification'),
        content: const Text('Add an extra layer of security to your account by requiring a PIN when registering your phone number with MyCampus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _changePassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password change coming soon')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.withOpacity(0.1),
            Colors.red.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.logout,
            color: Colors.red,
            size: 20,
          ),
        ),
        title: const Text(
          'Déconnexion',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        subtitle: const Text(
          'Se déconnecter de votre compte',
          style: TextStyle(
            color: Colors.red,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.red,
          size: 16,
        ),
        onTap: () => _showLogoutConfirmation(context),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkTheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Déconnexion',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir vous déconnecter ?',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 12),
            Text(
              'Vous devrez vous reconnecter pour accéder à votre compte.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: isDark ? Colors.white : Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Fermer le dialog
              await _performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
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

      final success = await authService.logout();
      
      // Fermer le dialog de chargement
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
    if (!mounted) return;

if (success) {
  Navigator.of(context).pushNamedAndRemoveUntil(
    '/login',
    (Route<dynamic> route) => false,
  );
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Erreur lors de la déconnexion'),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

    } catch (e) {
      // Fermer le dialog de chargement s'il est ouvert
  

if (!mounted) return;

Navigator.of(context).maybePop();

ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Erreur lors de la déconnexion: $e'),
    backgroundColor: Colors.red,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
);

    }
  }

  void _manageStorage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Storage management coming soon')),
    );
  }

  void _showNetworkUsage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Network Usage'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Sent: 2.1 GB'),
            Text('Received: 5.8 GB'),
            Text('Total: 7.9 GB'),
            SizedBox(height: 16),
            Text('Reset statistics: Never'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Reset statistics
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _selectNotificationTone(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Tone'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Default'),
              value: 'default',
              groupValue: 'default',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Bell'),
              value: 'bell',
              groupValue: 'default',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Chime'),
              value: 'chime',
              groupValue: 'default',
              onChanged: (value) => Navigator.pop(context),
            ),
            RadioListTile<String>(
              title: const Text('Silent'),
              value: 'silent',
              groupValue: 'default',
              onChanged: (value) => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _selectWallpaper(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wallpaper'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Default'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Solid Color'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('My Photos'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _selectChatWallpaper(BuildContext context, SettingsController settings) {
    _selectWallpaper(context);
  }

  void _showThemeOptions(BuildContext context, SettingsController settings) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir le thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Clair'),
              value: 'light',
              groupValue: themeProvider.isDarkTheme ? 'dark' : 'light',
              onChanged: (value) {
                if (value != null) {
                  themeProvider.toggleTheme();
                  // Synchroniser avec SettingsController pour la cohérence
                  settings.toggleDarkMode(false);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Sombre'),
              value: 'dark',
              groupValue: themeProvider.isDarkTheme ? 'dark' : 'light',
              onChanged: (value) {
                if (value != null) {
                  themeProvider.toggleTheme();
                  // Synchroniser avec SettingsController pour la cohérence
                  settings.toggleDarkMode(true);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Par défaut du système'),
              value: 'system',
              groupValue: 'system', // TODO: Implémenter le thème système
              onChanged: (value) {
                if (value != null) {
                  // TODO: Implémenter le thème système
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }

  void _showFontSizeOptions(BuildContext context, SettingsController settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Small'),
              value: 'small',
              groupValue: settings.fontSize,
              onChanged: (value) {
                if (value != null) {
                  settings.changeFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Medium'),
              value: 'medium',
              groupValue: settings.fontSize,
              onChanged: (value) {
                if (value != null) {
                  settings.changeFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<String>(
              title: const Text('Large'),
              value: 'large',
              groupValue: settings.fontSize,
              onChanged: (value) {
                if (value != null) {
                  settings.changeFontSize(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showVersionInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('MyCampus'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.school, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            const Text('Version 2.24.18.36'),
            const SizedBox(height: 8),
            const Text('© 2024 MyCampus'),
            const SizedBox(height: 16),
            const Text('Your campus life, simplified.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    Share.share(
      'Découvrez MyCampus - votre application de campus universitaire !',
      subject: 'MyCampus App',
    );
  }

  void _rateApp() {
    // TODO: Implémenter le lien vers le store
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notez-nous sur le store bientôt !')),
    );
  }

  Future<void> _launchHelpCenter() async {
    final Uri url = Uri.parse('https://help.mycampus.com');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@mycampus.com',
      query: 'subject=MyCampus Support Request',
    );
    if (!await launchUrl(emailLaunchUri)) {
      throw Exception('Could not launch $emailLaunchUri');
    }
  }

  Future<void> _launchTermsOfService() async {
    final Uri url = Uri.parse('https://mycampus.com/terms');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://mycampus.com/privacy');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('À propos'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('MyCampus'),
            Text('Version 1.0.0'),
            SizedBox(height: 16),
            Text('Application de campus universitaire moderne.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
