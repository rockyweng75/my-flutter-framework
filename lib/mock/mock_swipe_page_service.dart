
import 'package:my_flutter_framework/api/swipePage/i_swipe_page_service.dart';

class MockSwipePageService implements ISwipePageService {
  int mockCount = 3;
  final int loadStep = 3;
  MockSwipePageService();

  @override
  Future<int> getPageCount() async {
    // 模擬網路延遲
    await Future.delayed(const Duration(milliseconds: 300));
    return mockCount;
  }

  @override
  Future<int> loadMorePages() async {
    await Future.delayed(const Duration(milliseconds: 300));
    mockCount += loadStep;
    return mockCount;
  }
}
