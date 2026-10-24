import 'dart:math' as math;

/// Vietnamese lunar calendar (UTC+7), after Hồ Ngọc Đức's public algorithm
/// ("Âm lịch Việt Nam"). All dates are civil dates; time of day is ignored.
class LunarDate {
  const LunarDate(
    this.day,
    this.month,
    this.year, {
    this.isLeap = false,
    this.monthLength = 30,
  });

  final int day;
  final int month;
  final int year;
  final bool isLeap;

  /// 29 (tháng thiếu) or 30 (tháng đủ).
  final int monthLength;

  static const _can = [
    'Giáp',
    'Ất',
    'Bính',
    'Đinh',
    'Mậu',
    'Kỷ',
    'Canh',
    'Tân',
    'Nhâm',
    'Quý',
  ];
  static const _chi = [
    'Tý',
    'Sửu',
    'Dần',
    'Mão',
    'Thìn',
    'Tỵ',
    'Ngọ',
    'Mùi',
    'Thân',
    'Dậu',
    'Tuất',
    'Hợi',
  ];

  String get yearName => '${_can[(year + 6) % 10]} ${_chi[(year + 8) % 12]}';

  @override
  bool operator ==(Object other) =>
      other is LunarDate &&
      other.day == day &&
      other.month == month &&
      other.year == year &&
      other.isLeap == isLeap;

  @override
  int get hashCode => Object.hash(day, month, year, isLeap);

  @override
  String toString() => '$day/$month${isLeap ? 'N' : ''}/$year';
}

abstract final class LunarCalendar {
  static const double _tz = 7.0;

  static int _floor(double x) => x.floor();

  static int jdFromDate(int dd, int mm, int yy) {
    final a = (14 - mm) ~/ 12;
    final y = yy + 4800 - a;
    final m = mm + 12 * a - 3;
    var jd =
        dd +
        (153 * m + 2) ~/ 5 +
        365 * y +
        y ~/ 4 -
        y ~/ 100 +
        y ~/ 400 -
        32045;
    if (jd < 2299161) {
      jd = dd + (153 * m + 2) ~/ 5 + 365 * y + y ~/ 4 - 32083;
    }
    return jd;
  }

  static DateTime jdToDate(int jd) {
    int b, c;
    if (jd > 2299160) {
      final a = jd + 32044;
      b = (4 * a + 3) ~/ 146097;
      c = a - (b * 146097) ~/ 4;
    } else {
      b = 0;
      c = jd + 32082;
    }
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;
    final day = e - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = b * 100 + d - 4800 + m ~/ 10;
    return DateTime(year, month, day);
  }

  static double _newMoon(int k) {
    final t = k / 1236.85;
    final t2 = t * t;
    final t3 = t2 * t;
    const dr = math.pi / 180;
    var jd1 =
        2415020.75933 + 29.53058868 * k + 0.0001178 * t2 - 0.000000155 * t3;
    jd1 += 0.00033 * math.sin((166.56 + 132.87 * t - 0.009173 * t2) * dr);
    final m = 359.2242 + 29.10535608 * k - 0.0000333 * t2 - 0.00000347 * t3;
    final mpr = 306.0253 + 385.81691806 * k + 0.0107306 * t2 + 0.00001236 * t3;
    final f = 21.2964 + 390.67050646 * k - 0.0016528 * t2 - 0.00000239 * t3;
    var c1 =
        (0.1734 - 0.000393 * t) * math.sin(m * dr) +
        0.0021 * math.sin(2 * dr * m);
    c1 = c1 - 0.4068 * math.sin(mpr * dr) + 0.0161 * math.sin(dr * 2 * mpr);
    c1 = c1 - 0.0004 * math.sin(dr * 3 * mpr);
    c1 = c1 + 0.0104 * math.sin(dr * 2 * f) - 0.0051 * math.sin(dr * (m + mpr));
    c1 =
        c1 -
        0.0074 * math.sin(dr * (m - mpr)) +
        0.0004 * math.sin(dr * (2 * f + m));
    c1 =
        c1 -
        0.0004 * math.sin(dr * (2 * f - m)) -
        0.0006 * math.sin(dr * (2 * f + mpr));
    c1 =
        c1 +
        0.0010 * math.sin(dr * (2 * f - mpr)) +
        0.0005 * math.sin(dr * (2 * mpr + m));
    double deltat;
    if (t < -11) {
      deltat =
          0.001 +
          0.000839 * t +
          0.0002261 * t2 -
          0.00000845 * t3 -
          0.000000081 * t * t3;
    } else {
      deltat = -0.000278 + 0.000265 * t + 0.000262 * t2;
    }
    return jd1 + c1 - deltat;
  }

  static int _newMoonDay(int k) => _floor(_newMoon(k) + 0.5 + _tz / 24);

  static double _sunLongitudeRad(double jdn) {
    final t = (jdn - 2451545.0) / 36525;
    final t2 = t * t;
    const dr = math.pi / 180;
    final m =
        357.52910 + 35999.05030 * t - 0.0001559 * t2 - 0.00000048 * t * t2;
    final l0 = 280.46645 + 36000.76983 * t + 0.0003032 * t2;
    var dl = (1.914600 - 0.004817 * t - 0.000014 * t2) * math.sin(dr * m);
    dl +=
        (0.019993 - 0.000101 * t) * math.sin(dr * 2 * m) +
        0.000290 * math.sin(dr * 3 * m);
    var l = (l0 + dl) * dr;
    l = l - math.pi * 2 * _floor(l / (math.pi * 2));
    return l;
  }

  static int _sunLongitude(int dayNumber) =>
      _floor(_sunLongitudeRad(dayNumber - 0.5 - _tz / 24) / math.pi * 6);

  static int _lunarMonth11(int yy) {
    final off = jdFromDate(31, 12, yy) - 2415021;
    final k = _floor(off / 29.530588853);
    var nm = _newMoonDay(k);
    if (_sunLongitude(nm) >= 9) nm = _newMoonDay(k - 1);
    return nm;
  }

  static int _leapMonthOffset(int a11) {
    final k = _floor((a11 - 2415021.076998695) / 29.530588853 + 0.5);
    var last = 0;
    var i = 1;
    var arc = _sunLongitude(_newMoonDay(k + i));
    do {
      last = arc;
      i++;
      arc = _sunLongitude(_newMoonDay(k + i));
    } while (arc != last && i < 14);
    return i - 1;
  }

  static LunarDate fromSolar(DateTime date) {
    final dayNumber = jdFromDate(date.day, date.month, date.year);
    final k = _floor((dayNumber - 2415021.076998695) / 29.530588853);
    var monthStart = _newMoonDay(k + 1);
    var nextStart = _newMoonDay(k + 2);
    if (monthStart > dayNumber) {
      nextStart = monthStart;
      monthStart = _newMoonDay(k);
    }
    var a11 = _lunarMonth11(date.year);
    var b11 = a11;
    int lunarYear;
    if (a11 >= monthStart) {
      lunarYear = date.year;
      a11 = _lunarMonth11(date.year - 1);
    } else {
      lunarYear = date.year + 1;
      b11 = _lunarMonth11(date.year + 1);
    }
    final lunarDay = dayNumber - monthStart + 1;
    final diff = _floor((monthStart - a11) / 29);
    var isLeap = false;
    var lunarMonth = diff + 11;
    if (b11 - a11 > 365) {
      final leapMonthDiff = _leapMonthOffset(a11);
      if (diff >= leapMonthDiff) {
        lunarMonth = diff + 10;
        if (diff == leapMonthDiff) isLeap = true;
      }
    }
    if (lunarMonth > 12) lunarMonth -= 12;
    if (lunarMonth >= 11 && diff < 4) lunarYear -= 1;
    return LunarDate(
      lunarDay,
      lunarMonth,
      lunarYear,
      isLeap: isLeap,
      monthLength: nextStart - monthStart,
    );
  }

  /// Returns null when the date does not exist (e.g. a leap month that year doesn't have).
  static DateTime? toSolar(
    int lunarDay,
    int lunarMonth,
    int lunarYear, {
    bool isLeap = false,
  }) {
    int a11, b11;
    if (lunarMonth < 11) {
      a11 = _lunarMonth11(lunarYear - 1);
      b11 = _lunarMonth11(lunarYear);
    } else {
      a11 = _lunarMonth11(lunarYear);
      b11 = _lunarMonth11(lunarYear + 1);
    }
    final k = _floor(0.5 + (a11 - 2415021.076998695) / 29.530588853);
    var off = lunarMonth - 11;
    if (off < 0) off += 12;
    if (b11 - a11 > 365) {
      final leapOff = _leapMonthOffset(a11);
      var leapMonth = leapOff - 2;
      if (leapMonth < 0) leapMonth += 12;
      if (isLeap && lunarMonth != leapMonth) return null;
      if (isLeap || off >= leapOff) off += 1;
    } else if (isLeap) {
      return null;
    }
    final monthStart = _newMoonDay(k + off);
    final monthLength = _newMoonDay(k + off + 1) - monthStart;
    if (lunarDay < 1 || lunarDay > monthLength) return null;
    return jdToDate(monthStart + lunarDay - 1);
  }
}

/// Mười ngày trai — Kinh Địa Tạng, Phẩm 6 đoạn 12 (block q2.p6.s12.b1).
const thapTraiDays = [1, 8, 14, 15, 18, 23, 24, 28, 29, 30];

// TODO(buddhist-review): in a 29-day month there is no day 30; ask which day replaces it.
bool isThapTrai(LunarDate d) => thapTraiDays.contains(d.day);

/// Vía Đức Địa Tạng: 30/7 âm lịch; tháng 7 thiếu thì 29/7 (CLAUDE.md 3.2).
bool isViaDiaTang(LunarDate d) =>
    d.month == 7 &&
    !d.isLeap &&
    (d.day == 30 || (d.day == 29 && d.monthLength == 29));
