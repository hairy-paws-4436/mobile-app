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
    super.key,
    this.animalId,
  });

  @override
  State<AnimalFormScreen> createState() => _AnimalFormScreenState();
}

class _AnimalFormScreenState extends State<AnimalFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _healthDetailsController = TextEditingController();

  String _gender = 'male';
  bool _vaccinated = false;
  bool _sterilized = false;
  final List<XFile> _imageFiles = [];
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
    _typeController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    _healthDetailsController.dispose();
    super.dispose();
  }

  void _initializeForm(Animal animal) {
    _animal = animal;
    _nameController.text = animal.name;
    _typeController.text = animal.type;
    _breedController.text = animal.breed;
    _ageController.text = animal.age.toString();
    _weightController.text = animal.weight.toString();
    _gender = animal.gender.toLowerCase();
    _descriptionController.text = animal.description;
    _healthDetailsController.text = animal.healthDetails;
    _vaccinated = animal.vaccinated;
    _sterilized = animal.sterilized;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Mascota' : 'Añadir Mascota'),
      ),
      body: BlocConsumer<AnimalBloc, AnimalState>(
        listener: (context, state) {
          if (state is AnimalCreated || state is AnimalUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isEditing
                    ? 'Mascota actualizada correctamente'
                    : 'Mascota añadida correctamente'),
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
            return const LoadingIndicator(message: 'Cargando detalles de la mascota...');
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
                    'Imágenes de la Mascota',
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
                        label: const Text('Añadir Imágenes'),
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
                    'Información Básica',
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
                      labelText: 'Nombre',
                      hintText: 'Ingresa el nombre de la mascota',
                      prefixIcon: Icon(Icons.pets),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el nombre';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Type (antes era Species)
                  TextFormField(
                    controller: _typeController,
                    decoration: const InputDecoration(
                      labelText: 'Tipo',
                      hintText: 'Ingresa el tipo (ej. Perro, Gato)',
                      prefixIcon: Icon(Icons.category),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el tipo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Breed
                  TextFormField(
                    controller: _breedController,
                    decoration: const InputDecoration(
                      labelText: 'Raza',
                      hintText: 'Ingresa la raza',
                      prefixIcon: Icon(Icons.pets),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la raza';
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
                      labelText: 'Edad (años)',
                      hintText: 'Ingresa la edad en años',
                      prefixIcon: Icon(Icons.cake),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa la edad';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Por favor ingresa una edad válida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Weight (nuevo campo)
                  TextFormField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Peso (kg)',
                      hintText: 'Ingresa el peso en kilogramos',
                      prefixIcon: Icon(Icons.monitor_weight),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa el peso';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Por favor ingresa un peso válido';
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
                        'Género',
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
                              title: const Text('Macho'),
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
                              title: const Text('Hembra'),
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

                  // Health Status (nuevos campos booleanos)
                  const Text(
                    'Estado de Salud',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Vaccinated
                  SwitchListTile(
                    title: const Text('Vacunado'),
                    value: _vaccinated,
                    onChanged: (value) {
                      setState(() {
                        _vaccinated = value;
                      });
                    },
                    secondary: Icon(
                      Icons.vaccines,
                      color: _vaccinated ? Colors.green : Colors.grey,
                    ),
                  ),

                  // Sterilized
                  SwitchListTile(
                    title: const Text('Esterilizado'),
                    value: _sterilized,
                    onChanged: (value) {
                      setState(() {
                        _sterilized = value;
                      });
                    },
                    secondary: Icon(
                      Icons.cut,
                      color: _sterilized ? Colors.green : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Descripción',
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
                      hintText: 'Ingresa una descripción de la mascota...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa una descripción';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Health Details (reemplaza medicalInfo y vaccinationStatus)
                  const Text(
                    'Detalles de Salud',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _healthDetailsController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Ingresa información detallada sobre la salud de la mascota...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa detalles de salud';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: _isEditing ? 'Actualizar Mascota' : 'Añadir Mascota',
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
        'type': _typeController.text,
        'breed': _breedController.text,
        'age': int.parse(_ageController.text),
        'weight': double.parse(_weightController.text),
        'gender': _gender,
        'description': _descriptionController.text,
        'healthDetails': _healthDetailsController.text,
        'vaccinated': _vaccinated,
        'sterilized': _sterilized,
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