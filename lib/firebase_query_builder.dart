/// A fluent, chainable Firestore query builder for Flutter.
///
/// Firebase Query Builder provides a clean, readable API for constructing
/// complex Firestore queries without deeply nested method chains.
///
/// ## Basic Usage
///
/// ```dart
/// final results = await FireQuery.from('orders')
///   .where('status').equals('pending')
///   .where('amount').greaterThan(100)
///   .orderBy('createdAt', descending: true)
///   .limit(20)
///   .fetch();
/// ```
library firebase_query_builder;

export 'src/fire_query.dart';
export 'src/fire_query_field.dart';
export 'src/fire_query_result.dart';
export 'src/fire_query_paginator.dart';
export 'src/exceptions.dart';
