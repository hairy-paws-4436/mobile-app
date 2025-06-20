import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/user.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../common/custom_button.dart';
import '../../common/loading_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with user data
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final user = authState.user;
      _firstNameController = TextEditingController(text: user.firstName);
      _lastNameController = TextEditingController(text: user.lastName);
      _phoneController = TextEditingController(text: user.phoneNumber);
      _addressController = TextEditingController(text: user.address);
    } else {
      _firstNameController = TextEditingController();
      _lastNameController = TextEditingController();
      _phoneController = TextEditingController();
      _addressController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Profile updated successfully!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            // No hacer pop inmediatamente, esperar a que el usuario vea el mensaje
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) Navigator.pop(context);
            });
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingIndicator(message: 'Updating profile...');
          } else if (state is Authenticated) {
            final user = state.user;
            return _buildForm(context, user);
          }

          return const LoadingIndicator();
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture
            Center(
              child: Column(
                children: [
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
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.role).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
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
            const SizedBox(height: 32),

            // Form Fields
            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // First Name
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'First Name',
                hintText: 'Enter your first name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'First name is required';
                }
                if (value.trim().length < 2) {
                  return 'First name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Last Name
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last Name',
                hintText: 'Enter your last name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Last name is required';
                }
                if (value.trim().length < 2) {
                  return 'Last name must be at least 2 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Phone Number
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter 9 digits (e.g., 987654321)',
                prefixIcon: Icon(Icons.phone),
                helperText: 'Peruvian format: 9 digits only',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Phone number is required';
                }
                if (value.length != 9) {
                  return 'Must be exactly 9 digits';
                }
                if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                  return 'Only numbers allowed';
                }
                // Validar que empiece con 9 (números móviles peruanos)
                if (!value.startsWith('9')) {
                  return 'Mobile numbers must start with 9';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Enter your complete address',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Address is required';
                }
                if (value.trim().length < 10) {
                  return 'Please enter a complete address';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Update Button
            CustomButton(
              text: 'Update Profile',
              onPressed: () {
                // Quitar el foco de los campos de texto
                FocusScope.of(context).unfocus();

                if (_formKey.currentState!.validate()) {
                  // Debug logs
                  print('📝 Form validation passed');
                  print('📝 Data to send:');
                  print('   - firstName: "${_firstNameController.text.trim()}"');
                  print('   - lastName: "${_lastNameController.text.trim()}"');
                  print('   - phoneNumber: "${_phoneController.text.trim()}"');
                  print('   - address: "${_addressController.text.trim()}"');

                  // Verificar que no hay datos vacíos después del trim
                  final firstName = _firstNameController.text.trim();
                  final lastName = _lastNameController.text.trim();
                  final phoneNumber = _phoneController.text.trim();
                  final address = _addressController.text.trim();

                  if (firstName.isEmpty || lastName.isEmpty || phoneNumber.isEmpty || address.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('❌ All fields must be filled'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  context.read<AuthBloc>().add(
                    UpdateProfileEvent(
                      firstName: firstName,
                      lastName: lastName,
                      phoneNumber: phoneNumber,
                      address: address,
                    ),
                  );
                } else {
                  print('❌ Form validation failed');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Please fix the errors above'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
            ),
          ],
        ),
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