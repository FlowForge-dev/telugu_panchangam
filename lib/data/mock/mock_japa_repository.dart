import '../../domain/models/jatakam_models.dart';
import '../../domain/repositories/repositories.dart';
import 'mock_seed_data.dart';

class MockJapaRepository implements JapaRepository {
  @override
  Future<List<JapaRecommendation>> recommendationsFor(Jatakam jatakam) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // A real engine would tailor this list to the chart; the mock
    // simply returns the general list to keep the data path realistic.
    return mockJapaRecommendations;
  }

  @override
  Future<List<JapaRecommendation>> general() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return mockJapaRecommendations;
  }
}
