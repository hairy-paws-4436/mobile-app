import '../models/animal.dart';
import 'api_client.dart';

class AnimalService {
  final ApiClient apiClient;

  AnimalService({required this.apiClient});

  Future<List<Animal>> getAnimals() async {
    final response = await apiClient.get('/api/animals');
    return (response as List).map((json) => Animal.fromJson(json)).toList();
  }

  Future<Animal> getAnimalDetails(String id) async {
    final response = await apiClient.get('/api/animals/$id');
    return Animal.fromJson(response);
  }

  Future<List<Animal>> getOwnerAnimals() async {
    final response = await apiClient.get('/api/animals/owner');
    return (response as List).map((json) => Animal.fromJson(json)).toList();
  }

  Future<Animal> createAnimal(Map<String, dynamic> animalData, List<String> imagePaths) async {
    final fields = animalData.map((key, value) => MapEntry(key, value.toString()));
    final files = <String, String>{};

    // Add images to files map
    for (int i = 0; i < imagePaths.length; i++) {
      files['image$i'] = imagePaths[i];
    }

    final response = await apiClient.multipartPost('/api/animals', fields: fields, files: files);
    return Animal.fromJson(response);
  }

  Future<Animal> updateAnimal(String id, Map<String, dynamic> animalData) async {
    final response = await apiClient.put('/api/animals/$id', body: animalData);
    return Animal.fromJson(response);
  }

  Future<void> deleteAnimal(String id) async {
    await apiClient.delete('/api/animals/$id');
  }
}
