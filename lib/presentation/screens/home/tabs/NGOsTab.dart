import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/models/ngo.dart';
import '../../../bloc/ngo/ngo_bloc.dart';
import '../../../bloc/ngo/ngo_event.dart';
import '../../../bloc/ngo/ngo_state.dart';
import '../../../common/error_display.dart';
import '../../../common/loading_indicator.dart';
import '../../../common/ngo_card.dart';

class NGOsTab extends StatefulWidget {
  const NGOsTab({Key? key}) : super(key: key);

  @override
  State<NGOsTab> createState() => _NGOsTabState();
}

class _NGOsTabState extends State<NGOsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NGOBloc, NGOState>(
      builder: (context, state) {
        return Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search NGOs...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            
            // Content
            Expanded(
              child: _buildContent(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(NGOState state) {
    if (state is NGOLoading) {
      return const LoadingIndicator(message: 'Loading NGOs...');
    } else if (state is NGOError) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () {
          context.read<NGOBloc>().add(FetchNGOsEvent());
        },
      );
    } else if (state is NGOsLoaded) {
      final filteredNGOs = _filterNGOs(state.ngos);
      
      if (filteredNGOs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No NGOs found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        );
      }
      
      return RefreshIndicator(
        onRefresh: () async {
          context.read<NGOBloc>().add(FetchNGOsEvent());
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16.0),
          itemCount: filteredNGOs.length,
          itemBuilder: (context, index) {
            final ngo = filteredNGOs[index];
            return NGOCard(
              ngo: ngo,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/ngo-details',
                  arguments: {'ngoId': ngo.id},
                );
              },
            );
          },
        ),
      );
    }
    
    return const LoadingIndicator(message: 'Loading NGOs...');
  }

  List<NGO> _filterNGOs(List<NGO> ngos) {
    if (_searchQuery.isEmpty) {
      return ngos;
    }
    
    final query = _searchQuery.toLowerCase();
    return ngos.where((ngo) {
      return ngo.name.toLowerCase().contains(query) ||
             ngo.description.toLowerCase().contains(query);
    }).toList();
  }
}
