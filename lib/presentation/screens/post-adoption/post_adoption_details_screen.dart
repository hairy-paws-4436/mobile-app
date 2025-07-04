import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/post_adoption_models.dart';

import '../../bloc/post-adoption/post_adoption_bloc.dart';
import '../../bloc/post-adoption/post_adoption_event.dart';
import '../../bloc/post-adoption/post_adoption_state.dart';
import '../../common/custom_button.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class PostAdoptionDetailsScreen extends StatefulWidget {
  final String followupId;

  const PostAdoptionDetailsScreen({
    super.key,
    required this.followupId,
  });

  @override
  State<PostAdoptionDetailsScreen> createState() => _PostAdoptionDetailsScreenState();
}

class _PostAdoptionDetailsScreenState extends State<PostAdoptionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    _loadFollowUpDetails();
  }

  void _loadFollowUpDetails() {
    context.read<PostAdoptionBloc>().add(
        GetFollowUpDetailsEvent(followupId: widget.followupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Seguimiento'),
        elevation: 0,
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
          }
        },
        builder: (context, state) {
          if (state is PostAdoptionLoading) {
            return const LoadingIndicator(message: 'Cargando detalles...');
          } else if (state is PostAdoptionError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: _loadFollowUpDetails,
            );
          } else if (state is FollowUpDetailsLoaded) {
            return _buildDetailsContent(state.followUp);
          }

          return const LoadingIndicator(message: 'Cargando detalles...');
        },
      ),
    );
  }

  Widget _buildDetailsContent(PostAdoptionFollowUp followUp) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet and adoption info header
          _buildPetHeader(followUp),
          const SizedBox(height: 24),

          // Follow-up type and schedule info
          _buildFollowUpInfo(followUp),
          const SizedBox(height: 24),

          // Status and risk level
          _buildStatusInfo(followUp),
          const SizedBox(height: 24),

          // If completed, show evaluation details
          if (followUp.status == 'completed') ...[
            _buildEvaluationDetails(followUp),
          ] else
            if (followUp.status == 'pending') ...[
              _buildPendingActions(followUp),
            ] else
              if (followUp.status == 'skipped') ...[
                _buildSkippedInfo(followUp),
              ],
        ],
      ),
    );
  }

  Widget _buildPetHeader(PostAdoptionFollowUp followUp) {
    final animal = followUp.adoption?.animal;
    final adopter = followUp.adopter;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet info
            if (animal != null) ...[
              Row(
                children: [
                  // Pet image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 80,
                      child: animal.images.isNotEmpty
                          ? Image.network(
                        animal.images.first,
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
                  const SizedBox(width: 16),

                  // Pet details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          animal.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${animal.breed} • ${animal.age} ${animal.age == 1
                              ? 'año'
                              : 'años'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${animal.weight} kg • ${animal.gender == 'male'
                              ? 'Macho'
                              : 'Hembra'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
            ],

            // Adopter info
            if (adopter != null) ...[
              const Text(
                'Adoptante',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${adopter.firstName} ${adopter.lastName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.email,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    adopter.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (adopter.phoneNumber.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      adopter.phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFollowUpInfo(PostAdoptionFollowUp followUp) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información del Seguimiento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow(
              icon: Icons.assignment,
              label: 'Tipo de Seguimiento',
              value: _getFollowUpTypeLabel(followUp.followUpType),
            ),
            const SizedBox(height: 12),

            _buildInfoRow(
              icon: Icons.schedule,
              label: 'Fecha Programada',
              value: _formatDate(followUp.scheduledDate),
            ),
            const SizedBox(height: 12),

            if (followUp.completedDate != null)
              _buildInfoRow(
                icon: Icons.check_circle,
                label: 'Fecha de Completado',
                value: _formatDate(followUp.completedDate!),
              ),

            const SizedBox(height: 12),
            _buildInfoRow(
              icon: Icons.info,
              label: 'Creado',
              value: _formatDate(followUp.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusInfo(PostAdoptionFollowUp followUp) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado Actual',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
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
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRiskColor(followUp.riskLevel),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Riesgo: ${_getRiskLabel(followUp.riskLevel)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            if (followUp.needsSupport) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.support_agent, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El adoptante ha solicitado apoyo adicional',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (followUp.followUpRequired) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.event_repeat, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Se requiere seguimiento adicional',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationDetails(PostAdoptionFollowUp followUp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Resultados de la Evaluación',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Adaptation level
        if (followUp.adaptationLevel != null) ...[
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nivel de Adaptación',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getAdaptationLabel(followUp.adaptationLevel!),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Basic behaviors
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comportamientos Básicos',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 12),

                _buildBehaviorItem('Comiendo bien', followUp.eatingWell),
                _buildBehaviorItem('Durmiendo bien', followUp.sleepingWell),
                _buildBehaviorItem('Usando el baño apropiadamente',
                    followUp.usingBathroomProperly),
                _buildBehaviorItem(
                    'Mostrando afecto', followUp.showingAffection),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Behavioral issues
        if (followUp.behavioralIssues != null &&
            followUp.behavioralIssues!.isNotEmpty) ...[
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Problemas de Comportamiento Reportados',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...followUp.behavioralIssues!.map((issue) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                                Icons.warning, color: Colors.orange, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(issue)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Health concerns
        if (followUp.healthConcerns != null &&
            followUp.healthConcerns!.isNotEmpty) ...[
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preocupaciones de Salud',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...followUp.healthConcerns!.map((concern) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                                Icons.medical_services, color: Colors.red,
                                size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(concern)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Veterinary visit
        if (followUp.vetVisitScheduled != null) ...[
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Visita Veterinaria',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        followUp.vetVisitScheduled! ? Icons.check_circle : Icons
                            .cancel,
                        color: followUp.vetVisitScheduled!
                            ? Colors.green
                            : Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        followUp.vetVisitScheduled!
                            ? 'Visita programada'
                            : 'No programada',
                        style: TextStyle(
                          color: followUp.vetVisitScheduled!
                              ? Colors.green
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (followUp.vetVisitScheduled! &&
                      followUp.vetVisitDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Fecha: ${_formatDate(followUp.vetVisitDate!)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Satisfaction
        if (followUp.satisfactionScore != null) ...[
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Satisfacción del Adoptante',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${followUp.satisfactionScore}/10',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: followUp.satisfactionScore! / 10,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getSatisfactionColor(followUp.satisfactionScore!),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (followUp.wouldRecommend != null)
                    Row(
                      children: [
                        Icon(
                          followUp.wouldRecommend! ? Icons.thumb_up : Icons
                              .thumb_down,
                          color: followUp.wouldRecommend!
                              ? Colors.green
                              : Colors.red,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          followUp.wouldRecommend!
                              ? 'Recomendaría esta ONG'
                              : 'No recomendaría esta ONG',
                          style: TextStyle(
                            color: followUp.wouldRecommend!
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Support requested
        if (followUp.supportType != null &&
            followUp.supportType!.isNotEmpty) ...[
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Apoyo Solicitado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...followUp.supportType!.map((support) =>
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(
                                Icons.support_agent, color: Colors.purple,
                                size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(support)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Additional comments
        if (followUp.additionalComments != null &&
            followUp.additionalComments!.isNotEmpty) ...[
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comentarios Adicionales',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    followUp.additionalComments!,
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPendingActions(PostAdoptionFollowUp followUp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Disponibles',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Este seguimiento está pendiente de completar.',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Completar Ahora',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/post-adoption-form',
                        arguments: {'followupId': followUp.id},
                      );
                    },
                    icon: Icons.assignment_turned_in,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkippedInfo(PostAdoptionFollowUp followUp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seguimiento Omitido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.skip_next, color: Colors.orange),
                    SizedBox(width: 8),
                    Text(
                      'Este seguimiento fue omitido.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Aún puedes completarlo si cambias de opinión.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Completar Ahora',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/post-adoption-form',
                        arguments: {'followupId': followUp.id},
                      );
                    },
                    icon: Icons.assignment_turned_in,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorItem(String label, bool? value) {
    if (value == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: value ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
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

  String _getAdaptationLabel(String level) {
    switch (level) {
      case 'excellent':
        return 'Excelente';
      case 'good':
        return 'Buena';
      case 'fair':
        return 'Regular';
      case 'poor':
        return 'Pobre';
      default:
        return level;
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

  Color _getSatisfactionColor(int score) {
    if (score >= 8) {
      return Colors.green;
    } else if (score >= 6) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}