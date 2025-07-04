import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../bloc/matching/matching_bloc.dart';
import '../../bloc/matching/matching_event.dart';
import '../../bloc/matching/matching_state.dart';
import '../../common/custom_button.dart';
import '../../common/loading_indicator.dart';

class PreferencesFormScreen extends StatefulWidget {
  const PreferencesFormScreen({super.key});

  @override
  State<PreferencesFormScreen> createState() => _PreferencesFormScreenState();
}

class _PreferencesFormScreenState extends State<PreferencesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Form controllers and variables
  final List<String> _preferredAnimalTypes = [];
  final List<String> _preferredGenders = [];
  final _minAgeController = TextEditingController(text: '0');
  final _maxAgeController = TextEditingController(text: '15');
  final _minSizeController = TextEditingController(text: '0');
  final _maxSizeController = TextEditingController(text: '50');

  String _experienceLevel = 'beginner';
  final List<String> _previousPetTypes = [];
  String _housingType = 'apartment';
  String _familyComposition = 'single';
  bool _hasOtherPets = false;
  final _otherPetsController = TextEditingController();

  String _timeAvailability = 'limited';
  String _preferredActivityLevel = 'low';
  String _workSchedule = 'morning';
  bool _prefersTrained = true;
  bool _acceptsSpecialNeeds = false;
  bool _prefersVaccinated = true;
  bool _prefersSterilized = true;

  final _maxDistanceController = TextEditingController(text: '30');
  final _latitudeController = TextEditingController(text: '-12.0464');
  final _longitudeController = TextEditingController(text: '-77.0428');
  final _monthlyBudgetController = TextEditingController(text: '300');

  final _adoptionReasonController = TextEditingController();
  final _lifestyleController = TextEditingController();

  final List<String> _steps = [
    'Preferencias Básicas',
    'Experiencia y Hogar',
    'Estilo de Vida',
    'Ubicación y Presupuesto',
    'Información Adicional'
  ];

  // Options
  final List<Map<String, String>> _animalTypeOptions = [
    {'value': 'dog', 'label': 'Perro'},
    {'value': 'cat', 'label': 'Gato'},
    {'value': 'rabbit', 'label': 'Conejo'},
    {'value': 'bird', 'label': 'Ave'},
    {'value': 'other', 'label': 'Otro'},
  ];

  final List<Map<String, String>> _genderOptions = [
    {'value': 'male', 'label': 'Macho'},
    {'value': 'female', 'label': 'Hembra'},
  ];

  final List<Map<String, String>> _experienceLevelOptions = [
    {'value': 'beginner', 'label': 'Principiante'},
    {'value': 'some_experience', 'label': 'Algo de experiencia'},
    {'value': 'experienced', 'label': 'Experimentado'},
    {'value': 'expert', 'label': 'Experto'},
  ];

  final List<Map<String, String>> _housingTypeOptions = [
    {'value': 'apartment', 'label': 'Apartamento'},
    {'value': 'house_no_yard', 'label': 'Casa sin patio'},
    {'value': 'house_small_yard', 'label': 'Casa con patio pequeño'},
    {'value': 'house_large_yard', 'label': 'Casa con patio grande'},
    {'value': 'farm', 'label': 'Granja/Campo'},
  ];

  final List<Map<String, String>> _familyCompositionOptions = [
    {'value': 'single', 'label': 'Soltero/a'},
    {'value': 'couple', 'label': 'Pareja'},
    {'value': 'family_young_kids', 'label': 'Familia con niños pequeños'},
    {'value': 'family_older_kids', 'label': 'Familia con niños mayores'},
    {'value': 'elderly', 'label': 'Adulto mayor'},
    {'value': 'roommates', 'label': 'Compañeros de cuarto'},
  ];

  final List<Map<String, String>> _timeAvailabilityOptions = [
    {'value': 'limited', 'label': 'Limitado (menos de 2 horas/día)'},
    {'value': 'moderate', 'label': 'Moderado (2-4 horas/día)'},
    {'value': 'high', 'label': 'Alto (más de 4 horas/día)'},
  ];

  final List<Map<String, String>> _activityLevelOptions = [
    {'value': 'low', 'label': 'Bajo - Prefiero mascotas tranquilas'},
    {'value': 'moderate', 'label': 'Moderado - Balance entre actividad y calma'},
    {'value': 'high', 'label': 'Alto - Me gustan las mascotas activas'},
  ];

  final List<Map<String, String>> _workScheduleOptions = [
    {'value': 'morning', 'label': 'Horario matutino'},
    {'value': 'afternoon', 'label': 'Horario vespertino'},
    {'value': 'night', 'label': 'Horario nocturno'},
    {'value': 'flexible', 'label': 'Horario flexible'},
    {'value': 'work_from_home', 'label': 'Trabajo desde casa'},
  ];

  @override
  void initState() {
    super.initState();
    context.read<MatchingBloc>().add(GetUserPreferencesEvent());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    _minSizeController.dispose();
    _maxSizeController.dispose();
    _otherPetsController.dispose();
    _maxDistanceController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _monthlyBudgetController.dispose();
    _adoptionReasonController.dispose();
    _lifestyleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias de Adopción'),
        elevation: 0,
      ),
      body: BlocConsumer<MatchingBloc, MatchingState>(
        listener: (context, state) {
          if (state is PreferencesCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Preferencias guardadas correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            context.read<MatchingBloc>().add(GetRecommendationsEvent());
            Navigator.pop(context, true);
          } else if (state is MatchingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is PreferencesLoaded && state.preferences != null) {
            _loadExistingPreferences(state.preferences!);
          }
        },
        builder: (context, state) {
          if (state is MatchingLoading) {
            return const LoadingIndicator(message: 'Cargando preferencias...');
          }

          return Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 5,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),

              // Step indicator
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Paso ${_currentStep + 1} de 5: ${_steps[_currentStep]}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                      _buildStep4(),
                      _buildStep5(),
                    ],
                  ),
                ),
              ),

              // Navigation buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: CustomButton(
                          text: 'Anterior',
                          type: ButtonType.secondary,
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          },
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      flex: _currentStep > 0 ? 1 : 2,
                      child: CustomButton(
                        text: _currentStep == 4 ? 'Guardar' : 'Siguiente',
                        onPressed: _currentStep == 4 ? _submitForm : _nextStep,
                        isLoading: state is MatchingLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tipo de Mascota',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _animalTypeOptions.map((option) {
              final isSelected = _preferredAnimalTypes.contains(option['value']);
              return FilterChip(
                label: Text(option['label']!),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _preferredAnimalTypes.add(option['value']!);
                    } else {
                      _preferredAnimalTypes.remove(option['value']!);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          const Text(
            'Género Preferido',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _genderOptions.map((option) {
              final isSelected = _preferredGenders.contains(option['value']);
              return FilterChip(
                label: Text(option['label']!),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _preferredGenders.add(option['value']!);
                    } else {
                      _preferredGenders.remove(option['value']!);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minAgeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Edad mínima',
                    suffix: Text('años'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _maxAgeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Edad máxima',
                    suffix: Text('años'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Peso mínimo',
                    suffix: Text('kg'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _maxSizeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Peso máximo',
                    suffix: Text('kg'),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _experienceLevel,
            decoration: const InputDecoration(
              labelText: 'Nivel de Experiencia',
            ),
            items: _experienceLevelOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _experienceLevel = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          const Text(
            'Mascotas Anteriores',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _animalTypeOptions.map((option) {
              final isSelected = _previousPetTypes.contains(option['value']);
              return FilterChip(
                label: Text(option['label']!),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _previousPetTypes.add(option['value']!);
                    } else {
                      _previousPetTypes.remove(option['value']!);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _housingType,
            decoration: const InputDecoration(
              labelText: 'Tipo de Hogar',
            ),
            items: _housingTypeOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _housingType = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _familyComposition,
            decoration: const InputDecoration(
              labelText: 'Composición Familiar',
            ),
            items: _familyCompositionOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _familyComposition = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('¿Tienes otras mascotas?'),
            value: _hasOtherPets,
            onChanged: (value) {
              setState(() {
                _hasOtherPets = value;
              });
            },
          ),

          if (_hasOtherPets) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _otherPetsController,
              decoration: const InputDecoration(
                labelText: 'Describe tus otras mascotas',
                hintText: 'Ej: Un gato persa de 3 años, muy tranquilo',
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            value: _timeAvailability,
            decoration: const InputDecoration(
              labelText: 'Tiempo Disponible',
            ),
            items: _timeAvailabilityOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _timeAvailability = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _preferredActivityLevel,
            decoration: const InputDecoration(
              labelText: 'Nivel de Actividad Preferido',
            ),
            items: _activityLevelOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _preferredActivityLevel = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _workSchedule,
            decoration: const InputDecoration(
              labelText: 'Horario de Trabajo',
            ),
            items: _workScheduleOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _workSchedule = value!;
              });
            },
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Prefiero mascotas entrenadas'),
            value: _prefersTrained,
            onChanged: (value) {
              setState(() {
                _prefersTrained = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Acepto mascotas con necesidades especiales'),
            value: _acceptsSpecialNeeds,
            onChanged: (value) {
              setState(() {
                _acceptsSpecialNeeds = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Prefiero mascotas vacunadas'),
            value: _prefersVaccinated,
            onChanged: (value) {
              setState(() {
                _prefersVaccinated = value;
              });
            },
          ),

          SwitchListTile(
            title: const Text('Prefiero mascotas esterilizadas'),
            value: _prefersSterilized,
            onChanged: (value) {
              setState(() {
                _prefersSterilized = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _maxDistanceController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Distancia máxima',
              suffix: Text('km'),
              hintText: 'Radio de búsqueda desde tu ubicación',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa la distancia máxima';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _latitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Latitud',
                    hintText: '-12.0464',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _longitudeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Longitud',
                    hintText: '-77.0428',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Requerido';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tip: Puedes obtener tu ubicación actual usando el GPS',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _monthlyBudgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Presupuesto mensual',
              prefix: Text('S/ '),
              hintText: 'Presupuesto estimado para cuidados',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa tu presupuesto mensual';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _adoptionReasonController,
            decoration: const InputDecoration(
              labelText: 'Razón para adoptar',
              hintText: 'Ej: Busco compañía y quiero dar una segunda oportunidad',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor explica tu razón para adoptar';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _lifestyleController,
            decoration: const InputDecoration(
              labelText: 'Describe tu estilo de vida',
              hintText: 'Ej: Trabajo desde casa, salgo a correr en las mañanas',
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor describe tu estilo de vida';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  void _nextStep() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _loadExistingPreferences(dynamic preferences) {
    // Implementation for loading existing preferences
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_preferredAnimalTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona al menos un tipo de mascota'),
            backgroundColor: Colors.orange,
          ),
        );
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
        return;
      }

      if (_preferredGenders.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor selecciona al menos un género'),
            backgroundColor: Colors.orange,
          ),
        );
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
        return;
      }

      final preferencesData = {
        'preferredAnimalTypes': _preferredAnimalTypes,
        'preferredGenders': _preferredGenders,
        'minAge': int.parse(_minAgeController.text),
        'maxAge': int.parse(_maxAgeController.text),
        'minSize': double.parse(_minSizeController.text),
        'maxSize': double.parse(_maxSizeController.text),
        'experienceLevel': _experienceLevel,
        'previousPetTypes': _previousPetTypes,
        'housingType': _housingType,
        'familyComposition': _familyComposition,
        'hasOtherPets': _hasOtherPets,
        'otherPetsDescription': _otherPetsController.text,
        'timeAvailability': _timeAvailability,
        'preferredActivityLevel': _preferredActivityLevel,
        'workSchedule': _workSchedule,
        'prefersTrained': _prefersTrained,
        'acceptsSpecialNeeds': _acceptsSpecialNeeds,
        'prefersVaccinated': _prefersVaccinated,
        'prefersSterilized': _prefersSterilized,
        'maxDistanceKm': int.parse(_maxDistanceController.text),
        'latitude': double.parse(_latitudeController.text),
        'longitude': double.parse(_longitudeController.text),
        'monthlyBudget': double.parse(_monthlyBudgetController.text),
        'adoptionReason': _adoptionReasonController.text,
        'lifestyleDescription': _lifestyleController.text,
      };

      context.read<MatchingBloc>().add(
        CreateOrUpdatePreferencesEvent(preferencesData: preferencesData),
      );
    }
  }
}