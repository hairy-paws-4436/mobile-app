import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/notification_templates.dart';
import '../../bloc/notification-preferences/notification_preferences_bloc.dart';
import '../../bloc/notification-preferences/notification_preferences_event.dart';
import '../../bloc/notification-preferences/notification_preferences_state.dart';
import '../../common/custom_button.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationPreferencesBloc>().add(LoadNotificationPreferencesEvent());
    context.read<NotificationPreferencesBloc>().add(LoadNotificationTemplatesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () {
              Navigator.pushNamed(context, '/notification-preferences');
            },
            tooltip: 'Configuración avanzada',
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
                content: Text('Configuración actualizada'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationPreferencesLoading) {
            return const LoadingIndicator(message: 'Cargando configuración...');
          } else if (state is NotificationPreferencesError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                context.read<NotificationPreferencesBloc>().add(LoadNotificationPreferencesEvent());
              },
            );
          } else if (state is NotificationPreferencesLoaded) {
            return _buildContent(state);
          }

          return const LoadingIndicator(message: 'Inicializando...');
        },
      ),
    );
  }

  Widget _buildContent(NotificationPreferencesLoaded state) {
    final preferences = state.preferences;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Card
          Card(
            color: preferences.globalNotificationsEnabled
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    preferences.globalNotificationsEnabled
                        ? Icons.notifications_active
                        : Icons.notifications_off,
                    color: preferences.globalNotificationsEnabled
                        ? Colors.green
                        : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preferences.globalNotificationsEnabled
                              ? 'Notificaciones Activas'
                              : 'Notificaciones Desactivadas',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          preferences.globalNotificationsEnabled
                              ? 'Recibes notificaciones según tus preferencias'
                              : 'No recibirás ninguna notificación',
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
            ),
          ),
          const SizedBox(height: 24),

          // Quick Templates
          if (state.templates != null) ...[
            const Text(
              'Configuraciones Rápidas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...state.templates!.allTemplates.map((template) {
              return Card(
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getTemplateIcon(template.name.toLowerCase()),
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  title: Text(
                    template.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(template.description),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _applyTemplate(template.name.toLowerCase()),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Current Settings Summary
          const Text(
            'Resumen de Configuración',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Summary Cards
          _buildSummaryCard(
            'Adopciones',
            Icons.pets,
            _getAdoptionSummary(preferences),
                () => Navigator.pushNamed(context, '/notification-preferences'),
          ),

          _buildSummaryCard(
            'Eventos',
            Icons.event,
            _getEventsSummary(preferences),
                () => Navigator.pushNamed(context, '/notification-preferences'),
          ),

          _buildSummaryCard(
            'Canales',
            Icons.send,
            _getChannelsSummary(preferences),
                () => Navigator.pushNamed(context, '/notification-preferences'),
          ),

          if (preferences.quietHoursEnabled)
            _buildSummaryCard(
              'Horas de Silencio',
              Icons.bedtime,
              'De ${preferences.quietHoursStart.substring(0, 5)} a ${preferences.quietHoursEnd.substring(0, 5)}',
                  () => Navigator.pushNamed(context, '/notification-preferences'),
            ),

          const SizedBox(height: 24),

          // Action Buttons
          CustomButton(
            text: 'Configuración Avanzada',
            onPressed: () {
              Navigator.pushNamed(context, '/notification-preferences');
            },
            icon: Icons.tune,
            type: ButtonType.secondary,
          ),
          const SizedBox(height: 16),

          CustomButton(
            text: 'Enviar Notificación de Prueba',
            onPressed: _sendTestNotification,
            icon: Icons.notification_add,
            type: ButtonType.secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, IconData icon, String summary, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(summary),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  IconData _getTemplateIcon(String templateName) {
    switch (templateName) {
      case 'minimal':
      case 'mínimas':
        return Icons.notifications_none;
      case 'balanced':
      case 'equilibradas':
        return Icons.notifications;
      case 'everything':
      case 'todas':
        return Icons.notifications_active;
      default:
        return Icons.notifications;
    }
  }

  String _getAdoptionSummary(preferences) {
    final List<String> active = [];
    if (preferences.adoptionRequestsEnabled) active.add('Solicitudes');
    if (preferences.adoptionStatusEnabled) active.add('Estados');
    if (preferences.newMatchesEnabled) active.add('Coincidencias');
    if (preferences.newAnimalsEnabled) active.add('Nuevas mascotas');

    if (active.isEmpty) return 'Desactivadas';
    if (active.length >= 3) return 'Todas activas';
    return active.join(', ');
  }

  String _getEventsSummary(preferences) {
    final List<String> active = [];
    if (preferences.eventRemindersEnabled) active.add('Recordatorios');
    if (preferences.newEventsEnabled) active.add('Nuevos eventos');

    if (active.isEmpty) return 'Desactivadas';
    return active.join(', ');
  }

  String _getChannelsSummary(preferences) {
    final channels = preferences.preferredChannels.map((channel) {
      switch (channel) {
        case 'in_app': return 'App';
        case 'email': return 'Email';
        case 'push': return 'Push';
        case 'sms': return 'SMS';
        default: return channel;
      }
    }).toList();

    return channels.join(', ');
  }

  void _applyTemplate(String templateKey) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aplicar Configuración'),
        content: const Text(
          '¿Quieres aplicar esta configuración predefinida? Se cambiarán todas tus preferencias actuales.',
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

  void _sendTestNotification() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notificación de Prueba'),
        content: const Text(
          'Se enviará una notificación de prueba usando tu configuración actual.',
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
                  content: Text('📱 Notificación de prueba enviada'),
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