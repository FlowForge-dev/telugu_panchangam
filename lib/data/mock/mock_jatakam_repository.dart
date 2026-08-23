import '../../domain/models/jatakam_models.dart';
import '../../domain/models/profile_models.dart';
import '../../domain/repositories/repositories.dart';

/// Produces a deterministic, plausible-looking birth chart from the
/// given birth details so the same input always yields the same mock
/// chart during development. This is NOT a real ephemeris-based
/// Jyotisha calculation — see [Jatakam.isMockCalculated].
class MockJatakamRepository implements JatakamRepository {
  @override
  Future<Jatakam> computeFor(BirthDetails details) async {
    await Future.delayed(const Duration(milliseconds: 350));

    final seed = details.date.millisecondsSinceEpoch ~/ 60000 + details.time.hour * 61 + details.time.minute;

    final lagnaIndex = seed % 12;
    final moonRashiIndex = (seed ~/ 3 + 4) % 12;
    final nakshatraIndex = (seed ~/ 5 + 2) % 27;
    final pada = (seed % 4) + 1;

    final lagna = Rashi.all[lagnaIndex];
    final moonRashi = Rashi.all[moonRashiIndex];
    final nakshatra = Nakshatra.all[nakshatraIndex];

    final positions = <GrahaPosition>[];
    for (var i = 0; i < Graha.values.length; i++) {
      final graha = Graha.values[i];
      final rashiIndex = (seed ~/ (i + 2) + i * 2) % 12;
      final house = ((rashiIndex - lagnaIndex) % 12 + 12) % 12 + 1;
      final degree = ((seed * (i + 3)) % 300) / 10.0;
      final nakIndex = (nakshatraIndex + i * 3) % 27;
      positions.add(GrahaPosition(
        graha: graha,
        rashi: Rashi.all[rashiIndex],
        house: house,
        degree: degree,
        isRetrograde: graha != Graha.surya && graha != Graha.chandra && (seed + i) % 5 == 0,
        nakshatra: Nakshatra.all[nakIndex],
        pada: (seed + i) % 4 + 1,
      ));
    }

    return Jatakam(
      moonRashi: moonRashi,
      birthNakshatra: nakshatra,
      birthNakshatraPada: pada,
      lagna: lagna,
      grahaPositions: positions,
    );
  }
}
