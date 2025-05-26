import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/components/menus/circle_menu_bg_painter.dart';

void main() {
  group('CircleMenuBgPainter float compare', () {
    final painter = CircleMenuBgPainter(
      itemCount: 3,
      color: const Color(0xFF000000),
      menuLabels: const ['A', 'B', 'C'],
      arcStart: 0.0,
    );

    test('nearlyEqual returns true for close values', () {
      expect(painter.nearlyEqual(1.000001, 1.000002), isTrue);
      expect(painter.nearlyEqual(1.0, 1.0), isTrue);
      expect(painter.nearlyEqual(1.0, 1.0001), isFalse);
    });

    test('greaterOrNearlyEqual returns true for greater or nearly equal', () {
      expect(painter.greaterOrNearlyEqual(2.0, 1.999999), isTrue);
      expect(painter.greaterOrNearlyEqual(2.0, 2.0), isTrue);
      expect(painter.greaterOrNearlyEqual(1.0, 2.0), isFalse);
    });

    test('lessOrNearlyEqual returns true for less or nearly equal', () {
      expect(painter.lessOrNearlyEqual(1.999999, 2.0), isTrue);
      expect(painter.lessOrNearlyEqual(2.0, 2.0), isTrue);
      expect(painter.lessOrNearlyEqual(3.0, 2.0), isFalse);
    });

    test('strictlyGreater returns true only if strictly greater', () {
      expect(painter.strictlyGreater(2.0, 1.0), isTrue);
      expect(painter.strictlyGreater(2.0, 1.9999), isTrue); // 差距大於 epsilon
      expect(painter.strictlyGreater(2.0, 2.0), isFalse);
      expect(painter.strictlyGreater(2.0, 1.99999), isFalse); // 差距小於 epsilon
    });

    test('strictlyLess returns true only if strictly less', () {
      expect(painter.strictlyLess(1.0, 2.0), isTrue);
      expect(painter.strictlyLess(1.9999, 2.0), isTrue); // 差距大於 epsilon
      expect(painter.strictlyLess(2.0, 2.0), isFalse);
      expect(painter.strictlyLess(1.99999, 2.0), isFalse); // 差距小於 epsilon
    });
  });
}
