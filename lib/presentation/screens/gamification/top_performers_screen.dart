import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/gamification.dart';
import '../../bloc/gamification/gamification_bloc.dart';
import '../../bloc/gamification/gamification_event.dart';
import '../../bloc/gamification/gamification_state.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class TopPerformersScreen extends StatefulWidget {
  const TopPerformersScreen({super.key});

  @override
  State<TopPerformersScreen> createState() => _TopPerformersScreenState();
}

class _TopPerformersScreenState extends State<TopPerformersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';

  final Map<String, String> _categories = {
    'all': 'Todos',
    'adoptions': 'Adopciones',
    'events': 'Eventos',
    'donations': 'Donaciones',
    'engagement': 'Participación',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTopPerformers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTopPerformers() {
    context.read<GamificationBloc>().add(
      GetTopPerformersEvent(category: _selectedCategory),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Performers'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mensual'),
            Tab(text: 'Todo el tiempo'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrar por categoría',
            onSelected: (value) {
              setState(() {
                _selectedCategory = value;
              });
              _loadTopPerformers();
            },
            itemBuilder: (context) => _categories.entries
                .map((entry) => PopupMenuItem<String>(
              value: entry.key,
              child: Row(
                children: [
                  Icon(
                    _getCategoryIcon(entry.key),
                    size: 20,
                    color: _selectedCategory == entry.key
                        ? AppTheme.primaryColor
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.value,
                    style: TextStyle(
                      color: _selectedCategory == entry.key
                          ? AppTheme.primaryColor
                          : Colors.black,
                      fontWeight: _selectedCategory == entry.key
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (_selectedCategory == entry.key) ...[
                    const Spacer(),
                    const Icon(
                      Icons.check,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                  ],
                ],
              ),
            ))
                .toList(),
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
            return const LoadingIndicator(message: 'Cargando top performers...');
          } else if (state is GamificationError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: _loadTopPerformers,
            );
          } else if (state is TopPerformersLoaded) {
            return _buildTopPerformersContent(state.performers);
          }

          return const LoadingIndicator(message: 'Cargando top performers...');
        },
      ),
    );
  }

  Widget _buildTopPerformersContent(TopPerformers performers) {
    return Column(
      children: [
        // Category indicator
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(_selectedCategory),
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Categoría: ${_categories[_selectedCategory]}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),

        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildPerformersList(performers.monthlyTop, 'Mensual'),
              _buildPerformersList(performers.allTimeTop, 'Histórico'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPerformersList(List<LeaderboardEntry> performers, String period) {
    if (performers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay datos disponibles',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aún no hay suficientes datos para mostrar top performers en esta categoría.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadTopPerformers();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: performers.length,
        itemBuilder: (context, index) {
          final performer = performers[index];
          return _buildPerformerCard(performer, period);
        },
      ),
    );
  }

  Widget _buildPerformerCard(LeaderboardEntry performer, String period) {
    Color rankColor = Colors.grey;
    IconData rankIcon = Icons.circle;
    Widget? crownWidget;

    // Special styling for top 3
    if (performer.rank <= 3) {
      switch (performer.rank) {
        case 1:
          rankColor = Colors.amber;
          rankIcon = Icons.emoji_events;
          crownWidget = const Text('👑', style: TextStyle(fontSize: 20));
          break;
        case 2:
          rankColor = Colors.grey[400]!;
          rankIcon = Icons.workspace_premium;
          crownWidget = const Text('🥈', style: TextStyle(fontSize: 20));
          break;
        case 3:
          rankColor = Colors.brown[300]!;
          rankIcon = Icons.military_tech;
          crownWidget = const Text('🥉', style: TextStyle(fontSize: 20));
          break;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: performer.rank <= 3 ? 4 : 2,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: performer.rank == 1
              ? LinearGradient(
            colors: [
              Colors.amber.withOpacity(0.1),
              Colors.transparent,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Rank indicator
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: rankColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: performer.rank <= 3
                          ? Border.all(color: rankColor, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: performer.rank <= 3
                          ? Icon(rankIcon, color: rankColor, size: 24)
                          : Text(
                        '#${performer.rank}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rankColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // NGO info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                performer.ongName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: performer.rank <= 3
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            if (crownWidget != null) crownWidget,
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nivel ${performer.level}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Points
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${performer.points}',
                        style: TextStyle(
                          fontSize: performer.rank <= 3 ? 20 : 18,
                          fontWeight: FontWeight.bold,
                          color: performer.rank <= 3
                              ? rankColor
                              : AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        'puntos',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Stats row
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      Icons.favorite,
                      '${performer.adoptions}',
                      'Adopciones',
                      Colors.red,
                    ),
                    _buildStatItem(
                      Icons.emoji_events,
                      '${performer.badges.length}',
                      'Insignias',
                      Colors.amber,
                    ),
                    _buildStatItem(
                      _getCategoryIcon(_selectedCategory),
                      _getCategoryValue(performer),
                      _getCategoryLabel(),
                      AppTheme.primaryColor,
                    ),
                  ],
                ),
              ),

              // Badges (if any)
              if (performer.badges.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  children: performer.badges.take(3).map((badge) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getBadgeDisplayName(badge),
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'adoptions':
        return Icons.favorite;
      case 'events':
        return Icons.event;
      case 'donations':
        return Icons.attach_money;
      case 'engagement':
        return Icons.people;
      default:
        return Icons.star;
    }
  }

  String _getCategoryValue(LeaderboardEntry performer) {
    switch (_selectedCategory) {
      case 'adoptions':
        return performer.adoptions.toString();
      case 'events':
        return '0'; // You might need to add this field to the model
      case 'donations':
        return '0'; // You might need to add this field to the model
      case 'engagement':
        return performer.badges.length.toString();
      default:
        return performer.points.toString();
    }
  }

  String _getCategoryLabel() {
    switch (_selectedCategory) {
      case 'adoptions':
        return 'Adopciones';
      case 'events':
        return 'Eventos';
      case 'donations':
        return 'Donaciones';
      case 'engagement':
        return 'Insignias';
      default:
        return 'Puntos';
    }
  }

  String _getBadgeDisplayName(String badge) {
    // Convert badge ID to a readable name
    if (badge.contains('adoption')) return '🏆 Adopción';
    if (badge.contains('event')) return '🎪 Evento';
    if (badge.contains('donor')) return '💝 Donante';
    if (badge.contains('active')) return '🔥 Activo';
    return '⭐ Logro';
  }
}