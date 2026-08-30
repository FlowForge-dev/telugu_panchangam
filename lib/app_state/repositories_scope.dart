import '../data/mock/mock_devotional_repository.dart';
import '../data/mock/mock_festival_repository.dart';
import '../data/mock/mock_jatakam_repository.dart';
import '../data/mock/mock_japa_repository.dart';
import '../data/mock/mock_panchang_repository.dart';
import '../data/mock/mock_profile_repository.dart';
import '../data/mock/mock_reminder_repository.dart';
import '../data/mock/mock_vrata_repository.dart';
import '../domain/repositories/repositories.dart';

/// Composition root for repositories. Screens depend on the interfaces
/// in `domain/repositories` via this bundle rather than importing a
/// mock implementation directly, so swapping in a real backend later is
/// a one-file change.
class Repositories {
  Repositories({
    required this.panchang,
    required this.festival,
    required this.profile,
    required this.jatakam,
    required this.japa,
    required this.reminder,
    required this.vrata,
    required this.devotional,
  });

  factory Repositories.mock() => Repositories(
        panchang: MockPanchangRepository(),
        festival: MockFestivalRepository(),
        profile: MockProfileRepository(),
        jatakam: MockJatakamRepository(),
        japa: MockJapaRepository(),
        reminder: MockReminderRepository(),
        vrata: MockVrataRepository(),
        devotional: MockDevotionalRepository(),
      );

  final PanchangRepository panchang;
  final FestivalRepository festival;
  final ProfileRepository profile;
  final JatakamRepository jatakam;
  final JapaRepository japa;
  final ReminderRepository reminder;
  final VrataRepository vrata;
  final DevotionalRepository devotional;
}
