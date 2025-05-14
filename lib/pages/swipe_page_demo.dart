import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/swipePage/i_swipe_page_service.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/shared/components/swipe_page_view.dart';
import 'package:my_flutter_framework/shared/components/tutorial/gesture_type.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_button.dart';
import 'package:my_flutter_framework/shared/components/tutorial/tutorial_step.dart';
import 'package:my_flutter_framework/shared/utils/transaction_manager.dart';

class SwipePageDemo extends ConsumerStatefulWidget {
  const SwipePageDemo({super.key});

  @override
  ConsumerState<SwipePageDemo> createState() => _SwipePageDemoState();
}

class _SwipePageDemoState extends MainLayoutPage<SwipePageDemo> {
  late final PageController _pageController;
  late final ISwipePageService _pageService;
  int _pageCount = 3;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // 預設第二頁
    _pageService = ref.read(swipePageServiceProvider);
    // 註冊教學需要的 global key
    globalWidgetRegistry['swipePageDemo'] = GlobalKey();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPageCount();
    });
  }

  Future<void> _loadPageCount() async {
    await TransactionManager(context).execute(() async {
      final count = await _pageService.getPageCount();
      setState(() {
        _pageCount = count;
      });
    });
  }

  // String _pageKeyId(int index) {
  //   return 'swipePageView_${index.toString().padLeft(2, '0')}';
  // }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPage(Color color, String text) {
    return Container(
      // key: globalWidgetRegistry[_pageKeyId(_pageCount)],
      color: color,
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return SizedBox(
      height:
          MediaQuery.of(context).size.height - kToolbarHeight, // 減去 AppBar 高度
      child: SwipePageView(
        key: globalWidgetRegistry['swipePageDemo'], // 註冊 key
        controller: _pageController,
        pages: List.generate(
          _pageCount,
          (i) => i == 0
              ? Container(
                  // key: globalWidgetRegistry['swipePageDemo'], // 註冊 key
                  child: _buildPage(colors[i % colors.length], 'Page ${i + 1}'),
                )
              : _buildPage(colors[i % colors.length], 'Page ${i + 1}'),
        ),
        isLoadingMore: _isLoadingMore,
        onLoadMore: (currentPage) async {
          // 如果還有下一頁，先跳到下一頁
          if (currentPage < _pageCount - 1) {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
            return;
          }
          setState(() {
            _isLoadingMore = true;
          });

          final start = DateTime.now();
          final count = await _pageService.loadMorePages();
          final elapsed = DateTime.now().difference(start);
          final minDuration = const Duration(seconds: 1);

          if (elapsed < minDuration) {
            await Future.delayed(minDuration - elapsed);
          }
          setState(() {
            _pageCount = count;
            _isLoadingMore = false;
          });
          // 保持在原本頁面
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.jumpToPage(currentPage);
            }
          });
        },
      ),
    );
  }

  @override
  List<TutorialStep>? getTutorialSteps(BuildContext context) {
    return tutorialSteps;
  }

  final List<TutorialStep> tutorialSteps = [
    TutorialStep(
      title: 'Swipe Page Demo',
      description: '這是一個示範如何使用 SwipePageView 的頁面。',
      targetWidgetId: 'swipePageDemo',
      gestureType: GestureType.swipe,
    ),
    TutorialStep(
      title: 'Swipe Page View',
      description: '這是一個可滑動的頁面視圖，支援無限加載更多頁面。',
      targetWidgetId: 'swipePageDemo',
      gestureType: GestureType.swipeRight,
    ),
  ];
}
