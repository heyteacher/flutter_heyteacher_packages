/// Holds metadata for the images displayed in the carousel.
class HeroCarouselItemData {
  /// Creates a new instance of [HeroCarouselItemData].
  const HeroCarouselItemData({
    required this.title,
    required this.subtitle,
    required this.path,
  });

  /// The title displayed over the image.
  final String title;

  /// The subtitle displayed over the image.
  final String subtitle;

  /// The image asset path.
  final String path;
}
