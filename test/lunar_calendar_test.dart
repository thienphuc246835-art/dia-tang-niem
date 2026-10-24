import 'package:dia_tang_niem/core/utils/lunar_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LunarCalendar.fromSolar', () {
    test('Tết Nguyên Đán', () {
      expect(
        LunarCalendar.fromSolar(DateTime(2024, 2, 10)),
        const LunarDate(1, 1, 2024),
      );
      expect(
        LunarCalendar.fromSolar(DateTime(2025, 1, 29)),
        const LunarDate(1, 1, 2025),
      );
      expect(
        LunarCalendar.fromSolar(DateTime(2026, 2, 17)),
        const LunarDate(1, 1, 2026),
      );
    });

    test('day before Tết belongs to the previous lunar year', () {
      final d = LunarCalendar.fromSolar(DateTime(2026, 2, 16));
      expect(d.year, 2025);
      expect(d.month, 12);
    });

    test('leap month 2 of Quý Mão (2023)', () {
      final d = LunarCalendar.fromSolar(DateTime(2023, 3, 22));
      expect(d, const LunarDate(1, 2, 2023, isLeap: true));
    });

    test('month length is 29 or 30', () {
      for (var i = 0; i < 400; i += 7) {
        final d = LunarCalendar.fromSolar(
          DateTime(2026, 1, 1).add(Duration(days: i)),
        );
        expect(d.monthLength, anyOf(29, 30));
      }
    });

    test('can chi of the year', () {
      expect(const LunarDate(1, 1, 2026).yearName, 'Bính Ngọ');
      expect(const LunarDate(1, 1, 2025).yearName, 'Ất Tỵ');
    });
  });

  group('LunarCalendar.toSolar', () {
    test('round-trips every day of 2026', () {
      for (var i = 0; i < 365; i++) {
        final solar = DateTime(2026, 1, 1).add(Duration(days: i));
        final lunar = LunarCalendar.fromSolar(solar);
        expect(
          LunarCalendar.toSolar(
            lunar.day,
            lunar.month,
            lunar.year,
            isLeap: lunar.isLeap,
          ),
          solar,
          reason: 'lunar $lunar',
        );
      }
    });

    test('rejects a leap month the year does not have', () {
      expect(LunarCalendar.toSolar(1, 5, 2026, isLeap: true), isNull);
    });
  });

  group('practice days', () {
    test('Thập Trai follows Phẩm 6', () {
      expect(thapTraiDays, [1, 8, 14, 15, 18, 23, 24, 28, 29, 30]);
      expect(isThapTrai(const LunarDate(18, 3, 2026)), isTrue);
      expect(isThapTrai(const LunarDate(16, 3, 2026)), isFalse);
    });

    test('vía Địa Tạng is 30/7, or 29/7 in a short month', () {
      expect(
        isViaDiaTang(const LunarDate(30, 7, 2026, monthLength: 30)),
        isTrue,
      );
      expect(
        isViaDiaTang(const LunarDate(29, 7, 2026, monthLength: 30)),
        isFalse,
      );
      expect(
        isViaDiaTang(const LunarDate(29, 7, 2026, monthLength: 29)),
        isTrue,
      );
      expect(isViaDiaTang(const LunarDate(30, 7, 2026, isLeap: true)), isFalse);
    });
  });
}
