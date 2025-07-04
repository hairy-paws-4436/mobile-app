import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/post_adoption_models.dart';
import '../../bloc/post-adoption/post_adoption_bloc.dart';
import '../../bloc/post-adoption/post_adoption_event.dart';
import '../../bloc/post-adoption/post_adoption_state.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class PostAdoptionScreen extends StatefulWidget {
  const PostAdoptionScreen({super.key});

  @override
  State<PostAdoptionScreen> createState() => _PostAdoptionScreenState();
}

class _PostAdoptionScreenState extends State<PostAdoptionScreen> {
  String? _selectedStatus;

  final List<Map<String, String>> _statusOptions = [
    {'value': 'pending', 'label': 'Pendientes'},
    {'value': 'completed', 'label': 'Completados'},
    {'value': 'skipped', 'label': 'Omitidos'},
  ];

  @override
  void initState() {
    super.initState();
    _loadFollowUps();
  }

  void _loadFollowUps() {
    context.read<PostAdoptionBloc>().add(GetMyFollowUpsEvent(status: _selectedStatus));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento Post-Adopción'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (status) {
              setState(() {
                _selectedStatus = status == 'all' ? null : status;
              });
              _loadFollowUps();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Todos'),
              ),
              ..._statusOptions.map((option) => PopupMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              )),
            ],
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
          } else if (state is FollowUpCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Seguimiento completado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            _loadFollowUps(); // Refresh the list
          } else if (state is FollowUpSkipped) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Seguimiento omitido'),
                backgroundColor: Colors.orange,
              ),
            );
            _loadFollowUps(); // Refresh the list
          }
        },
        builder: (context, state) {
          if (state is PostAdoptionLoading) {
            return const LoadingIndicator(message: 'Cargando seguimientos...');
          } else if (state is PostAdoptionError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: _loadFollowUps,
            );
          } else if (state is MyFollowUpsLoaded) {
            return _buildFollowUpsList(state.followUps);
          }

          return const LoadingIndicator(message: 'Cargando seguimientos...');
        },
      ),
    );
  }

  Widget _buildFollowUpsList(List<PostAdoptionFollowUp> followUps) {
    if (followUps.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'No hay seguimientos',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedStatus == null
                  ? 'No tienes seguimientos programados'
                  : 'No hay seguimientos con este estado',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        _loadFollowUps();
      },
      child: Column(
        children: [
          // Status filter chips
          if (_selectedStatus != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Chip(
                    label: Text(_statusOptions
                        .firstWhere((option) => option['value'] == _selectedStatus)['label']!),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _selectedStatus = null;
                      });
                      _loadFollowUps();
                    },
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppTheme.primaryColor),
                  ),
                ],
              ),
            ),

          // Follow-ups list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: followUps.length,
              itemBuilder: (context, index) {
                final followUp = followUps[index];
                return _buildFollowUpCard(followUp);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowUpCard(PostAdoptionFollowUp followUp) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/post-adoption-details',
            arguments: {'followupId': followUp.id},
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with pet info and status
              Row(
                children: [
                  // Pet image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 60,
                      height: 60,
                      child: followUp.adoption?.animal?.images.isNotEmpty == true
                          ? Image.network(
                        followUp.adoption!.animal!.images.first,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.pets,
                              size: 30,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                          : Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.pets,
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Pet info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          followUp.adoption?.animal?.name ?? 'Mascota',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getFollowUpTypeLabel(followUp.followUpType),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Programado: ${_formatDate(followUp.scheduledDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(followUp.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getStatusLabel(followUp.status),
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

              // Risk level indicator
              if (followUp.riskLevel != 'low')
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getRiskColor(followUp.riskLevel).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getRiskColor(followUp.riskLevel).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        color: _getRiskColor(followUp.riskLevel),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nivel de riesgo: ${_getRiskLabel(followUp.riskLevel)}',
                        style: TextStyle(
                          color: _getRiskColor(followUp.riskLevel),
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  if (followUp.status == 'pending') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showSkipDialog(followUp);
                        },
                        child: const Text('Omitir'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/post-adoption-form',
                            arguments: {'followupId': followUp.id},
                          );
                        },
                        child: const Text('Completar'),
                      ),
                    ),
                  ] else if (followUp.status == 'completed') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/post-adoption-details',
                            arguments: {'followupId': followUp.id},
                          );
                        },
                        child: const Text('Ver Detalles'),
                      ),
                    ),
                  ] else if (followUp.status == 'skipped') ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/post-adoption-form',
                            arguments: {'followupId': followUp.id},
                          );
                        },
                        child: const Text('Completar Ahora'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSkipDialog(PostAdoptionFollowUp followUp) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Omitir Seguimiento'),
        content: Text(
          '¿Estás seguro que deseas omitir el seguimiento de ${_getFollowUpTypeLabel(followUp.followUpType)}? Podrás completarlo más tarde.',
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
              context.read<PostAdoptionBloc>().add(SkipFollowUpEvent(followupId: followUp.id));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Omitir'),
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

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'completed':
        return 'Completado';
      case 'skipped':
        return 'Omitido';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'skipped':
        return Colors.grey;
      default:
        return Colors.grey;
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}