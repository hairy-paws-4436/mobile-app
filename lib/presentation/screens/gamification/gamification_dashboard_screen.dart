import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/gamification.dart';
import '../../bloc/gamification/gamification_bloc.dart';
import '../../bloc/gamification/gamification_event.dart';
import '../../bloc/gamification/gamification_state.dart';
import '../../common/custom_button.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class GamificationDashboardScreen extends StatefulWidget {
  const GamificationDashboardScreen({super.key});

  @override
  State<GamificationDashboardScreen> createState() => _GamificationDashboardScreenState();
}

class _GamificationDashboardScreenState extends State<GamificationDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<GamificationBloc>().add(GetMyStatsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Progreso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            onPressed: () {
              Navigator.pushNamed(context, '/gamification-leaderboard');
            },
            tooltip: 'Ver Ranking',
          ),
          IconButton(
            icon: const Icon(Icons.badge),
            onPressed: () {
              Navigator.pushNamed(context, '/gamification-badges');
            },
            tooltip: 'Ver Insignias',
          ),
        ],
      ),
      body: BlocConsumer<GamificationBloc, GamificationState>(
        listener: (context, state) {
          if (state is GamificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is MonthlyGoalSet) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Meta mensual establecida correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GamificationLoading && state is! MyStatsLoaded) {
            return const LoadingIndicator(message: 'Cargando estadísticas...');
          } else if (state is GamificationError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: _loadData,
            );
          } else if (state is MyStatsLoaded) {
            return _buildDashboard(context, state.stats);
          }

          return const LoadingIndicator(message: 'Cargando progreso...');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showGoalDialog(context);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.flag),
        tooltip: 'Establecer Meta',
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, MyGamificationStats stats) {
    final gamification = stats.gamification;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<GamificationBloc>().add(RefreshMyStatsEvent());
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with level and points
            _buildHeaderCard(gamification),
            const SizedBox(height: 16),

            // Progress indicators
            _buildProgressSection(gamification),
            const SizedBox(height: 16),

            // Statistics grid
            _buildStatsGrid(gamification),
            const SizedBox(height: 16),

            // Monthly goal progress
            if (gamification.monthlyAdoptionGoal != null)
              _buildMonthlyGoalCard(gamification),

            // Next badges to earn
            if (stats.nextBadges.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildNextBadgesSection(stats.nextBadges),
            ],

            // Recent achievements
            if (stats.recentAchievements.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildRecentAchievements(stats.recentAchievements),
            ],

            // Ranking info
            const SizedBox(height: 16),
            _buildRankingCard(stats.rankingInfo),

            const SizedBox(height: 100), // Space for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(GamificationStats stats) {
    return Card(
      elevation: 4,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor,
              AppTheme.primaryColor.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nivel ${stats.currentLevel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${stats.totalPoints} puntos totales',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '🏆',
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress to next level
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Progreso al siguiente nivel',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${stats.pointsToNextLevel} puntos restantes',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: stats.pointsToNextLevel > 0
                      ? (100 - stats.pointsToNextLevel) / 100
                      : 1.0,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(GamificationStats stats) {
    return Row(
      children: [
        Expanded(
          child: _buildProgressCard(
            'Esta Semana',
            stats.weeklyPoints,
            Colors.blue,
            Icons.calendar_view_week,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProgressCard(
            'Este Mes',
            stats.monthlyPoints,
            Colors.green,
            Icons.calendar_month,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProgressCard(
            'Racha',
            stats.currentStreakDays,
            Colors.orange,
            Icons.local_fire_department,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(String title, int value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(GamificationStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas de Impacto',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              'Adopciones\nFacilitadas',
              stats.totalAdoptionsFacilitated.toString(),
              Icons.favorite,
              Colors.red,
            ),
            _buildStatCard(
              'Mascotas\nPublicadas',
              stats.animalsPublished.toString(),
              Icons.pets,
              Colors.blue,
            ),
            _buildStatCard(
              'Eventos\nOrganizados',
              stats.eventsOrganized.toString(),
              Icons.event,
              Colors.purple,
            ),
            _buildStatCard(
              'Donaciones\nRecibidas',
              'S/${stats.donationsReceived.toStringAsFixed(0)}',
              Icons.attach_money,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyGoalCard(GamificationStats stats) {
    final progress = stats.monthlyAdoptionGoal! > 0
        ? stats.monthlyAdoptionsCurrent / stats.monthlyAdoptionGoal!
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Meta Mensual',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${stats.monthlyAdoptionsCurrent}/${stats.monthlyAdoptionGoal}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress > 1.0 ? 1.0 : progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.green : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              progress >= 1.0
                  ? '¡Meta cumplida! 🎉'
                  : '${(progress * 100).toStringAsFixed(1)}% completado',
              style: TextStyle(
                color: progress >= 1.0 ? Colors.green : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextBadgesSection(List<GamificationBadge> badges) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximas Insignias',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: badges.length,
            itemBuilder: (context, index) {
              final badge = badges[index];
              return _buildBadgeCard(badge);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadgeCard(GamificationBadge badge) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getBadgeName(badge.badge),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: badge.target > 0 ? badge.progress / 100 : 0,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
              const SizedBox(height: 4),
              Text(
                '${badge.current}/${badge.target}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAchievements(List<Achievement> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Logros Recientes',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...achievements.map((achievement) => Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                achievement.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(achievement.badgeName),
            subtitle: Text(achievement.description),
            trailing: Text(
              '+${achievement.points}',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildRankingCard(RankingInfo ranking) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mi Posición en Rankings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRankingItem(
                  'Global',
                  '#${ranking.globalRank}',
                  '/${ranking.totalOngs}',
                ),
                _buildRankingItem(
                  'Mensual',
                  '#${ranking.monthlyRank}',
                  '/${ranking.totalOngs}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(String title, String rank, String total) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black),
            children: [
              TextSpan(
                text: rank,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              TextSpan(
                text: total,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getBadgeName(String badgeId) {
    // Convert badge ID to readable name
    switch (badgeId.toLowerCase()) {
      case 'adoption_milestone_10':
        return 'Adoptador Dedicado';
      case 'event_organizer':
        return 'Organizador de Eventos';
      case 'donor_favorite':
        return 'Favorito de Donantes';
      case 'first_adoption':
        return 'Primera Adopción';
      case 'profile_completeness':
        return 'Perfil Completo';
      case 'monthly_active':
        return 'Siempre Activo';
      case 'rapid_responder':
        return 'Respuesta Rápida';
      default:
        return badgeId.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
        ).join(' ');
    }
  }

  void _showGoalDialog(BuildContext context) {
    final goalController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Establecer Meta Mensual'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¿Cuántas adopciones quieres facilitar este mes?'),
            const SizedBox(height: 16),
            TextFormField(
              controller: goalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Número de adopciones',
                hintText: '10',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final goal = int.tryParse(goalController.text);
              if (goal != null && goal > 0) {
                context.read<GamificationBloc>().add(SetMonthlyGoalEvent(goal: goal));
                Navigator.pop(context);
              }
            },
            child: const Text('Establecer'),
          ),
        ],
      ),
    );
  }
}