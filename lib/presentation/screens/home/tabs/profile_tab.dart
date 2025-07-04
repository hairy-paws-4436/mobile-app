import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme.dart';
import '../../../../data/models/user.dart';
import '../../../bloc/auth/auth_bloc.dart';
import '../../../bloc/auth/auth_event.dart';
import '../../../common/custom_button.dart';

class ProfileTab extends StatelessWidget {
  final User user;

  const ProfileTab({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Profile Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // User Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${user.firstName[0]}${user.lastName[0]}',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Name
                  Text(
                    '${user.firstName} ${user.lastName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // User Email
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Role Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getRoleText(user.role),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getRoleColor(user.role),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Smart Matching Section (solo para adoptantes)
          if (user.role == 'adopter') ...[
            const Text(
              'Matching Inteligente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildMenuOption(
              context,
              icon: Icons.psychology,
              title: 'Mis Recomendaciones',
              subtitle: 'Mascotas perfectas para ti',
              onTap: () {
                Navigator.pushNamed(context, '/recommendations');
              },
            ),

            _buildMenuOption(
              context,
              icon: Icons.tune,
              title: 'Preferencias de Adopción',
              subtitle: 'Configura tus criterios de búsqueda',
              onTap: () {
                Navigator.pushNamed(context, '/preferences-form');
              },
            ),

            const SizedBox(height: 24),
          ],

          // Gamification Section (solo para ONGs)
          if (user.role == 'ong') ...[
            const Text(
              'Gamificación y Progreso',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildMenuOption(
              context,
              icon: Icons.dashboard,
              title: 'Mi Dashboard',
              subtitle: 'Progreso, puntos y estadísticas',
              onTap: () {
                Navigator.pushNamed(context, '/gamification-dashboard');
              },
            ),

            _buildMenuOption(
              context,
              icon: Icons.leaderboard,
              title: 'Ranking de ONGs',
              subtitle: 'Ve tu posición en el ranking',
              onTap: () {
                Navigator.pushNamed(context, '/gamification-leaderboard');
              },
            ),

            _buildMenuOption(
              context,
              icon: Icons.emoji_events,
              title: 'Mis Insignias',
              subtitle: 'Logros desbloqueados y por desbloquear',
              onTap: () {
                Navigator.pushNamed(context, '/gamification-badges');
              },
            ),

            const SizedBox(height: 24),
          ],

          // Post-Adoption Section (para adoptantes y ONGs)
          if (user.role == 'adopter' || user.role == 'ong') ...[
            const Text(
              'Seguimiento Post-Adopción',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (user.role == 'adopter') ...[
              _buildMenuOption(
                context,
                icon: Icons.assignment_turned_in,
                title: 'Mis Seguimientos',
                subtitle: 'Evaluaciones de adaptación pendientes',
                onTap: () {
                  Navigator.pushNamed(context, '/post-adoption');
                },
              ),
            ],

            if (user.role == 'ong') ...[
              _buildMenuOption(
                context,
                icon: Icons.analytics,
                title: 'Dashboard de Seguimientos',
                subtitle: 'Analíticas y adopciones en riesgo',
                onTap: () {
                  Navigator.pushNamed(context, '/ngo-dashboard');
                },
              ),
            ],

            const SizedBox(height: 24),
          ],

          // Account Section
          const Text(
            'Cuenta',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildMenuOption(
            context,
            icon: Icons.person,
            title: 'Editar Perfil',
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),

          if (user.role == 'owner')
            _buildMenuOption(
              context,
              icon: Icons.pets,
              title: 'Mis Mascotas',
              onTap: () {
                Navigator.pushNamed(context, '/owner-animals');
              },
            ),

          _buildMenuOption(
            context,
            icon: Icons.history,
            title: 'Solicitudes de Adopción',
            onTap: () {
              Navigator.pushNamed(context, '/adoption-requests');
            },
          ),

          _buildMenuOption(
            context,
            icon: Icons.lock,
            title: 'Cambiar Contraseña',
            onTap: () {
              Navigator.pushNamed(context, '/change-password');
            },
          ),

          _buildMenuOption(
            context,
            icon: Icons.notifications,
            title: 'Configurar Notificaciones',
            subtitle: 'Personaliza cómo recibes notificaciones',
            onTap: () {
              Navigator.pushNamed(context, '/notification-settings');
            },
          ),


          const SizedBox(height: 24),

          // Herramientas para Owners/NGOs
          if (user.role == 'owner' || user.role == 'ong') ...[
            const Text(
              'Herramientas de Gestión',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // NGO Registration (for adopters and owners)
          if (user.role != 'ong')
            _buildMenuOption(
              context,
              icon: Icons.business,
              title: 'Registrarse como NGO',
              onTap: () {
                Navigator.pushNamed(context, '/ngo-form');
              },
            ),

          // NGO Details (for NGO role)
          if (user.role == 'ong')
            _buildMenuOption(
              context,
              icon: Icons.business,
              title: 'Mi NGO',
              onTap: () {
                Navigator.pushNamed(context, '/ngo-details', arguments: {'isUserNGO': true});
              },
            ),

          const SizedBox(height: 24),

          // Danger Zone
          const Text(
            'Zona de Peligro',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),

          _buildMenuOption(
            context,
            icon: Icons.person_off,
            title: 'Desactivar Cuenta',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () {
              _showDeactivateDialog(context);
            },
          ),

          const SizedBox(height: 40),

          // Logout Button
          CustomButton(
            text: 'Cerrar Sesión',
            onPressed: () {
              _showLogoutDialog(context);
            },
            type: ButtonType.secondary,
            icon: Icons.logout,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOption(
      BuildContext context, {
        required IconData icon,
        required String title,
        String? subtitle,
        Color iconColor = AppTheme.primaryColor,
        Color textColor = Colors.black,
        Widget? trailing,
        VoidCallback? onTap,
      }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(LogoutEvent());
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desactivar Cuenta'),
        content: const Text(
          '¿Estás seguro que deseas desactivar tu cuenta? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AuthBloc>().add(DeactivateAccountEvent());
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Desactivar'),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'adopter':
        return Colors.blue;
      case 'owner':
        return Colors.green;
      case 'ong':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'adopter':
        return 'Adoptante';
      case 'owner':
        return 'Dueño de Mascota';
      case 'ong':
        return 'Administrador NGO';
      default:
        return role;
    }
  }
}