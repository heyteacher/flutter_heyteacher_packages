/// Represents the data for a video, including its title and URL.
class VideoData {
  /// Creates a [VideoData] object.
  const VideoData({
    required String title,
    required String subTitle,
    required String url,
  }) : _url = url, _title = title, _subTitle = subTitle;

  /// The title of the video.
  final String _title;

 /// The title of the video.
  final String _subTitle;

  /// The URL of the video.
  final String _url;

  /// Returns the title of the video.
  String get title => _title;

  /// Returns the sub title of the video.
  String get subTitle => _subTitle;

  /// Returns the URL of the video.
  String get url => _url;
}
