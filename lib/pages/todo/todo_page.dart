import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/todos/itodo_service.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/pages/todo/todo_details_page.dart';
import 'package:my_flutter_framework/pages/todo/todo_list_page.dart';
import 'package:my_flutter_framework/shared/pages/simple_form_page.dart';
import 'package:my_flutter_framework/shared/utils/transaction_manager.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends MainLayoutPage<TodoPage> {
  late ITodoService _todoService;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  List<Map<String, dynamic>> _todos = [];
  bool _isLoading = false;
  bool _hasNextPage = true;
  bool _isScreenLocked = false;

  // void _lockScreen() {
  //   if (mounted) {
  //     setState(() {
  //       _isScreenLocked = true;
  //     });
  //   }
  // }

  // void _unlockScreen() {
  //   if (mounted) {
  //     setState(() {
  //       _isScreenLocked = false;
  //     });
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _todoService = ref.read(todoServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialTodos(context);
    });
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreTodos(context, null);
      }
    });
  }

  Future<void> _loadInitialTodos(context) async {
    TransactionManager transactionManager = TransactionManager(context);
    await transactionManager.execute(() async {
      final response = await _todoService.getTodos(
        page: _currentPage,
        pageSize: 8,
      );
      if (mounted) {
        setState(() {
          _todos = response.data;
          _currentPage = 1;
          _hasNextPage = response.data.isNotEmpty;
        });
      }
    });
    // _lockScreen();
    // final response = await _todoService.getTodos(page: 1, pageSize: 8);
    // if (mounted) {
    //   setState(() {
    //     _todos = response.data;
    //     _currentPage = 1;
    //     _hasNextPage = response.data.isNotEmpty;
    //   });
    // }
    // _unlockScreen();
  }

  Future<void> _loadMoreTodos(
    context,
    Map<String, dynamic>? queryParameters,
  ) async {
    TransactionManager transactionManager = TransactionManager(context);

    if (_isLoading || !_hasNextPage) return;

    // if (mounted) {
    //   setState(() {
    //     _isLoading = true;
    //   });
    // }
    await transactionManager.execute(() async {
      setState(() {
        _isLoading = true;
      });

      final nextPage = _currentPage + 1;
      final response = await _todoService.getTodos(page: nextPage, pageSize: 8);
      if (response.data.isNotEmpty) {
        if (mounted) {
          setState(() {
            _todos.addAll(response.data);
            _currentPage = nextPage;
          });
        }
      }

      if (response.data.isEmpty || response.data.length < 8) {
        if (mounted) {
          setState(() {
            _hasNextPage = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasNextPage = true;
          });
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    return TodoListPage(
      items: _todos,
      scrollController: _scrollController,
      isLoading: _isLoading,
      isScreenLocked: _isScreenLocked,
      onLoadMore: (params) => _loadMoreTodos(context, params),
      onItemTap: (todo) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TodoDetailsPage(todo: todo)),
        );
      },
      rowBuilder: (context, item) {
        final index = _todos.indexOf(item);
        return Card(
          color:
              index % 2 == 0
                  ? AppColor.cardEvenBackground
                  : AppColor.cardOddBackground, // 使用 AppColor 定義的顏色
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: ListTile(
            leading: Icon(
              item['completed'] ? Icons.check_circle : Icons.circle,
              color: item['completed'] ? Colors.green : Colors.grey,
            ),
            title: Text(
              item['title'],
              style: TextStyle(
                decoration:
                    item['completed']
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
              ),
            ),
            subtitle: Text('ID: ${item['id']}'),
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TodoDetailsPage(todo: item),
                  ),
                ),
          ),
        );
      },
    );
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TodoDetailsPage(
                  todo: {
                    'id': DateTime.now().millisecondsSinceEpoch,
                    'title': '',
                    'completed': false,
                  },
                  viewMode: ViewMode.create, // 傳遞一個參數來標記為編輯模式
                ),
          ),
        );

        if (result != null && result is Map<String, dynamic>) {
          // _lockScreen();
          _todoService.addTodo(result);
          await _loadInitialTodos(context);
          // _unlockScreen();
        }
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
