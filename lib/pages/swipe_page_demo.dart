import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_flutter_framework/api/swipePage/i_swipe_page_service.dart';
import 'package:my_flutter_framework/pages/layout/main_layout_page.dart';
import 'package:my_flutter_framework/shared/components/swipe_page_view.dart';
import 'package:my_flutter_framework/shared/utils/transaction_manager.dart';

class SwipePageDemo extends ConsumerStatefulWidget {
  const SwipePageDemo({Key? key}) : super(key: key);

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildPage(Color color, String text) {
    return Container(
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
        controller: _pageController,
        pages: List.generate(
          _pageCount,
          (i) => _buildPage(colors[i % colors.length], 'Page ${i + 1}'),
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
}
