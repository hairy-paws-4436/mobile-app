import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../config/theme.dart';
import '../../../data/models/adoption_request.dart';
import '../../../data/models/animal.dart';
import '../../bloc/adoption/adoption_bloc.dart';
import '../../bloc/adoption/adoption_event.dart';
import '../../bloc/adoption/adoption_state.dart';
import '../../bloc/animal/animal_bloc.dart';
import '../../bloc/animal/animal_event.dart';
import '../../bloc/animal/animal_state.dart';
import '../../common/custom_button.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class AdoptionRequestFormScreen extends StatefulWidget {
  final String animalId;
  final String? type; // 'adoption' or 'visit'

  const AdoptionRequestFormScreen({
    Key? key,
    required this.animalId,
    this.type,
  }) : super(key: key);

  @override
  State<AdoptionRequestFormScreen> createState() => _AdoptionRequestFormScreenState();
}

class _AdoptionRequestFormScreenState extends State<AdoptionRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _requestType = 'adoption';

  @override
  void initState() {
    super.initState();

    // Set request type if provided
    if (widget.type != null) {
      _requestType = widget.type!;
    }

    // Fetch animal details
    context.read<AnimalBloc>().add(FetchAnimalDetailsEvent(widget.animalId));
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_requestType == 'adoption' ? 'Adoption Request' : 'Schedule Visit'),
      ),
      body: BlocConsumer<AdoptionBloc, AdoptionState>(
        listener: (context, state) {
          if (state is AdoptionRequestCreated) {
            // Show success snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _requestType == 'adoption'
                      ? 'Adoption request submitted successfully!'
                      : 'Visit scheduled successfully!',
                ),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate back to pet details
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return BlocBuilder<AnimalBloc, AnimalState>(
            builder: (context, animalState) {
              if (animalState is AnimalLoading) {
                return const LoadingIndicator(message: 'Loading pet details...');
              } else if (animalState is AnimalError) {
                return ErrorDisplay(
                  message: animalState.message,
                  onRetry: () {
                    context.read<AnimalBloc>().add(FetchAnimalDetailsEvent(widget.animalId));
                  },
                );
              } else if (animalState is AnimalDetailsLoaded) {
                final animal = animalState.animal;
                return _buildContent(context, animal, state);
              }

              return const LoadingIndicator(message: 'Loading pet details...');
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Animal animal, AdoptionState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Pet Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: animal.images.isNotEmpty
                          ? Image.network(
                        animal.images.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.pets,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                        ),
                      )
                          : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.pets,
                          size: 40,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Pet Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            animal.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${animal.breed} · ${animal.age} ${animal.age == 1 ? 'year' : 'years'} old',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${animal.gender} · ${animal.size}',
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
            ),
            const SizedBox(height: 24),

            // Request Type
            const Text(
              'Request Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Adoption'),
                    subtitle: const Text('Request to adopt'),
                    value: 'adoption',
                    groupValue: _requestType,
                    onChanged: (value) {
                      setState(() {
                        _requestType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Visit'),
                    subtitle: const Text('Schedule a visit'),
                    value: 'visit',
                    groupValue: _requestType,
                    onChanged: (value) {
                      setState(() {
                        _requestType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Visit Date
            const Text(
              'Visit Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Visit Time
            const Text(
              'Visit Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectTime(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            const Text(
              'Additional Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Add any additional information or questions you have...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter some notes about your request';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Submit Button
            CustomButton(
              text: _requestType == 'adoption' ? 'Submit Adoption Request' : 'Schedule Visit',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final visitDateTime = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );

                  final adoptionRequest = AdoptionRequest(
                    id: '', // Will be generated on the server
                    animalId: animal.id,
                    type: _requestType,
                    visitDate: visitDateTime,
                    notes: _notesController.text,
                    status: 'pending',
                    requesterId: '', // Will be set by the server
                  );

                  context.read<AdoptionBloc>().add(
                    CreateAdoptionRequestEvent(adoptionRequest),
                  );
                }
              },
              isLoading: state is AdoptionLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
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

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
}
