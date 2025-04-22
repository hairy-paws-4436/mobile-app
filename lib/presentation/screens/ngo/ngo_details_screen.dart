import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../config/theme.dart';
import '../../../data/models/ngo.dart';
import '../../../data/models/user.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/ngo/ngo_bloc.dart';
import '../../bloc/ngo/ngo_event.dart';
import '../../bloc/ngo/ngo_state.dart';
import '../../common/custom_button.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class NGODetailsScreen extends StatefulWidget {
  final String? ngoId;
  final bool isUserNGO;

  const NGODetailsScreen({
    Key? key,
    this.ngoId,
    this.isUserNGO = false,
  }) : super(key: key);

  @override
  State<NGODetailsScreen> createState() => _NGODetailsScreenState();
}

class _NGODetailsScreenState extends State<NGODetailsScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch NGO details
    if (widget.isUserNGO) {
      context.read<NGOBloc>().add(FetchUserNGOEvent());
    } else if (widget.ngoId != null) {
      context.read<NGOBloc>().add(FetchNGODetailsEvent(widget.ngoId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NGO Details'),
        actions: [
          if (widget.isUserNGO)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navigate to edit NGO form
              },
            ),
        ],
      ),
      body: BlocBuilder<NGOBloc, NGOState>(
        builder: (context, state) {
          if (state is NGOLoading) {
            return const LoadingIndicator(message: 'Loading NGO details...');
          } else if (state is NGOError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                if (widget.isUserNGO) {
                  context.read<NGOBloc>().add(FetchUserNGOEvent());
                } else if (widget.ngoId != null) {
                  context.read<NGOBloc>().add(FetchNGODetailsEvent(widget.ngoId!));
                }
              },
            );
          } else if (state is NGODetailsLoaded || state is UserNGOLoaded) {
            final NGO ngo = state is NGODetailsLoaded
                ? state.ngo
                : (state as UserNGOLoaded).ngo;

            return _buildContent(context, ngo);
          }

          return const LoadingIndicator(message: 'Loading NGO details...');
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, NGO ngo) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        User? currentUser;
        bool isOwner = false;

        if (authState is Authenticated) {
          currentUser = authState.user;
          isOwner = currentUser.id == ngo.ownerId;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NGO Header
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // NGO Logo
                      Container(
                        width: 100,
                        height: 100,
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
                          size: 60,
                          color: AppTheme.primaryColor,
                        )
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // NGO Name
                      Text(
                        ngo.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Description
                      Text(
                        ngo.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mission and Vision
              if (ngo.mission != null || ngo.vision != null)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (ngo.mission != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mission',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ngo.mission!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                              if (ngo.vision != null) const SizedBox(height: 16),
                            ],
                          ),
                        if (ngo.vision != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vision',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                ngo.vision!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Contact Information
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contact Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Address
                      _buildContactItem(
                        icon: Icons.location_on,
                        text: ngo.address,
                        onTap: () async {
                          final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(ngo.address)}';
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Phone
                      _buildContactItem(
                        icon: Icons.phone,
                        text: ngo.phone,
                        onTap: () async {
                          final url = 'tel:${ngo.phone}';
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Email
                      _buildContactItem(
                        icon: Icons.email,
                        text: ngo.email,
                        onTap: () async {
                          final url = 'mailto:${ngo.email}';
                          if (await canLaunch(url)) {
                            await launch(url);
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      // Website
                      if (ngo.website != null)
                        _buildContactItem(
                          icon: Icons.language,
                          text: ngo.website!,
                          onTap: () async {
                            if (await canLaunch(ngo.website!)) {
                              await launch(ngo.website!);
                            }
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bank Information (only for donors)
              if (!isOwner && authState is Authenticated)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Banking Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildInfoRow('Bank', ngo.bankName),
                        const SizedBox(height: 12),
                        _buildInfoRow('Account Number', ngo.bankAccount),
                        const SizedBox(height: 12),
                        _buildInfoRow('Interbank Code (CCI)', ngo.interbankAccount),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),

              // Action Buttons (Donate Button for non-owners)
              if (!isOwner && authState is Authenticated)
                CustomButton(
                  text: 'Make a Donation',
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/donation-form',
                      arguments: {'ngoId': ngo.id},
                    );
                  },
                  icon: Icons.volunteer_activism,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                icon,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
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
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
