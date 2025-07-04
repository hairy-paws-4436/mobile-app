import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme.dart';
import '../../../../data/models/recommendation.dart';
import '../../../bloc/matching/matching_bloc.dart';
import '../../../bloc/matching/matching_event.dart';
import '../../../bloc/matching/matching_state.dart';
import '../../../common/custom_button.dart';
import '../../../common/error_display.dart';
import '../../../common/loading_indicator.dart';
import '../../../common/safe_animal_image.dart';

class RecommendationsTab extends StatefulWidget {
  const RecommendationsTab({Key? key}) : super(key: key);

  @override
  State<RecommendationsTab> createState() => _RecommendationsTabState();
}

class _RecommendationsTabState extends State<RecommendationsTab> {
  bool _hasLoadedOnce = false;

  @override
  void initState() {
    super.initState();
    // Solo cargar recomendaciones la primera vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoadedOnce) {
        _loadRecommendations();
      }
    });
  }

  void _loadRecommendations() {
    if (!_hasLoadedOnce) {
      _hasLoadedOnce = true;
    }
    context.read<MatchingBloc>().add(GetRecommendationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatchingBloc, MatchingState>(
      listener: (context, state) {
        if (state is MatchingError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is MatchingLoading) {
          return const LoadingIndicator(message: 'Buscando recomendaciones...');
        } else if (state is MatchingError) {
          return ErrorDisplay(
            message: state.message,
            onRetry: _loadRecommendations,
          );
        } else if (state is RecommendationsLoaded) {
          final recommendations = state.recommendations;

          if (recommendations.needsOnboarding) {
            return _buildOnboardingView();
          }

          if (recommendations.recommendations.isEmpty) {
            return _buildEmptyView();
          }

          return _buildRecommendationsList(recommendations);
        }

        return _buildInitialView();
      },
    );
  }

  Widget _buildInitialView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Recomendaciones Inteligentes',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Encuentra la mascota perfecta para ti basada en tus preferencias y estilo de vida.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Comenzar',
              onPressed: _loadRecommendations,
              icon: Icons.start,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.tune,
              size: 80,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Configuremos tus preferencias',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Para ofrecerte las mejores recomendaciones, necesitamos conocer tus preferencias de adopción.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CustomButton(
              text: 'Configurar Preferencias',
              onPressed: () {
                Navigator.pushNamed(context, '/preferences-form').then((_) {
                  _loadRecommendations();
                });
              },
              icon: Icons.settings,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/recommendations');
              },
              child: const Text('Ver todas las opciones'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No hay recomendaciones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'No encontramos mascotas que coincidan con tus preferencias actuales.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Ajustar Preferencias',
                    type: ButtonType.secondary,
                    onPressed: () {
                      Navigator.pushNamed(context, '/preferences-form').then((_) {
                        _loadRecommendations();
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    text: 'Ver Todas',
                    onPressed: () {
                      Navigator.pushNamed(context, '/recommendations');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList(RecommendationsResponse recommendations) {
    return RefreshIndicator(
      onRefresh: () async {
        _loadRecommendations();
      },
      child: Column(
        children: [
          // Header with quick actions
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${recommendations.totalMatches} mascotas compatibles',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/recommendations');
                  },
                  icon: const Icon(Icons.fullscreen),
                  tooltip: 'Ver vista completa',
                ),
              ],
            ),
          ),

          // Quick recommendations list (mostrar solo los top 3)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: recommendations.recommendations.take(3).length,
              itemBuilder: (context, index) {
                final recommendation = recommendations.recommendations[index];
                return _buildCompactRecommendationCard(recommendation);
              },
            ),
          ),

          // Ver más button
          if (recommendations.recommendations.length > 3)
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomButton(
                text: 'Ver todas las recomendaciones (${recommendations.recommendations.length})',
                type: ButtonType.secondary,
                onPressed: () {
                  Navigator.pushNamed(context, '/recommendations');
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactRecommendationCard(AnimalRecommendation recommendation) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/animal-details',
            arguments: {'animalId': recommendation.animal.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SafeAnimalImage(
                  images: recommendation.animal.images,
                  width: 80,
                  height: 80,
                  iconSize: 30,
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            recommendation.animal.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getScoreColor(recommendation.score),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(recommendation.score * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recommendation.animal.breed} • ${recommendation.animal.age} ${recommendation.animal.age == 1 ? 'año' : 'años'}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (recommendation.matchReasons.isNotEmpty)
                      Text(
                        recommendation.matchReasons.first,
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }
}