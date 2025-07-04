import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/recommendation.dart';
import '../../bloc/matching/matching_bloc.dart';
import '../../bloc/matching/matching_event.dart';
import '../../bloc/matching/matching_state.dart';
import '../../common/custom_button.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  double _minScore = 0.3;
  bool _includeSpecialNeeds = false;
  int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  void _loadRecommendations() {
    context.read<MatchingBloc>().add(GetRecommendationsEvent(
      limit: _limit,
      minScore: _minScore,
      includeSpecialNeeds: _includeSpecialNeeds,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recomendaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/preferences-form');
            },
          ),
        ],
      ),
      body: BlocConsumer<MatchingBloc, MatchingState>(
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

          return const LoadingIndicator(message: 'Cargando recomendaciones...');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadRecommendations,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.refresh),
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
              Icons.psychology,
              size: 80,
              color: Colors.grey[400],
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
              'No encontramos mascotas que coincidan con tus preferencias actuales. Intenta ajustar los filtros o tus preferencias.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  text: 'Ajustar Filtros',
                  type: ButtonType.secondary,
                  onPressed: _showFilterDialog,
                ),
                CustomButton(
                  text: 'Editar Preferencias',
                  onPressed: () {
                    Navigator.pushNamed(context, '/preferences-form').then((_) {
                      _loadRecommendations();
                    });
                  },
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
          // Header with stats
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${recommendations.totalMatches} mascotas compatibles encontradas',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.favorite,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ],
            ),
          ),

          // Recommendations list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: recommendations.recommendations.length,
              itemBuilder: (context, index) {
                final recommendation = recommendations.recommendations[index];
                return _buildRecommendationCard(recommendation);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(AnimalRecommendation recommendation) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                  child: Container(
                    width: 120,
                    height: 120,
                    child: recommendation.animal.images.isNotEmpty
                        ? Image.network(
                      recommendation.animal.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.pets,
                            size: 40,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.pets,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
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
                        Text(
                          recommendation.animal.description,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Compatibility breakdown
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Compatibilidad',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCompatibilityBar('Personalidad', recommendation.compatibility.personality),
                      const SizedBox(width: 8),
                      _buildCompatibilityBar('Estilo de vida', recommendation.compatibility.lifestyle),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildCompatibilityBar('Experiencia', recommendation.compatibility.experience),
                      const SizedBox(width: 8),
                      _buildCompatibilityBar('Práctico', recommendation.compatibility.practical),
                    ],
                  ),
                ],
              ),
            ),

            // Match reasons
            if (recommendation.matchReasons.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: recommendation.matchReasons.take(3).map((reason) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Text(
                        reason,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Concerns
            if (recommendation.concerns.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: recommendation.concerns.take(2).map((concern) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Text(
                        concern,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showCompatibilityAnalysis(recommendation.animal.id);
                      },
                      icon: const Icon(Icons.analytics, size: 16),
                      label: const Text('Ver Análisis'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/adoption-request-form',
                          arguments: {
                            'animalId': recommendation.animal.id,
                            'type': 'adoption',
                          },
                        );
                      },
                      icon: const Icon(Icons.favorite, size: 16),
                      label: const Text('Adoptar'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompatibilityBar(String label, int score) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(height: 2),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(_getScoreColor(score / 100)),
          ),
          const SizedBox(height: 2),
          Text(
            '$score%',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 0.8) return Colors.green;
    if (score >= 0.6) return Colors.orange;
    return Colors.red;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros de Búsqueda'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Puntuación mínima: ${(_minScore * 100).round()}%'),
                Slider(
                  value: _minScore,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  onChanged: (value) {
                    setState(() {
                      _minScore = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Incluir necesidades especiales'),
                  value: _includeSpecialNeeds,
                  onChanged: (value) {
                    setState(() {
                      _includeSpecialNeeds = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Text('Límite de resultados: $_limit'),
                Slider(
                  value: _limit.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  onChanged: (value) {
                    setState(() {
                      _limit = value.round();
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadRecommendations();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _showCompatibilityAnalysis(String animalId) {
    context.read<MatchingBloc>().add(GetCompatibilityAnalysisEvent(animalId: animalId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => BlocBuilder<MatchingBloc, MatchingState>(
        builder: (context, state) {
          if (state is MatchingLoading) {
            return const SizedBox(
              height: 200,
              child: LoadingIndicator(message: 'Analizando compatibilidad...'),
            );
          } else if (state is CompatibilityAnalysisLoaded) {
            return _buildCompatibilityAnalysisSheet(state.analysis);
          } else if (state is MatchingError) {
            return SizedBox(
              height: 200,
              child: ErrorDisplay(
                message: state.message,
                onRetry: () {
                  context.read<MatchingBloc>().add(GetCompatibilityAnalysisEvent(animalId: animalId));
                },
              ),
            );
          }
          return const SizedBox(height: 200);
        },
      ),
    );
  }

  Widget _buildCompatibilityAnalysisSheet(CompatibilityAnalysis analysis) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Análisis de Compatibilidad',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(analysis.score),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${(analysis.score * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            'Recomendación: ${analysis.recommendation}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Desglose de Compatibilidad',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          _buildCompatibilityBar('Personalidad', analysis.compatibility.personality),
          const SizedBox(height: 8),
          _buildCompatibilityBar('Estilo de vida', analysis.compatibility.lifestyle),
          const SizedBox(height: 8),
          _buildCompatibilityBar('Experiencia', analysis.compatibility.experience),
          const SizedBox(height: 8),
          _buildCompatibilityBar('Aspectos prácticos', analysis.compatibility.practical),

          const SizedBox(height: 24),

          if (analysis.matchReasons.isNotEmpty) ...[
            const Text(
              'Puntos a favor',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...analysis.matchReasons.map((reason) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(reason)),
                ],
              ),
            )),
            const SizedBox(height: 16),
          ],

          if (analysis.concerns.isNotEmpty) ...[
            const Text(
              'Consideraciones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...analysis.concerns.map((concern) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(concern)),
                ],
              ),
            )),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ),
        ],
      ),
    );
  }
}