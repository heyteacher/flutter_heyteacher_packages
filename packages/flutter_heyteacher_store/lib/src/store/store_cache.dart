import 'dart:async';
import 'package:flutter_heyteacher_store/flutter_heyteacher_store.dart';
import 'package:logging/logging.dart';

/// An in-memory cache for Firestore documents.
///
/// This class provides a simple key-value store to temporarily hold
/// `DetailsDataType` objects, reducing redundant reads from Firestore.
class StoreCache<DetailsDataType extends FirestoreData<dynamic>> {
  final _logger = Logger('StoreCache');

  final Map<String, DetailsDataType?> _cache = {};

  /// Checks if a document with the given [id] exists in the cache.
  bool exists(String id) => _cache.containsKey(id);

  /// Retrieves a document with the given [id] from the cache.
  ///
  /// Returns the cached `DetailsDataType` object if found, otherwise `null`.
  Future<DetailsDataType?> get(String id) async {
    _logger.finest('<get>:');
    if (exists(id)) {
      _logger.finest('(get): id $id. HIT runtimeType '
          '${DetailsDataType.runtimeType} hashCode $hashCode');
      return _cache[id];
    }
    _logger.finer('(get): id $id. MISS runtimeType '
        '${DetailsDataType.runtimeType} hashCode $hashCode');
    return null;
  }

  /// Adds or updates a document in the cache.
  ///
  /// - [id]: The unique identifier for the document.
  /// - [detailsData]: The document data to cache. Can be `null` to cache a
  ///   non-existent document.
  void set(String id, DetailsDataType? detailsData) {
    _logger.finer('<set>: id $id');
    _cache[id] = detailsData;
  }

  /// delete object [id] from cache
  void delete(String id) {
    _logger.finer('<delete>: id $id');
    _cache.remove(id);
  }
}
