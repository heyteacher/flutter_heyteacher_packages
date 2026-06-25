import 'package:flutter/widgets.dart';

/// Holds data for the images displayed into a slide.
class SlideData {
  /// Creates a new instance of [SlideData].
  SlideData({
    this.title,
    this.subtitle,
    this.imagePaths,
    this.body,
  }) : assert(title == null || title.isNotEmpty, 'title cannot be empty'),
       assert(
         (imagePaths?.isNotEmpty ?? false) || (body?.isNotEmpty ?? false),
         'imagePath or body must be provided',
       );

  /// The title displayed over the image.
  final String? title;

  /// The subtitle displayed over the image.
  final String? subtitle;

  /// The image asset path.
  final Iterable<String>? imagePaths;

  /// The body as list of sentences
  final Iterable<
    ({IconData? leadingIcon, Color? leadingIconColor, String text})
  >?
  body;
}
