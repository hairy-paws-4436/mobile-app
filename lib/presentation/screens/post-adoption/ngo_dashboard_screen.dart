import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/post_adoption_models.dart';

import '../../bloc/post-adoption/post_adoption_bloc.dart';
import '../../bloc/post-adoption/post_adoption_event.dart';
import '../../bloc/post-adoption/post_adoption_state.dart';
import '../../common/custom_button.dart';
import '../../common/loading_indicator.dart';

class NGODashboardScreen extends StatefulWidget {
  const NGODashboardScreen({super.key});

  @override
  State<NGODashboardScreen> createState() => _NGODashboardScreenState();
}

class _NGODashboardScreenState extends State<NGODashboardScreen> {
  PostAdoptionDashboard? _dashboard;
  PostAdoptionAnalytics? _analytics;
  List<PostAdoptionFollowUp>? _atRiskAdoptions;
  String _selectedPeriod = 'month';

  final List<Map<String, String>> _periodOptions = [
    {'value': 'week', 'label': 'Semana'},
    {'value': 'month', 'label': 'Mes'},
    {'value': 'quarter', 'label': 'Trimestre'},
    {'value': 'year', 'label': 'Año'},
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    context.read<PostAdoptionBloc>().add(GetNGODashboardEvent());
    context.read<PostAdoptionBloc>().add(GetNGOAnalyticsEvent(period: _selectedPeriod));
    context.read<PostAdoptionBloc>().add(GetAtRiskAdoptionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard de Seguimientos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range),
            onSelected: (period) {
              setState(() {
                _selectedPeriod = period;
              });
              context.read<PostAdoptionBloc>().add(GetNGOAnalyticsEvent(period: period));
            },
            itemBuilder: (context) => _periodOptions.map((option) => PopupMenuItem(
              value: option['value'],
              child: Text(option['label']!),
            )).toList(),
          ),
        ],
      ),
      body: BlocConsumer<PostAdoptionBloc, PostAdoptionState>(
        listener: (context, state) {
          if (state is PostAdoptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is NGODashboardLoaded) {
            setState(() {
              _dashboard = state.dashboard;
            });
          } else if (state is NGOAnalyticsLoaded) {
            setState(() {
              _analytics = state.analytics;
            });
          } else if (state is AtRiskAdoptionsLoaded) {
            setState(() {
              _atRiskAdoptions = state.atRiskAdoptions;
            });
          } else if (state is InterventionStarted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Intervención iniciada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            _loadDashboardData(); // Refresh data
          }
        },
        builder: (context, state) {
          if (state is PostAdoptionLoading && _dashboard == null) {
            return const LoadingIndicator(message: 'Cargando dashboard...');
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadDashboardData();
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard summary cards
                  if (_dashboard != null) _buildDashboardSummary(_dashboard!),
                  const SizedBox(height: 24),

                  // At-risk adoptions
                  if (_atRiskAdoptions != null) _buildAtRiskSection(_atRiskAdoptions!),
                  const SizedBox(height: 24),

                  // Analytics
                  if (_analytics != null) _buildAnalyticsSection(_analytics!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardSummary(PostAdoptionDashboard dashboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resumen General',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildSummaryCard(
              'Total Seguimientos',
              dashboard.totalFollowUps.toString(),
              Icons.assignment,
              Colors.blue,
            ),
            _buildSummaryCard(
              'Completados',
              dashboard.completedFollowUps.toString(),
              Icons.check_circle,
              Colors.green,
            ),
            _buildSummaryCard(
              'Pendientes',
              dashboard.pendingFollowUps.toString(),
              Icons.pending,
              Colors.orange,
            ),
            _buildSummaryCard(
              'En Riesgo',
              dashboard.atRiskAdoptions.toString(),
              Icons.warning,
              Colors.red,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Completion rate
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.trending_up,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tasa de Finalización',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    Text(
                      '${dashboard.completionRate.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              CircularProgressIndicator(
                value: dashboard.completionRate / 100,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: color,
          ),
          const SizedBox(height: 8),
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
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAtRiskSection(List<PostAdoptionFollowUp> atRiskAdoptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Adopciones en Riesgo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (atRiskAdoptions.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${atRiskAdoptions.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        if (atRiskAdoptions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Excelente! No hay adopciones en riesgo en este momento.',
                    style: TextStyle(color: Colors.green),
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: atRiskAdoptions.length,
            itemBuilder: (context, index) {
              final followUp = atRiskAdoptions[index];
              return _buildAtRiskCard(followUp);
            },
          ),
      ],
    );
  }

  Widget _buildAtRiskCard(PostAdoptionFollowUp followUp) {
    final animal = followUp.adoption?.animal;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Pet image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 50,
                    height: 50,
                    child: animal?.images.isNotEmpty == true
                        ? Image.network(
                      animal!.images.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.pets,
                            size: 25,
                            color: Colors.grey,
                          ),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.pets,
                        size: 25,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        animal?.name ?? 'Mascota',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getFollowUpTypeLabel(followUp.followUpType),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getRiskColor(followUp.riskLevel),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getRiskLabel(followUp.riskLevel),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Fixed button with proper constraints
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Iniciar Intervención',
                onPressed: () {
                  _showInterventionDialog(followUp);
                },
                type: ButtonType.secondary,
                icon: Icons.support_agent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(PostAdoptionAnalytics analytics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Análisis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Período: ${_periodOptions.firstWhere((option) => option['value'] == _selectedPeriod)['label']}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Success rate and adaptation score
        Row(
          children: [
            Expanded(
              child: _buildAnalyticsCard(
                'Tasa de Éxito',
                '${analytics.adoptionSuccessRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAnalyticsCard(
                'Puntuación Promedio',
                '${analytics.averageAdaptationScore.toStringAsFixed(1)}/10',
                Icons.star,
                Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Common issues
        if (analytics.commonIssues.isNotEmpty) ...[
          const Text(
            'Problemas Más Comunes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...analytics.commonIssues.take(5).map((issue) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    issue.issue,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${issue.frequency}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ],
    );
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
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
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showInterventionDialog(PostAdoptionFollowUp followUp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar Intervención'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mascota: ${followUp.adoption?.animal?.name ?? 'N/A'}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Adoptante: ${followUp.adopter?.firstName ?? ''} ${followUp.adopter?.lastName ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Nivel de riesgo: ${_getRiskLabel(followUp.riskLevel)}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _getRiskColor(followUp.riskLevel),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '¿Estás seguro que deseas iniciar una intervención para esta adopción? Se contactará al adoptante para brindar apoyo adicional.',
            ),
          ],
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
              context.read<PostAdoptionBloc>().add(
                StartInterventionEvent(followupId: followUp.id),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Iniciar Intervención'),
          ),
        ],
      ),
    );
  }

  String _getFollowUpTypeLabel(String type) {
    switch (type) {
      case 'initial_3_days':
        return 'Seguimiento inicial (3 días)';
      case 'week_1':
        return 'Seguimiento de 1 semana';
      case 'week_2':
        return 'Seguimiento de 2 semanas';
      case 'month_1':
        return 'Seguimiento de 1 mes';
      case 'month_3':
        return 'Seguimiento de 3 meses';
      case 'month_6':
        return 'Seguimiento de 6 meses';
      case 'year_1':
        return 'Seguimiento de 1 año';
      default:
        return type;
    }
  }

  String _getRiskLabel(String risk) {
    switch (risk) {
      case 'low':
        return 'Bajo';
      case 'medium':
        return 'Medio';
      case 'high':
        return 'Alto';
      default:
        return risk;
    }
  }

  Color _getRiskColor(String risk) {
    switch (risk) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}