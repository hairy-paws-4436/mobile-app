import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../bloc/matching/matching_bloc.dart';
import '../../bloc/matching/matching_event.dart';
import '../../bloc/matching/matching_state.dart';
import '../../common/custom_button.dart';
import '../../common/loading_indicator.dart';

class AnimalProfileFormScreen extends StatefulWidget {
  final String animalId;

  const AnimalProfileFormScreen({
    super.key,
    required this.animalId,
  });

  @override
  State<AnimalProfileFormScreen> createState() => _AnimalProfileFormScreenState();
}

class _AnimalProfileFormScreenState extends State<AnimalProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Form controllers and variables
  String _energyLevel = 'moderate';
  String _socialLevel = 'friendly';
  bool _goodWithKids = true;
  bool _goodWithOtherPets = true;
  bool _goodWithStrangers = true;

  String _trainingLevel = 'basic';
  bool _houseTrained = true;
  bool _leashTrained = true;
  final List<String> _knownCommands = [];

  String _careLevel = 'moderate';
  String _exerciseNeeds = 'moderate';
  String _groomingNeeds = 'moderate';
  bool _specialDiet = false;
  final _dietDescriptionController = TextEditingController();

  final List<String> _chronicConditions = [];
  final List<String> _medications = [];
  final List<String> _allergies = [];
  final _veterinaryNeedsController = TextEditingController();

  bool _destructiveBehavior = false;
  bool _separationAnxiety = false;
  bool _noiseSensitivity = false;
  bool _escapeTendency = false;

  String _idealHomeType = 'house_with_yard';
  String _spaceRequirements = 'moderate';
  final List<String> _climatePreferences = [];

  final _rescueStoryController = TextEditingController();
  final _previousHomeController = TextEditingController();
  final _behavioralNotesController = TextEditingController();

  bool _beginnerFriendly = true;
  bool _apartmentSuitable = true;
  bool _familyFriendly = true;

  // Options
  final List<Map<String, String>> _levelOptions = [
    {'value': 'low', 'label': 'Bajo'},
    {'value': 'moderate', 'label': 'Moderado'},
    {'value': 'high', 'label': 'Alto'},
  ];

  final List<Map<String, String>> _socialLevelOptions = [
    {'value': 'shy', 'label': 'Tímido'},
    {'value': 'friendly', 'label': 'Amigable'},
    {'value': 'outgoing', 'label': 'Extrovertido'},
    {'value': 'selective', 'label': 'Selectivo'},
  ];

  final List<Map<String, String>> _trainingLevelOptions = [
    {'value': 'untrained', 'label': 'Sin entrenar'},
    {'value': 'basic', 'label': 'Entrenamiento básico'},
    {'value': 'intermediate', 'label': 'Entrenamiento intermedio'},
    {'value': 'advanced', 'label': 'Entrenamiento avanzado'},
  ];

  final List<Map<String, String>> _commandOptions = [
    {'value': 'sit', 'label': 'Sentado'},
    {'value': 'stay', 'label': 'Quieto'},
    {'value': 'come', 'label': 'Ven'},
    {'value': 'down', 'label': 'Echado'},
    {'value': 'heel', 'label': 'Junto'},
    {'value': 'shake', 'label': 'Dar la pata'},
    {'value': 'roll_over', 'label': 'Rodar'},
    {'value': 'play_dead', 'label': 'Hacerse el muerto'},
  ];

  final List<Map<String, String>> _homeTypeOptions = [
    {'value': 'apartment', 'label': 'Apartamento'},
    {'value': 'house_no_yard', 'label': 'Casa sin patio'},
    {'value': 'house_small_yard', 'label': 'Casa con patio pequeño'},
    {'value': 'house_with_yard', 'label': 'Casa con patio grande'},
    {'value': 'farm', 'label': 'Granja/Campo'},
  ];

  final List<Map<String, String>> _climateOptions = [
    {'value': 'cold', 'label': 'Frío'},
    {'value': 'temperate', 'label': 'Templado'},
    {'value': 'warm', 'label': 'Cálido'},
    {'value': 'humid', 'label': 'Húmedo'},
    {'value': 'dry', 'label': 'Seco'},
  ];

  final List<String> _commonConditions = [
    'Artritis',
    'Diabetes',
    'Epilepsia',
    'Problemas cardíacos',
    'Problemas renales',
    'Alergias cutáneas',
    'Problemas dentales',
    'Cataratas',
    'Displasia de cadera',
  ];

  final List<String> _commonMedications = [
    'Insulina',
    'Antiinflamatorios',
    'Antibióticos',
    'Vitaminas',
    'Suplementos articulares',
    'Medicamentos para el corazón',
    'Antihistamínicos',
  ];

  final List<String> _commonAllergies = [
    'Pollo',
    'Res',
    'Granos',
    'Lácteos',
    'Huevos',
    'Soja',
    'Polen',
    'Ácaros',
    'Productos químicos',
  ];

  @override
  void initState() {
    super.initState();
    // Load existing profile if available
    context.read<MatchingBloc>().add(GetAnimalProfileEvent(animalId: widget.animalId));
  }

  @override
  void dispose() {
    _dietDescriptionController.dispose();
    _veterinaryNeedsController.dispose();
    _rescueStoryController.dispose();
    _previousHomeController.dispose();
    _behavioralNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil Detallado'),
        elevation: 0,
      ),
      body: BlocConsumer<MatchingBloc, MatchingState>(
        listener: (context, state) {
          if (state is AnimalProfileCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil creado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is MatchingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AnimalProfileLoaded && state.profile != null) {
            _loadExistingProfile(state.profile!);
          }
        },
        builder: (context, state) {
          if (state is MatchingLoading) {
            return const LoadingIndicator(message: 'Cargando perfil...');
          }

          return Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 5,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),

              Expanded(
                child: Form(
                  key: _formKey,
                  child: Stepper(
                    currentStep: _currentStep,
                    onStepTapped: (step) {
                      setState(() {
                        _currentStep = step;
                      });
                    },
                    controlsBuilder: (context, details) {
                      return Row(
                        children: [
                          if (details.stepIndex > 0)
                            TextButton(
                              onPressed: details.onStepCancel,
                              child: const Text('Anterior'),
                            ),
                          const SizedBox(width: 8),
                          CustomButton(
                            text: details.stepIndex == 4 ? 'Guardar' : 'Siguiente',
                            onPressed: details.stepIndex == 4
                                ? _submitForm
                                : () {
                              if (details.onStepContinue != null) {
                                details.onStepContinue!();
                              }
                            },
                            isLoading: state is MatchingLoading,
                          ),
                        ],
                      );
                    },
                    steps: [
                      _buildStep1(), // Personalidad y comportamiento
                      _buildStep2(), // Entrenamiento
                      _buildStep3(), // Cuidados y salud
                      _buildStep4(), // Hogar ideal
                      _buildStep5(), // Historia y notas
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: const Text('Personalidad'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _energyLevel,
            decoration: const InputDecoration(
              labelText: 'Nivel de Energía',
            ),
            items: _levelOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _energyLevel = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _socialLevel,
            decoration: const InputDecoration(
              labelText: 'Nivel Social',
            ),
            items: _socialLevelOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _socialLevel = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          const Text(
            'Compatibilidad',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Bueno con niños'),
            value: _goodWithKids,
            onChanged: (value) {
              setState(() {
                _goodWithKids = value;
              });
            },
            secondary: Icon(
              Icons.child_care,
              color: _goodWithKids ? Colors.green : Colors.grey,
            ),
          ),

          SwitchListTile(
            title: const Text('Bueno con otras mascotas'),
            value: _goodWithOtherPets,
            onChanged: (value) {
              setState(() {
                _goodWithOtherPets = value;
              });
            },
            secondary: Icon(
              Icons.pets,
              color: _goodWithOtherPets ? Colors.green : Colors.grey,
            ),
          ),

          SwitchListTile(
            title: const Text('Bueno con extraños'),
            value: _goodWithStrangers,
            onChanged: (value) {
              setState(() {
                _goodWithStrangers = value;
              });
            },
            secondary: Icon(
              Icons.people,
              color: _goodWithStrangers ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Comportamientos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Comportamiento destructivo'),
            value: _destructiveBehavior,
            onChanged: (value) {
              setState(() {
                _destructiveBehavior = value;
              });
            },
            secondary: Icon(
              Icons.warning,
              color: _destructiveBehavior ? Colors.red : Colors.grey,
            ),
          ),

          SwitchListTile(
            title: const Text('Ansiedad por separación'),
            value: _separationAnxiety,
            onChanged: (value) {
              setState(() {
                _separationAnxiety = value;
              });
            },
            secondary: Icon(
              Icons.sentiment_very_dissatisfied,
              color: _separationAnxiety ? Colors.orange : Colors.grey,
            ),
          ),

          SwitchListTile(
            title: const Text('Sensible al ruido'),
            value: _noiseSensitivity,
            onChanged: (value) {
              setState(() {
                _noiseSensitivity = value;
              });
            },
            secondary: Icon(
              Icons.volume_up,
              color: _noiseSensitivity ? Colors.orange : Colors.grey,
            ),
          ),

          SwitchListTile(
            title: const Text('Tendencia a escapar'),
            value: _escapeTendency,
            onChanged: (value) {
              setState(() {
                _escapeTendency = value;
              });
            },
            secondary: Icon(
              Icons.directions_run,
              color: _escapeTendency ? Colors.red : Colors.grey,
            ),
          ),
        ],
      ),
      isActive: _currentStep == 0,
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text('Entrenamiento'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _trainingLevel,
            decoration: const InputDecoration(
              labelText: 'Nivel de Entrenamiento',
            ),
            items: _trainingLevelOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _trainingLevel = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Entrenado para ir al baño'),
            value: _houseTrained,
            onChanged: (value) {
              setState(() {
                _houseTrained = value;
              });
            },
            secondary: Icon(
              Icons.home,
              color: _houseTrained ? Colors.green : Colors.grey,
            ),
          ),

          SwitchListTile(
            title: const Text('Entrenado con correa'),
            value: _leashTrained,
            onChanged: (value) {
              setState(() {
                _leashTrained = value;
              });
            },
            secondary: Icon(
              Icons.pets,
              color: _leashTrained ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Comandos Conocidos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _commandOptions.map((command) {
              final isSelected = _knownCommands.contains(command['value']);
              return FilterChip(
                label: Text(command['label']!),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _knownCommands.add(command['value']!);
                    } else {
                      _knownCommands.remove(command['value']!);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
      isActive: _currentStep == 1,
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text('Cuidados y Salud'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _careLevel,
            decoration: const InputDecoration(
              labelText: 'Nivel de Cuidado Requerido',
            ),
            items: _levelOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _careLevel = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _exerciseNeeds,
            decoration: const InputDecoration(
              labelText: 'Necesidades de Ejercicio',
            ),
            items: _levelOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _exerciseNeeds = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _groomingNeeds,
            decoration: const InputDecoration(
              labelText: 'Necesidades de Aseo',
            ),
            items: _levelOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _groomingNeeds = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          SwitchListTile(
            title: const Text('Dieta especial requerida'),
            value: _specialDiet,
            onChanged: (value) {
              setState(() {
                _specialDiet = value;
              });
            },
            secondary: Icon(
              Icons.restaurant,
              color: _specialDiet ? Colors.orange : Colors.grey,
            ),
          ),

          if (_specialDiet) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _dietDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción de la dieta',
                hintText: 'Ej: Dieta hipoalergénica, sin granos',
              ),
              maxLines: 2,
            ),
          ],
          const SizedBox(height: 24),

          const Text(
            'Condiciones Crónicas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _commonConditions.map((condition) {
              final isSelected = _chronicConditions.contains(condition);
              return FilterChip(
                label: Text(condition),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _chronicConditions.add(condition);
                    } else {
                      _chronicConditions.remove(condition);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          const Text(
            'Medicamentos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _commonMedications.map((medication) {
              final isSelected = _medications.contains(medication);
              return FilterChip(
                label: Text(medication),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _medications.add(medication);
                    } else {
                      _medications.remove(medication);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          const Text(
            'Alergias',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _commonAllergies.map((allergy) {
              final isSelected = _allergies.contains(allergy);
              return FilterChip(
                label: Text(allergy),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _allergies.add(allergy);
                    } else {
                      _allergies.remove(allergy);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _veterinaryNeedsController,
            decoration: const InputDecoration(
              labelText: 'Necesidades Veterinarias',
              hintText: 'Ej: Revisiones mensuales por diabetes',
            ),
            maxLines: 2,
          ),
        ],
      ),
      isActive: _currentStep == 2,
    );
  }

  Step _buildStep4() {
    return Step(
      title: const Text('Hogar Ideal'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _idealHomeType,
            decoration: const InputDecoration(
              labelText: 'Tipo de Hogar Ideal',
            ),
            items: _homeTypeOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _idealHomeType = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _spaceRequirements,
            decoration: const InputDecoration(
              labelText: 'Requerimientos de Espacio',
            ),
            items: _levelOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _spaceRequirements = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          const Text(
            'Preferencias de Clima',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _climateOptions.map((climate) {
              final isSelected = _climatePreferences.contains(climate['value']);
              return FilterChip(
                label: Text(climate['label']!),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _climatePreferences.add(climate['value']!);
                    } else {
                      _climatePreferences.remove(climate['value']!);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          const Text(
            'Adecuado para',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Principiantes'),
            value: _beginnerFriendly,
            onChanged: (value) {
              setState(() {
                _beginnerFriendly = value;
              });
            },
            secondary: Icon(
              Icons.school,
              color: _beginnerFriendly ? Colors.green : Colors.grey,
            ),
          ),

          SwitchListTile(
            title: const Text('Apartamentos'),
            value: _apartmentSuitable,
            onChanged: (value) {
              setState(() {
                _apartmentSuitable = value;
              });
            },
            secondary: Icon(
              Icons.apartment,
              color: _apartmentSuitable ? Colors.green : Colors.grey,
            ),
          ),

          SwitchListTile(
            title: const Text('Familias'),
            value: _familyFriendly,
            onChanged: (value) {
              setState(() {
                _familyFriendly = value;
              });
            },
            secondary: Icon(
              Icons.family_restroom,
              color: _familyFriendly ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      isActive: _currentStep == 3,
    );
  }

  Step _buildStep5() {
    return Step(
      title: const Text('Historia'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _rescueStoryController,
            decoration: const InputDecoration(
              labelText: 'Historia de Rescate',
              hintText: 'Ej: Encontrado en la calle con desnutrición, ahora completamente recuperado',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa la historia de rescate';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _previousHomeController,
            decoration: const InputDecoration(
              labelText: 'Experiencia en Hogar Anterior',
              hintText: 'Ej: Vivió 2 años en una familia con niños, muy adaptado a la vida doméstica',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _behavioralNotesController,
            decoration: const InputDecoration(
              labelText: 'Notas de Comportamiento',
              hintText: 'Ej: Le encanta jugar con pelotas, muy protector con la familia',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa notas de comportamiento';
              }
              return null;
            },
          ),
        ],
      ),
      isActive: _currentStep == 4,
    );
  }

  void _loadExistingProfile(dynamic profile) {
    // This would load existing profile into the form
    // Implementation depends on your AnimalProfile model structure
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final profileData = {
        'energyLevel': _energyLevel,
        'socialLevel': _socialLevel,
        'goodWithKids': _goodWithKids,
        'goodWithOtherPets': _goodWithOtherPets,
        'goodWithStrangers': _goodWithStrangers,
        'trainingLevel': _trainingLevel,
        'houseTrained': _houseTrained,
        'leashTrained': _leashTrained,
        'knownCommands': _knownCommands,
        'careLevel': _careLevel,
        'exerciseNeeds': _exerciseNeeds,
        'groomingNeeds': _groomingNeeds,
        'specialDiet': _specialDiet,
        'dietDescription': _dietDescriptionController.text,
        'chronicConditions': _chronicConditions,
        'medications': _medications,
        'allergies': _allergies,
        'veterinaryNeeds': _veterinaryNeedsController.text,
        'destructiveBehavior': _destructiveBehavior,
        'separationAnxiety': _separationAnxiety,
        'noiseSensitivity': _noiseSensitivity,
        'escapeTendency': _escapeTendency,
        'idealHomeType': _idealHomeType,
        'spaceRequirements': _spaceRequirements,
        'climatePreferences': _climatePreferences,
        'rescueStory': _rescueStoryController.text,
        'previousHomeExperience': _previousHomeController.text,
        'behavioralNotes': _behavioralNotesController.text,
        'beginnerFriendly': _beginnerFriendly,
        'apartmentSuitable': _apartmentSuitable,
        'familyFriendly': _familyFriendly,
      };

      context.read<MatchingBloc>().add(
        CreateAnimalProfileEvent(
          animalId: widget.animalId,
          profileData: profileData,
        ),
      );
    }
  }
}