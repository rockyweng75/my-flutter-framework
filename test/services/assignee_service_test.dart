import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/assignee/iassignee_service.dart';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/paginated_response.dart';
import 'package:my_flutter_framework/mock/mock_assignee_service.dart';
import 'package:my_flutter_framework/models/assignee.dart';

final assigneeServiceProvider = Provider<IAssigneeService>((ref) {
  final HttpClient httpClient = ref.watch(httpClientProvider);
  return MockAssigneeService(httpClient);
});

void main() {
  late ProviderContainer container;
  late MockAssigneeService mockAssigneeService;

  setUp(() {
    container = ProviderContainer();
    mockAssigneeService = container.read(assigneeServiceProvider) as MockAssigneeService;
  });

  test('getAssignees should return a paginated response', () async {
    final response = await mockAssigneeService.getAssignees(page: 1, pageSize: 5);
    
    expect(response, isA<PaginatedResponse<Assignee>>());
    expect(response.page, 1);
    expect(response.pageSize, 5);
    expect(response.total, greaterThan(0));
    expect(response.data.length, lessThanOrEqualTo(5));
  });

  test('getAssignees with keyword should filter results', () async {
    // 先取回一個 Assignee 的名字作為關鍵字
    final response = await mockAssigneeService.getAssignees(page: 1, pageSize: 1);

    final keyword = response.data.first.name.substring(0, 3); // Get a substring of the first assignee's name
    final filteredResponse = await mockAssigneeService.getAssignees(keyword: keyword, page: 1, pageSize: 5);

    expect(filteredResponse, isA<PaginatedResponse<Assignee>>());
    expect(filteredResponse.page, 1);
    expect(filteredResponse.pageSize, 5);
    expect(filteredResponse.total, greaterThan(0));
    expect(filteredResponse.data.length, lessThanOrEqualTo(5));
    expect(filteredResponse.data.every((assignee) => assignee.name.toLowerCase().contains(keyword.toLowerCase())), isTrue);
  });

  tearDown(() {
    container.dispose();
  });
  
}
