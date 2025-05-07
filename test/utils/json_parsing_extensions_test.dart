import 'package:flutter_test/flutter_test.dart';
import 'package:my_flutter_framework/shared/utils/json_parsing_extensions.dart';

void main() {
  group('JsonParsingExtensions', () {
    test('toInt should parse valid int strings', () {
      expect('123'.toInt(), 123);
      expect('0'.toInt(), 0);
    });

    test('toInt should return fallback for invalid int strings', () {
      expect('abc'.toInt(42), 42);
      expect(null.toInt(42), 42);
    });

    test('toDouble should parse valid double strings', () {
      expect('123.45'.toDouble(), 123.45);
      expect('0'.toDouble(), 0.0);
    });

    test('toDouble should return fallback for invalid double strings', () {
      expect('abc'.toDouble(42.0), 42.0);
      expect(null.toDouble(42.0), 42.0);
    });

    test('toStringValue should return string representation', () {
      expect(123.toStringValue(), '123');
      expect(null.toStringValue('fallback'), 'fallback');
    });

    test('toBool should parse valid boolean values', () {
      expect('true'.toBool(), true);
      expect('false'.toBool(), false);
      expect(1.toBool(), true);
      expect(0.toBool(), false);
    });

    test('toBool should return fallback for invalid boolean values', () {
      expect('abc'.toBool(true), true);
      expect(null.toBool(true), true);
    });
  });
}