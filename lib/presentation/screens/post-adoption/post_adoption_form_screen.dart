import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/post_adoption_models.dart';

import '../../bloc/post-adoption/post_adoption_bloc.dart';
import '../../bloc/post-adoption/post_adoption_event.dart' show CompleteFollowUpEvent, GetFollowUpDetailsEvent;
import '../../bloc/post-adoption/post_adoption_state.dart';
import '../../common/custom_button.dart';
import '../../common/loading_indicator.dart';

class PostAdoptionFormScreen extends StatefulWidget {
  final String followupId;

  const PostAdoptionFormScreen({
    super.key,
    required this.followupId,
  });

  @override
  State<PostAdoptionFormScreen> createState() => _PostAdoptionFormScreenState();
}

class _PostAdoptionFormScreenState extends State<PostAdoptionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Form data
  String _adaptationLevel = 'good';
  bool _eatingWell = true;
  bool _sleepingWell = true;
  bool _usingBathroomProperly = true;
  bool _showingAffection = true;
  final List<String> _behavioralIssues = [];
  final List<String> _healthConcerns = [];
  bool _vetVisitScheduled = false;
  DateTime? _vetVisitDate;
  int _satisfactionScore = 8;
  bool _wouldRecommend = true;
  final _additionalCommentsController = TextEditingController();
  bool _needsSupport = false;
  final List<String> _supportType = [];

  PostAdoptionFollowUp? _followUp;

  // Options
  final List<Map<String, String>> _adaptationOptions = [
    {'value': 'excellent', 'label': 'Excelente'},
    {'value': 'good', 'label': 'Buena'},
    {'value': 'fair', 'label': 'Regular'},
    {'value': 'poor', 'label': 'Pobre'},
  ];

  final List<String> _behavioralIssueOptions = [
    'Ansiedad por separación',
    'Ladridos/maullidos excesivos',
    'Destructividad',
    'Agresividad',
    'Problemas de socialización',
    'Miedo a ruidos fuertes',
    'Marcaje de territorio',
    'Problemas de obediencia',
  ];

  final List<String> _healthConcernOptions = [
    'Problemas digestivos',
    'Problemas respiratorios',
    'Cojera o dificultad para caminar',
    'Pérdida de apetito',
    'Letargo o falta de energía',
    'Problemas de piel',
    'Vómitos frecuentes',
    'Diarrea',
    'Otros',
  ];

  final List<String> _supportTypeOptions = [
    'Entrenamiento de comportamiento',
    'Asesoría veterinaria',
    'Apoyo económico',
    'Consulta con especialista',
    'Material educativo',
    'Visita domiciliaria',
  ];

  @override
  void initState() {
    super.initState();
    _loadFollowUpDetails();
  }

  void _loadFollowUpDetails() {
    context.read<PostAdoptionBloc>().add(GetFollowUpDetailsEvent(followupId: widget.followupId));
  }

  @override
  void dispose() {
    _additionalCommentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluación de Seguimiento'),
        elevation: 0,
      ),
      body: BlocConsumer<PostAdoptionBloc, PostAdoptionState>(
        listener: (context, state) {
          if (state is FollowUpCompleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Seguimiento completado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is PostAdoptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is FollowUpDetailsLoaded) {
            setState(() {
              _followUp = state.followUp;
            });
          }
        },
        builder: (context, state) {
          if (state is PostAdoptionLoading && _followUp == null) {
            return const LoadingIndicator(message: 'Cargando detalles...');
          }

          return Column(
            children: [
              // Pet info header
              if (_followUp != null) _buildPetHeader(),

              // Progress indicator
              LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Stepper(
                      physics: const NeverScrollableScrollPhysics(),
                      currentStep: _currentStep,
                      onStepTapped: (step) {
                        setState(() {
                          _currentStep = step;
                        });
                      },
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            children: [
                              if (details.stepIndex > 0)
                                Expanded(
                                  flex: 1,
                                  child: TextButton(
                                    onPressed: () {
                                      if (details.onStepCancel != null) {
                                        details.onStepCancel!();
                                      }
                                    },
                                    child: const Text('Anterior'),
                                  ),
                                ),
                              if (details.stepIndex > 0) const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: CustomButton(
                                  text: details.stepIndex == 3 ? 'Enviar Evaluación' : 'Siguiente',
                                  onPressed: details.stepIndex == 3
                                      ? _submitForm
                                      : () {
                                    if (details.onStepContinue != null) {
                                      details.onStepContinue!();
                                    }
                                  },
                                  isLoading: state is PostAdoptionLoading,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      steps: [
                        _buildStep1(), // Adaptación general
                        _buildStep2(), // Problemas y salud
                        _buildStep3(), // Satisfacción
                        _buildStep4(), // Apoyo adicional
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPetHeader() {
    final animal = _followUp!.adoption?.animal;
    if (animal == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              child: animal.images.isNotEmpty
                  ? Image.network(
                animal.images.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.pets,
                      size: 30,
                      color: Colors.grey,
                    ),
                  );
                },
              )
                  : Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.pets,
                  size: 30,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                Text(
                  '${animal.breed} • ${animal.age} ${animal.age == 1 ? 'año' : 'años'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _getFollowUpTypeLabel(_followUp!.followUpType),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: const Text('Adaptación General'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Cómo está la adaptación general de la mascota?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _adaptationLevel,
            decoration: const InputDecoration(
              labelText: 'Nivel de Adaptación',
            ),
            items: _adaptationOptions.map((option) {
              return DropdownMenuItem(
                value: option['value'],
                child: Text(option['label']!),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _adaptationLevel = value!;
              });
            },
          ),
          const SizedBox(height: 24),

          const Text(
            'Comportamientos Básicos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('¿Está comiendo bien?'),
            value: _eatingWell,
            onChanged: (value) {
              setState(() {
                _eatingWell = value;
              });
            },
            secondary: Icon(
              Icons.restaurant,
              color: _eatingWell ? Colors.green : Colors.grey,
            ),
          ),

          SwitchListTile(
            title: const Text('¿Está durmiendo bien?'),
            value: _sleepingWell,
            onChanged: (value) {
              setState(() {
                _sleepingWell = value;
              });
            },
            secondary: Icon(
              Icons.bed,
              color: _sleepingWell ? Colors.green : Colors.grey,
            ),
          ),

          SwitchListTile(
            title: const Text('¿Usa el baño apropiadamente?'),
            value: _usingBathroomProperly,
            onChanged: (value) {
              setState(() {
                _usingBathroomProperly = value;
              });
            },
            secondary: Icon(
              Icons.home,
              color: _usingBathroomProperly ? Colors.green : Colors.grey,
            ),
          ),

          SwitchListTile(
            title: const Text('¿Muestra afecto?'),
            value: _showingAffection,
            onChanged: (value) {
              setState(() {
                _showingAffection = value;
              });
            },
            secondary: Icon(
              Icons.favorite,
              color: _showingAffection ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
      isActive: _currentStep == 0,
    );
  }

  Step _buildStep2() {
    return Step(
      title: const Text('Problemas y Salud'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Problemas de Comportamiento',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona cualquier problema que hayas observado:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            children: _behavioralIssueOptions.map((issue) {
              final isSelected = _behavioralIssues.contains(issue);
              return FilterChip(
                label: Text(issue),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _behavioralIssues.add(issue);
                    } else {
                      _behavioralIssues.remove(issue);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          const Text(
            'Preocupaciones de Salud',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Selecciona cualquier problema de salud que hayas notado:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            children: _healthConcernOptions.map((concern) {
              final isSelected = _healthConcerns.contains(concern);
              return FilterChip(
                label: Text(concern),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _healthConcerns.add(concern);
                    } else {
                      _healthConcerns.remove(concern);
                    }
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SwitchListTile(
            title: const Text('¿Has programado una visita veterinaria?'),
            value: _vetVisitScheduled,
            onChanged: (value) {
              setState(() {
                _vetVisitScheduled = value;
              });
            },
            secondary: Icon(
              Icons.local_hospital,
              color: _vetVisitScheduled ? Colors.green : Colors.grey,
            ),
          ),

          if (_vetVisitScheduled) ...[
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Fecha de la visita veterinaria',
                hintText: 'Selecciona una fecha',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _vetVisitDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _vetVisitDate = date;
                  });
                }
              },
              controller: TextEditingController(
                text: _vetVisitDate != null
                    ? '${_vetVisitDate!.day}/${_vetVisitDate!.month}/${_vetVisitDate!.year}'
                    : '',
              ),
            ),
          ],
        ],
      ),
      isActive: _currentStep == 1,
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text('Satisfacción'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Califica tu experiencia de adopción',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          const Text('Puntuación de satisfacción (1-10):'),
          const SizedBox(height: 8),
          Slider(
            value: _satisfactionScore.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            label: _satisfactionScore.toString(),
            onChanged: (value) {
              setState(() {
                _satisfactionScore = value.round();
              });
            },
          ),
          Text(
            'Puntuación: $_satisfactionScore/10',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),

          SwitchListTile(
            title: const Text('¿Recomendarías esta ONG a otros?'),
            value: _wouldRecommend,
            onChanged: (value) {
              setState(() {
                _wouldRecommend = value;
              });
            },
            secondary: Icon(
              Icons.thumb_up,
              color: _wouldRecommend ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _additionalCommentsController,
            decoration: const InputDecoration(
              labelText: 'Comentarios adicionales',
              hintText: 'Comparte tu experiencia y cualquier observación...',
              border: OutlineInputBorder(),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor comparte tu experiencia';
              }
              return null;
            },
          ),
        ],
      ),
      isActive: _currentStep == 2,
    );
  }

  Step _buildStep4() {
    return Step(
      title: const Text('Apoyo Adicional'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '¿Necesitas apoyo adicional?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Necesito apoyo o asesoría adicional'),
            value: _needsSupport,
            onChanged: (value) {
              setState(() {
                _needsSupport = value;
                if (!value) {
                  _supportType.clear();
                }
              });
            },
            secondary: Icon(
              Icons.help,
              color: _needsSupport ? Colors.orange : Colors.grey,
            ),
          ),

          if (_needsSupport) ...[
            const SizedBox(height: 16),
            const Text(
              'Tipo de apoyo que necesitas:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              children: _supportTypeOptions.map((support) {
                final isSelected = _supportType.contains(support);
                return FilterChip(
                  label: Text(support),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _supportType.add(support);
                      } else {
                        _supportType.remove(support);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Información importante',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Tu evaluación nos ayuda a mejorar nuestro proceso de adopción y proporcionar mejor apoyo a futuras familias adoptivas.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      isActive: _currentStep == 3,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final formData = FollowUpFormData(
        adaptationLevel: _adaptationLevel,
        eatingWell: _eatingWell,
        sleepingWell: _sleepingWell,
        usingBathroomProperly: _usingBathroomProperly,
        showingAffection: _showingAffection,
        behavioralIssues: _behavioralIssues,
        healthConcerns: _healthConcerns,
        vetVisitScheduled: _vetVisitScheduled,
        vetVisitDate: _vetVisitDate,
        satisfactionScore: _satisfactionScore,
        wouldRecommend: _wouldRecommend,
        additionalComments: _additionalCommentsController.text,
        needsSupport: _needsSupport,
        supportType: _supportType,
      );

      context.read<PostAdoptionBloc>().add(
        CompleteFollowUpEvent(
          followupId: widget.followupId,
          formData: formData,
        ),
      );
    }
  }

  String _getFollowUpTypeLabel(String type) {
    switch (type) {
      case 'initial_3_days':
        return 'Seguimiento inicial (3 días)';
      case 'week_1':
        return 'Seguimiento de 1 semana';
      case 'week_2':
        return 'Seguimiento de 2 semanas';
      case 'month_1':
        return 'Seguimiento de 1 mes';
      case 'month_3':
        return 'Seguimiento de 3 meses';
      case 'month_6':
        return 'Seguimiento de 6 meses';
      case 'year_1':
        return 'Seguimiento de 1 año';
      default:
        return type;
    }
  }
}