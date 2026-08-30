import '../../domain/models/devotional_models.dart';
import '../../domain/repositories/repositories.dart';
import 'mock_seed_data.dart';

class MockDevotionalRepository implements DevotionalRepository {
  @override
  Future<List<DevotionalText>> all() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return mockDevotionalTexts;
  }

  @override
  Future<DevotionalText?> byId(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return mockDevotionalTexts.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
