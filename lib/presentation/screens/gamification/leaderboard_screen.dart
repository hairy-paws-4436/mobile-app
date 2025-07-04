import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/gamification.dart';
import '../../bloc/gamification/gamification_bloc.dart';
import '../../bloc/gamification/gamification_event.dart';
import '../../bloc/gamification/gamification_state.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedTimeframe = 'monthly';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadLeaderboard() {
    context.read<GamificationBloc>().add(
      GetLeaderboardEvent(timeframe: _selectedTimeframe, limit: 50),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ranking de ONGs'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mensual'),
            Tab(text: 'Semanal'),
            Tab(text: 'Todo el tiempo'),
          ],
          onTap: (index) {
            setState(() {
              switch (index) {
                case 0:
                  _selectedTimeframe = 'monthly';
                  break;
                case 1:
                  _selectedTimeframe = 'weekly';
                  break;
                case 2:
                  _selectedTimeframe = 'all';
                  break;
              }
            });
            _loadLeaderboard();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Información del ranking',
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
          }
        },
        builder: (context, state) {
          if (state is GamificationLoading) {
            return const LoadingIndicator(message: 'Cargando ranking...');
          } else if (state is GamificationError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: _loadLeaderboard,
            );
          } else if (state is LeaderboardLoaded) {
            return _buildLeaderboard(context, state.leaderboard);
          }

          return const LoadingIndicator(message: 'Cargando ranking...');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/gamification-top-performers');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.star),
        tooltip: 'Ver Top Performers',
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, List<LeaderboardEntry> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.leaderboard,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              'No hay datos de ranking disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLeaderboard,
              child: const Text('Recargar'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadLeaderboard();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return _buildLeaderboardItem(entry, false);
        },
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> topThree) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primaryColor.withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            '🏆 Top 3 ONGs 🏆',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2nd place
              if (topThree.length > 1)
                _buildPodiumPlace(topThree[1], 2, Colors.grey[400]!),

              // 1st place
              _buildPodiumPlace(topThree[0], 1, Colors.amber),

              // 3rd place
              if (topThree.length > 2)
                _buildPodiumPlace(topThree[2], 3, Colors.brown[300]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, int place, Color color) {
    final height = place == 1 ? 100.0 : (place == 2 ? 80.0 : 60.0);
    final iconSize = place == 1 ? 40.0 : 30.0;

    return Column(
      children: [
        // NGO info
        Container(
          width: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  entry.ongName.isNotEmpty ? entry.ongName[0].toUpperCase() : 'O',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.ongName,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${entry.points} pts',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Podium base
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                place == 1
                    ? Icons.emoji_events
                    : place == 2
                    ? Icons.workspace_premium
                    : Icons.military_tech,
                color: Colors.white,
                size: iconSize,
              ),
              const SizedBox(height: 4),
              Text(
                place.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, bool isTopThree) {
    Color rankColor = Colors.grey;
    IconData rankIcon = Icons.circle;

    if (entry.rank <= 3) {
      switch (entry.rank) {
        case 1:
          rankColor = Colors.amber;
          rankIcon = Icons.emoji_events;
          break;
        case 2:
          rankColor = Colors.grey[400]!;
          rankIcon = Icons.workspace_premium;
          break;
        case 3:
          rankColor = Colors.brown[300]!;
          rankIcon = Icons.military_tech;
          break;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: rankColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: entry.rank <= 3
                ? Icon(rankIcon, color: rankColor, size: 20)
                : Text(
              '#${entry.rank}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: rankColor,
                fontSize: 12,
              ),
            ),
          ),
        ),
        title: Text(
          entry.ongName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(Icons.favorite, size: 14, color: Colors.red[300]),
            const SizedBox(width: 4),
            Text('${entry.adoptions} adopciones'),
            const SizedBox(width: 12),
            Icon(Icons.star, size: 14, color: Colors.amber[600]),
            const SizedBox(width: 4),
            Text('Nivel ${entry.level}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.points}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppTheme.primaryColor,
              ),
            ),
            const Text(
              'puntos',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to NGO public profile
          Navigator.pushNamed(
            context,
            '/ngo-details',
            arguments: {'ngoId': entry.ongId},
          );
        },
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sistema de Puntuación'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Las ONGs ganan puntos por:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('🏆 Facilitar adopciones exitosas'),
              Text('📝 Publicar mascotas para adopción'),
              Text('🎪 Organizar eventos comunitarios'),
              Text('💝 Recibir donaciones'),
              Text('⚡ Responder rápidamente a consultas'),
              Text('🔥 Mantener actividad constante'),
              SizedBox(height: 16),
              Text(
                'Rankings:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Semanal: Se reinicia cada lunes'),
              Text('• Mensual: Se reinicia cada mes'),
              Text('• Todo el tiempo: Puntuación histórica'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}