import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/models/animal.dart';

class PetCard extends StatelessWidget {
  final Animal animal;
  final VoidCallback onTap;

  const PetCard({
    super.key,
    required this.animal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12.0)),
              child: animal.images.isNotEmpty
                  ? Image.network(
                animal.images.first,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Center(
                    child: Icon(
                      Icons.pets,
                      size: 60,
                      color: AppTheme.primaryColor.withOpacity(0.5),
                    ),
                  ),
                ),
              )
                  : SizedBox(
                height: 180,
                width: double.infinity,
                child: Center(
                  child: Icon(
                    Icons.pets,
                    size: 60,
                    color: AppTheme.primaryColor.withOpacity(0.5),
                  ),
                ),
              ),
            ),

            // Pet Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          animal.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      /*if (isAdopted)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Text(
                            'Adoptado',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),*/
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${animal.breed} · ${animal.age} años',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
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
                      _buildInfoChip(Icons.monitor_weight, '${animal.weight} kg'),
                    ],
                  ),

                  // Indicadores de salud
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildStatusChip(
                          Icons.vaccines,
                          'Vacunado',
                          animal.vaccinated
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(
                          Icons.cut,
                          'Esterilizado',
                          animal.sterilized
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
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
              fontSize: 12,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(IconData icon, String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.0),
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
              fontSize: 12,
              color: isActive ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}