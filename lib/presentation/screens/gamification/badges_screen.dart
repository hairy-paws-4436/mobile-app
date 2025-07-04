import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/gamification.dart';
import '../../bloc/gamification/gamification_bloc.dart';
import '../../bloc/gamification/gamification_event.dart';
import '../../bloc/gamification/gamification_state.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBadges();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadBadges() {
    context.read<GamificationBloc>().add(GetAvailableBadgesEvent());
    context.read<GamificationBloc>().add(GetMyStatsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Insignias'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Próximas'),
            Tab(text: 'Todas'),
          ],
        ),
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
          }
        },
        builder: (context, state) {
          if (state is GamificationLoading) {
            return const LoadingIndicator(message: 'Cargando insignias...');
          } else if (state is GamificationError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: _loadBadges,
            );
          } else if (state is AvailableBadgesLoaded) {
            return _buildBadgesContent(state.badges);
          }

          return const LoadingIndicator(message: 'Cargando insignias...');
        },
      ),
    );
  }

  Widget _buildBadgesContent(AvailableBadges badges) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildNextBadgesTab(badges.nextBadges, badges.allBadgeDescriptions),
        _buildAllBadgesTab(badges.allBadgeDescriptions),
      ],
    );
  }

  Widget _buildNextBadgesTab(List<GamificationBadge> nextBadges, Map<String, BadgeDescription> descriptions) {
    if (nextBadges.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '¡Has desbloqueado todas las insignias!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Sigue trabajando para mantener tu progreso',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadBadges();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: nextBadges.length,
        itemBuilder: (context, index) {
          final badge = nextBadges[index];
          final description = descriptions[badge.badge];
          return _buildNextBadgeCard(badge, description);
        },
      ),
    );
  }

  Widget _buildAllBadgesTab(Map<String, BadgeDescription> descriptions) {
    final sortedBadges = descriptions.entries.toList()
      ..sort((a, b) => b.value.points.compareTo(a.value.points));

    return RefreshIndicator(
      onRefresh: () async {
        _loadBadges();
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemCount: sortedBadges.length,
        itemBuilder: (context, index) {
          final entry = sortedBadges[index];
          return _buildAllBadgeCard(entry.key, entry.value);
        },
      ),
    );
  }

  Widget _buildNextBadgeCard(GamificationBadge badge, BadgeDescription? description) {
    final progress = badge.target > 0 ? (badge.current / badge.target) * 100 : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      description?.icon ?? '🏆',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        description?.name ?? _getBadgeName(badge.badge),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${description?.points ?? 0}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progreso: ${badge.current}/${badge.target}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${progress.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),

            const SizedBox(height: 8),
            Text(
              progress >= 100
                  ? '¡Insignia desbloqueada!'
                  : 'Faltan ${badge.target - badge.current} para desbloquear',
              style: TextStyle(
                fontSize: 12,
                color: progress >= 100 ? Colors.green : Colors.grey[600],
                fontWeight: progress >= 100 ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllBadgeCard(String badgeId, BadgeDescription description) {
    // Check if badge is earned by looking at current stats
    // This would need to be enhanced with actual earned badges data
    final isEarned = false; // Placeholder - you'd check against earned badges

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge icon with overlay for locked badges
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isEarned
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      description.icon,
                      style: TextStyle(
                        fontSize: 30,
                        color: isEarned ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (!isEarned)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Text(
              description.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isEarned ? Colors.black : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            Text(
              description.description,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isEarned
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${description.points}',
                style: TextStyle(
                  color: isEarned ? AppTheme.primaryColor : Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getBadgeName(String badgeId) {
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
      case 'adoption_milestone_50':
        return 'Héroe de Rescate';
      case 'adoption_milestone_100':
        return 'Campeón de Adopciones';
      case 'adoption_milestone_500':
        return 'Leyenda de Rescate';
      default:
        return badgeId.replaceAll('_', ' ').split(' ').map((word) =>
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
        ).join(' ');
    }
  }
}