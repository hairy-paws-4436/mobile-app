import '../models/ngo.dart';
import '../services/ngo_service.dart';

class NGORepository {
  final NGOService ngoService;

  NGORepository({required this.ngoService});

  Future<List<NGO>> getNGOs() async {
    try {
      return await ngoService.getNGOs();
    } catch (e) {
      throw e;
    }
  }

  Future<NGO> getNGODetails(String id) async {
    try {
      return await ngoService.getNGODetails(id);
    } catch (e) {
      throw e;
    }
  }

  Future<NGO> getUserNGO() async {
    try {
      return await ngoService.getUserNGO();
    } catch (e) {
      throw e;
    }
  }

  Future<NGO> registerNGO(Map<String, dynamic> ngoData, String? logoPath) async {
    try {
      return await ngoService.registerNGO(ngoData, logoPath);
    } catch (e) {
      throw e;
    }
  }

  Future<NGO> updateNGO(String id, Map<String, dynamic> ngoData) async {
    try {
      return await ngoService.updateNGO(id, ngoData);
    } catch (e) {
      throw e;
    }
  }
}
