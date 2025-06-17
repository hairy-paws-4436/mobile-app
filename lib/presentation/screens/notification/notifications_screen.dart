import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/notification.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/notification/notification_event.dart';
import '../../bloc/notification/notification_state.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';
import '../../common/notification_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              _showMarkAllAsReadConfirmation(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is DonationAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Donation accepted successfully'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is DonationRejected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Donation rejected'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is AdoptionAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Adoption request approved'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AdoptionRejected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Adoption request rejected'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is VisitAccepted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Visit request approved'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is VisitRejected) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('❌ Visit request rejected'),
                backgroundColor: Colors.orange,
              ),
            );
          } else if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const LoadingIndicator(message: 'Loading notifications...');
          } else if (state is NotificationError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                context.read<NotificationBloc>().add(FetchNotificationsEvent());
              },
            );
          } else if (state is NotificationsLoaded) {
            final notifications = state.notifications;

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'You don\'t have any notifications yet',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(FetchNotificationsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16.0),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () {
                      _handleNotificationTap(notification);
                    },
                    onMarkAsRead: () {
                      context.read<NotificationBloc>().add(
                        MarkNotificationAsReadEvent(notification.id),
                      );
                    },
                    onDelete: () {
                      _showDeleteConfirmation(context, notification.id);
                    },
                    // Add all request-specific actions
                    onAcceptDonation: notification.isDonationNotification
                        ? () => _handleAcceptDonation(notification)
                        : null,
                    onRejectDonation: notification.isDonationNotification
                        ? () => _handleRejectDonation(notification)
                        : null,
                    onAcceptAdoption: notification.isAdoptionRequest
                        ? () => _handleAcceptAdoption(notification)
                        : null,
                    onRejectAdoption: notification.isAdoptionRequest
                        ? () => _handleRejectAdoption(notification)
                        : null,
                    onAcceptVisit: notification.isVisitRequest
                        ? () => _handleAcceptVisit(notification)
                        : null,
                    onRejectVisit: notification.isVisitRequest
                        ? () => _handleRejectVisit(notification)
                        : null,
                  );
                },
              ),
            );
          }

          return const LoadingIndicator(message: 'Loading notifications...');
        },
      ),
    );
  }

  void _handleNotificationTap(AppNotification notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      context.read<NotificationBloc>().add(
        MarkNotificationAsReadEvent(notification.id),
      );
    }

    // Navigate based on notification type
    switch (notification.type.toLowerCase()) {
      case 'adoption_request':
      case 'adoption_approved':
      case 'adoption_rejected':
        if (notification.referenceId != null) {
          Navigator.pushNamed(
            context,
            '/adoption-details',
            arguments: {'adoptionId': notification.referenceId},
          );
        }
        break;
      case 'visit_request':
      case 'visit_approved':
      case 'visit_rejected':
        if (notification.referenceId != null) {
          Navigator.pushNamed(
            context,
            '/visit-details',
            arguments: {'visitId': notification.referenceId},
          );
        }
        break;
      case 'donation_received':
      case 'donation_confirmed':
      // Could navigate to donation details if needed
        if (notification.referenceId != null) {
          Navigator.pushNamed(
            context,
            '/donation-details',
            arguments: {'donationId': notification.referenceId},
          );
        }
        break;
      case 'event_reminder':
      case 'new_event':
        Navigator.pushNamed(context, '/events');
        break;
    }
  }

  void _handleAcceptDonation(AppNotification notification) {
    final donationId = notification.extractedDonationId;
    if (donationId != null) {
      _showAcceptDonationDialog(notification.id, donationId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not find donation ID'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleRejectDonation(AppNotification notification) {
    final donationId = notification.extractedDonationId;
    if (donationId != null) {
      _showRejectDonationDialog(notification.id, donationId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not find donation ID'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAcceptDonationDialog(String notificationId, String donationId) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.volunteer_activism, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Accept Donation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to accept this donation?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any notes about receiving the donation...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(
                AcceptDonationEvent(
                  donationId: donationId,
                  notificationId: notificationId,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept Donation'),
          ),
        ],
      ),
    );
  }

  void _showRejectDonationDialog(String notificationId, String donationId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Reject Donation'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why are you rejecting this donation?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                hintText: 'Explain why you cannot accept this donation...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(
                RejectDonationEvent(
                  donationId: donationId,
                  notificationId: notificationId,
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : null,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject Donation'),
          ),
        ],
      ),
    );
  }
  void _showAcceptAdoptionDialog(String notificationId, String adoptionId) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.pets, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Approve Adoption'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to approve this adoption request?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any notes about the adoption approval...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(
                AcceptAdoptionEvent(
                  adoptionId: adoptionId,
                  notificationId: notificationId,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve Adoption'),
          ),
        ],
      ),
    );
  }

  void _showRejectAdoptionDialog(String notificationId, String adoptionId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.close, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Reject Adoption'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why are you rejecting this adoption request?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                hintText: 'Explain why this adoption cannot be approved...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(
                RejectAdoptionEvent(
                  adoptionId: adoptionId,
                  notificationId: notificationId,
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : null,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject Adoption'),
          ),
        ],
      ),
    );
  }

  void _showAcceptVisitDialog(String notificationId, String visitId) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Approve Visit'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to approve this visit request?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any notes about the visit approval...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(
                AcceptVisitEvent(
                  visitId: visitId,
                  notificationId: notificationId,
                  notes: notesController.text.isNotEmpty
                      ? notesController.text
                      : null,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Approve Visit'),
          ),
        ],
      ),
    );
  }

  void _showRejectVisitDialog(String notificationId, String visitId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.event_busy, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Reject Visit'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Why are you rejecting this visit request?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                hintText: 'Explain why this visit cannot be approved...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(
                RejectVisitEvent(
                  visitId: visitId,
                  notificationId: notificationId,
                  reason: reasonController.text.isNotEmpty
                      ? reasonController.text
                      : null,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject Visit'),
          ),
        ],
      ),
    );
  }  void _handleAcceptAdoption(AppNotification notification) {
    final adoptionId = notification.extractedAdoptionId;
    if (adoptionId != null) {
      _showAcceptAdoptionDialog(notification.id, adoptionId);
    } else {
      _showErrorSnackBar('Could not find adoption ID');
    }
  }

  void _handleRejectAdoption(AppNotification notification) {
    final adoptionId = notification.extractedAdoptionId;
    if (adoptionId != null) {
      _showRejectAdoptionDialog(notification.id, adoptionId);
    } else {
      _showErrorSnackBar('Could not find adoption ID');
    }
  }

  void _handleAcceptVisit(AppNotification notification) {
    final visitId = notification.extractedVisitId;
    if (visitId != null) {
      _showAcceptVisitDialog(notification.id, visitId);
    } else {
      _showErrorSnackBar('Could not find visit ID');
    }
  }

  void _handleRejectVisit(AppNotification notification) {
    final visitId = notification.extractedVisitId;
    if (visitId != null) {
      _showRejectVisitDialog(notification.id, visitId);
    } else {
      _showErrorSnackBar('Could not find visit ID');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
  void _showDeleteConfirmation(BuildContext context, String notificationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Notification'),
        content: const Text(
          'Are you sure you want to delete this notification?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(
                DeleteNotificationEvent(notificationId),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showMarkAllAsReadConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All as Read'),
        content: const Text(
          'Are you sure you want to mark all notifications as read?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<NotificationBloc>().add(
                MarkAllNotificationsAsReadEvent(),
              );
              Navigator.pop(context);
            },
            child: const Text('Mark All as Read'),
          ),
        ],
      ),
    );
  }
}