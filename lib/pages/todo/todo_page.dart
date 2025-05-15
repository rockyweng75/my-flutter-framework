import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:my_flutter_framework/database/todo_repository.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/pages/todo/todo_details_page.dart';
import 'package:my_flutter_framework/pages/todo/todo_list_page.dart';
import 'package:my_flutter_framework/shared/components/tutorial/gesture_type.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_button.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';
import 'package:my_flutter_framework/shared/pages/simple_form_page.dart';
import 'package:my_flutter_framework/shared/pages/simple_list_page.dart';
import 'package:my_flutter_framework/shared/pages/simple_query_form_page.dart';
import 'package:my_flutter_framework/styles/app_color.dart';

class TodoPage extends ConsumerStatefulWidget {
  const TodoPage({super.key});

  @override
  ConsumerState<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends MainLayoutPage<TodoPage> {
  final Logger _logger = Logger();
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  List<Map<String, dynamic>> _todos = [];
  bool _isLoading = false;
  bool _hasNextPage = true;
  bool _isScreenLocked = false;

  // 教學導引元件 key
  final GlobalKey _addButtonKey = GlobalKey(debugLabel: 'addButton');

  @override
  void initState() {
    super.initState();
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
    setState(() {
      _isLoading = true;
    });
    final todos = await TodoRepository.getAllTodos(page: 1, pageSize: 8);
    setState(() {
      _todos = todos.map((e) => e.toJson()).toList();
      _currentPage = 1;
      _hasNextPage = todos.length == 8;
      _isLoading = false;
    });
  }

  Future<void> _loadMoreTodos(
    context,
    Map<String, dynamic>? queryParameters,
  ) async {
    if (_isLoading || !_hasNextPage) return;
    setState(() {
      _isLoading = true;
    });
    final nextPage = _currentPage + 1;
    final todos = await TodoRepository.getAllTodos(page: nextPage, pageSize: 8);
    setState(() {
      _todos.addAll(todos.map((e) => e.toJson()));
      _currentPage = nextPage;
      _hasNextPage = todos.length == 8;
      _isLoading = false;
    });
  }

  @override
  Widget buildContent(BuildContext context) {
    // 註冊教學元件 key
    globalWidgetRegistry['addButton'] = _addButtonKey;

    return TodoListPage(
      items: _todos,
      scrollController: _scrollController,
      isLoading: _isLoading,
      isScreenLocked: _isScreenLocked,
      onLoadMore: (params) => _loadMoreTodos(context, params),
      onItemTap: (todo) async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TodoDetailsPage(todo: todo, id: todo['id']),
          ),
        );
        _logger.d('result: $result');
        if (result != null &&
            result is Map<String, dynamic> &&
            result['id'] != null) {
          // 單筆更新：找到 id 相同的 todo，直接更新
          final idx = _todos.indexWhere((t) => t['id'] == result['id']);
          if (idx != -1) {
            if (mounted) {
              setState(() {
                _todos[idx] = Map<String, dynamic>.from(result);
                _todos = List<Map<String, dynamic>>.from(_todos); // 強制刷新
              });
            }
          } else {
            // 若找不到，代表是新增，直接刷新全部
            if (mounted) {
              await _loadInitialTodos(context);
            }
          }
        }
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
              item['status'] == 'done' ? Icons.check_circle : Icons.circle,
              color:
                  item['status'] == 'done' ? AppColor.success : AppColor.info,
            ),
            title: Text(
              item['title'],
              style: TextStyle(
                decoration:
                    item['status'] == 'done'
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
              ),
            ),
            subtitle: Text('ID: ${item['id']}'),
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TodoDetailsPage(todo: item, id: item['id']),
                ),
              );
              _logger.d('result: $result');
              if (result != null &&
                  result is Map<String, dynamic> &&
                  result['id'] != null) {
                final idx = _todos.indexWhere((t) => t['id'] == result['id']);
                if (idx != -1) {
                  if (mounted) {
                    setState(() {
                      _todos[idx] = Map<String, dynamic>.from(result);
                      _todos = List<Map<String, dynamic>>.from(_todos);
                    });
                  }
                } else {
                  if (mounted) {
                    await _loadInitialTodos(context);
                  }
                }
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget? buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      key: _addButtonKey,
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => TodoDetailsPage(
                  todo: {
                    'id': 0,
                    'title': '',
                    'startTime': DateTime.now().toIso8601String(),
                    'endTime': DateTime.now().toIso8601String(),
                    'status': 'open',
                  },
                  id: 0,
                  viewMode: ViewMode.create, // 傳遞一個參數來標記為編輯模式
                ),
          ),
        );
        if (result != null && result is Map<String, dynamic>) {
          // 新增或編輯成功後自動刷新列表
          await _loadInitialTodos(context);
        }
      },
      child: const Icon(Icons.add),
    );
  }

  @override
  List<TutorialStep>? getTutorialSteps(BuildContext context) {
    final listSteps = SimpleListPage.tutorialSteps;
    final querySteps = SimpleQueryFormPage.tutorialSteps;
    return [
      ...tutorialSteps,
      ...listSteps,
      ...querySteps,
    ];
  }

  final List<TutorialStep> tutorialSteps = [
    TutorialStep(
      title: '新增任務',
      description: '點擊右下角的按鈕來新增任務。',
      targetWidgetId: 'addButton',
      gestureType: GestureType.tap,
    )
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
