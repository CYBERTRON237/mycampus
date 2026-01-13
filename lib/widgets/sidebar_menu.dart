import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class DashboardSidebar extends StatefulWidget {
  final UserModel user;
  final List<Map<String, dynamic>> modules;
  final String selectedModuleKey;
  final void Function(String key) onModuleSelected;
  final VoidCallback onSidebarToggle;
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;

  const DashboardSidebar({
    required this.user,
    required this.modules,
    required this.selectedModuleKey,
    required this.onModuleSelected,
    required this.onSidebarToggle,
    required this.isDarkTheme,
    required this.onToggleTheme,
    required this.onLogout,
    super.key,
  });

  @override
  State<DashboardSidebar> createState() => _DashboardSidebarState();
}

class _DashboardSidebarState extends State<DashboardSidebar> with SingleTickerProviderStateMixin {
  int _hovered = -1;
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredModules {
    if (_searchQuery.isEmpty) return widget.modules;
    return widget.modules.where((module) {
      final label = module['label'].toString().toLowerCase();
      return label.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: 290,
        height: double.infinity,
        decoration: BoxDecoration(
          color: widget.isDarkTheme ? const Color(0xFF1A1D2E) : Colors.white,
          border: Border(
            right: BorderSide(
              color: widget.isDarkTheme ? Colors.indigo.withOpacity(0.3) : Colors.indigo.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isDarkTheme ? Colors.black.withOpacity(0.3) : Colors.indigo.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(3, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _SidebarHeader(
              user: user,
              isDarkTheme: widget.isDarkTheme,
              onSidebarToggle: widget.onSidebarToggle,
            ),
            const SizedBox(height: 12),
            _SearchBar(
              controller: _searchController,
              isDarkTheme: widget.isDarkTheme,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 8),
            _UserQuickStats(user: user, isDarkTheme: widget.isDarkTheme),
            const SizedBox(height: 12),
            Expanded(
              child: _ModulesList(
                modules: _filteredModules,
                selectedModuleKey: widget.selectedModuleKey,
                onModuleSelected: widget.onModuleSelected,
                isDarkTheme: widget.isDarkTheme,
                scrollController: _scrollController,
                hovered: _hovered,
                onHoverChange: (index) {
                  setState(() {
                    _hovered = index;
                  });
                },
              ),
            ),
            _SidebarFooter(
              isDarkTheme: widget.isDarkTheme,
              onToggleTheme: widget.onToggleTheme,
              onLogout: widget.onLogout,
              onSidebarToggle: widget.onSidebarToggle,
            ),
          ],
        ),
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  final UserModel user;
  final bool isDarkTheme;
  final VoidCallback onSidebarToggle;
  const _SidebarHeader({
    required this.user,
    required this.isDarkTheme,
    required this.onSidebarToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkTheme
              ? [const Color(0xFF2E3440), const Color(0xFF3B4252)]
              : [Colors.indigo[50]!, Colors.blue[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkTheme ? Colors.indigo.withOpacity(0.3) : Colors.indigo.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                backgroundImage: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                backgroundColor: Colors.indigo[700],
                radius: 28,
                child: (user.avatarUrl == null || user.avatarUrl == '' || user.firstName.isEmpty)
                    ? const Icon(Icons.account_circle, size: 35, color: Colors.white)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: isDarkTheme ? const Color(0xFF2E3440) : Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${user.firstName} ${user.lastName}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isDarkTheme ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.role,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkTheme ? Colors.indigoAccent[100] : Colors.indigo[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if ((user.institutionName ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.school, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          user.institutionName ?? '',
                          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_left,
              color: isDarkTheme ? Colors.white70 : Colors.black54,
            ),
            onPressed: onSidebarToggle,
            tooltip: "Cacher le menu",
            iconSize: 22,
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDarkTheme;
  final ValueChanged<String> onChanged;
  const _SearchBar({
    required this.controller,
    required this.isDarkTheme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Rechercher un module...',
          hintStyle: TextStyle(color: isDarkTheme ? Colors.white54 : Colors.grey[600]),
          prefixIcon: Icon(Icons.search, color: isDarkTheme ? Colors.white54 : Colors.grey[600]),
          filled: true,
          fillColor: isDarkTheme ? const Color(0xFF2E3440) : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

class _UserQuickStats extends StatelessWidget {
  final UserModel user;
  final bool isDarkTheme;
  const _UserQuickStats({required this.user, required this.isDarkTheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 0,
        color: isDarkTheme ? const Color(0xFF2E3440) : Colors.blue[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _QuickStatItem(
                icon: Icons.groups,
                value: '12',
                label: 'Groupes',
                isDarkTheme: isDarkTheme,
              ),
              _QuickStatItem(
                icon: Icons.message,
                value: '45',
                label: 'Messages',
                isDarkTheme: isDarkTheme,
              ),
              _QuickStatItem(
                icon: Icons.notifications,
                value: '8',
                label: 'Notifs',
                isDarkTheme: isDarkTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDarkTheme;
  const _QuickStatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: isDarkTheme ? Colors.indigoAccent[100] : Colors.indigo[700], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkTheme ? Colors.white : Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDarkTheme ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _ModulesList extends StatelessWidget {
  final List<Map<String, dynamic>> modules;
  final String selectedModuleKey;
  final void Function(String key) onModuleSelected;
  final bool isDarkTheme;
  final ScrollController scrollController;
  final int hovered;
  final ValueChanged<int> onHoverChange;

  const _ModulesList({
    required this.modules,
    required this.selectedModuleKey,
    required this.onModuleSelected,
    required this.isDarkTheme,
    required this.scrollController,
    required this.hovered,
    required this.onHoverChange,
  });

  @override
  Widget build(BuildContext context) {
    if (modules.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Aucun module trouvé',
            style: TextStyle(
              color: isDarkTheme ? Colors.white70 : Colors.grey[600],
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: modules.length,
      itemBuilder: (c, i) {
        final m = modules[i];
        final selected = m['key'] == selectedModuleKey;
        return MouseRegion(
          onEnter: (_) => onHoverChange(i),
          onExit: (_) => onHoverChange(-1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected
                  ? (isDarkTheme ? Colors.indigo[900]?.withOpacity(0.5) : Colors.indigo[100])
                  : (hovered == i
                      ? (isDarkTheme ? Colors.indigo[900]?.withOpacity(0.3) : Colors.indigo[50])
                      : Colors.transparent),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? (isDarkTheme ? Colors.indigoAccent : Colors.indigo)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              leading: Icon(
                m['icon'],
                color: selected
                    ? (isDarkTheme ? Colors.indigoAccent[100] : Colors.indigo[900])
                    : (isDarkTheme ? Colors.white70 : Colors.indigo[700]),
                size: 24,
              ),
              title: Text(
                m['label'],
                style: TextStyle(
                  color: selected
                      ? (isDarkTheme ? Colors.white : Colors.indigo[900])
                      : (isDarkTheme ? Colors.white70 : Colors.grey[800]),
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
              trailing: selected
                  ? Icon(
                      Icons.arrow_right,
                      color: isDarkTheme ? Colors.indigoAccent[100] : Colors.indigo,
                      size: 24,
                    )
                  : null,
              onTap: () => onModuleSelected(m['key']),
            ),
          ),
        );
      },
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  final bool isDarkTheme;
  final VoidCallback onToggleTheme;
  final VoidCallback onLogout;
  final VoidCallback onSidebarToggle;
  const _SidebarFooter({
    required this.isDarkTheme,
    required this.onToggleTheme,
    required this.onLogout,
    required this.onSidebarToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDarkTheme ? Colors.white12 : Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onToggleTheme,
                  icon: Icon(
                    isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                    size: 18,
                  ),
                  label: Text(
                    isDarkTheme ? "Clair" : "Sombre",
                    style: const TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    backgroundColor: isDarkTheme ? Colors.amber[700] : Colors.blue[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Sortir', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onSidebarToggle,
            icon: const Icon(Icons.keyboard_double_arrow_left, size: 18),
            label: const Text('Rétracter', style: TextStyle(fontSize: 12)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              foregroundColor: isDarkTheme ? Colors.white70 : Colors.indigo[700],
              side: BorderSide(
                color: isDarkTheme ? Colors.white30 : Colors.indigo[300]!,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(thickness: 1),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.verified,
                size: 16,
                color: isDarkTheme ? Colors.indigoAccent[100] : Colors.indigo,
              ),
              const SizedBox(width: 6),
              Text(
                "NOVAPRIME v2.0",
                style: TextStyle(
                  fontSize: 11,
                  color: isDarkTheme ? Colors.indigoAccent[100] : Colors.indigo,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            "© ${DateTime.now().year} - Plateforme Universitaire",
            style: TextStyle(
              fontSize: 10,
              color: isDarkTheme ? Colors.white54 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _FooterLink(label: 'Support', isDarkTheme: isDarkTheme, onTap: () {}),
              _FooterLink(label: 'Docs', isDarkTheme: isDarkTheme, onTap: () {}),
              _FooterLink(label: 'À propos', isDarkTheme: isDarkTheme, onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final bool isDarkTheme;
  final VoidCallback onTap;
  const _FooterLink({
    required this.label,
    required this.isDarkTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: isDarkTheme ? Colors.indigoAccent[100] : Colors.indigo,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
