import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../data/models/notification.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;
  final VoidCallback? onAcceptDonation;
  final VoidCallback? onRejectDonation;
  final VoidCallback? onAcceptAdoption;
  final VoidCallback? onRejectAdoption;
  final VoidCallback? onAcceptVisit;
  final VoidCallback? onRejectVisit;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onDelete,
    this.onAcceptDonation,
    this.onRejectDonation,
    this.onAcceptAdoption,
    this.onRejectAdoption,
    this.onAcceptVisit,
    this.onRejectVisit,
  }) : super(key: key); // <- este paréntesis era el que faltaba

  Widget _buildActionSection() {
    String title = '';
    String acceptLabel = '';
    String rejectLabel = '';
    VoidCallback? acceptAction;
    VoidCallback? rejectAction;
    IconData acceptIcon = Icons.check_circle;
    IconData rejectIcon = Icons.cancel;

    if (notification.type.toLowerCase() == 'donation_received') {
      title = 'Donation Actions';
      acceptLabel = 'Accept Donation';
      rejectLabel = 'Reject Donation';
      acceptAction = onAcceptDonation;
      rejectAction = onRejectDonation;
      acceptIcon = Icons.volunteer_activism;
      rejectIcon = Icons.cancel;
    } else if (notification.type.toLowerCase() == 'adoption_request') {
      title = 'Adoption Request';
      acceptLabel = 'Approve';
      rejectLabel = 'Reject';
      acceptAction = onAcceptAdoption;
      rejectAction = onRejectAdoption;
      acceptIcon = Icons.pets;
      rejectIcon = Icons.close;
    } else if (notification.type.toLowerCase() == 'visit_request') {
      title = 'Visit Request';
      acceptLabel = 'Approve Visit';
      rejectLabel = 'Reject Visit';
      acceptAction = onAcceptVisit;
      rejectAction = onRejectVisit;
      acceptIcon = Icons.calendar_today;
      rejectIcon = Icons.event_busy;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (acceptAction != null)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: acceptAction,
                  icon: Icon(acceptIcon, size: 18),
                  label: Text(acceptLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            if (acceptAction != null && rejectAction != null)
              const SizedBox(width: 12),
            if (rejectAction != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: rejectAction,
                  icon: Icon(rejectIcon, size: 18),
                  label: Text(rejectLabel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    side: BorderSide(color: Colors.red[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasActions = notification.type.toLowerCase() == 'donation_received' ||
        notification.type.toLowerCase() == 'adoption_request' ||
        notification.type.toLowerCase() == 'visit_request';

    return Card(
      elevation: notification.isRead ? 2 : 6,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(
          color: _getNotificationColor(notification.type).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: notification.isRead
              ? null
              : LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getNotificationColor(notification.type).withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.0),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _getNotificationColor(notification.type),
                            _getNotificationColor(notification.type).withOpacity(0.7),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _getNotificationColor(notification.type).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        _getNotificationIcon(notification.type),
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: notification.isRead
                                        ? FontWeight.w600
                                        : FontWeight.bold,
                                    color: notification.isRead
                                        ? Colors.grey[800]
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: _getNotificationColor(notification.type),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatNotificationTime(notification.createdAt),
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (hasActions) ...[
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  _buildActionSection(),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!notification.isRead)
                      TextButton.icon(
                        onPressed: onMarkAsRead,
                        icon: const Icon(Icons.done, size: 16),
                        label: const Text('Mark as Read'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Delete'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[600],
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'adoption_request':
      case 'adoption_approved':
      case 'adoption_rejected':
        return Icons.pets;
      case 'visit_request':
      case 'visit_approved':
      case 'visit_rejected':
        return Icons.calendar_today;
      case 'donation_received':
      case 'donation_confirmed':
        return Icons.volunteer_activism;
      case 'event_reminder':
      case 'new_event':
        return Icons.event;
      case 'account_verified':
        return Icons.verified_user;
      case 'general':
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type.toLowerCase()) {
      case 'adoption_request':
      case 'adoption_approved':
      case 'adoption_rejected':
        return AppTheme.primaryColor;
      case 'visit_request':
      case 'visit_approved':
      case 'visit_rejected':
        return Colors.purple;
      case 'donation_received':
      case 'donation_confirmed':
        return AppTheme.successColor;
      case 'event_reminder':
      case 'new_event':
        return AppTheme.secondaryColor;
      case 'account_verified':
        return Colors.green;
      case 'general':
      default:
        return AppTheme.textPrimaryColor;
    }
  }
}
