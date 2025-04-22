import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/animal.dart';
import '../../bloc/animal/animal_bloc.dart';
import '../../bloc/animal/animal_event.dart';
import '../../bloc/animal/animal_state.dart';
import '../../common/custom_button.dart';
import '../../common/loading_indicator.dart';

class AnimalFormScreen extends StatefulWidget {
  final String? animalId;

  const AnimalFormScreen({
    Key? key,
    this.animalId,
  }) : super(key: key);

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _colorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _medicalInfoController = TextEditingController();
  final _vaccinationStatusController = TextEditingController();

  String _gender = 'male';
  String _size = 'medium';
  List<XFile> _imageFiles = [];
  final _imagePicker = ImagePicker();
  bool _isEditing = false;
  Animal? _animal;

  @override
  void initState() {
    super.initState();

    // Check if editing existing animal
    if (widget.animalId != null) {
      _isEditing = true;
      // Fetch animal details
      context.read<AnimalBloc>().add(FetchAnimalDetailsEvent(widget.animalId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _colorController.dispose();
    _descriptionController.dispose();
    _medicalInfoController.dispose();
    _vaccinationStatusController.dispose();
    super.dispose();
  }

  void _initializeForm(Animal animal) {
    _animal = animal;
    _nameController.text = animal.name;
    _speciesController.text = animal.species;
    _breedController.text = animal.breed;
    _ageController.text = animal.age.toString();
    _gender = animal.gender.toLowerCase();
    _size = animal.size.toLowerCase();
    _colorController.text = animal.color;
    _descriptionController.text = animal.description;
    _medicalInfoController.text = animal.medicalInfo ?? '';
    _vaccinationStatusController.text = animal.vaccinationStatus ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Pet' : 'Add Pet'),
      ),
      body: BlocConsumer<AnimalBloc, AnimalState>(
        listener: (context, state) {
          if (state is AnimalCreated || state is AnimalUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditing
                    ? 'Pet updated successfully'
                    : 'Pet added successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is AnimalError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AnimalDetailsLoaded && _isEditing && _animal == null) {
            _initializeForm(state.animal);
          }
        },
        builder: (context, state) {
          if (_isEditing && state is AnimalLoading && _animal == null) {
            return const LoadingIndicator(message: 'Loading pet details...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet Images
                  const Text(
                    'Pet Images',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Image Picker
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imageFiles.isEmpty && (_animal == null || _animal!.images.isEmpty)
                        ? Center(
                      child: TextButton.icon(
                        onPressed: _pickImages,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Images'),
                      ),
                    )
                        : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageFiles.length + (_animal != null ? _animal!.images.length : 0) + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: _pickImages,
                              child: Container(
                                width: 100,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          );
                        } else if (index <= _imageFiles.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(
                                        File(_imageFiles[index - 1].path),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _imageFiles.removeAt(index - 1);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          final imageIndex = index - _imageFiles.length - 1;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        _animal!.images[imageIndex],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      // Handle removing existing image
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Information
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name',
                      hintText: 'Enter pet name',
                      prefixIcon: Icon(Icons.pets),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the pet name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Species
                  TextFormField(
                    controller: _speciesController,
                    decoration: const InputDecoration(
                      labelText: 'Species',
                      hintText: 'Enter species (e.g., Dog, Cat)',
                      prefixIcon: Icon(Icons.category),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the species';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Breed
                  TextFormField(
                    controller: _breedController,
                    decoration: const InputDecoration(
                      labelText: 'Breed',
                      hintText: 'Enter breed',
                      prefixIcon: Icon(Icons.pets),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the breed';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Age
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age (years)',
                      hintText: 'Enter age in years',
                      prefixIcon: Icon(Icons.cake),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the age';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid age';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Gender',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Male'),
                              value: 'male',
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Female'),
                              value: 'female',
                              groupValue: _gender,
                              onChanged: (value) {
                                setState(() {
                                  _gender = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Size
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Size',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Small'),
                              value: 'small',
                              groupValue: _size,
                              onChanged: (value) {
                                setState(() {
                                  _size = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Medium'),
                              value: 'medium',
                              groupValue: _size,
                              onChanged: (value) {
                                setState(() {
                                  _size = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Large'),
                              value: 'large',
                              groupValue: _size,
                              onChanged: (value) {
                                setState(() {
                                  _size = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Color
                  TextFormField(
                    controller: _colorController,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      hintText: 'Enter pet color',
                      prefixIcon: Icon(Icons.palette),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the color';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Enter a description of the pet...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Medical Information
                  const Text(
                    'Medical Information (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _medicalInfoController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter any medical information...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vaccination Status
                  TextFormField(
                    controller: _vaccinationStatusController,
                    decoration: const InputDecoration(
                      labelText: 'Vaccination Status (Optional)',
                      hintText: 'Enter vaccination details',
                      prefixIcon: Icon(Icons.medical_services),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: _isEditing ? 'Update Pet' : 'Add Pet',
                    onPressed: _submitForm,
                    isLoading: state is AnimalLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _imageFiles.addAll(images);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final animalData = {
        'name': _nameController.text,
        'species': _speciesController.text,
        'breed': _breedController.text,
        'age': int.parse(_ageController.text),
        'gender': _gender,
        'size': _size,
        'color': _colorController.text,
        'description': _descriptionController.text,
        'medicalInfo': _medicalInfoController.text,
        'vaccinationStatus': _vaccinationStatusController.text,
      };

      if (_isEditing) {
        context.read<AnimalBloc>().add(
          UpdateAnimalEvent(
            animalId: widget.animalId!,
            animalData: animalData,
          ),
        );
      } else {
        final imagePaths = _imageFiles.map((file) => file.path).toList();
        context.read<AnimalBloc>().add(
          CreateAnimalEvent(
            animalData: animalData,
            imagePaths: imagePaths,
          ),
        );
      }
    }
  }
}
