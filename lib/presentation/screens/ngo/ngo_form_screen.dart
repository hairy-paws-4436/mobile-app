// lib/presentation/screens/ngo/ngo_form_screen.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../config/theme.dart';
import '../../bloc/ngo/ngo_bloc.dart';
import '../../bloc/ngo/ngo_event.dart';
import '../../bloc/ngo/ngo_state.dart';
import '../../common/custom_button.dart';

class NGOFormScreen extends StatefulWidget {
  const NGOFormScreen({Key? key}) : super(key: key);

  @override
  State<NGOFormScreen> createState() => _NGOFormScreenState();
}

class _NGOFormScreenState extends State<NGOFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _rucController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _missionController = TextEditingController();
  final _visionController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _interbankAccountController = TextEditingController();

  XFile? _logoImage;
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _rucController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _missionController.dispose();
    _visionController.dispose();
    _bankAccountController.dispose();
    _bankNameController.dispose();
    _interbankAccountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register NGO'),
      ),
      body: BlocConsumer<NGOBloc, NGOState>(
        listener: (context, state) {
          if (state is NGORegistered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('NGO registered successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is NGOError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo Upload
                  Center(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _pickLogo,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                              image: _logoImage != null
                                  ? DecorationImage(
                                image: FileImage(
                                  File(_logoImage!.path),
                                ),
                                fit: BoxFit.cover,
                              )
                                  : null,
                            ),
                            child: _logoImage == null
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate,
                                  size: 40,
                                  color: AppTheme.primaryColor,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Add Logo',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'NGO Logo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Information Section
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
                      labelText: 'NGO Name',
                      hintText: 'Enter NGO name',
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the NGO name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // RUC
                  TextFormField(
                    controller: _rucController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'RUC',
                      hintText: 'Enter RUC (11 digits)',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the RUC';
                      }
                      if (value.length != 11) {
                        return 'RUC must be 11 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter NGO description',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Contact Information Section
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Enter NGO address',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Enter contact phone number',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter contact email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Website (Optional)
                  TextFormField(
                    controller: _websiteController,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'Website (Optional)',
                      hintText: 'Enter NGO website',
                      prefixIcon: Icon(Icons.language),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mission and Vision Section
                  const Text(
                    'Mission and Vision (Optional)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mission
                  TextFormField(
                    controller: _missionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Mission',
                      hintText: 'Enter NGO mission',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.assignment),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Vision
                  TextFormField(
                    controller: _visionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Vision',
                      hintText: 'Enter NGO vision',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.visibility),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Banking Information Section
                  const Text(
                    'Banking Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Bank Name
                  TextFormField(
                    controller: _bankNameController,
                    decoration: const InputDecoration(
                      labelText: 'Bank Name',
                      hintText: 'Enter bank name',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the bank name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Bank Account
                  TextFormField(
                    controller: _bankAccountController,
                    decoration: const InputDecoration(
                      labelText: 'Bank Account Number',
                      hintText: 'Enter bank account number',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the bank account number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Interbank Account
                  TextFormField(
                    controller: _interbankAccountController,
                    decoration: const InputDecoration(
                      labelText: 'Interbank Account Number (CCI)',
                      hintText: 'Enter interbank account number',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the interbank account number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  CustomButton(
                    text: 'Register NGO',
                    onPressed: _submitForm,
                    isLoading: state is NGOLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _logoImage = image;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final ngoData = {
        'name': _nameController.text,
        'ruc': _rucController.text,
        'description': _descriptionController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'website': _websiteController.text,
        'mission': _missionController.text,
        'vision': _visionController.text,
        'bankAccount': _bankAccountController.text,
        'bankName': _bankNameController.text,
        'interbankAccount': _interbankAccountController.text,
      };

      context.read<NGOBloc>().add(
        RegisterNGOEvent(
          ngoData: ngoData,
          logoPath: _logoImage?.path,
        ),
      );
    }
  }
}