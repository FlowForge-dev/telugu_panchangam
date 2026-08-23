/// Provenance model for any religious/astrological claim shown in the
/// app (mantra, festival rule, Jyotisha statement). Treated as a
/// first-class feature, not an afterthought — every [JapaRecommendation]
/// and festival mantra section should carry one of these.
enum VerificationStatus {
  /// Content has been checked against the cited source by an editor.
  verified,

  /// Content is present in the UI as a structural placeholder only and
  /// must not be treated as authoritative. Always paired with the
  /// literal marker text "[VERIFIED CONTENT REQUIRED]" or
  /// "[AUTHORITATIVE SOURCE REQUIRED]" in the surfaced copy.
  pendingVerification,

  /// Multiple traditions/sampradayas differ; shown with a note.
  variesByTradition,
}

class SourceReference {
  const SourceReference({
    required this.title,
    this.sectionOrChapter,
    this.edition,
    this.language,
    this.notes,
    this.status = VerificationStatus.pendingVerification,
  });

  final String title;
  final String? sectionOrChapter;
  final String? edition;
  final String? language;
  final String? notes;
  final VerificationStatus status;

  /// A source with no title yet — used as an explicit placeholder so UI
  /// never silently renders empty provenance.
  static const SourceReference unverified = SourceReference(
    title: '[AUTHORITATIVE SOURCE REQUIRED]',
    status: VerificationStatus.pendingVerification,
    notes: 'This entry is a structural placeholder pending review by a qualified source.',
  );
}
