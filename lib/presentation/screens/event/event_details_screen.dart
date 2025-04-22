import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/event.dart';
import '../../../data/models/user.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/event/event_bloc.dart';
import '../../bloc/event/event_event.dart';
import '../../bloc/event/event_state.dart';
import '../../common/custom_button.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({
    Key? key,
    required this.eventId,
  }) : super(key: key);

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch event details
    context.read<EventBloc>().add(FetchEventDetailsEvent(widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          if (state is EventLoading) {
            return const LoadingIndicator(message: 'Loading event details...');
          } else if (state is EventError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                context.read<EventBloc>().add(FetchEventDetailsEvent(widget.eventId));
              },
            );
          } else if (state is EventDetailsLoaded) {
            final event = state.event;
            return _buildContent(context, event);
          }

          return const LoadingIndicator(message: 'Loading event details...');
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Event event) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        late User? currentUser;
        bool isOrganizer = false;

        if (authState is Authenticated) {
          currentUser = authState.user;
          isOrganizer = currentUser.id == event.organizerId;
        }

        return CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: event.image != null
                    ? Image.network(
                  event.image!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppTheme.primaryColor,
                    child: Center(
                      child: Icon(
                        event.isVolunteerEvent ? Icons.volunteer_activism : Icons.event,
                        size: 60,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                )
                    : Container(
                  color: AppTheme.primaryColor,
                  child: Center(
                    child: Icon(
                      event.isVolunteerEvent ? Icons.volunteer_activism : Icons.event,
                      size: 60,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              actions: [
                if (isOrganizer)
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: AppTheme.primaryColor),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.pushNamed(
                          context,
                          '/event-form',
                          arguments: {'eventId': event.id},
                        );
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, event);
                      }
                    },
                  ),
              ],
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title and Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (event.isVolunteerEvent)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Volunteer',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Date and Time Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.calendar_today,
                              'Date',
                              DateFormat('EEEE, MMMM d, y').format(event.eventDate),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.access_time,
                              'Time',
                              DateFormat('h:mm a').format(event.eventDate),
                            ),
                            if (event.endDate != null) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.timer,
                                'End Time',
                                DateFormat('h:mm a').format(event.endDate!),
                              ),
                            ],
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.location_on,
                              'Location',
                              event.location,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      'About this Event',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Volunteer Information
                    if (event.isVolunteerEvent) ...[
                      const Text(
                        'Volunteer Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.people,
                                'Max Participants',
                                event.maxParticipants?.toString() ?? 'Unlimited',
                              ),
                              if (event.requirements != null && event.requirements!.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  Icons.assignment,
                                  'Requirements',
                                  event.requirements!,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Add to Calendar Button
                    CustomButton(
                      text: 'Add to Calendar',
                      onPressed: () {
                        _addToCalendar(event);
                      },
                      type: ButtonType.secondary,
                      icon: Icons.calendar_today,
                    ),
                    const SizedBox(height: 16),

                    // Get Directions Button
                    CustomButton(
                      text: 'Get Directions',
                      onPressed: () async {
                        final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(event.location)}';
                        if (await canLaunch(url)) {
                          await launch(url);
                        }
                      },
                      type: ButtonType.secondary,
                      icon: Icons.directions,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  void _showDeleteConfirmationDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text(
          'Are you sure you want to delete "${event.title}"? This action cannot be undone.',
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
              context.read<EventBloc>().add(DeleteEventEvent(event.id));
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
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

  Future<void> _addToCalendar(Event event) async {
    // Use a calendar plugin or intent to add the event to calendar
    // This is a placeholder for the functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Event added to calendar'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
