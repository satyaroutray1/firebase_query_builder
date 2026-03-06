import 'package:cloud_firestore/cloud_firestore.dart';
import 'fire_query_field.dart';
import 'fire_query_result.dart';
import 'fire_query_paginator.dart';
import 'exceptions.dart';

/// The main entry point for building Firestore queries fluently.
///
/// Use [FireQuery.from] to start a query on a collection,
/// or [FireQuery.fromGroup] for collection group queries.
///
/// Example:
/// ```dart
/// final results = await FireQuery.from('products')
///   .where('category').equals('electronics')
///   .where('price').lessThanOrEqual(500)
///   .orderBy('price')
///   .limit(10)
///   .fetch();
/// ```
class FireQuery {
  final Query<Map<String, dynamic>> _query;
  final String _collectionPath;
  int? _pageSize;

  FireQuery._(this._query, this._collectionPath);

  /// Creates a query builder targeting the given [collectionPath].
  ///
  /// Example:
  /// ```dart
  /// FireQuery.from('users')
  /// ```
  static FireQuery from(
    String collectionPath, {
    FirebaseFirestore? firestore,
  }) {
    final db = firestore ?? FirebaseFirestore.instance;
    return FireQuery._(db.collection(collectionPath), collectionPath);
  }

  /// Creates a query builder targeting a Firestore collection group.
  ///
  /// Example:
  /// ```dart
  /// FireQuery.fromGroup('comments')
  /// ```
  static FireQuery fromGroup(
    String collectionId, {
    FirebaseFirestore? firestore,
  }) {
    final db = firestore ?? FirebaseFirestore.instance;
    return FireQuery._(db.collectionGroup(collectionId), collectionId);
  }

  /// Returns a [FireQueryField] to apply conditions on the given [field].
  ///
  /// Example:
  /// ```dart
  /// .where('status').equals('active')
  /// .where('age').greaterThan(18)
  /// ```
  FireQueryField where(String field) {
    return FireQueryField(field, this);
  }

  /// Orders results by [field].
  ///
  /// Set [descending] to `true` for newest-first ordering.
  ///
  /// Example:
  /// ```dart
  /// .orderBy('createdAt', descending: true)
  /// ```
  FireQuery orderBy(String field, {bool descending = false}) {
    return FireQuery._(
        _query.orderBy(field, descending: descending), _collectionPath);
  }

  /// Limits the number of documents returned.
  ///
  /// Example:
  /// ```dart
  /// .limit(25)
  /// ```
  FireQuery limit(int count) {
    if (count <= 0) throw FireQueryException('limit() must be greater than 0.');
    return FireQuery._(_query.limit(count), _collectionPath);
  }

  /// Limits to the last [count] documents (used with orderBy).
  FireQuery limitToLast(int count) {
    if (count <= 0)
      throw FireQueryException('limitToLast() must be greater than 0.');
    return FireQuery._(_query.limitToLast(count), _collectionPath);
  }

  /// Starts the query after the given [document] snapshot.
  /// Used for cursor-based pagination.
  FireQuery startAfterDocument(DocumentSnapshot document) {
    return FireQuery._(_query.startAfterDocument(document), _collectionPath);
  }

  /// Starts the query at the given [document] snapshot.
  FireQuery startAtDocument(DocumentSnapshot document) {
    return FireQuery._(_query.startAtDocument(document), _collectionPath);
  }

  /// Ends the query before the given [document] snapshot.
  FireQuery endBeforeDocument(DocumentSnapshot document) {
    return FireQuery._(_query.endBeforeDocument(document), _collectionPath);
  }

  /// Ends the query at the given [document] snapshot.
  FireQuery endAtDocument(DocumentSnapshot document) {
    return FireQuery._(_query.endAtDocument(document), _collectionPath);
  }

  /// Enables automatic pagination with [pageSize] documents per page.
  ///
  /// Returns a [FireQueryPaginator] to navigate pages.
  ///
  /// Example:
  /// ```dart
  /// final paginator = FireQuery.from('products')
  ///   .where('inStock').equals(true)
  ///   .paginate(pageSize: 10);
  ///
  /// final firstPage = await paginator.nextPage();
  /// final secondPage = await paginator.nextPage();
  /// ```
  FireQueryPaginator paginate({required int pageSize}) {
    if (pageSize <= 0)
      throw FireQueryException('pageSize must be greater than 0.');
    _pageSize = pageSize;
    return FireQueryPaginator(_query, pageSize);
  }

  /// Executes the query and returns a [FireQueryResult].
  ///
  /// Example:
  /// ```dart
  /// final result = await FireQuery.from('orders').fetch();
  /// for (final doc in result.docs) {
  ///   print(doc.data());
  /// }
  /// ```
  Future<FireQueryResult> fetch() async {
    try {
      final snapshot = await _query.get();
      return FireQueryResult(snapshot);
    } on FirebaseException catch (e) {
      throw FireQueryException('Firestore error: ${e.message}', cause: e);
    }
  }

  /// Executes the query and returns a single document or null if not found.
  ///
  /// Note: This fetches with limit(1) internally.
  ///
  /// Example:
  /// ```dart
  /// final doc = await FireQuery.from('users')
  ///   .where('email').equals('user@example.com')
  ///   .fetchOne();
  /// ```
  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> fetchOne() async {
    try {
      final snapshot = await _query.limit(1).get();
      if (snapshot.docs.isEmpty) return null;
      return snapshot.docs.first;
    } on FirebaseException catch (e) {
      throw FireQueryException('Firestore error: ${e.message}', cause: e);
    }
  }

  /// Returns a real-time stream of [FireQueryResult] updates.
  ///
  /// Example:
  /// ```dart
  /// FireQuery.from('messages')
  ///   .where('roomId').equals('room_1')
  ///   .orderBy('sentAt', descending: true)
  ///   .stream()
  ///   .listen((result) {
  ///     print('Got ${result.count} messages');
  ///   });
  /// ```
  Stream<FireQueryResult> stream() {
    return _query.snapshots().map((snapshot) => FireQueryResult(snapshot));
  }

  /// Returns the count of documents matching the query without fetching them.
  ///
  /// More efficient than fetching all docs just to count.
  ///
  /// Example:
  /// ```dart
  /// final count = await FireQuery.from('orders')
  ///   .where('status').equals('pending')
  ///   .count();
  /// ```
  Future<int> count() async {
    try {
      final snapshot = await _query.count().get();
      return snapshot.count ?? 0;
    } on FirebaseException catch (e) {
      throw FireQueryException('Firestore error: ${e.message}', cause: e);
    }
  }

  /// Returns the raw Firestore [Query] for advanced use cases.
  Query<Map<String, dynamic>> toRaw() => _query;

  /// Internal method used by [FireQueryField] to apply conditions.
  FireQuery applyCondition(Query<Map<String, dynamic>> newQuery) {
    return FireQuery._(newQuery, _collectionPath);
  }

  Query<Map<String, dynamic>> get rawQuery => _query;
}
