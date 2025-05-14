import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../config/theme.dart';
import '../../../data/models/animal.dart';
import '../../../data/models/user.dart';
import '../../bloc/animal/animal_bloc.dart';
import '../../bloc/animal/animal_event.dart';
import '../../bloc/animal/animal_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../common/custom_button.dart';
import '../../common/error_display.dart';
import '../../common/loading_indicator.dart';

class AnimalDetailsScreen extends StatefulWidget {
  final String animalId;

  const AnimalDetailsScreen({
    super.key,
    required this.animalId,
  });

  @override
  State<AnimalDetailsScreen> createState() => _AnimalDetailsScreenState();
}

class _AnimalDetailsScreenState extends State<AnimalDetailsScreen> {
  int _currentImageIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Fetch animal details
    context.read<AnimalBloc>().add(FetchAnimalDetailsEvent(widget.animalId));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnimalBloc, AnimalState>(
      builder: (context, state) {
        if (state is AnimalLoading) {
          return const Scaffold(
            body: LoadingIndicator(message: 'Cargando detalles de la mascota...'),
          );
        } else if (state is AnimalError) {
          return Scaffold(
            body: ErrorDisplay(
              message: state.message,
              onRetry: () {
                context.read<AnimalBloc>().add(FetchAnimalDetailsEvent(widget.animalId));
              },
            ),
          );
        } else if (state is AnimalDetailsLoaded) {
          final animal = state.animal;
          return _buildContent(context, animal);
        }

        return const Scaffold(
          body: LoadingIndicator(message: 'Cargando detalles de la mascota...'),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, Animal animal) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        late User currentUser;
        bool isOwner = false;
        // Determinar si está adoptado basado en si tiene un ownerId
        bool isAdopted = animal.ownerId != null && animal.ownerId!.isNotEmpty;

        if (authState is Authenticated) {
          currentUser = authState.user;
          isOwner = currentUser.id == animal.ownerId;
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildImageSlider(animal),
                ),
                actions: [
                  if (isOwner)
                    PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, color: AppTheme.primaryColor),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'edit') {
                          Navigator.pushNamed(
                            context,
                            '/animal-form',
                            arguments: {'animalId': animal.id},
                          );
                        } else if (value == 'delete') {
                          _showDeleteConfirmationDialog(context, animal);
                        }
                      },
                    ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet Name and Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              animal.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isAdopted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Adoptado',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Pet Specs - Primera fila
                      Row(
                        children: [
                          _buildInfoChip(Icons.pets, animal.type),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            animal.gender.toLowerCase() == 'male'
                                ? Icons.male
                                : Icons.female,
                            animal.gender,
                          ),
                          const SizedBox(width: 8),
                          _buildInfoChip(
                            Icons.cake,
                            '${animal.age} ${animal.age == 1 ? 'año' : 'años'}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Pet Specs - Segunda fila (Peso y Raza)
                      Row(
                        children: [
                          _buildInfoChip(Icons.monitor_weight, '${animal.weight} kg'),
                          const SizedBox(width: 8),
                          _buildInfoChip(Icons.pets_outlined, animal.breed),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Description
                      const Text(
                        'Acerca de',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        animal.description,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Health Details
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información de Salud',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.medical_services,
                                  color: Colors.blue,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    animal.healthDetails,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),

                      // Estado de vacunación y esterilización
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Estado Sanitario',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Chips para vacunado y esterilizado
                          Row(
                            children: [
                              _buildStatusChip(
                                  Icons.vaccines,
                                  'Vacunado',
                                  animal.vaccinated
                              ),
                              const SizedBox(width: 16),
                              _buildStatusChip(
                                  Icons.cut,
                                  'Esterilizado',
                                  animal.sterilized
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Bottom Buttons
          bottomNavigationBar: !isOwner && authState is Authenticated
              ? SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Visit Button
                  Expanded(
                    child: CustomButton(
                      text: 'Programar Visita',
                      type: ButtonType.secondary,
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/adoption-request-form',
                          arguments: {
                            'animalId': animal.id,
                            'type': 'visit',
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Adopt Button
                  Expanded(
                    child: CustomButton(
                      text: 'Adoptar Mascota',
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/adoption-request-form',
                          arguments: {
                            'animalId': animal.id,
                            'type': 'adoption',
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
              : null,
        );
      },
    );
  }

  Widget _buildImageSlider(Animal animal) {
    if (animal.images.isEmpty) {
      return Container(
        color: Colors.grey[300],
        child: Center(
          child: Icon(
            Icons.pets,
            size: 80,
            color: Colors.grey[400],
          ),
        ),
      );
    }

    return Stack(
      children: [
        // Image Slider
        PageView.builder(
          controller: _pageController,
          itemCount: animal.images.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return Image.network(
              animal.images[index],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            );
          },
        ),

        // Image Counter
        if (animal.images.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${animal.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(IconData icon, String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isActive ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isActive ? Colors.green : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Animal animal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Mascota'),
        content: Text(
          '¿Estás seguro que deseas eliminar a ${animal.name}? Esta acción no se puede deshacer.',
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
              context.read<AnimalBloc>().add(DeleteAnimalEvent(animal.id));
              Navigator.pop(context); // Cerrar diálogo
              Navigator.pop(context); // Volver a la pantalla anterior
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}