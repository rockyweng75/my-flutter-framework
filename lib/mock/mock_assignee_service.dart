import 'dart:async';
import 'package:faker/faker.dart';
import 'package:my_flutter_framework/api/assignee/iassignee_service.dart';
import 'package:my_flutter_framework/api/http_client.dart';
import 'package:my_flutter_framework/api/paginated_response.dart';
import 'package:my_flutter_framework/models/assignee.dart';

class MockAssigneeService implements IAssigneeService {
  final HttpClient _httpClient;

  MockAssigneeService(this._httpClient);

  final List<Assignee> _mockDatabase = List.generate(20, (index) {
    final faker = Faker();
    return Assignee(
      id: index + 1,
      name: faker.person.name(),
    );
  });

  @override
  Future<PaginatedResponse<Assignee>> getAssignees({String? keyword, int page = 1, int pageSize = 10}) async {
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    List<Assignee> filteredDatabase = _mockDatabase;
    if (keyword != null && keyword.isNotEmpty) {
      filteredDatabase = _mockDatabase
          .where((assignee) => assignee.name.toLowerCase().contains(keyword.toLowerCase()))
          .toList();
    }

    if (startIndex >= filteredDatabase.length) {
      return PaginatedResponse(
        page: page,
        pageSize: pageSize,
        total: filteredDatabase.length,
        data: [],
      );
    }

    final data = filteredDatabase.sublist(
      startIndex,
      endIndex > filteredDatabase.length ? filteredDatabase.length : endIndex,
    );
    return PaginatedResponse(
      page: page,
      pageSize: pageSize,
      total: filteredDatabase.length,
      data: data,
    );
  }
}