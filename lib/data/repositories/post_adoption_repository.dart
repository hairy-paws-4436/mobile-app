import '../models/post_adoption_models.dart';
import '../services/post_adoption_service.dart';

class PostAdoptionRepository {
  final PostAdoptionService postAdoptionService;

  PostAdoptionRepository({required this.postAdoptionService});

  // Adopter methods
  Future<List<PostAdoptionFollowUp>> getMyFollowUps({String? status}) async {
    try {
      return await postAdoptionService.getMyFollowUps(status: status);
    } catch (e) {
      throw e;
    }
  }

  Future<PostAdoptionFollowUp> getFollowUpDetails(String followupId) async {
    try {
      return await postAdoptionService.getFollowUpDetails(followupId);
    } catch (e) {
      throw e;
    }
  }

  Future<void> scheduleFollowUps(String adoptionId) async {
    try {
      await postAdoptionService.scheduleFollowUps(adoptionId);
    } catch (e) {
      throw e;
    }
  }

  Future<void> completeFollowUp(String followupId, FollowUpFormData formData) async {
    try {
      await postAdoptionService.completeFollowUp(followupId, formData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> skipFollowUp(String followupId) async {
    try {
      await postAdoptionService.skipFollowUp(followupId);
    } catch (e) {
      throw e;
    }
  }

  // NGO methods
  Future<PostAdoptionDashboard> getNGODashboard() async {
    try {
      return await postAdoptionService.getNGODashboard();
    } catch (e) {
      throw e;
    }
  }

  Future<PostAdoptionAnalytics> getNGOAnalytics({String? period}) async {
    try {
      return await postAdoptionService.getNGOAnalytics(period: period);
    } catch (e) {
      throw e;
    }
  }

  Future<List<PostAdoptionFollowUp>> getAtRiskAdoptions() async {
    try {
      return await postAdoptionService.getAtRiskAdoptions();
    } catch (e) {
      throw e;
    }
  }

  Future<void> startIntervention(String followupId) async {
    try {
      await postAdoptionService.startIntervention(followupId);
    } catch (e) {
      throw e;
    }
  }

  // Admin methods
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      return await postAdoptionService.getAdminStats();
    } catch (e) {
      throw e;
    }
  }

  Future<void> sendReminders() async {
    try {
      await postAdoptionService.sendReminders();
    } catch (e) {
      throw e;
    }
  }
}