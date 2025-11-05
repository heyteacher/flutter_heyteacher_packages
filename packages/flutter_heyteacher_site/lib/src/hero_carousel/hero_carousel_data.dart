import 'package:flutter/widgets.dart';

/// Holds metadata for the images displayed in the carousel.
class HeroCarouselItemData {
  /// Creates a new instance of [HeroCarouselItemData].
  HeroCarouselItemData({
    required this.title,
    this.subtitle,
    this.imagePath,
    this.body,
  }) : assert(title.isNotEmpty, 'title cannot be empty'),
       assert(
         (imagePath?.isNotEmpty ?? false) || (body?.isNotEmpty ?? false),
         'imagePath or body must be provided',
       );

  /// The title displayed over the image.
  final String title;

  /// The subtitle displayed over the image.
  final String? subtitle;

  /// The image asset path.
  final String? imagePath;

  /// The body as list of sentences
  final Iterable<({IconData leadingIcon, Color leadingIconColor, String text})>?
  body;
}
