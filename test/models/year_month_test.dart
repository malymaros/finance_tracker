import 'package:flutter_test/flutter_test.dart';
import 'package:finance_tracker/models/year_month.dart';

void main() {
  group('YearMonth comparison', () {
    test('equal when year and month match', () {
      expect(YearMonth(2024, 3), equals(YearMonth(2024, 3)));
    });

    test('isBefore when year is earlier', () {
      expect(YearMonth(2023, 12).isBefore(YearMonth(2024, 1)), isTrue);
    });

    test('isBefore when same year but earlier month', () {
      expect(YearMonth(2024, 2).isBefore(YearMonth(2024, 3)), isTrue);
    });

    test('isAfter when year is later', () {
      expect(YearMonth(2025, 1).isAfter(YearMonth(2024, 12)), isTrue);
    });

    test('isAtOrBefore includes equal', () {
      expect(YearMonth(2024, 3).isAtOrBefore(YearMonth(2024, 3)), isTrue);
    });

    test('isAtOrAfter includes equal', () {
      expect(YearMonth(2024, 3).isAtOrAfter(YearMonth(2024, 3)), isTrue);
    });

    test('compareTo returns 0 for equal', () {
      expect(YearMonth(2024, 6).compareTo(YearMonth(2024, 6)), 0);
    });

    test('compareTo returns negative when before', () {
      expect(YearMonth(2024, 1).compareTo(YearMonth(2024, 6)), isNegative);
    });
  });

  group('YearMonth.addMonths', () {
    test('adds positive months within year', () {
      expect(YearMonth(2024, 3).addMonths(2), equals(YearMonth(2024, 5)));
    });

    test('wraps forward across year boundary', () {
      expect(YearMonth(2024, 11).addMonths(3), equals(YearMonth(2025, 2)));
    });

    test('wraps backward across year boundary', () {
      expect(YearMonth(2024, 1).addMonths(-1), equals(YearMonth(2023, 12)));
    });

    test('subtracts within year', () {
      expect(YearMonth(2024, 6).addMonths(-3), equals(YearMonth(2024, 3)));
    });

    test('adding zero returns same month', () {
      expect(YearMonth(2024, 6).addMonths(0), equals(YearMonth(2024, 6)));
    });

    test('wraps from December forward', () {
      expect(YearMonth(2024, 12).addMonths(1), equals(YearMonth(2025, 1)));
    });

    test('large addition', () {
      expect(YearMonth(2024, 1).addMonths(13), equals(YearMonth(2025, 2)));
    });
  });

  group('YearMonth serialization', () {
    test('toJson and fromJson round-trip', () {
      final original = YearMonth(2024, 11);
      final restored = YearMonth.fromJson(original.toJson());
      expect(restored, equals(original));
    });

    test('toString formats correctly', () {
      expect(YearMonth(2024, 3).toString(), '2024-03');
      expect(YearMonth(2024, 12).toString(), '2024-12');
    });
  });

  group('YearMonth.monthNames', () {
    test('has 13 entries (index 0 is empty sentinel)', () {
      expect(YearMonth.monthNames.length, 13);
    });

    test('index 0 is empty string', () {
      expect(YearMonth.monthNames[0], '');
    });

    test('index 1 is January', () {
      expect(YearMonth.monthNames[1], 'January');
    });

    test('index 12 is December', () {
      expect(YearMonth.monthNames[12], 'December');
    });

    test('all months are present in order', () {
      const expected = [
        '', 'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      expect(YearMonth.monthNames, expected);
    });
  });

  group('YearMonth.monthAbbreviations', () {
    test('has 13 entries (index 0 is empty sentinel)', () {
      expect(YearMonth.monthAbbreviations.length, 13);
    });

    test('index 0 is empty string', () {
      expect(YearMonth.monthAbbreviations[0], '');
    });

    test('index 1 is Jan', () {
      expect(YearMonth.monthAbbreviations[1], 'Jan');
    });

    test('index 12 is Dec', () {
      expect(YearMonth.monthAbbreviations[12], 'Dec');
    });

    test('all abbreviations are 3 characters (except sentinel)', () {
      for (int i = 1; i <= 12; i++) {
        expect(YearMonth.monthAbbreviations[i].length, 3,
            reason: 'index $i should be 3 chars');
      }
    });

    test('abbreviations are prefixes of full names', () {
      for (int i = 1; i <= 12; i++) {
        expect(
          YearMonth.monthNames[i].startsWith(YearMonth.monthAbbreviations[i]),
          isTrue,
          reason: 'monthNames[$i] should start with monthAbbreviations[$i]',
        );
      }
    });
  });
}
