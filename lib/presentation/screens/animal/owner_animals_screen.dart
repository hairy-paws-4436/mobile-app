// lib/presentation/screens/animal/owner_animals_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../bloc/animal/animal_bloc.dart';
import '../../bloc/animal/animal_event.dart';
import '../../bloc/animal/animal_state.dart';
import '../../common/custom_button.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';
import '../../common/pet_card.dart';


class OwnerAnimalsScreen extends StatefulWidget {
  const OwnerAnimalsScreen({Key? key}) : super(key: key);

  @override
  State<OwnerAnimalsScreen> createState() => _OwnerAnimalsScreenState();
}

class _OwnerAnimalsScreenState extends State<OwnerAnimalsScreen> {
  @override
  void initState() {
    super.initState();

    // Fetch owner's animals
    context.read<AnimalBloc>().add(FetchOwnerAnimalsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
      ),
      body: BlocBuilder<AnimalBloc, AnimalState>(
        builder: (context, state) {
          if (state is AnimalLoading) {
            return const LoadingIndicator(message: 'Loading your pets...');
          } else if (state is AnimalError) {
            return ErrorDisplay(
              message: state.message,
              onRetry: () {
                context.read<AnimalBloc>().add(FetchOwnerAnimalsEvent());
              },
            );
          } else if (state is OwnerAnimalsLoaded) {
            final animals = state.animals;

            if (animals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.pets,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pets registered',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add your first pet for adoption',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Add Pet',
                      onPressed: () {
                        Navigator.pushNamed(context, '/animal-form');
                      },
                      icon: Icons.add,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AnimalBloc>().add(FetchOwnerAnimalsEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 80.0),
                itemCount: animals.length,
                itemBuilder: (context, index) {
                  final animal = animals[index];
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

          return const LoadingIndicator(message: 'Loading your pets...');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/animal-form');
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}