import 'package:flutter/material.dart';
import '../../models/dashboard_stats_model.dart';
import '../../../university/presentation/pages/university_management_page.dart';
import '../../../faculty/presentation/pages/faculty_management_page.dart';
import '../../../department/presentation/pages/department_management_page.dart';
import '../../../program/presentation/pages/program_management_page.dart';
import '../../../course/presentation/pages/course_management_page.dart';
import '../../../user_management/presentation/pages/user_management_page.dart';

class AdminDashboardWidget extends StatelessWidget {
  final DashboardStatsModel stats;
  final bool isDarkTheme;

  const AdminDashboardWidget({
    super.key,
    required this.stats,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildMainStats(),
          const SizedBox(height: 24),
          _buildQuickActions(context),
          const SizedBox(height: 24),
          _buildGrowthSection(),
          const SizedBox(height: 24),
          _buildTopInstitutions(),
          const SizedBox(height: 24),
          _buildRecentActivities(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tableau de Bord Administrateur',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Vue d\'ensemble en temps réel de votre institution',
          style: TextStyle(
            fontSize: 16,
            color: isDarkTheme ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildMainStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          icon: Icons.people_rounded,
          label: 'Total Utilisateurs',
          value: '${stats.totalUsers}',
          color: Colors.blue,
        ),
        _buildStatCard(
          icon: Icons.school_rounded,
          label: 'Étudiants Actifs',
          value: '${stats.activeStudents}',
          color: Colors.green,
        ),
        _buildStatCard(
          icon: Icons.person_rounded,
          label: 'Enseignants',
          value: '${stats.totalTeachers}',
          color: Colors.orange,
        ),
        _buildStatCard(
          icon: Icons.account_balance_rounded,
          label: 'Institutions',
          value: '${stats.totalInstitutions}',
          color: Colors.purple,
        ),
        _buildStatCard(
          icon: Icons.business_rounded,
          label: 'Départements',
          value: '${stats.totalDepartments}',
          color: Colors.teal,
        ),
        _buildStatCard(
          icon: Icons.book_rounded,
          label: 'Cours Actifs',
          value: '${stats.activeCourses}',
          color: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkTheme ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions Rapides',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(
              icon: Icons.account_balance,
              label: 'Universités',
              color: Colors.purple,
              onTap: () => _navigateToPage(context, const UniversityManagementPage()),
            ),
            _buildActionCard(
              icon: Icons.business,
              label: 'Facultés',
              color: Colors.teal,
              onTap: () => _navigateToPage(context, const FacultyManagementPage()),
            ),
            _buildActionCard(
              icon: Icons.domain,
              label: 'Départements',
              color: Colors.orange,
              onTap: () => _navigateToPage(context, const DepartmentManagementPage()),
            ),
            _buildActionCard(
              icon: Icons.menu_book,
              label: 'Filières',
              color: Colors.deepOrange,
              onTap: () => _navigateToPage(context, const ProgramManagementPage()),
            ),
            _buildActionCard(
              icon: Icons.book,
              label: 'Cours',
              color: Colors.indigo,
              onTap: () => _navigateToPage(context, const CourseManagementPage()),
            ),
            _buildActionCard(
              icon: Icons.people,
              label: 'Utilisateurs',
              color: Colors.blue,
              onTap: () => _navigateToPage(context, const UserManagementPage()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Croissance ce mois',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGrowthCard(
                  'Nouveaux utilisateurs',
                  '+${stats.newUsersThisMonth}',
                  '${stats.userGrowthRate.toStringAsFixed(1)}%',
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGrowthCard(
                  'Nouveaux cours',
                  '+${stats.newCoursesThisMonth}',
                  '${stats.courseGrowthRate.toStringAsFixed(1)}%',
                  Colors.indigo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard(String title, String value, String percentage, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: isDarkTheme ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                double.parse(percentage.replaceAll('%', '')) > 0
                    ? Icons.trending_up
                    : Icons.trending_down,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopInstitutions() {
    if (stats.topInstitutions.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top Institutions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...stats.topInstitutions.take(5).map((institution) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      color: Colors.purple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          institution['name'] ?? 'Institution',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkTheme ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${institution['count'] ?? 0} facultés',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkTheme ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRecentActivities() {
    if (stats.recentActivities.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkTheme ? const Color(0xFF1D1E33) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activités Récentes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...stats.recentActivities.take(10).map((activity) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.cyan,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity['description'] ?? 'Activité',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDarkTheme ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          _formatDate(activity['created_at']),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkTheme ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Date inconnue';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inMinutes > 0) {
        return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'À l\'instant';
      }
    } catch (e) {
      return dateString;
    }
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}
