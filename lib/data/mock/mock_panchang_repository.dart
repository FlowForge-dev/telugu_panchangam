import '../../domain/models/panchang_models.dart';
import '../../domain/repositories/repositories.dart';
import 'mock_seed_data.dart';

class MockPanchangRepository implements PanchangRepository {
  @override
  Future<DateTime> ugadiStartFor(DateTime withinGregorianYear) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return kMockUgadiStart;
  }

  @override
  Future<PanchangSummary> summaryFor(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 180));
    final day = generateMockPanchangDay(date);
    return PanchangSummary(
      date: day.date,
      vara: day.vara,
      masa: day.masa,
      paksha: day.paksha,
      tithi: day.tithi,
      nakshatra: day.nakshatra,
      sunrise: day.sunrise,
      sunset: day.sunset,
      isMockCalculated: day.isMockCalculated,
    );
  }

  @override
  Future<PanchangDay> dayDetail(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return generateMockPanchangDay(date);
  }

  @override
  Future<Map<DateTime, PanchangDay>> monthRange(DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final map = <DateTime, PanchangDay>{};
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      map[cursor] = generateMockPanchangDay(cursor);
      cursor = cursor.add(const Duration(days: 1));
    }
    return map;
  }
}
