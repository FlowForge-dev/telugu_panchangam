import '../../domain/models/festival_models.dart';
import '../../domain/repositories/repositories.dart';
import 'mock_seed_data.dart';

class MockFestivalRepository implements FestivalRepository {
  @override
  Future<List<Festival>> all() async {
    await Future.delayed(const Duration(milliseconds: 150));
    final list = List<Festival>.from(mockFestivals)..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  @override
  Future<Festival?> byId(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return mockFestivals.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Festival?> nextUpcoming({DateTime? from}) async {
    final ref = from ?? DateTime.now();
    final list = await upcoming(from: ref, limit: 1);
    return list.isEmpty ? null : list.first;
  }

  @override
  Future<List<Festival>> upcoming({DateTime? from, int limit = 10}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final ref = DateTime(from?.year ?? DateTime.now().year, from?.month ?? DateTime.now().month, from?.day ?? DateTime.now().day);
    final list = mockFestivals.where((f) => !f.date.isBefore(ref)).toList()..sort((a, b) => a.date.compareTo(b.date));
    return list.take(limit).toList();
  }

  @override
  Future<List<Festival>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 120));
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return mockFestivals
        .where((f) => f.name.toLowerCase().contains(q) || f.teluguName.contains(query.trim()) || f.shortSignificance.toLowerCase().contains(q))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
