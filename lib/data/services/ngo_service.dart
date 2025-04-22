import '../models/ngo.dart';
import 'api_client.dart';

class NGOService {
  final ApiClient apiClient;

  NGOService({required this.apiClient});

  Future<List<NGO>> getNGOs() async {
    final response = await apiClient.get('/api/ongs');
    return (response as List).map((json) => NGO.fromJson(json)).toList();
  }

  Future<NGO> getNGODetails(String id) async {
    final response = await apiClient.get('/api/ongs/$id');
    return NGO.fromJson(response);
  }

  Future<NGO> getUserNGO() async {
    final response = await apiClient.get('/api/ongs/user/me');
    return NGO.fromJson(response);
  }

  Future<NGO> registerNGO(Map<String, dynamic> ngoData, String? logoPath) async {
    final fields = ngoData.map((key, value) => MapEntry(key, value.toString()));
    final files = <String, String>{};

    if (logoPath != null) {
      files['logo'] = logoPath;
    }

    final response = await apiClient.multipartPost('/api/ongs', fields: fields, files: files);
    return NGO.fromJson(response);
  }

  Future<NGO> updateNGO(String id, Map<String, dynamic> ngoData) async {
    final response = await apiClient.put('/api/ongs/$id', body: ngoData);
    return NGO.fromJson(response);
  }
}
