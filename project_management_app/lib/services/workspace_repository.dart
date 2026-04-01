import '../models/stored_session.dart';
import '../models/workspace_models.dart';
import 'api_client.dart';

class WorkspaceRepository {
  Future<WorkspaceSnapshot> fetchSnapshot(StoredSession session) async {
    final client = ApiClient(
      baseUrl: session.baseUrl,
      token: session.token,
    );

    final response = await client.get('/api/v1/dashboard');
    final data = response['data'] as Map<String, dynamic>? ?? {};

    return WorkspaceSnapshot.fromJson(data);
  }
}
