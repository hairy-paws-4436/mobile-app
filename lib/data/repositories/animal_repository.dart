
import '../models/animal.dart';
import '../services/animal_service.dart';

class AnimalRepository {
  final AnimalService animalService;

  AnimalRepository({required this.animalService});

  Future<List<Animal>> getAnimals() async {
    try {
      return await animalService.getAnimals();
    } catch (e) {
      throw e;
    }
  }

  Future<Animal> getAnimalDetails(String id) async {
    try {
      return await animalService.getAnimalDetails(id);
    } catch (e) {
      throw e;
    }
  }

  Future<List<Animal>> getOwnerAnimals() async {
    try {
      return await animalService.getOwnerAnimals();
    } catch (e) {
      throw e;
    }
  }

  Future<Animal> createAnimal(Map<String, dynamic> animalData, List<String> imagePaths) async {
    try {
      return await animalService.createAnimal(animalData, imagePaths);
    } catch (e) {
      throw e;
    }
  }

  Future<Animal> updateAnimal(String id, Map<String, dynamic> animalData) async {
    try {
      return await animalService.updateAnimal(id, animalData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> deleteAnimal(String id) async {
    try {
      await animalService.deleteAnimal(id);
    } catch (e) {
      throw e;
    }
  }
}
