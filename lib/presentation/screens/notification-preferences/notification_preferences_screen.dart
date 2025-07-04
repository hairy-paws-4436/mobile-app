import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/notification_templates.dart';
import '../../bloc/notification-preferences/notification_preferences_bloc.dart';
import '../../bloc/notification-preferences/notification_preferences_event.dart';
import '../../bloc/notification-preferences/notification_preferences_state.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Load preferences and templates
    context.read<NotificationPreferencesBloc>().add(LoadNotificationPreferencesEvent());
    context.read<NotificationPreferencesBloc>().add(LoadNotificationTemplatesEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Notificaciones'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'Adopciones'),
            Tab(text: 'Eventos'),
            Tab(text: 'Filtros'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: () => _showResetDialog(),
            tooltip: 'Restablecer',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'templates') {
                _showTemplatesDialog();
              } else if (value == 'test') {
                _showTestNotificationDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'templates',
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text('Plantillas'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'test',
                child: Row(
                  children: [
                    Icon(Icons.notification_add, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text('Enviar notificación de prueba'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<NotificationPreferencesBloc, NotificationPreferencesState>(
        listener: (context, state) {
          if (state is NotificationPreferencesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is NotificationPreferencesUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Preferencias actualizadas'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationPreferencesLoading) {
            return const LoadingIndicator(message: 'Cargando preferencias...');
          } else if (state is NotificationPreferencesError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                context.read<NotificationPreferencesBloc>().add(LoadNotificationPreferencesEvent());
              },
            );
          } else if (state is NotificationPreferencesLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildGeneralTab(state),
                _buildAdoptionTab(state),
                _buildEventsTab(state),
                _buildFiltersTab(state),
              ],
            );
          }

          return const LoadingIndicator(message: 'Inicializando...');
        },
      ),
    );
  }



  Widget _buildAdoptionTab(NotificationPreferencesLoaded state) {
    final preferences = state.preferences;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Adoption Requests
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pets, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Solicitudes de Adopción',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: preferences.adoptionRequestsEnabled,
                        onChanged: (value) {
                          context.read<NotificationPreferencesBloc>().add(
                            UpdateAdoptionNotificationsEvent(
                              requestsEnabled: value,
                              requestsFrequency: preferences.adoptionRequestsFrequency,
                              statusEnabled: preferences.adoptionStatusEnabled,
                              statusFrequency: preferences.adoptionStatusFrequency,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (preferences.adoptionRequestsEnabled) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Frecuencia',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFrequencySelector(
                      preferences.adoptionRequestsFrequency,
                          (frequency) {
                        context.read<NotificationPreferencesBloc>().add(
                          UpdateAdoptionNotificationsEvent(
                            requestsEnabled: preferences.adoptionRequestsEnabled,
                            requestsFrequency: frequency,
                            statusEnabled: preferences.adoptionStatusEnabled,
                            statusFrequency: preferences.adoptionStatusFrequency,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Adoption Status Updates
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.update, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Actualizaciones de Estado',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: preferences.adoptionStatusEnabled,
                        onChanged: (value) {
                          context.read<NotificationPreferencesBloc>().add(
                            UpdateAdoptionNotificationsEvent(
                              requestsEnabled: preferences.adoptionRequestsEnabled,
                              requestsFrequency: preferences.adoptionRequestsFrequency,
                              statusEnabled: value,
                              statusFrequency: preferences.adoptionStatusFrequency,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (preferences.adoptionStatusEnabled) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Frecuencia',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFrequencySelector(
                      preferences.adoptionStatusFrequency,
                          (frequency) {
                        context.read<NotificationPreferencesBloc>().add(
                          UpdateAdoptionNotificationsEvent(
                            requestsEnabled: preferences.adoptionRequestsEnabled,
                            requestsFrequency: preferences.adoptionRequestsFrequency,
                            statusEnabled: preferences.adoptionStatusEnabled,
                            statusFrequency: frequency,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // New Matches
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Nuevas Coincidencias',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: preferences.newMatchesEnabled,
                        onChanged: (value) {
                          context.read<NotificationPreferencesBloc>().add(
                            UpdateMatchingNotificationsEvent(
                              newMatchesEnabled: value,
                              newMatchesFrequency: preferences.newMatchesFrequency,
                              newAnimalsEnabled: preferences.newAnimalsEnabled,
                              newAnimalsFrequency: preferences.newAnimalsFrequency,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (preferences.newMatchesEnabled) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Frecuencia',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFrequencySelector(
                      preferences.newMatchesFrequency,
                          (frequency) {
                        context.read<NotificationPreferencesBloc>().add(
                          UpdateMatchingNotificationsEvent(
                            newMatchesEnabled: preferences.newMatchesEnabled,
                            newMatchesFrequency: frequency,
                            newAnimalsEnabled: preferences.newAnimalsEnabled,
                            newAnimalsFrequency: preferences.newAnimalsFrequency,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // New Animals
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pets_outlined, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Nuevas Mascotas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: preferences.newAnimalsEnabled,
                        onChanged: (value) {
                          context.read<NotificationPreferencesBloc>().add(
                            UpdateMatchingNotificationsEvent(
                              newMatchesEnabled: preferences.newMatchesEnabled,
                              newMatchesFrequency: preferences.newMatchesFrequency,
                              newAnimalsEnabled: value,
                              newAnimalsFrequency: preferences.newAnimalsFrequency,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (preferences.newAnimalsEnabled) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Frecuencia',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFrequencySelector(
                      preferences.newAnimalsFrequency,
                          (frequency) {
                        context.read<NotificationPreferencesBloc>().add(
                          UpdateMatchingNotificationsEvent(
                            newMatchesEnabled: preferences.newMatchesEnabled,
                            newMatchesFrequency: preferences.newMatchesFrequency,
                            newAnimalsEnabled: preferences.newAnimalsEnabled,
                            newAnimalsFrequency: frequency,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab(NotificationPreferencesLoaded state) {
    final preferences = state.preferences;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Reminders
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Recordatorios de Eventos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: preferences.eventRemindersEnabled,
                        onChanged: (value) {
                          context.read<NotificationPreferencesBloc>().add(
                            UpdateEventNotificationsEvent(
                              eventRemindersEnabled: value,
                              eventRemindersFrequency: preferences.eventRemindersFrequency,
                              newEventsEnabled: preferences.newEventsEnabled,
                              newEventsFrequency: preferences.newEventsFrequency,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (preferences.eventRemindersEnabled) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Frecuencia',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFrequencySelector(
                      preferences.eventRemindersFrequency,
                          (frequency) {
                        context.read<NotificationPreferencesBloc>().add(
                          UpdateEventNotificationsEvent(
                            eventRemindersEnabled: preferences.eventRemindersEnabled,
                            eventRemindersFrequency: frequency,
                            newEventsEnabled: preferences.newEventsEnabled,
                            newEventsFrequency: preferences.newEventsFrequency,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // New Events
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.new_releases, color: AppTheme.primaryColor),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Nuevos Eventos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Switch(
                        value: preferences.newEventsEnabled,
                        onChanged: (value) {
                          context.read<NotificationPreferencesBloc>().add(
                            UpdateEventNotificationsEvent(
                              eventRemindersEnabled: preferences.eventRemindersEnabled,
                              eventRemindersFrequency: preferences.eventRemindersFrequency,
                              newEventsEnabled: value,
                              newEventsFrequency: preferences.newEventsFrequency,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  if (preferences.newEventsEnabled) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Frecuencia',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFrequencySelector(
                      preferences.newEventsFrequency,
                          (frequency) {
                        context.read<NotificationPreferencesBloc>().add(
                          UpdateEventNotificationsEvent(
                            eventRemindersEnabled: preferences.eventRemindersEnabled,
                            eventRemindersFrequency: preferences.eventRemindersFrequency,
                            newEventsEnabled: preferences.newEventsEnabled,
                            newEventsFrequency: frequency,
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Other notifications
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.more_horiz, color: AppTheme.primaryColor),
                      SizedBox(width: 12),
                      Text(
                        'Otras Notificaciones',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Confirmaciones de Donación'),
                    subtitle: const Text('Recibir confirmación cuando dones'),
                    value: preferences.donationConfirmationsEnabled,
                    onChanged: (value) {
                      // Update donation confirmations
                      final updatedPreferences = state.preferences.copyWith(
                        donationConfirmationsEnabled: value,
                      );
                      context.read<NotificationPreferencesBloc>().add(
                        UpdateNotificationPreferencesEvent(
                          preferences: updatedPreferences.toJson(),
                        ),
                      );
                    },
                    secondary: const Icon(Icons.volunteer_activism),
                  ),
                  SwitchListTile(
                    title: const Text('Recordatorios de Seguimiento'),
                    subtitle: const Text('Recordatorios sobre el cuidado post-adopción'),
                    value: preferences.followupRemindersEnabled,
                    onChanged: (value) {
                      final updatedPreferences = state.preferences.copyWith(
                        followupRemindersEnabled: value,
                      );
                      context.read<NotificationPreferencesBloc>().add(
                        UpdateNotificationPreferencesEvent(
                          preferences: updatedPreferences.toJson(),
                        ),
                      );
                    },
                    secondary: const Icon(Icons.schedule),
                  ),
                  SwitchListTile(
                    title: const Text('Actualizaciones de Cuenta'),
                    subtitle: const Text('Cambios importantes en tu cuenta'),
                    value: preferences.accountUpdatesEnabled,
                    onChanged: (value) {
                      final updatedPreferences = state.preferences.copyWith(
                        accountUpdatesEnabled: value,
                      );
                      context.read<NotificationPreferencesBloc>().add(
                        UpdateNotificationPreferencesEvent(
                          preferences: updatedPreferences.toJson(),
                        ),
                      );
                    },
                    secondary: const Icon(Icons.account_circle),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersTab(NotificationPreferencesLoaded state) {
    final preferences = state.preferences;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preferred Animal Types
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.filter_list, color: AppTheme.primaryColor),
                      SizedBox(width: 12),
                      Text(
                        'Tipos de Mascotas Preferidas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Recibir notificaciones solo para estos tipos de mascotas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: AnimalType.values.map((type) {
                      final isSelected = preferences.preferredAnimalTypesForNotifications
                          ?.contains(type.value) ??
                          false;
                      return FilterChip(
                        label: Text(type.label),
                        selected: isSelected,
                        onSelected: (selected) {
                          final currentTypes = List<String>.from(
                            preferences.preferredAnimalTypesForNotifications ?? [],
                          );
                          if (selected) {
                            currentTypes.add(type.value);
                          } else {
                            currentTypes.remove(type.value);
                          }
                          context.read<NotificationPreferencesBloc>().add(
                            UpdateFilteringPreferencesEvent(
                              preferredAnimalTypes: currentTypes.isEmpty ? null : currentTypes,
                              maxDistanceKm: preferences.maxDistanceNotificationsKm,
                              onlyHighCompatibility: preferences.onlyHighCompatibility,
                            ),
                          );
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  if (preferences.preferredAnimalTypesForNotifications?.isNotEmpty == true)
                    TextButton(
                      onPressed: () {
                        context.read<NotificationPreferencesBloc>().add(
                          UpdateFilteringPreferencesEvent(
                            preferredAnimalTypes: null,
                            maxDistanceKm: preferences.maxDistanceNotificationsKm,
                            onlyHighCompatibility: preferences.onlyHighCompatibility,
                          ),
                        );
                      },
                      child: const Text('Limpiar selección'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Max Distance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.primaryColor),
                      SizedBox(width: 12),
                      Text(
                        'Distancia Máxima',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Solo notificar sobre mascotas dentro de ${preferences.maxDistanceNotificationsKm} km',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: preferences.maxDistanceNotificationsKm.toDouble(),
                    min: 5,
                    max: 200,
                    divisions: 39,
                    label: '${preferences.maxDistanceNotificationsKm} km',
                    onChanged: (value) {
                      context.read<NotificationPreferencesBloc>().add(
                        UpdateFilteringPreferencesEvent(
                          preferredAnimalTypes: preferences.preferredAnimalTypesForNotifications,
                          maxDistanceKm: value.round(),
                          onlyHighCompatibility: preferences.onlyHighCompatibility,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // High Compatibility Only
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SwitchListTile(
                title: const Text('Solo Alta Compatibilidad'),
                subtitle: const Text('Recibir notificaciones solo de mascotas con alta compatibilidad (80%+)'),
                value: preferences.onlyHighCompatibility,
                onChanged: (value) {
                  context.read<NotificationPreferencesBloc>().add(
                    UpdateFilteringPreferencesEvent(
                      preferredAnimalTypes: preferences.preferredAnimalTypesForNotifications,
                      maxDistanceKm: preferences.maxDistanceNotificationsKm,
                      onlyHighCompatibility: value,
                    ),
                  );
                },
                secondary: const Icon(Icons.star, color: Colors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(NotificationPreferencesLoaded state) {
    final preferences = state.preferences;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Global Notifications Switch
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        preferences.globalNotificationsEnabled
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: preferences.globalNotificationsEnabled
                            ? AppTheme.primaryColor
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Notificaciones Globales',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              preferences.globalNotificationsEnabled
                                  ? 'Recibir todas las notificaciones'
                                  : 'Notificaciones desactivadas',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: preferences.globalNotificationsEnabled,
                        onChanged: (value) {
                          context.read<NotificationPreferencesBloc>().add(
                            UpdateGlobalNotificationsEvent(enabled: value),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quiet Hours
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bedtime,
                        color: preferences.quietHoursEnabled
                            ? AppTheme.primaryColor
                            : Colors.grey,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Horas de Silencio',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              preferences.quietHoursEnabled
                                  ? 'De ${preferences.quietHoursStart.substring(0, 5)} a ${preferences.quietHoursEnd.substring(0, 5)}'
                                  : 'Sin restricciones horarias',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: preferences.quietHoursEnabled,
                        onChanged: (value) {
                          context.read<NotificationPreferencesBloc>().add(
                            UpdateQuietHoursEvent(enabled: value),
                          );
                        },
                      ),
                    ],
                  ),
                  if (preferences.quietHoursEnabled) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeSelector(
                            'Inicio',
                            preferences.quietHoursStart,
                                (time) {
                              context.read<NotificationPreferencesBloc>().add(
                                UpdateQuietHoursEvent(
                                  enabled: true,
                                  startTime: time,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeSelector(
                            'Fin',
                            preferences.quietHoursEnd,
                                (time) {
                              context.read<NotificationPreferencesBloc>().add(
                                UpdateQuietHoursEvent(
                                  enabled: true,
                                  endTime: time,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Preferred Channels
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.send, color: AppTheme.primaryColor),
                      SizedBox(width: 12),
                      Text(
                        'Canales de Notificación',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Selecciona cómo quieres recibir las notificaciones',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: NotificationChannel.values.map((channel) {
                      final isSelected = preferences.preferredChannels.contains(channel.value);
                      return FilterChip(
                        label: Text(channel.label), // Cambiar de type.label a channel.label
                        selected: isSelected,
                        onSelected: (selected) {
                          final updatedChannels = List<String>.from(preferences.preferredChannels);
                          if (selected) {
                            updatedChannels.add(channel.value); // Cambiar de type.value a channel.value
                          } else {
                            updatedChannels.remove(channel.value); // Cambiar de type.value a channel.value
                          }
                          context.read<NotificationPreferencesBloc>().add(
                            UpdatePreferredChannelsEvent(channels: updatedChannels), // Cambiar el evento
                          );
                        },
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        checkmarkColor: AppTheme.primaryColor,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  if (preferences.preferredAnimalTypesForNotifications?.isNotEmpty == true)
                    TextButton(
                      onPressed: () {
                        context.read<NotificationPreferencesBloc>().add(
                          UpdateFilteringPreferencesEvent(
                            preferredAnimalTypes: null,
                            maxDistanceKm: preferences.maxDistanceNotificationsKm,
                            onlyHighCompatibility: preferences.onlyHighCompatibility,
                          ),
                        );
                      },
                      child: const Text('Limpiar selección'),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Max Distance
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on, color: AppTheme.primaryColor),
                      SizedBox(width: 12),
                      Text(
                        'Distancia Máxima',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Solo notificar sobre mascotas dentro de ${preferences.maxDistanceNotificationsKm} km',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: preferences.maxDistanceNotificationsKm.toDouble(),
                    min: 5,
                    max: 200,
                    divisions: 39,
                    label: '${preferences.maxDistanceNotificationsKm} km',
                    onChanged: (value) {
                      context.read<NotificationPreferencesBloc>().add(
                        UpdateFilteringPreferencesEvent(
                          preferredAnimalTypes: preferences.preferredAnimalTypesForNotifications,
                          maxDistanceKm: value.round(),
                          onlyHighCompatibility: preferences.onlyHighCompatibility,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // High Compatibility Only
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SwitchListTile(
                title: const Text('Solo Alta Compatibilidad'),
                subtitle: const Text('Recibir notificaciones solo de mascotas con alta compatibilidad (80%+)'),
                value: preferences.onlyHighCompatibility,
                onChanged: (value) {
                  context.read<NotificationPreferencesBloc>().add(
                    UpdateFilteringPreferencesEvent(
                      preferredAnimalTypes: preferences.preferredAnimalTypesForNotifications,
                      maxDistanceKm: preferences.maxDistanceNotificationsKm,
                      onlyHighCompatibility: value,
                    ),
                  );
                },
                secondary: const Icon(Icons.star, color: Colors.amber),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(String label, String currentTime, Function(String) onTimeChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                hour: int.parse(currentTime.split(':')[0]),
                minute: int.parse(currentTime.split(':')[1]),
              ),
            );
            if (time != null) {
              final timeString = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
              onTimeChanged(timeString);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 20),
                const SizedBox(width: 8),
                Text(currentTime.substring(0, 5)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencySelector(String currentFrequency, Function(String) onFrequencyChanged) {
    return Wrap(
      spacing: 8,
      children: NotificationFrequency.values.map((frequency) {
        final isSelected = currentFrequency == frequency.value;
        return ChoiceChip(
          label: Text(frequency.label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onFrequencyChanged(frequency.value);
            }
          },
          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
          labelStyle: TextStyle(
            color: isSelected ? AppTheme.primaryColor : null,
          ),
        );
      }).toList(),
    );
  }

  void _showTemplatesDialog() {
    final state = context.read<NotificationPreferencesBloc>().state;
    if (state is NotificationPreferencesLoaded && state.templates != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Plantillas Predefinidas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: state.templates!.allTemplates.map((template) {
              return Card(
                child: ListTile(
                  title: Text(template.name),
                  subtitle: Text(template.description),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.pop(context);
                    _applyTemplate(template.name.toLowerCase());
                  },
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      );
    }
  }

  void _applyTemplate(String templateKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aplicar Plantilla'),
        content: const Text(
          '¿Estás seguro de que quieres aplicar esta plantilla? Se sobrescribirán todas tus configuraciones actuales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationPreferencesBloc>().add(
                ApplyNotificationTemplateEvent(templateName: templateKey),
              );
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer Configuración'),
        content: const Text(
          '¿Estás seguro de que quieres restablecer todas las configuraciones de notificación a los valores por defecto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NotificationPreferencesBloc>().add(
                ResetNotificationPreferencesEvent(),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
  }

  void _showTestNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificación de Prueba'),
        content: const Text(
          'Se enviará una notificación de prueba usando tus configuraciones actuales.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificación de prueba enviada'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}