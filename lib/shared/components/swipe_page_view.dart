import 'package:flutter/material.dart';

typedef LoadMoreCallback = Future<void> Function(int currentPage);

class SwipePageView extends StatefulWidget {
  final List<Widget> pages;
  final PageController? controller;
  final LoadMoreCallback? onLoadMore;
  final bool isLoadingMore;

  const SwipePageView({
    super.key,
    required this.pages,
    this.controller,
    this.onLoadMore,
    this.isLoadingMore = false,
  });

  @override
  _SwipePageViewState createState() => _SwipePageViewState();
}

class _SwipePageViewState extends State<SwipePageView> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = widget.controller ?? PageController();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _pageController.dispose();
    }
    super.dispose();
  }

  Future<void> _onLoadMoreMiddleware(
    int currentPage, {
    bool isNext = false,
  }) async {
    if (widget.onLoadMore != null) {
      await widget.onLoadMore!(currentPage);
      if (isNext) {
        // 如果是往後滑，則頁數加一
        currentPage++;
      } else {
        // 如果是往前滑，則頁數減一
        if (currentPage > 0) {
          // 確保不會小於0
          currentPage--;
        }
      }
      // 保持在當前頁
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(currentPage);
        }
      });
    }
  }

  /// 建立 loading 頁面
  /// 可以覆寫此方法來自定義 loading 頁面
  /// 預設為灰階背景+圓形 loading
  Widget buildLoadingPage() {
    return Container(
      color: Colors.grey[400],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPages =
        widget.isLoadingMore ? widget.pages.length + 1 : widget.pages.length;

    return NotificationListener<ScrollEndNotification>(
      onNotification: (notification) {
        if (notification.metrics is PageMetrics) {
          final metrics = notification.metrics as PageMetrics;
          // 往後滑到最後一頁時觸發 onLoadMore
          if (!widget.isLoadingMore &&
              widget.onLoadMore != null &&
              metrics.page != null &&
              metrics.page!.round() == widget.pages.length - 1) {
            final currentPage = metrics.page!.round();
            _onLoadMoreMiddleware(currentPage, isNext: true);
          }
          // 往前滑到第一頁時觸發 onLoadMore
          if (!widget.isLoadingMore &&
              widget.onLoadMore != null &&
              metrics.page != null &&
              metrics.page!.round() == 0) {
            final currentPage = metrics.page!.round();
            _onLoadMoreMiddleware(currentPage, isNext: false);
          }
        }
        return false;
      },
      child: PageView.builder(
        controller: _pageController,
        itemCount: totalPages,
        itemBuilder: (context, i) {
          if (i < widget.pages.length) {
            return widget.pages[i];
          } else {
            // loading page
            return buildLoadingPage();
          }
        },
      ),
    );
  }
}
