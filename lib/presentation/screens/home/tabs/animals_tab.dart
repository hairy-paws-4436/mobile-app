import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/theme.dart';
import '../../../../data/models/animal.dart';
import '../../../bloc/animal/animal_bloc.dart';
import '../../../bloc/animal/animal_event.dart';
import '../../../bloc/animal/animal_state.dart';
import '../../../common/error_display.dart';
import '../../../common/loading_indicator.dart';
import '../../../common/pet_card.dart';

class AnimalsTab extends StatefulWidget {
  const AnimalsTab({Key? key}) : super(key: key);

  @override
  State<AnimalsTab> createState() => _AnimalsTabState();
}

class _AnimalsTabState extends State<AnimalsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecies = 'All';

  final List<String> _speciesOptions = ['cat', 'dog'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimalBloc, AnimalState>(
      builder: (context, state) {
        return Column(
          children: [
            // Search and Filter Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Search Field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search pets...',
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
                  const SizedBox(width: 8),
                  // Filter Button
                  InkWell(
                    onTap: () {
                      _showFilterBottomSheet(context);
                    },
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Filter Chips
            if (_selectedSpecies != 'All')
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Chip(
                      label: Text(_selectedSpecies),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _selectedSpecies = 'All';
                        });
                      },
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      labelStyle: const TextStyle(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedSpecies = 'All';
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
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

  Widget _buildContent(AnimalState state) {
    if (state is AnimalLoading) {
      return const LoadingIndicator(message: 'Loading pets...');
    } else if (state is AnimalError) {
      return ErrorDisplay(
        message: state.message,
        onRetry: () {
          context.read<AnimalBloc>().add(FetchAnimalsEvent());
        },
      );
    } else if (state is AnimalsLoaded) {
      final filteredAnimals = _filterAnimals(state.animals);

      if (filteredAnimals.isEmpty) {
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
                'No pets found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
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
          context.read<AnimalBloc>().add(FetchAnimalsEvent());
        },
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 16.0),
          itemCount: filteredAnimals.length,
          itemBuilder: (context, index) {
            final animal = filteredAnimals[index];
            return PetCard(
              animal: animal,
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/animal-details',
                  arguments: {'animalId': animal.id},
                );
              },
            );
          },
        ),
      );
    }

    return const LoadingIndicator(message: 'Loading pets...');
  }

  List<Animal> _filterAnimals(List<Animal> animals) {
    return animals.where((animal) {
      // Apply species filter
      if (_selectedSpecies != 'All' && animal.type != _selectedSpecies) {
        return false;
      }

      // Apply search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return animal.name.toLowerCase().contains(query) ||
            animal.breed.toLowerCase().contains(query) ||
            animal.description.toLowerCase().contains(query);
      }

      return true;
    }).toList();
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filter Pets',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Species Filter
                  const Text(
                    'Species',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _speciesOptions.map((species) {
                      final isSelected = _selectedSpecies == species;
                      return ChoiceChip(
                        label: Text(species),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSpecies = species;
                          });

                          // Also update the parent state
                          this.setState(() {});
                        },
                        backgroundColor: Colors.grey[200],
                        selectedColor: AppTheme.primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : Colors.black,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Apply Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
