import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/conversation_list_widget.dart';
import '../widgets/search_user_widget.dart';
import '../widgets/search_user_phone_widget.dart';
import '../widgets/contacts_list_widget.dart';
import '../widgets/contact_requests_widget.dart';
import '../widgets/add_contact_widget.dart';
import '../widgets/group_list_widget.dart';
import '../../domain/models/contact_model.dart';
import '../../domain/models/group_model.dart';
import '../../data/repositories/group_repository.dart';
import 'user_profile_page.dart';  
import 'create_group_page.dart';
import 'group_conversation_page.dart';
import 'dart:async';
import '../../../../constants/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/theme_provider.dart';
import 'package:flutter/foundation.dart';

class MessagingHomePage extends StatefulWidget {
  const MessagingHomePage({super.key});

  @override
  State<MessagingHomePage> createState() => _MessagingHomePageState();
}

class _MessagingHomePageState extends State<MessagingHomePage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _searchBarAnimationController;
  late AnimationController _fabAnimationController;
  late AnimationController _statusAnimationController;
  late Animation<double> _searchBarAnimation;
  late Animation<double> _fabAnimation;
  late Animation<Offset> _fabSlideAnimation;
  
  bool _isSearching = false;
  bool _searchByPhone = false;
  bool _isOnline = true;
  String _connectionStatus = 'Connecté';
  Timer? _connectionCheckTimer;
  int _unreadMessagesCount = 0;
  bool _isRefreshing = false;
  
  int _currentTabIndex = 0;
  bool _showAddContact = false;
  bool _showContactsList = false;
  bool _showArchivedChats = false;
  
  List<GroupModel> _groups = [];
  bool _isLoadingGroups = false;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _statusScrollController = ScrollController();
  late TabController _tabController;
  
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  double _scrollOffset = 0.0;
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _startConnectionCheck();
    _loadUnreadCount();
    _setupScrollListener();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadGroups();
        _startStatusAutoScroll();
      }
    });
  }

  void _initializeAnimations() {
    _searchBarAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _statusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _tabController = TabController(length: 3, vsync: this);
    
    _searchBarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchBarAnimationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _fabSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fabAnimationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final offset = _scrollController.offset;
      setState(() {
        _scrollOffset = offset;
        _showScrollToTop = offset > 500;
      });
    });
  }

  void _startStatusAutoScroll() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || !_statusScrollController.hasClients) {
        timer.cancel();
        return;
      }
      
      final maxScroll = _statusScrollController.position.maxScrollExtent;
      final currentScroll = _statusScrollController.offset;
      final delta = 80.0;
      
      if (currentScroll >= maxScroll - delta) {
        _statusScrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        _statusScrollController.animateTo(
          currentScroll + delta,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _loadGroups() async {
    if (!mounted) return;
    setState(() => _isLoadingGroups = true);
    
    try {
      final groupRepository = Provider.of<GroupRepositoryImpl>(context, listen: false);
      final result = await groupRepository.getUserGroups();
      
      result.fold(
        (error) {
          if (mounted) {
            // _showCustomSnackBar(
            //   'Erreur lors du chargement des groupes: $error',
            //   Icons.error_outline,
            //   AppColors.error,
            // );
          }
        },
        (groups) {
          if (mounted) {
            setState(() => _groups = groups);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        // _showCustomSnackBar(
        //   'Erreur: $e',
        //   Icons.error_outline,
        //   AppColors.error,
        // );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingGroups = false);
      }
    }
  }

  void _startConnectionCheck() {
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkConnectionStatus();
    });
  }

  Future<void> _checkConnectionStatus() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isOnline = true;
          _connectionStatus = 'Connecté';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOnline = false;
          _connectionStatus = 'Hors ligne';
        });
      }
    }
  }

  Future<void> _loadUnreadCount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _unreadMessagesCount = 0;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _checkConnectionStatus();
        _loadUnreadCount();
        break;
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchBarAnimationController.dispose();
    _fabAnimationController.dispose();
    _statusAnimationController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    _statusScrollController.dispose();
    _connectionCheckTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchByPhone = false;
        _searchBarAnimationController.reverse();
      } else {
        _searchBarAnimationController.forward();
      }
    });
  }

  void _activatePhoneSearch() {
    setState(() {
      _isSearching = true;
      _searchByPhone = true;
      _searchController.clear();
      _searchBarAnimationController.forward();
    });
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    
    HapticFeedback.lightImpact();
    setState(() => _isRefreshing = true);

    try {
      await Future.wait<void>([
        _loadUnreadCount(),
        _checkConnectionStatus(),
        if (_currentTabIndex == 1) _loadGroups(),
        Future.delayed(const Duration(milliseconds: 1000)),
      ]);

      if (mounted) {
        _showCustomSnackBar(
          'Actualisé à ${_formatTime(DateTime.now())}',
          Icons.check_circle,
          const Color(0xFF25D366),
        );
      }
    } catch (e) {
      if (mounted) {
        _showCustomSnackBar(
          'Erreur lors du rafraîchissement',
          Icons.error_outline,
          Colors.red[700]!,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _showCustomSnackBar(String message, IconData icon, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
        elevation: 6,
      ),
    );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkTheme;
    
    if (_showAddContact) {
      return _buildAddContactScreen(isDarkMode);
    }

    if (_showContactsList) {
      return _buildContactsListScreen(isDarkMode);
    }

    if (_showArchivedChats) {
      return _buildArchivedChatsScreen(isDarkMode);
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: _buildAppBar(isDarkMode),
      drawer: _buildDrawer(isDarkMode),
      body: _buildBody(isDarkMode),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAddContactScreen(bool isDarkMode) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.primary,
        elevation: 0,
        title: const Text(
          'Ajouter un contact',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _showAddContact = false);
          },
        ),
      ),
      body: AddContactWidget(
        onContactAdded: () {
          setState(() {
            _showAddContact = false;
            _currentTabIndex = 0;
          });
          _showCustomSnackBar(
            'Contact ajouté avec succès',
            Icons.check_circle,
            const Color(0xFF25D366),
          );
        },
      ),
    );
  }

  Widget _buildContactsListScreen(bool isDarkMode) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.primary,
        elevation: 0,
        title: const Text(
          'Mes contacts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _showContactsList = false);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _toggleSearch,
          ),
        ],
      ),
      body: ContactsListWidget(
        onContactTap: _handleContactSelected,
        onContactLongPress: _handleContactLongPress,
        showFavorites: true,
      ),
    );
  }

  Widget _buildArchivedChatsScreen(bool isDarkMode) {
    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.backgroundDark : AppColors.primary,
        elevation: 0,
        title: const Text(
          'Discussions archivées',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _showArchivedChats = false);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.archive_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune discussion archivée',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Les discussions que vous archivez apparaîtront ici',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode) {
    final appBarColor = isDarkMode ? AppColors.backgroundDark : AppColors.primary;
    final opacity = (_scrollOffset / 100).clamp(0.0, 1.0);
    
    return AppBar(
      backgroundColor: appBarColor,
      elevation: opacity * 4,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: appBarColor,
        statusBarIconBrightness: Brightness.light,
      ),
      title: _isSearching ? _buildSearchField() : _buildAppBarTitle(opacity),
      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _toggleSearch,
            )
          : IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                HapticFeedback.lightImpact();
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
      actions: _buildAppBarActions(),
    );
  }

  Widget _buildAppBarTitle(double opacity) {
    return AnimatedOpacity(
      opacity: 1.0 - (opacity * 0.3),
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'MyCampus Chat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          if (!_isOnline)
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const Text(
                  'En attente de connexion...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return FadeTransition(
      opacity: _searchBarAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.2, 0),
          end: Offset.zero,
        ).animate(_searchBarAnimation),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          keyboardType: _searchByPhone ? TextInputType.phone : TextInputType.text,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: _searchByPhone
                ? 'Numéro de téléphone...'
                : 'Rechercher...',
            hintStyle: const TextStyle(
              color: Colors.white60,
              fontSize: 16,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              _searchByPhone ? Icons.phone : Icons.search,
              color: Colors.white70,
              size: 22,
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white, size: 22),
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _searchController.clear());
            },
          ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 24),
          onPressed: () {
            HapticFeedback.lightImpact();
            _toggleSearch();
          },
        ),
      ];
    }

    return [
      IconButton(
        icon: Stack(
          children: [
            const Icon(Icons.search, color: Colors.white, size: 24),
            if (_unreadMessagesCount > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    _unreadMessagesCount > 99 ? '99+' : '$_unreadMessagesCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          _toggleSearch();
        },
      ),
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, color: Colors.white, size: 24),
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        offset: const Offset(0, 50),
        onSelected: _handleMenuSelection,
        itemBuilder: (context) => [
          _buildMenuItem('dashboard', Icons.dashboard_outlined, 'Dashboard', Colors.blue),
          const PopupMenuDivider(height: 1),
          _buildMenuItem('add_contact', Icons.person_add_outlined, 'Ajouter contact', const Color(0xFF075E54)),
          _buildMenuItem('search_phone', Icons.phone_outlined, 'Recherche téléphone', const Color(0xFF075E54)),
          const PopupMenuDivider(height: 1),
          _buildMenuItem('new_group', Icons.group_add_outlined, 'Nouveau groupe', const Color(0xFF25D366)),
          _buildMenuItem('new_broadcast', Icons.campaign_outlined, 'Diffusion', const Color(0xFF34B7F1)),
          const PopupMenuDivider(height: 1),
          _buildMenuItem('archived', Icons.archive_outlined, 'Archivées', Colors.orange),
          _buildMenuItem('starred', Icons.star_outline, 'Favoris', Colors.amber),
          const PopupMenuDivider(height: 1),
          _buildMenuItem('settings', Icons.settings_outlined, 'Paramètres', Colors.grey[700]!),
        ],
      ),
    ];
  }

  PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text, Color color) {
    return PopupMenuItem(
      value: value,
      height: 48,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 16),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuSelection(String value) {
    HapticFeedback.lightImpact();
    switch (value) {
      case 'dashboard':
        Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
        break;
      case 'add_contact':
        setState(() => _showAddContact = true);
        break;
      case 'search_phone':
        _activatePhoneSearch();
        break;
      case 'new_group':
        _handleCreateGroup();
        break;
      case 'archived':
        setState(() => _showArchivedChats = true);
        break;
      case 'starred':
      case 'new_broadcast':
      case 'settings':
        _showComingSoonDialog(value);
        break;
    }
  }

  void _showComingSoonDialog(String feature) {
    final featureNames = {
      'starred': 'Messages favoris',
      'new_broadcast': 'Liste de diffusion',
      'settings': 'Paramètres',
    };
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF075E54).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.info_outline, color: Color(0xFF075E54), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                featureNames[feature] ?? 'Fonctionnalité',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        content: const Text(
          'Cette fonctionnalité sera bientôt disponible.',
          style: TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Compris',
              style: TextStyle(
                color: Color(0xFF075E54),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Drawer _buildDrawer(bool isDarkMode) {
    final bgColor = isDarkMode ? AppColors.backgroundDark : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    
    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF075E54),
                    const Color(0xFF128C7E),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 32,
                      color: const Color(0xFF075E54),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Mon Profil',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _connectionStatus,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildDrawerItem(
                    Icons.account_circle_outlined,
                    'Mon profil',
                    textColor,
                    () {
                      Navigator.pop(context);
                      _showComingSoonDialog('settings');
                    },
                  ),
                  _buildDrawerItem(
                    Icons.group_outlined,
                    'Mes groupes',
                    textColor,
                    () {
                      Navigator.pop(context);
                      setState(() => _currentTabIndex = 1);
                    },
                  ),
                  _buildDrawerItem(
                    Icons.contacts_outlined,
                    'Mes contacts',
                    textColor,
                    () {
                      Navigator.pop(context);
                      setState(() => _showContactsList = true);
                    },
                  ),
                  _buildDrawerItem(
                    Icons.archive_outlined,
                    'Archives',
                    textColor,
                    () {
                      Navigator.pop(context);
                      setState(() => _showArchivedChats = true);
                    },
                  ),
                  const Divider(height: 1),
                  _buildDrawerItem(
                    Icons.settings_outlined,
                    'Paramètres',
                    textColor,
                    () {
                      Navigator.pop(context);
                      _showComingSoonDialog('settings');
                    },
                  ),
                  _buildDrawerItem(
                    Icons.help_outline,
                    'Aide',
                    textColor,
                    () {
                      Navigator.pop(context);
                      _showComingSoonDialog('settings');
                    },
                  ),
                  const Divider(height: 1),
                  _buildDrawerItem(
                    Icons.dashboard_outlined,
                    'Retour au dashboard',
                    Colors.blue,
                    () {
                      Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (route) => false);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Widget _buildBody(bool isDarkMode) {
    if (_isSearching) {
      return _buildSearchMode();
    }

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        _buildStatusSection(isDarkMode),
        _buildTabBarSection(isDarkMode),
        SliverFillRemaining(
          hasScrollBody: true,
          child: _buildCurrentTabContent(isDarkMode),
        ),
      ],
    );
  }

  Widget _buildStatusSection(bool isDarkMode) {
    final statusData = [
      {'name': 'Alice', 'time': '14:30', 'hasStory': true, 'isViewed': false},
      {'name': 'Bob', 'time': '12:15', 'hasStory': true, 'isViewed': true},
      {'name': 'Claire', 'time': 'Hier', 'hasStory': true, 'isViewed': false},
      {'name': 'David', 'time': '2j', 'hasStory': true, 'isViewed': true},
      {'name': 'Emma', 'time': '3j', 'hasStory': true, 'isViewed': false},
      {'name': 'Frank', 'time': '4j', 'hasStory': true, 'isViewed': true},
    ];

    return SliverToBoxAdapter(
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          border: Border(
            bottom: BorderSide(
              color: isDarkMode ? Colors.white10 : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Statuts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF075E54),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDarkMode ? Colors.white54 : Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _statusScrollController,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: statusData.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildMyStatusCircle(isDarkMode);
                  }
                  return _buildStatusCircle(
                    statusData[index - 1],
                    isDarkMode,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyStatusCircle(bool isDarkMode) {
    return Container(
      width: 68,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.white24 : Colors.grey[300]!,
                    width: 2.5,
                  ),
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                child: Icon(
                  Icons.person,
                  size: 28,
                  color: isDarkMode ? Colors.white54 : Colors.grey[600],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Mon statut',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCircle(Map<String, dynamic> status, bool isDarkMode) {
    final hasStory = status['hasStory'] as bool;
    final isViewed = status['isViewed'] as bool? ?? false;
    final name = status['name'] as String;
    
    return Container(
      width: 68,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: hasStory && !isViewed
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00D4FF), Color(0xFF0066FF)],
                    )
                  : null,
              border: Border.all(
                color: isViewed 
                    ? (isDarkMode ? Colors.white24 : Colors.grey[300]!)
                    : Colors.transparent,
                width: 2.5,
              ),
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                border: Border.all(
                  color: isDarkMode ? AppColors.surfaceDark : Colors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person,
                size: 24,
                color: isDarkMode ? Colors.white54 : Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarSection(bool isDarkMode) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabBarDelegate(
        TabBar(
          controller: _tabController,
          onTap: (index) {
            HapticFeedback.selectionClick();
            setState(() => _currentTabIndex = index);
          },
          tabs: const [
            Tab(
              icon: Icon(Icons.chat_bubble_outline, size: 22),
              text: 'Discussions',
            ),
            Tab(
              icon: Icon(Icons.group_outlined, size: 22),
              text: 'Groupes',
            ),
            Tab(
              icon: Icon(Icons.notifications_outlined, size: 22),
              text: 'Demandes',
            ),
          ],
          labelColor: const Color(0xFF075E54),
          unselectedLabelColor: isDarkMode ? Colors.white54 : Colors.grey[600],
          indicatorColor: const Color(0xFF075E54),
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        isDarkMode,
      ),
    );
  }

  Widget _buildCurrentTabContent(bool isDarkMode) {
    return IndexedStack(
      index: _currentTabIndex,
      children: [
        _buildConversationsTab(isDarkMode),
        _buildGroupsTab(isDarkMode),
        _buildRequestsTab(isDarkMode),
      ],
    );
  }

  Widget _buildConversationsTab(bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFF075E54),
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      child: ConversationListWidget(
        searchQuery: null,
        onConversationTap: (userId, userName, userAvatar) {
          HapticFeedback.lightImpact();
          Navigator.pushNamed(
            context,
            '/conversation',
            arguments: {
              'userId': userId,
              'userName': userName,
              'userAvatar': userAvatar,
            },
          );
        },
      ),
    );
  }

  Widget _buildGroupsTab(bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: _loadGroups,
      color: const Color(0xFF075E54),
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      child: GroupListWidget(
        groups: _groups,
        isLoading: _isLoadingGroups,
        onGroupTap: _handleGroupTap,
        onGroupLongPress: _handleGroupLongPress,
        onCreateGroup: _handleCreateGroup,
      ),
    );
  }

  Widget _buildRequestsTab(bool isDarkMode) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: const Color(0xFF075E54),
      backgroundColor: isDarkMode ? AppColors.surfaceDark : Colors.white,
      child: ContactRequestsWidget(
        onRequestProcessed: () {
          _showCustomSnackBar(
            'Demande traitée avec succès',
            Icons.check_circle,
            const Color(0xFF25D366),
          );
        },
      ),
    );
  }

  Widget _buildSearchMode() {
    return Column(
      children: [
        if (_searchByPhone)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF9C4),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFF57C00), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Recherchez un utilisateur par son numéro',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFF57C00),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: _searchByPhone
              ? SearchUserPhoneWidget(onUserSelected: _handleUserSelected)
              : SearchUserWidget(onUserSelected: _handleUserSelected),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_showScrollToTop)
          ScaleTransition(
            scale: _fabAnimation,
            child: FloatingActionButton.small(
              heroTag: 'scroll_top',
              backgroundColor: Colors.white,
              elevation: 4,
              onPressed: () {
                HapticFeedback.mediumImpact();
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                );
              },
              child: const Icon(
                Icons.keyboard_arrow_up,
                color: Color(0xFF075E54),
              ),
            ),
          ),
        if (_showScrollToTop) const SizedBox(height: 12),
        ScaleTransition(
          scale: _fabAnimation,
          child: SlideTransition(
            position: _fabSlideAnimation,
            child: FloatingActionButton(
              backgroundColor: const Color(0xFF25D366),
              elevation: 6,
              onPressed: () {
                HapticFeedback.mediumImpact();
                _showActionMenu();
              },
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            ),
          ),
        ),
      ],
    );
  }

  void _showActionMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDarkMode = themeProvider.isDarkTheme;
        
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Actions rapides',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF075E54),
                    ),
                  ),
                ),
              ),
              _buildActionMenuItem(
                Icons.group_add_outlined,
                'Nouveau groupe',
                'Créer un groupe de discussion',
                const Color(0xFF128C7E),
                () {
                  Navigator.pop(context);
                  _handleCreateGroup();
                },
              ),
              _buildActionMenuItem(
                Icons.campaign_outlined,
                'Nouvelle diffusion',
                'Envoyer un message à plusieurs contacts',
                const Color(0xFF34B7F1),
                () {
                  Navigator.pop(context);
                  _showComingSoonDialog('new_broadcast');
                },
              ),
              _buildActionMenuItem(
                Icons.person_add_outlined,
                'Ajouter un contact',
                'Rechercher et ajouter des contacts',
                const Color(0xFF25D366),
                () {
                  Navigator.pop(context);
                  setState(() => _showAddContact = true);
                },
              ),
              _buildActionMenuItem(
                Icons.contacts_outlined,
                'Voir les contacts',
                'Parcourir tous vos contacts',
                const Color(0xFF075E54),
                () {
                  Navigator.pop(context);
                  setState(() => _showContactsList = true);
                },
              ),
              _buildActionMenuItem(
                Icons.search_outlined,
                'Rechercher',
                'Rechercher par nom ou téléphone',
                Colors.blue[700]!,
                () {
                  Navigator.pop(context);
                  _toggleSearch();
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionMenuItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  void _handleUserSelected(dynamic user) async {
    // Afficher un indicateur de chargement immédiatement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Création de la conversation..."),
          ],
        ),
      ),
    );

    try {
      // Pré-créer la conversation en arrière-plan
      final conversationId = await _createConversationInBackground(user.id);
      
      // Fermer le dialogue de chargement
      Navigator.pop(context);
      
      // Naviguer vers la conversation avec l'ID pré-créé
      Navigator.pushNamed(
        context,
        '/conversation',
        arguments: {
          'userId': user.id,
          'userName': user.name,
          'userAvatar': user.avatar,
          'conversationId': conversationId, // Ajouter l'ID pré-créé
        },
      );
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      Navigator.pop(context);
      
      // Afficher un message d'erreur
      _showCustomSnackBar(
        'Erreur lors de la création de la conversation',
        Icons.error_outline,
        AppColors.error,
      );
      
      // Fallback: naviguer quand même vers la conversation
      Navigator.pushNamed(
        context,
        '/conversation',
        arguments: {
          'userId': user.id,
          'userName': user.name,
          'userAvatar': user.avatar,
        },
      );
    }
  }

  Future<String> _createConversationInBackground(String userId) async {
    final currentUserId = await _getCurrentUserId();
    
    final client = http.Client();
    String url = kIsWeb 
        ? 'http://localhost/mycampus/api/messaging/messages/get_conversation_id.php'
        : 'http://127.0.0.1/mycampus/api/messaging/messages/get_conversation_id.php';
    
    final conversationResponse = await client.get(
      Uri.parse(url).replace(queryParameters: {
        'user_id': currentUserId,
        'participant_id': userId,
      }),
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': currentUserId,
      },
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw Exception('Délai d\'attente dépassé'),
    );

    if (conversationResponse.statusCode == 200) {
      final conversationData = json.decode(conversationResponse.body);
      if (conversationData['success'] == true) {
        return conversationData['conversation_id'].toString();
      } else {
        throw Exception('Échec de la création de conversation');
      }
    } else {
      throw Exception('Erreur serveur: ${conversationResponse.statusCode}');
    }
  }

  Future<String> _getCurrentUserId() async {
    // Simuler la récupération de l'ID utilisateur actuel
    // Dans une vraie implémentation, cela viendrait du service d'authentification
    return "1"; // Placeholder
  }

  void _handleContactSelected(ContactModel contact) async {
    HapticFeedback.lightImpact();
    
    // Afficher un indicateur de chargement immédiatement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text("Création de la conversation..."),
          ],
        ),
      ),
    );

    try {
      // Pré-créer la conversation en arrière-plan
      final conversationId = await _createConversationInBackground(contact.contactUserId);
      
      // Fermer le dialogue de chargement
      Navigator.pop(context);
      
      // Naviguer vers la conversation avec l'ID pré-créé
      Navigator.pushNamed(
        context,
        '/conversation',
        arguments: {
          'userId': contact.contactUserId,
          'userName': contact.fullName,
          'userAvatar': contact.avatar,
          'conversationId': conversationId, // Ajouter l'ID pré-créé
        },
      );
    } catch (e) {
      // Fermer le dialogue de chargement en cas d'erreur
      Navigator.pop(context);
      
      // Afficher un message d'erreur
      _showCustomSnackBar(
        'Erreur lors de la création de la conversation',
        Icons.error_outline,
        AppColors.error,
      );
      
      // Fallback: naviguer quand même vers la conversation
      Navigator.pushNamed(
        context,
        '/conversation',
        arguments: {
          'userId': contact.contactUserId,
          'userName': contact.fullName,
          'userAvatar': contact.avatar,
        },
      );
    }
  }

  void _handleContactLongPress(ContactModel contact) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final isDarkMode = themeProvider.isDarkTheme;
        
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? AppColors.surfaceDark : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: const Color(0xFF075E54).withOpacity(0.1),
                      backgroundImage: contact.avatar != null ? NetworkImage(contact.avatar!) : null,
                      child: contact.avatar == null
                          ? Text(
                              contact.initials,
                              style: const TextStyle(
                                color: Color(0xFF075E54),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
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
                            contact.fullName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getRoleLabel(contact.role),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _buildContactActionTile(
                Icons.chat_bubble_outline,
                'Message',
                const Color(0xFF075E54),
                () {
                  Navigator.pop(context);
                  _handleContactSelected(contact);
                },
              ),
              _buildContactActionTile(
                contact.isFavorite ? Icons.star : Icons.star_border,
                contact.isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                Colors.amber,
                () {
                  Navigator.pop(context);
                  _showCustomSnackBar(
                    contact.isFavorite ? 'Retiré des favoris' : 'Ajouté aux favoris',
                    Icons.star,
                    Colors.amber,
                  );
                },
              ),
              _buildContactActionTile(
                Icons.info_outline,
                'Voir le profil',
                Colors.blue,
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(contact: contact),
                    ),
                  );
                },
              ),
              _buildContactActionTile(
                Icons.archive_outlined,
                'Archiver',
                Colors.orange,
                () {
                  Navigator.pop(context);
                  _showCustomSnackBar(
                    'Discussion archivée',
                    Icons.archive,
                    Colors.orange,
                  );
                },
              ),
              _buildContactActionTile(
                Icons.delete_outline,
                'Supprimer',
                Colors.red,
                () {
                  Navigator.pop(context);
                  _confirmDeleteContact(contact);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactActionTile(IconData icon, String title, Color color, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
    );
  }

  String _getRoleLabel(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return 'Étudiant';
      case 'teacher':
        return 'Enseignant';
      case 'admin':
        return 'Administrateur';
      default:
        return role;
    }
  }

  void _confirmDeleteContact(ContactModel contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Supprimer le contact',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer ${contact.fullName} de vos contacts ?',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showCustomSnackBar(
                'Contact supprimé',
                Icons.delete,
                Colors.red,
              );
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleGroupTap(GroupModel group) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupConversationPage(group: group),
      ),
    ).then((_) => _loadGroups());
  }

  void _handleGroupLongPress(GroupModel group) {
    HapticFeedback.mediumImpact();
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFF075E54).withOpacity(0.1),
                    child: const Icon(
                      Icons.group,
                      color: Color(0xFF075E54),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${group.currentMembersCount} membres',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _buildContactActionTile(
              Icons.info_outline,
              'Infos du groupe',
              Colors.blue,
              () {
                Navigator.pop(context);
                _showComingSoonDialog('settings');
              },
            ),
            _buildContactActionTile(
              Icons.notifications_outlined,
              'Mettre en sourdine',
              Colors.orange,
              () {
                Navigator.pop(context);
                _showCustomSnackBar(
                  'Groupe mis en sourdine',
                  Icons.notifications_off,
                  Colors.orange,
                );
              },
            ),
            _buildContactActionTile(
              Icons.archive_outlined,
              'Archiver',
              Colors.grey[700]!,
              () {
                Navigator.pop(context);
                _showCustomSnackBar(
                  'Groupe archivé',
                  Icons.archive,
                  Colors.grey[700]!,
                );
              },
            ),
            _buildContactActionTile(
              Icons.exit_to_app,
              'Quitter le groupe',
              Colors.red,
              () {
                Navigator.pop(context);
                _confirmLeaveGroup(group);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _handleCreateGroup() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateGroupPage(),
      ),
    ).then((result) {
      if (result != null) {
        _loadGroups();
        _showCustomSnackBar(
          'Groupe créé avec succès',
          Icons.check_circle,
          const Color(0xFF25D366),
        );
      }
    });
  }

  void _confirmLeaveGroup(GroupModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Quitter le groupe',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir quitter "${group.name}" ?',
          style: const TextStyle(height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final groupRepository = Provider.of<GroupRepositoryImpl>(context, listen: false);
                final result = await groupRepository.leaveGroup(group.id!);
                
                result.fold(
                  (error) => _showCustomSnackBar('Erreur: $error', Icons.error, AppColors.error),
                  (_) {
                    _showCustomSnackBar(
                      'Vous avez quitté le groupe',
                      Icons.check_circle,
                      const Color(0xFF25D366),
                    );
                    _loadGroups();
                  },
                );
              } catch (e) {
                _showCustomSnackBar('Erreur: $e', Icons.error, AppColors.error);
              }
            },
            child: const Text(
              'Quitter',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDarkMode;

  _TabBarDelegate(this.tabBar, this.isDarkMode);

  @override
  double get minExtent => 52;
  
  @override
  double get maxExtent => 52;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.surfaceDark : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.white10 : const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar || isDarkMode != oldDelegate.isDarkMode;
  }
}
