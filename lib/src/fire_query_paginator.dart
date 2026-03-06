import 'package:cloud_firestore/cloud_firestore.dart';
import 'fire_query_result.dart';
import 'exceptions.dart';

/// Handles cursor-based pagination for Firestore queries.
///
/// Obtain via [FireQuery.paginate]:
/// ```dart
/// final paginator = FireQuery.from('products')
///   .orderBy('createdAt', descending: true)
///   .paginate(pageSize: 10);
///
/// final page1 = await paginator.nextPage();
/// final page2 = await paginator.nextPage();
///
/// if (paginator.hasMore) {
///   final page3 = await paginator.nextPage();
/// }
/// ```
class FireQueryPaginator {
  final Query<Map<String, dynamic>> _baseQuery;
  final int _pageSize;

  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;
  int _currentPage = 0;

  FireQueryPaginator(this._baseQuery, this._pageSize);

  /// Whether more pages are available.
  bool get hasMore => _hasMore;

  /// The current page index (0-based).
  int get currentPage => _currentPage;

  /// Resets the paginator back to the first page.
  void reset() {
    _lastDocument = null;
    _hasMore = true;
    _currentPage = 0;
  }

  /// Fetches the next page of results.
  ///
  /// Returns null if no more pages are available.
  /// Check [hasMore] before calling to avoid unnecessary requests.
  ///
  /// Example:
  /// ```dart
  /// while (paginator.hasMore) {
  ///   final page = await paginator.nextPage();
  ///   if (page == null) break;
  ///   processDocs(page.docs);
  /// }
  /// ```
  Future<FireQueryResult?> nextPage() async {
    if (!_hasMore) return null;

    try {
      Query<Map<String, dynamic>> query = _baseQuery.limit(_pageSize);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty || snapshot.docs.length < _pageSize) {
        _hasMore = false;
      }

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
        _currentPage++;
      }

      return FireQueryResult(snapshot);
    } on FirebaseException catch (e) {
      throw FireQueryException('Pagination error: ${e.message}', cause: e);
    }
  }

  /// Fetches all remaining pages and returns combined results.
  ///
  /// Use with caution on large collections.
  ///
  /// Example:
  /// ```dart
  /// final allDocs = await paginator.fetchAll();
  /// ```
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> fetchAll() async {
    final all = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
    while (_hasMore) {
      final page = await nextPage();
      if (page == null) break;
      all.addAll(page.docs);
    }
    return all;
  }
}
