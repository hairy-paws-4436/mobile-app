import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/event.dart';
import '../../../bloc/event/event_bloc.dart';
import '../../../bloc/event/event_event.dart';
import '../../../bloc/event/event_state.dart';
import '../../../common/error_display.dart';
import '../../../common/event_card.dart';
import '../../../common/loading_indicator.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({Key? key}) : super(key: key);

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showOnlyVolunteerEvents = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Search Field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search events...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Filter Switch
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text(
                    'Volunteer Events Only',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: _showOnlyVolunteerEvents,
                    onChanged: (value) {
                      setState(() {
                        _showOnlyVolunteerEvents = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _buildContent(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(EventState state) {
    if (state is EventLoading) {
      return const LoadingIndicator(message: 'Loading events...');
    } else if (state is EventError) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () {
          context.read<EventBloc>().add(FetchEventsEvent());
        },
      );
    } else if (state is EventsLoaded) {
      final filteredEvents = _filterEvents(state.events);

      if (filteredEvents.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No events found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
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
          context.read<EventBloc>().add(FetchEventsEvent());
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16.0),
          itemCount: filteredEvents.length,
          itemBuilder: (context, index) {
            final event = filteredEvents[index];
            return EventCard(
              event: event,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/event-details',
                  arguments: {'eventId': event.id},
                );
              },
            );
          },
        ),
      );
    }

    return const LoadingIndicator(message: 'Loading events...');
  }

  List<Event> _filterEvents(List<Event> events) {
    return events.where((event) {
      // Apply volunteer filter
      if (_showOnlyVolunteerEvents && !event.isVolunteerEvent) {
        return false;
      }

      // Apply search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return event.title.toLowerCase().contains(query) ||
            event.description.toLowerCase().contains(query) ||
            event.location.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }
}
