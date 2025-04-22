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
                    user.email!,
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

          // Account Section
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildMenuOption(
            context,
            icon: Icons.person,
            title: 'Edit Profile',
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),

          if (user.role == 'owner')
            _buildMenuOption(
              context,
              icon: Icons.pets,
              title: 'My Pets',
              onTap: () {
                Navigator.pushNamed(context, '/owner-animals');
              },
            ),

          _buildMenuOption(
            context,
            icon: Icons.history,
            title: 'Adoption Requests',
            onTap: () {
              Navigator.pushNamed(context, '/adoption-requests');
            },
          ),

          _buildMenuOption(
            context,
            icon: Icons.lock,
            title: 'Change Password',
            onTap: () {
              Navigator.pushNamed(context, '/change-password');
            },
          ),

          _buildMenuOption(
            context,
            icon: Icons.security,
            title: 'Two-Factor Authentication',
            subtitle: user.is2faEnabled ? 'Enabled' : 'Disabled',
            trailing: Switch(
              value: user.is2faEnabled,
              onChanged: (value) {
                if (!user.is2faEnabled) {
                  context.read<AuthBloc>().add(Enable2FAEvent());
                }
              },
            ),
          ),

          // NGO Registration (for adopters and owners)
          if (user.role != 'ngo')
            _buildMenuOption(
              context,
              icon: Icons.business,
              title: 'Register as NGO',
              onTap: () {
                Navigator.pushNamed(context, '/ngo-form');
              },
            ),

          // NGO Details (for NGO role)
          if (user.role == 'ngo')
            _buildMenuOption(
              context,
              icon: Icons.business,
              title: 'My NGO',
              onTap: () {
                Navigator.pushNamed(context, '/ngo-details', arguments: {'isUserNGO': true});
              },
            ),

          const SizedBox(height: 24),

          // Danger Zone
          const Text(
            'Danger Zone',
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
            title: 'Deactivate Account',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () {
              _showDeactivateDialog(context);
            },
          ),

          const SizedBox(height: 40),

          // Logout Button
          CustomButton(
            text: 'Log Out',
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
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
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
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Account'),
        content: const Text(
          'Are you sure you want to deactivate your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
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
            child: const Text('Deactivate'),
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
      case 'ngo':
        return Colors.purple;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _getRoleText(String role) {
    switch (role.toLowerCase()) {
      case 'adopter':
        return 'Pet Adopter';
      case 'owner':
        return 'Pet Owner';
      case 'ngo':
        return 'NGO Admin';
      default:
        return role;
    }
  }
}
