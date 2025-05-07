class PaginatedResponse<T> {
  final int page;
  final int pageSize;
  final int total;
  final List<T> data;

  PaginatedResponse({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.data,
  });

  int get totalPages => (total / pageSize).ceil();
  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;
  int get nextPage => hasNextPage ? page + 1 : page;
  int get previousPage => hasPreviousPage ? page - 1 : page;
  int get startIndex => (page - 1) * pageSize + 1;
  int get endIndex => (page * pageSize > total) ? total : page * pageSize;
}