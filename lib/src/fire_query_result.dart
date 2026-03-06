import 'package:cloud_firestore/cloud_firestore.dart';

/// Wraps a Firestore [QuerySnapshot] and provides
/// convenient helpers for accessing results.
///
/// Returned by [FireQuery.fetch] and emitted by [FireQuery.stream].
class FireQueryResult {
  final QuerySnapshot<Map<String, dynamic>> _snapshot;

  FireQueryResult(this._snapshot);

  /// All documents returned by the query.
  List<QueryDocumentSnapshot<Map<String, dynamic>>> get docs => _snapshot.docs;

  /// Number of documents returned.
  int get count => _snapshot.docs.length;

  /// Whether the result set is empty.
  bool get isEmpty => _snapshot.docs.isEmpty;

  /// Whether the result set has documents.
  bool get isNotEmpty => _snapshot.docs.isNotEmpty;

  /// The last document in the result — useful for pagination cursors.
  QueryDocumentSnapshot<Map<String, dynamic>>? get lastDocument =>
      _snapshot.docs.isNotEmpty ? _snapshot.docs.last : null;

  /// The first document in the result.
  QueryDocumentSnapshot<Map<String, dynamic>>? get firstDocument =>
      _snapshot.docs.isNotEmpty ? _snapshot.docs.first : null;

  /// Maps all documents to a list of [T] using [mapper].
  ///
  /// Example:
  /// ```dart
  /// final users = result.mapTo((doc) => User.fromMap(doc.data()));
  /// ```
  List<T> mapTo<T>(T Function(QueryDocumentSnapshot<Map<String, dynamic>> doc) mapper) {
    return _snapshot.docs.map(mapper).toList();
  }

  /// Returns all document data as a list of maps.
  List<Map<String, dynamic>> get data =>
      _snapshot.docs.map((doc) => doc.data()).toList();

  /// Returns all document IDs.
  List<String> get ids => _snapshot.docs.map((doc) => doc.id).toList();

  /// The raw Firestore snapshot, for advanced use cases.
  QuerySnapshot<Map<String, dynamic>> get raw => _snapshot;
}
