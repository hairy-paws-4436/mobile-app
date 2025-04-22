import '../models/adoption_request.dart';
import '../services/adoption_service.dart';

class AdoptionRepository {
  final AdoptionService adoptionService;

  AdoptionRepository({required this.adoptionService});

  Future<void> requestAdoption(AdoptionRequest request) async {
    try {
      await adoptionService.requestAdoption(request);
    } catch (e) {
      throw e;
    }
  }

  Future<List<AdoptionRequest>> getAdoptionRequests() async {
    try {
      return await adoptionService.getAdoptionRequests();
    } catch (e) {
      throw e;
    }
  }

  Future<AdoptionRequest> getAdoptionRequestDetails(String id) async {
    try {
      return await adoptionService.getAdoptionRequestDetails(id);
    } catch (e) {
      throw e;
    }
  }

  Future<void> approveAdoptionRequest(String id, String notes) async {
    try {
      await adoptionService.approveAdoptionRequest(id, notes);
    } catch (e) {
      throw e;
    }
  }

  Future<void> rejectAdoptionRequest(String id, String notes) async {
    try {
      await adoptionService.rejectAdoptionRequest(id, notes);
    } catch (e) {
      throw e;
    }
  }

  Future<void> cancelAdoptionRequest(String id, String notes) async {
    try {
      await adoptionService.cancelAdoptionRequest(id, notes);
    } catch (e) {
      throw e;
    }
  }
}
