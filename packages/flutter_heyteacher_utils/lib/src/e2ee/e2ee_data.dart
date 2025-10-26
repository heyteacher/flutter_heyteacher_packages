import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'e2ee_data.g.dart';

/// Represents an encrypted value along with its Initialization Vector (IV).
///
/// Used to package the ciphertext and IV together, as both are needed for
/// decryption.
/// Provides methods for JSON serialization/deserialization, including GZip compression
/// and Base64 encoding for efficient storage or transmission.
@JsonSerializable()
class E2EEValue {
  /// Creates an [E2EEValue].
  const E2EEValue({required this.value, required this.iv});

  /// Creates an [E2EEValue] from a map (typically from JSON deserialization).
  ///
  /// Assumes the 'value' and 'iv' fields in the map are Base64 encoded and
  /// GZipped.
  factory E2EEValue.fromJson(Map<String, dynamic> map) =>
      _$E2EEValueFromJson(map);

  /// The encrypted data (ciphertext).
  @JsonKey(fromJson: _unzip, toJson: _zip)
  final Uint8List value;

  /// The Initialization Vector used during encryption.
  @JsonKey(fromJson: _unzip, toJson: _zip)
  final Uint8List iv;

  /// Converts the [E2EEValue] to a JSON-compatible map.
  ///
  /// The 'value' and 'iv' are GZipped and Base64 encoded.
  Map<String, dynamic> toJson() => _$E2EEValueToJson(this);

  static String? _zip(Object? object) {
    if (object == null) return null;
    final jsonEncodeValue = jsonEncode(object);
    final utf8Encoded = utf8.encode(jsonEncodeValue);
    final gzipEncoded = const GZipEncoder().encodeBytes(utf8Encoded);
    final base64Encoded = base64.encode(gzipEncoded);
    return base64Encoded;
  }

  static Uint8List _unzip(String? base64Encoded) {
    if (base64Encoded == null) return Uint8List.fromList([]);
    final base64Decoded = base64.decode(base64Encoded);
    final gzipDecoded = const GZipDecoder().decodeBytes(base64Decoded);
    final uft8Decoded = utf8.decode(gzipDecoded);
    return Uint8List.fromList(
      (jsonDecode(uft8Decoded) as Iterable).cast<int>() as List<int>,
    );
  }
}
