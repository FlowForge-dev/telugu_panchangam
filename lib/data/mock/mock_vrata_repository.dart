import '../../domain/models/vrata_models.dart';
import '../../domain/repositories/repositories.dart';
import 'mock_seed_data.dart';

class MockVrataRepository implements VrataRepository {
  @override
  Future<List<VrataObservance>> all() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return mockVrataObservances;
  }
}
