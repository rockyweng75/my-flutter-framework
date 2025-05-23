import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/paginated_response.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/api/todos/itodo_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_flutter_framework/shared/utils/transaction_manager.dart';
import 'package:my_flutter_framework/shared/pages/swipe_card_list.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends MainLayoutPage<DashboardPage> {
  late final ITodoService _todoService;
  int _completedTodos = 0;
  int _incompleteTodos = 0;
  List<Map<String, dynamic>> _todayTodoList = [];

  @override
  void initState() {
    super.initState();
    _todoService = ref.read(todoServiceProvider);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _fetchTodoCounts();
    });
  }

  Future<void> _fetchTodoCounts() async {
    TransactionManager transactionManager = TransactionManager(context);
    final todos = await transactionManager
        .execute<PaginatedResponse<Map<String, dynamic>>>(() async {
          return await _todoService.getTodos(page: 1, pageSize: 100);
        });
    if (!mounted) return; // 確保 widget 仍在 widget tree 中
    if (todos == null) return; // 確保 todos 不為 null
    final today = DateTime.now();
    setState(() {
      _completedTodos =
          todos.data.where((todo) => todo['completed'] == true).length;
      _incompleteTodos =
          todos.data.where((todo) => todo['completed'] == false).length;
      _todayTodoList =
          todos.data.where((todo) {
            final dueDate = todo['dueDate'];
            if (dueDate == null) return false;
            final due = DateTime.tryParse(dueDate);
            if (due == null) return false;
            return due.year == today.year &&
                due.month == today.month &&
                due.day == today.day;
          }).toList();
    });
  }

  List<BarChartGroupData> _generateBarGroups() {
    final Map<String, int> todosByDate = {};

    // Simulate fetching todos and grouping by completion date
    final todos = [
      {
        'completedDate': '2025-05-01',
        'completedCount': 3,
        'incompletedCount': 2,
      },
      {
        'completedDate': '2025-05-02',
        'completedCount': 1,
        'incompletedCount': 1,
      },
      {
        'completedDate': '2025-05-03',
        'completedCount': 1,
        'incompletedCount': 3,
      },
    ];

    for (var todo in todos) {
      final String date = todo['completedDate'] as String;
      final int count = (todo['completedCount'] as num).toInt();
      todosByDate[date] = (todosByDate[date] ?? 0) + count;
    }

    final barGroups = <BarChartGroupData>[];
    todos.forEach((value) {
      final date = value['completedDate'] as String;
      final completedCount = (value['completedCount'] as num).toInt();
      final incompletedCount = (value['incompletedCount'] as num).toInt();

      barGroups.add(
        BarChartGroupData(
          x: int.parse(date.split('-')[2]), // 取出日期的日部分作為 x 軸
          barRods: [
            BarChartRodData(
              toY: completedCount.toDouble(),
              color: Colors.green,
              width: 16,
            ),
            BarChartRodData(
              toY: incompletedCount.toDouble(),
              color: Colors.red,
              width: 16,
            ),
          ],
        ),
      );
    });
    return barGroups;
  }

  @override
  Widget buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.green[100],
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Completed Todos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$_completedTodos',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: Colors.red[100],
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Incomplete Todos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '$_incompleteTodos',
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Todo Chart',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.linear,
                      BarChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 1, // 設置 y 軸的最小單位為整數
                        ),
                        titlesData: FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                if (value % 1 == 0) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40, // 自適應寬度，增加 reservedSize
                              getTitlesWidget: (value, meta) {
                                final dateLabels = [
                                  '05-01',
                                  '05-02',
                                  '05-03',
                                ]; // 改為顯示月日
                                if (value.toInt() >= 1 &&
                                    value.toInt() <= dateLabels.length) {
                                  return Text(
                                    dateLabels[value.toInt() - 1],
                                    style: const TextStyle(fontSize: 10),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        barGroups: _generateBarGroups(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Image Slider',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = constraints.maxWidth < 600;
                      return CarouselSlider(
                        options: CarouselOptions(
                          height: isMobile ? 150.0 : 200.0, // 手機版高度調整
                          autoPlay: true,
                          enlargeCenterPage: true,
                        ),
                        items:
                            [
                              'assets/images/image1.jpeg',
                              'assets/images/image2.jpeg',
                              'assets/images/image3.jpeg',
                            ].map((imagePath) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return Image.asset(
                                    imagePath,
                                    fit: BoxFit.cover,
                                  );
                                },
                              );
                            }).toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '今日待辦清單',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  SwipeCardList(
                    items: _todayTodoList,
                    onConfirm: (item) async {
                      await _todoService.updateTodo(item['id'], {
                        'completed': true,
                      });
                      await _fetchTodoCounts();
                    },
                    onCancel: (item) async {
                      await _todoService.deleteTodo(item['id']);
                      await _fetchTodoCounts();
                    },
                    emptyText: '今日無待辦事項',
                    buildContent: (item) => Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['title'] ?? '無標題',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (item['description'] != null &&
                                  item['description'].toString().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    item['description'],
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Positioned(
                          right: 12,
                          bottom: 8,
                          child: Text(
                            item['dueDate'] != null
                                ? '截止日期: ${item['dueDate']}'
                                : '無截止日期',
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/todo');
            },
            child: const Text('Go to Todo Page'),
          ),
        ],
      ),
    );
  }
}
