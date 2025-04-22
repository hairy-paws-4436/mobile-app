import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/event.dart';
import '../../bloc/event/event_bloc.dart';
import '../../bloc/event/event_event.dart';
import '../../bloc/event/event_state.dart';
import '../../common/custom_button.dart';
import '../../common/loading_indicator.dart';


class EventFormScreen extends StatefulWidget {
  final String? eventId;

  const EventFormScreen({
    Key? key,
    this.eventId,
  }) : super(key: key);

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  DateTime _eventDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _eventTime = TimeOfDay.now();
  DateTime? _endDate;
  TimeOfDay? _endTime;
  bool _isVolunteerEvent = false;
  XFile? _imageFile;
  final _imagePicker = ImagePicker();
  bool _isEditing = false;
  Event? _event;

  @override
  void initState() {
    super.initState();

    // Check if editing existing event
    if (widget.eventId != null) {
      _isEditing = true;
      // Fetch event details
      context.read<EventBloc>().add(FetchEventDetailsEvent(widget.eventId!));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _requirementsController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  void _initializeForm(Event event) {
    _event = event;
    _titleController.text = event.title;
    _descriptionController.text = event.description;
    _eventDate = event.eventDate;
    _eventTime = TimeOfDay.fromDateTime(event.eventDate);
    if (event.endDate != null) {
      _endDate = event.endDate;
      _endTime = TimeOfDay.fromDateTime(event.endDate!);
    }
    _locationController.text = event.location;
    _isVolunteerEvent = event.isVolunteerEvent;
    if (event.maxParticipants != null) {
      _maxParticipantsController.text = event.maxParticipants.toString();
    }
    if (event.requirements != null) {
      _requirementsController.text = event.requirements!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Event' : 'Create Event'),
      ),
      body: BlocConsumer<EventBloc, EventState>(
        listener: (context, state) {
          if (state is EventCreated || state is EventUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditing
                    ? 'Event updated successfully'
                    : 'Event created successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is EventDetailsLoaded && _isEditing && _event == null) {
            _initializeForm(state.event);
          }
        },
        builder: (context, state) {
          if (_isEditing && state is EventLoading && _event == null) {
            return const LoadingIndicator(message: 'Loading event details...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Event Image
                  const Text(
                    'Event Image (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Image Picker
                  InkWell(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        image: _imageFile != null
                            ? DecorationImage(
                          image: FileImage(
                            File(_imageFile!.path),
                          ),
                          fit: BoxFit.cover,
                        )
                            : _event != null && _event!.image != null
                            ? DecorationImage(
                          image: NetworkImage(_event!.image!),
                          fit: BoxFit.cover,
                        )
                            : null,
                      ),
                      child: _imageFile == null && (_event == null || _event!.image == null)
                          ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Event Image',
                            style: TextStyle(
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Information
                  const Text(
                    'Event Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Event Title',
                      hintText: 'Enter event title',
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the event title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter event description',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the event description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Event Date
                  InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Event Date',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        DateFormat('EEEE, MMMM d, y').format(_eventDate),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Event Time
                  InkWell(
                    onTap: () => _selectTime(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Event Time',
                        prefixIcon: Icon(Icons.access_time),
                      ),
                      child: Text(_eventTime.format(context)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // End Date and Time (Optional)
                  Row(
                    children: [
                      Expanded(
                        child: CheckboxListTile(
                          title: const Text('Add End Date/Time'),
                          value: _endDate != null,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _endDate = _eventDate;
                                _endTime = TimeOfDay(
                                  hour: _eventTime.hour + 2,
                                  minute: _eventTime.minute,
                                );
                              } else {
                                _endDate = null;
                                _endTime = null;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  if (_endDate != null) ...[
                    const SizedBox(height: 16),

                    // End Date
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          DateFormat('EEEE, MMMM d, y').format(_endDate!),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // End Time
                    InkWell(
                      onTap: () => _selectTime(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(_endTime!.format(context)),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Location
                  TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      hintText: 'Enter event location',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the event location';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Volunteer Event Section
                  const Text(
                    'Volunteer Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Is Volunteer Event
                  SwitchListTile(
                    title: const Text('Volunteer Event'),
                    subtitle: const Text('Is this a volunteer event?'),
                    value: _isVolunteerEvent,
                    onChanged: (value) {
                      setState(() {
                        _isVolunteerEvent = value;
                      });
                    },
                  ),

                  if (_isVolunteerEvent) ...[
                    const SizedBox(height: 16),

                    // Max Participants
                    TextFormField(
                      controller: _maxParticipantsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Maximum Participants',
                        hintText: 'Enter maximum number of volunteers',
                        prefixIcon: Icon(Icons.people),
                      ),
                      validator: (value) {
                        if (_isVolunteerEvent) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the maximum number of participants';
                          }
                          if (int.tryParse(value) == null || int.parse(value) <= 0) {
                            return 'Please enter a valid number';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Requirements
                    TextFormField(
                      controller: _requirementsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Requirements',
                        hintText: 'Enter volunteer requirements',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.assignment),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: _isEditing ? 'Update Event' : 'Create Event',
                    onPressed: _submitForm,
                    isLoading: state is EventLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _eventDate : _endDate!;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime.now() : _eventDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _eventDate = picked;
          // Update end date if it exists and is before the new start date
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = picked;
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final initialTime = isStartTime ? _eventTime : _endTime!;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _eventTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Combine date and time
      final eventDateTime = DateTime(
        _eventDate.year,
        _eventDate.month,
        _eventDate.day,
        _eventTime.hour,
        _eventTime.minute,
      );

      DateTime? endDateTime;
      if (_endDate != null && _endTime != null) {
        endDateTime = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
          _endTime!.hour,
          _endTime!.minute,
        );
      }

      final eventData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'eventDate': eventDateTime.toIso8601String(),
        'location': _locationController.text,
        'isVolunteerEvent': _isVolunteerEvent,
        if (endDateTime != null) 'endDate': endDateTime.toIso8601String(),
        if (_isVolunteerEvent && _maxParticipantsController.text.isNotEmpty)
          'maxParticipants': int.parse(_maxParticipantsController.text),
        if (_isVolunteerEvent && _requirementsController.text.isNotEmpty)
          'requirements': _requirementsController.text,
      };

      if (_isEditing) {
        context.read<EventBloc>().add(
          UpdateEventEvent(
            eventId: widget.eventId!,
            eventData: eventData,
          ),
        );
      } else {
        context.read<EventBloc>().add(
          CreateEventEvent(
            eventData: eventData,
            imagePath: _imageFile?.path,
          ),
        );
      }
    }
  }
}