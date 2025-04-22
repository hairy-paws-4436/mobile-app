// lib/presentation/screens/adoption/adoption_requests_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/adoption_request.dart';
import '../../../data/models/user.dart';
import '../../bloc/adoption/adoption_bloc.dart';
import '../../bloc/adoption/adoption_event.dart';
import '../../bloc/adoption/adoption_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';


class AdoptionRequestsScreen extends StatefulWidget {
  const AdoptionRequestsScreen({Key? key}) : super(key: key);

  @override
  State<AdoptionRequestsScreen> createState() => _AdoptionRequestsScreenState();
}

class _AdoptionRequestsScreenState extends State<AdoptionRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch adoption requests
    context.read<AdoptionBloc>().add(FetchAdoptionRequestsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adoption Requests'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
            Tab(text: 'Rejected'),
          ],
        ),
      ),
      body: BlocBuilder<AdoptionBloc, AdoptionState>(
        builder: (context, state) {
          if (state is AdoptionLoading) {
            return const LoadingIndicator(message: 'Loading adoption requests...');
          } else if (state is AdoptionError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                context.read<AdoptionBloc>().add(FetchAdoptionRequestsEvent());
              },
            );
          } else if (state is AdoptionRequestsLoaded) {
            final requests = state.requests;

            // Filter requests by status
            final pendingRequests = requests.where((r) => r.status == 'pending').toList();
            final approvedRequests = requests.where((r) => r.status == 'approved').toList();
            final rejectedRequests = requests.where((r) => r.status == 'rejected').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                // Pending Requests Tab
                _buildRequestsList(pendingRequests),

                // Approved Requests Tab
                _buildRequestsList(approvedRequests),

                // Rejected Requests Tab
                _buildRequestsList(rejectedRequests),
              ],
            );
          }

          return const LoadingIndicator(message: 'Loading adoption requests...');
        },
      ),
    );
  }

  Widget _buildRequestsList(List<AdoptionRequest> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pets,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No requests found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdoptionBloc>().add(FetchAdoptionRequestsEvent());
      },
      child: ListView.builder(
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildRequestCard(request);
        },
      ),
    );
  }

  Widget _buildRequestCard(AdoptionRequest request) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        late User currentUser;
        bool isOwner = false;

        if (authState is Authenticated) {
          currentUser = authState.user;
          isOwner = currentUser.id != request.requesterId;
        }

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Request Type Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: request.type == 'adoption'
                            ? AppTheme.primaryColor
                            : AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        request.type == 'adoption' ? 'Adoption' : 'Visit',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM d, y · h:mm a').format(request.visitDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes
                const Text(
                  'Request Notes:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  request.notes,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Action Buttons (for owners)
                if (isOwner && request.status == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _showResponseDialog(context, request, false);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Reject'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showResponseDialog(context, request, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text('Approve'),
                      ),
                    ],
                  ),

                // Cancel Button (for requesters)
                if (!isOwner && request.status == 'pending')
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        _showCancelDialog(context, request);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Cancel Request'),
                    ),
                  ),

                // Status Message (for non-pending requests)
                if (request.status != 'pending')
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: request.status == 'approved'
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          request.status == 'approved'
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: request.status == 'approved'
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                request.status == 'approved'
                                    ? 'Request Approved'
                                    : 'Request Rejected',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: request.status == 'approved'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                              if (request.status == 'approved')
                                const Text(
                                  'Check your notifications for more details.',
                                  style: TextStyle(fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
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