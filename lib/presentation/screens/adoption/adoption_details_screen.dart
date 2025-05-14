// lib/presentation/screens/adoption/adoption_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/adoption_request.dart';
import '../../../data/models/animal.dart';
import '../../../data/models/user.dart';
import '../../bloc/adoption/adoption_bloc.dart';
import '../../bloc/adoption/adoption_event.dart';
import '../../bloc/adoption/adoption_state.dart';
import '../../bloc/animal/animal_bloc.dart';
import '../../bloc/animal/animal_event.dart';
import '../../bloc/animal/animal_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../common/custom_button.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';


class AdoptionDetailsScreen extends StatefulWidget {
  final String adoptionId;

  const AdoptionDetailsScreen({
    Key? key,
    required this.adoptionId,
  }) : super(key: key);

  @override
  State<AdoptionDetailsScreen> createState() => _AdoptionDetailsScreenState();
}

class _AdoptionDetailsScreenState extends State<AdoptionDetailsScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch adoption request details
    context.read<AdoptionBloc>().add(FetchAdoptionDetailsEvent(widget.adoptionId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adoption Request Details'),
      ),
      body: BlocBuilder<AdoptionBloc, AdoptionState>(
        builder: (context, state) {
          if (state is AdoptionLoading) {
            return const LoadingIndicator(message: 'Loading request details...');
          } else if (state is AdoptionError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                context.read<AdoptionBloc>().add(FetchAdoptionDetailsEvent(widget.adoptionId));
              },
            );
          } else if (state is AdoptionDetailsLoaded) {
            final request = state.request;

            // Fetch animal details
            context.read<AnimalBloc>().add(FetchAnimalDetailsEvent(request.animalId));

            return BlocBuilder<AnimalBloc, AnimalState>(
              builder: (context, animalState) {
                if (animalState is AnimalLoading) {
                  return const LoadingIndicator(message: 'Loading pet details...');
                } else if (animalState is AnimalError) {
                  return ErrorDisplay(
                    message: animalState.message,
                    onRetry: () {
                      context.read<AnimalBloc>().add(FetchAnimalDetailsEvent(request.animalId));
                    },
                  );
                } else if (animalState is AnimalDetailsLoaded) {
                  final animal = animalState.animal;
                  return _buildContent(context, request, animal);
                }

                return const LoadingIndicator(message: 'Loading request details...');
              },
            );
          }

          return const LoadingIndicator(message: 'Loading request details...');
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdoptionRequest request, Animal animal) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        late User currentUser;
        bool isOwner = false;

        if (authState is Authenticated) {
          currentUser = authState.user;
          isOwner = currentUser.id != request.requesterId;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card
              Card(
                color: _getStatusColor(request.status).withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(request.status),
                          color: _getStatusColor(request.status),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusText(request.status),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(request.status),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStatusDescription(request.status, request.type),
                              style: TextStyle(
                                fontSize: 14,
                                color: _getStatusColor(request.status).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Pet Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Column(
                  children: [
                    // Pet Image
                    if (animal.images.isNotEmpty)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12.0),
                        ),
                        child: Image.network(
                          animal.images.first,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 200,
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.pets,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ),

                    // Pet Details
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  animal.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/animal-details',
                                    arguments: {'animalId': animal.id},
                                  );
                                },
                                icon: const Icon(Icons.info),
                                label: const Text('View Details'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${animal.breed} · ${animal.age} years old · ${animal.gender}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Request Details
              const Text(
                'Request Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.category,
                        'Request Type',
                        request.type == 'adoption' ? 'Adoption' : 'Visit',
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Requested Date',
                        DateFormat('EEEE, MMMM d, y').format(request.visitDate!),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.access_time,
                        'Requested Time',
                        DateFormat('h:mm a').format(request.visitDate!),
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.note,
                        'Notes',
                        request.notes,
                        crossAlign: CrossAxisAlignment.start,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              if (request.status == 'pending')
                isOwner
                    ? // Owner Actions
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Reject',
                        onPressed: () {
                          _showResponseDialog(context, request, false);
                        },
                        type: ButtonType.secondary,
                        icon: Icons.close,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Approve',
                        onPressed: () {
                          _showResponseDialog(context, request, true);
                        },
                        icon: Icons.check,
                      ),
                    ),
                  ],
                )
                    : // Requester Actions
                CustomButton(
                  text: 'Cancel Request',
                  onPressed: () {
                    _showCancelDialog(context, request);
                  },
                  type: ButtonType.secondary,
                  icon: Icons.cancel,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {CrossAxisAlignment crossAlign = CrossAxisAlignment.center}) {
    return Row(
      crossAxisAlignment: crossAlign,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.orange;
      case 'pending':
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.do_not_disturb;
      case 'pending':
      default:
        return Icons.hourglass_empty;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pending';
    }
  }

  String _getStatusDescription(String status, String type) {
    switch (status) {
      case 'approved':
        return type == 'adoption'
            ? 'Your adoption request has been approved'
            : 'Your visit has been scheduled';
      case 'rejected':
        return 'This request has been rejected';
      case 'cancelled':
        return 'This request has been cancelled';
      case 'pending':
      default:
        return 'Waiting for approval';
    }
  }

  void _showResponseDialog(BuildContext context, AdoptionRequest request, bool isApprove) {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isApprove ? 'Approve Request?' : 'Reject Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isApprove
                  ? 'Are you sure you want to approve this ${request.type} request?'
                  : 'Are you sure you want to reject this ${request.type} request?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: isApprove ? 'Additional instructions' : 'Reason for rejection',
                hintText: isApprove
                    ? 'Add any additional details or instructions...'
                    : 'Add a reason for rejection...',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (isApprove) {
                context.read<AdoptionBloc>().add(
                  ApproveAdoptionRequestEvent(
                    requestId: request.id,
                    notes: notesController.text,
                  ),
                );
              } else {
                context.read<AdoptionBloc>().add(
                  RejectAdoptionRequestEvent(
                    requestId: request.id,
                    notes: notesController.text,
                  ),
                );
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
            ),
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, AdoptionRequest request) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to cancel this request?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                hintText: 'Add a reason for cancellation...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdoptionBloc>().add(
                CancelAdoptionRequestEvent(
                  requestId: request.id,
                  notes: reasonController.text,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );
  }
}
