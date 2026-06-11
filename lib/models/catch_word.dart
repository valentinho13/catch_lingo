/// A word that can be discovered and caught in the real world.
///
/// [id] is the stable identity used for persistence — never change ids of
/// shipped words without a migration.
class CatchWord {
  const CatchWord({
    required this.id,
    required this.source,
    required this.translation,
    required this.category,
  });

  /// Stable identifier, e.g. `cafe.coffee`.
  final String id;

  /// The word as noticed in the world (English for now).
  final String source;

  /// The word to learn (Indonesian first).
  final String translation;

  final String category;
}
