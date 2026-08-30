import 'source_reference.dart';

/// A recurring fasting/observance day (Ekadashi, Sankashti, Pradosha, ...).
/// Distinct from [Festival] — a vrata typically recurs multiple times a
/// year on a Tithi rather than being a single annual calendar date.
class VrataObservance {
  const VrataObservance({
    required this.id,
    required this.name,
    required this.teluguName,
    required this.recurrence,
    required this.shortInfo,
    required this.source,
  });

  final String id;
  final String name;
  final String teluguName;

  /// Plain-language recurrence description, e.g. "Every Ekadashi tithi".
  final String recurrence;
  final String shortInfo;
  final SourceReference source;
}
