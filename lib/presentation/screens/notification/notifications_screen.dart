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

    // Fetch notifications
    context.read<NotificationBloc>().add(FetchNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Mark all as read button
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {
              _showMarkAllAsReadConfirmation(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
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
      case 'adoption':
      // Extract adoption request ID if available
        final adoptionIdRegex = RegExp(r'ID: ([a-zA-Z0-9-]+)');
        final match = adoptionIdRegex.firstMatch(notification.message);
        if (match != null && match.groupCount >= 1) {
          final adoptionId = match.group(1);
          Navigator.pushNamed(
            context,
            '/adoption-details',
            arguments: {'adoptionId': adoptionId},
          );
        }
        break;
      case 'donation':
        Navigator.pushNamed(context, '/donations');
        break;
      case 'event':
        Navigator.pushNamed(context, '/events');
        break;
      default:
      // Just mark as read
        break;
    }
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
            onPressed: () {
              Navigator.pop(context);
            },
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
            onPressed: () {
              Navigator.pop(context);
            },
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