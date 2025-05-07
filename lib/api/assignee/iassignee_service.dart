import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/assignee/assignee_service.dart';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/paginated_response.dart';
import 'package:my_flutter_framework/mock/mock_assignee_service.dart';
import 'package:my_flutter_framework/models/assignee.dart';

abstract class IAssigneeService {
  Future<PaginatedResponse<Assignee>> getAssignees({String? keyword, int page = 1, int pageSize = 10}) ;
}

final assigneeServiceProvider = Provider<IAssigneeService>((ref) {
  // 判斷是否為測試環境
  final httpClient = ref.watch(httpClientProvider);
  if (kDebugMode) {
    return MockAssigneeService(httpClient);
  } else {
    return AssigneeService(httpClient);
  }
});
