import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme.dart';
import '../../../data/models/donation.dart';
import '../../../data/models/ngo.dart';
import '../../../data/models/user.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/donation/donation_bloc.dart';
import '../../bloc/donation/donation_event.dart';
import '../../bloc/donation/donation_state.dart';
import '../../bloc/ngo/ngo_bloc.dart';
import '../../bloc/ngo/ngo_event.dart';
import '../../bloc/ngo/ngo_state.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';


class DonationsScreen extends StatefulWidget {
  const DonationsScreen({Key? key}) : super(key: key);

  @override
  State<DonationsScreen> createState() => _DonationsScreenState();
}

class _DonationsScreenState extends State<DonationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Fetch donations
    context.read<DonationBloc>().add(FetchDonationsEvent());

    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUser = authState.user;
    }

    // Fetch NGOs for NGO names
    context.read<NGOBloc>().add(FetchNGOsEvent());
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
        title: const Text('Donations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Confirmed'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: BlocBuilder<DonationBloc, DonationState>(
        builder: (context, state) {
          if (state is DonationLoading) {
            return const LoadingIndicator(message: 'Loading donations...');
          } else if (state is DonationError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                context.read<DonationBloc>().add(FetchDonationsEvent());
              },
            );
          } else if (state is DonationsLoaded) {
            return BlocBuilder<NGOBloc, NGOState>(
              builder: (context, ngoState) {
                final Map<String, NGO> ngoMap = {};

                if (ngoState is NGOsLoaded) {
                  for (final ngo in ngoState.ngos) {
                    ngoMap[ngo.id] = ngo;
                  }
                }

                final donations = state.donations;

                // Filter donations by status
                final pendingDonations = donations.where((d) => d.status == 'pending').toList();
                final confirmedDonations = donations.where((d) => d.status == 'confirmed').toList();
                final cancelledDonations = donations.where((d) => d.status == 'cancelled').toList();

                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Pending Donations Tab
                    _buildDonationsList(pendingDonations, ngoMap),

                    // Confirmed Donations Tab
                    _buildDonationsList(confirmedDonations, ngoMap),

                    // Cancelled Donations Tab
                    _buildDonationsList(cancelledDonations, ngoMap),
                  ],
                );
              },
            );
          }

          return const LoadingIndicator(message: 'Loading donations...');
        },
      ),
    );
  }

  Widget _buildDonationsList(List<Donation> donations, Map<String, NGO> ngoMap) {
    if (donations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.volunteer_activism,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No donations found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DonationBloc>().add(FetchDonationsEvent());
      },
      child: ListView.builder(
        itemCount: donations.length,
        itemBuilder: (context, index) {
          final donation = donations[index];
          return _buildDonationCard(donation, ngoMap[donation.ongId]);
        },
      ),
    );
  }

  Widget _buildDonationCard(Donation donation, NGO? ngo) {
    final bool isNGO = _currentUser?.role == 'ngo';
    final bool canConfirm = isNGO && donation.status == 'pending';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NGO Name and Donation Type
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: donation.type == 'money'
                        ? Colors.green.withOpacity(0.1)
                        : AppTheme.secondaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    donation.type == 'money' ? 'Money' : 'Items',
                    style: TextStyle(
                      color: donation.type == 'money'
                          ? Colors.green
                          : AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  ngo?.name ?? 'NGO',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Donation Details
            if (donation.type == 'money') ...[
              _buildInfoRow('Amount', 'S/ ${donation.amount?.toStringAsFixed(2)}'),
              if (donation.transactionId != null)
                _buildInfoRow('Transaction ID', donation.transactionId!),
            ] else if (donation.items != null && donation.items!.isNotEmpty) ...[
              const Text(
                'Donated Items:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...donation.items!.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text('• ${item.quantity}x ${item.name} - ${item.description}'),
              )).toList(),
            ],

            if (donation.notes != null && donation.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildInfoRow('Notes', donation.notes!),
            ],

            const SizedBox(height: 12),
            _buildInfoRow('Date', 'Status: ${donation.status.capitalize()}'),

            // Action Buttons (for NGO admins)
            if (canConfirm) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _showCancelDialog(context, donation);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _showConfirmDialog(context, donation);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Confirm Receipt'),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context, Donation donation) {
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Donation Receipt'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to confirm receiving this donation?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Thank you note (optional)',
                hintText: 'Add a thank you note to the donor...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
              context.read<DonationBloc>().add(
                ConfirmDonationEvent(
                  donationId: donation.id,
                  notes: notesController.text,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Donation donation) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Donation?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to reject this donation?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Add a reason for rejection...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DonationBloc>().add(
                CancelDonationEvent(
                  donationId: donation.id,
                  notes: reasonController.text,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

// Extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}