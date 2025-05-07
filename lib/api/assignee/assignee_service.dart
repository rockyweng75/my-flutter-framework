import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/paginated_response.dart';
import 'package:my_flutter_framework/api/assignee/iassignee_service.dart';
import 'package:my_flutter_framework/models/assignee.dart';

class AssigneeService implements IAssigneeService {
  final HttpClient _httpClient;

  AssigneeService(this._httpClient);

  @override
  Future<PaginatedResponse<Assignee>> getAssignees({
    String? keyword,
    int page = 1,
    int pageSize = 10,
  }) async {
    String url = '/assignees?page=$page&pageSize=$pageSize';
    if (keyword != null && keyword.isNotEmpty) {
      url += '&keyword=$keyword';
    }

    final response = await _httpClient.get<List<Map<String, dynamic>>>(
      url,
      fromJson: (json) => List<Map<String, dynamic>>.from(json),
    );

    final assignees = response.map((json) => Assignee.fromJson(json)).toList();

    return PaginatedResponse(
      page: page,
      pageSize: pageSize,
      total: assignees.length,
      data: assignees,
    );
  }
}
