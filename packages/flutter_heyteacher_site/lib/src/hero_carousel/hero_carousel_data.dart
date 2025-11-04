/// Holds metadata for the images displayed in the carousel.
class HeroCarouselItemData {
  /// Creates a new instance of [HeroCarouselItemData].
  const HeroCarouselItemData({
    required String title,
    required String subtitle,
    required String path,
  }) : _path = path,
       _subtitle = subtitle,
       _title = title;

  final String _title;
  final String _subtitle;
  final String _path;

  /// The title displayed over the image.
  String get title => _title;

  /// The subtitle displayed over the image.
  String get subtitle => _subtitle;

  /// The image asset path.
  String get path => _path;
}
