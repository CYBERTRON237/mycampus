import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/conversation_list_widget.dart';
import '../widgets/search_user_widget.dart';
import 'whatsapp_layout_page.dart';

class MessagingHomePage extends StatefulWidget {
  const MessagingHomePage({super.key});

  @override
  State<MessagingHomePage> createState() => _MessagingHomePageState();
}

class _MessagingHomePageState extends State<MessagingHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2196F3),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Rechercher...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});
                },
              )
            : const Text(
                'Messages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
        actions: [
          if (!_isSearching) ...[
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              color: Colors.white,
              onSelected: (value) {
                switch (value) {
                  case 'new_group':
                    // TODO: Implement new group
                    break;
                  case 'new_broadcast':
                    // TODO: Implement new broadcast
                    break;
                  case 'linked_devices':
                    // TODO: Implement linked devices
                    break;
                  case 'starred_messages':
                    // TODO: Implement starred messages
                    break;
                  case 'settings':
                    // TODO: Navigate to settings
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'new_group',
                  child: Row(
                    children: [
                      Icon(Icons.group, color: Color(0xFF2196F3)),
                      SizedBox(width: 12),
                      Text('Nouveau groupe'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'new_broadcast',
                  child: Row(
                    children: [
                      Icon(Icons.broadcast_on_personal, color: Color(0xFF2196F3)),
                      SizedBox(width: 12),
                      Text('Nouveau message diffusé'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'linked_devices',
                  child: Row(
                    children: [
                      Icon(Icons.devices, color: Color(0xFF2196F3)),
                      SizedBox(width: 12),
                      Text('Appareils associés'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'starred_messages',
                  child: Row(
                    children: [
                      Icon(Icons.star_border, color: Color(0xFF2196F3)),
                      SizedBox(width: 12),
                      Text('Messages favoris'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Color(0xFF2196F3)),
                      SizedBox(width: 12),
                      Text('Paramètres'),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchController.clear();
                });
              },
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 16),
          tabs: const [
            Tab(
              icon: Icon(Icons.camera_alt),
              iconMargin: EdgeInsets.zero,
            ),
            Tab(text: 'DISCUSSIONS'),
            Tab(text: 'APPELS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCameraTab(),
          _buildConversationsTab(),
          _buildCallsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF2196F3),
              onPressed: () {
                setState(() {
                  _tabController.animateTo(2);
                });
              },
              child: const Icon(Icons.message, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildCameraTab() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 80, color: Colors.white54),
            SizedBox(height: 20),
            Text(
              'Appareil photo',
              style: TextStyle(color: Colors.white54, fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Glisser vers le haut pour accéder à la galerie',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsTab() {
    return Column(
      children: [
        if (_isSearching && _searchController.text.isNotEmpty)
          Expanded(
            child: SearchUserWidget(
              onUserSelected: (user) {
                Navigator.pushNamed(
                  context,
                  '/conversation',
                  arguments: {
                    'userId': user.id,
                    'userName': user.name,
                    'userAvatar': user.avatar,
                  },
                );
              },
            ),
          )
        else
          Expanded(
            child: ConversationListWidget(
              searchQuery: _isSearching ? _searchController.text : null,
 ),
          ),
      ],
    );
  }

  Widget _buildCallsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'Appels',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            'Fonctionnalité bientôt disponible',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
