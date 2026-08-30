import 'source_reference.dart';

enum DevotionalCategory {
  aarti('Aarti', 'హారతి'),
  chalisa('Chalisa', 'చాలీసా'),
  stotram('Stotram', 'స్తోత్రం'),
  ashtottaram('Ashtottara Shatanamavali', 'అష్టోత్తర శతనామావళి');

  const DevotionalCategory(this.label, this.telugu);
  final String label;
  final String telugu;
}

/// A single devotional text listing. The actual verse/lyric text is
/// deliberately never stored here as free text — see [contentPlaceholder]
/// — since these are exact sacred/copyrighted texts that must come from
/// a verified traditional source, not be generated.
class DevotionalText {
  const DevotionalText({
    required this.id,
    required this.title,
    required this.teluguTitle,
    required this.category,
    required this.deity,
    required this.source,
  });

  final String id;
  final String title;
  final String teluguTitle;
  final DevotionalCategory category;
  final String deity;
  final SourceReference source;

  static const String contentPlaceholder =
      '[VERIFIED CONTENT REQUIRED] — full text withheld pending citation from a verified traditional source.';
}
