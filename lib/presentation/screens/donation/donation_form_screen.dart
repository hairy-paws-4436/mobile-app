import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/donation.dart';
import '../../../data/models/ngo.dart';
import '../../bloc/donation/donation_bloc.dart';
import '../../bloc/donation/donation_event.dart';
import '../../bloc/donation/donation_state.dart';
import '../../bloc/ngo/ngo_bloc.dart';
import '../../bloc/ngo/ngo_event.dart';
import '../../bloc/ngo/ngo_state.dart';
import '../../common/custom_button.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class DonationFormScreen extends StatefulWidget {
  final String ngoId;

  const DonationFormScreen({
    Key? key,
    required this.ngoId,
  }) : super(key: key);

  @override
  State<DonationFormScreen> createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _transactionIdController = TextEditingController();
  final _notesController = TextEditingController();

  String _donationType = 'money';
  List<DonationItem> _items = [];
  XFile? _receiptImage;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Fetch NGO details
    context.read<NGOBloc>().add(FetchNGODetailsEvent(widget.ngoId));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Donation'),
      ),
      body: BlocConsumer<DonationBloc, DonationState>(
        listener: (context, state) {
          if (state is DonationCreated) {
            // Show success snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Donation submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate back
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return BlocBuilder<NGOBloc, NGOState>(
            builder: (context, ngoState) {
              if (ngoState is NGOLoading) {
                return const LoadingIndicator(message: 'Loading NGO details...');
              } else if (ngoState is NGOError) {
                return ErrorDisplay(
                  message: ngoState.message,
                  onRetry: () {
                    context.read<NGOBloc>().add(FetchNGODetailsEvent(widget.ngoId));
                  },
                );
              } else if (ngoState is NGODetailsLoaded) {
                final ngo = ngoState.ngo;
                return _buildContent(context, ngo, state);
              }

              return const LoadingIndicator(message: 'Loading NGO details...');
            },
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, NGO ngo, DonationState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NGO Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // NGO Logo
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                        image: ngo.logo != null
                            ? DecorationImage(
                          image: NetworkImage(ngo.logo!),
                          fit: BoxFit.cover,
                          onError: (exception, stackTrace) => {},
                        )
                            : null,
                      ),
                      child: ngo.logo == null
                          ? const Icon(
                        Icons.business,
                        size: 30,
                        color: AppTheme.primaryColor,
                      )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    // NGO Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ngo.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ngo.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Donation Type
            const Text(
              'Donation Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Money'),
                    subtitle: const Text('Monetary donation'),
                    value: 'money',
                    groupValue: _donationType,
                    onChanged: (value) {
                      setState(() {
                        _donationType = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Items'),
                    subtitle: const Text('Donate items'),
                    value: 'items',
                    groupValue: _donationType,
                    onChanged: (value) {
                      setState(() {
                        _donationType = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Money Donation Fields
            if (_donationType == 'money')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Money Donation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bank Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bank Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow('Bank', ngo.bankName),
                        const SizedBox(height: 4),
                        _buildInfoRow('Account Number', ngo.bankAccount),
                        const SizedBox(height: 4),
                        _buildInfoRow('Interbank Code (CCI)', ngo.interbankAccount),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      hintText: 'Enter donation amount',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (_donationType == 'money') {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the donation amount';
                        }
                        if (double.tryParse(value) == null || double.parse(value) <= 0) {
                          return 'Please enter a valid amount';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Transaction ID
                  TextFormField(
                    controller: _transactionIdController,
                    decoration: const InputDecoration(
                      labelText: 'Transaction ID',
                      hintText: 'Enter bank transaction ID',
                      prefixIcon: Icon(Icons.receipt_long),
                    ),
                    validator: (value) {
                      if (_donationType == 'money') {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the transaction ID';
                        }
                      }
                      return null;
                    },
                  ),
                ],
              ),

            // Items Donation Fields
            if (_donationType == 'items')
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Items Donation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Items List
                  if (_items.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'No items added yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(item.name),
                            subtitle: Text(
                              '${item.quantity} ${item.quantity > 1 ? 'units' : 'unit'} - ${item.description}',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _items.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 8),

                  // Add Item Button
                  CustomButton(
                    text: 'Add Item',
                    onPressed: () {
                      _showAddItemDialog(context);
                    },
                    type: ButtonType.secondary,
                    icon: Icons.add,
                  ),
                ],
              ),
            const SizedBox(height: 24),

            // Notes
            const Text(
              'Additional Notes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Add any additional notes about your donation...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Receipt Image
            const Text(
              'Receipt/Proof (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[300]!,
                  ),
                ),
                child: _receiptImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    _receiptImage!.path,
                    fit: BoxFit.cover,
                  ),
                )
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to add receipt image',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            CustomButton(
              text: 'Submit Donation',
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (_donationType == 'items' && _items.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add at least one item'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final donationData = {
                    'ongId': ngo.id,
                    'type': _donationType,
                    'amount': _donationType == 'money' ? double.parse(_amountController.text) : null,
                    'transactionId': _donationType == 'money' ? _transactionIdController.text : null,
                    'notes': _notesController.text,
                    'items': _donationType == 'items' ? _items.map((item) => item.toJson()).toList() : null,
                  };

                  context.read<DonationBloc>().add(
                    CreateDonationEvent(
                      donationData: donationData,
                      receiptPath: _receiptImage?.path,
                    ),
                  );
                }
              },
              isLoading: state is DonationLoading,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _receiptImage = image;
      });
    }
  }

  void _showAddItemDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _quantityController = TextEditingController();
    final _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Donation Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Item Name
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name',
                    hintText: 'Enter item name',
                  ),
                ),
                const SizedBox(height: 16),

                // Quantity
                TextField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    hintText: 'Enter quantity',
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                TextField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Enter item description',
                  ),
                ),
              ],
            ),
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
                // Validate inputs
                if (_nameController.text.isNotEmpty &&
                    _quantityController.text.isNotEmpty &&
                    _descriptionController.text.isNotEmpty) {

                  // Add item
                  setState(() {
                    _items.add(DonationItem(
                      name: _nameController.text,
                      quantity: int.parse(_quantityController.text),
                      description: _descriptionController.text,
                    ));
                  });

                  Navigator.pop(context);
                } else {
                  // Show error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill all fields'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Add Item'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue[700],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
