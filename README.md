# firebase_query_builder

[![pub package](https://img.shields.io/pub/v/firebase_query_builder.svg)](https://pub.dev/packages/firebase_query_builder)
[![likes](https://img.shields.io/pub/likes/firebase_query_builder)](https://pub.dev/packages/firebase_query_builder)
[![popularity](https://img.shields.io/pub/popularity/firebase_query_builder)](https://pub.dev/packages/firebase_query_builder)
[![pub points](https://img.shields.io/pub/points/firebase_query_builder)](https://pub.dev/packages/firebase_query_builder)

A fluent, chainable Firestore query builder for Flutter. Write clean, readable, and expressive Firestore queries — no more deeply nested method chains.

---

## The Problem

Firestore queries in Flutter get messy fast:

```dart
// Standard Firestore — hard to read, easy to make mistakes
FirebaseFirestore.instance
    .collection('orders')
    .where('status', isEqualTo: 'pending')
    .where('amount', isGreaterThan: 100)
    .where('tags', arrayContains: 'priority')
    .orderBy('createdAt', descending: true)
    .limit(20)
    .get();
```

## The Solution

```dart
// firebase_query_builder — clean, readable, expressive
FireQuery.from('orders')
    .where('status').equals('pending')
    .where('amount').greaterThan(100)
    .where('tags').contains('priority')
    .orderBy('createdAt', descending: true)
    .limit(20)
    .fetch();
```

---

## Features

- ✅ Fluent, chainable API for all Firestore filter types
- ✅ Built-in cursor-based **pagination** with `FireQueryPaginator`
- ✅ **Real-time streaming** with `.stream()`
- ✅ **Single document** retrieval with `.fetchOne()`
- ✅ **Count documents** efficiently without fetching with `.count()`
- ✅ **Typed mapping** with `.mapTo<T>()`
- ✅ String prefix search with `.startsWith()`
- ✅ Helpful error messages via `FireQueryException`
- ✅ Full test coverage

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  firebase_query_builder: ^0.0.1
```

Then run:

```bash
flutter pub get
```

---

## Usage

### Basic Fetch

```dart
import 'package:firebase_query_builder/firebase_query_builder.dart';

final result = await FireQuery.from('products')
    .where('category').equals('electronics')
    .where('price').lessThan(1000)
    .orderBy('price')
    .limit(10)
    .fetch();

print('Found ${result.count} products');

for (final doc in result.docs) {
  print(doc.data());
}
```

---

### Fetch a Single Document

```dart
final doc = await FireQuery.from('users')
    .where('email').equals('user@example.com')
    .fetchOne();

if (doc != null) {
  print('Found: ${doc.data()['name']}');
}
```

---

### Real-Time Stream

```dart
FireQuery.from('messages')
    .where('roomId').equals('room_001')
    .orderBy('sentAt', descending: true)
    .limit(50)
    .stream()
    .listen((result) {
  print('${result.count} messages');
});
```

---

### Pagination

```dart
final paginator = FireQuery.from('orders')
    .where('status').equals('pending')
    .orderBy('createdAt', descending: true)
    .paginate(pageSize: 10);

// Load page by page
while (paginator.hasMore) {
  final page = await paginator.nextPage();
  if (page == null) break;
  print('Page ${paginator.currentPage}: ${page.count} orders');
}

// Or fetch everything at once
final all = await paginator.fetchAll();
```

---

### Count Without Fetching

```dart
// Efficient — does not download documents
final count = await FireQuery.from('orders')
    .where('status').whereIn(['pending', 'processing'])
    .count();

print('Active orders: $count');
```

---

### Typed Mapping

```dart
final result = await FireQuery.from('users').fetch();

final users = result.mapTo((doc) => User.fromMap(doc.data()));
```

---

### Collection Groups

```dart
final result = await FireQuery.fromGroup('comments')
    .where('userId').equals('abc123')
    .orderBy('createdAt', descending: true)
    .fetch();
```

---

## Available Filter Methods

| Method | Description |
|--------|-------------|
| `.equals(value)` | Field equals value |
| `.notEquals(value)` | Field does not equal value |
| `.lessThan(value)` | Field < value |
| `.lessThanOrEqual(value)` | Field <= value |
| `.greaterThan(value)` | Field > value |
| `.greaterThanOrEqual(value)` | Field >= value |
| `.isNull()` | Field is null |
| `.isNotNull()` | Field is not null |
| `.contains(value)` | Array field contains value |
| `.containsAny(values)` | Array field contains any of values |
| `.whereIn(values)` | Field is one of values |
| `.whereNotIn(values)` | Field is not one of values |
| `.startsWith(prefix)` | String field starts with prefix |

---

## FireQueryResult Helpers

```dart
final result = await FireQuery.from('orders').fetch();

result.count        // number of documents
result.isEmpty      // true if no documents
result.isNotEmpty   // true if has documents
result.docs         // List<QueryDocumentSnapshot>
result.data         // List<Map<String, dynamic>>
result.ids          // List of document IDs
result.firstDocument  // first document or null
result.lastDocument   // last document or null (useful for cursors)
result.mapTo((doc) => MyModel.fromMap(doc.data()))
result.raw          // original QuerySnapshot
```

---

## Error Handling

```dart
try {
  final result = await FireQuery.from('orders').fetch();
} on FireQueryException catch (e) {
  print('Query failed: ${e.message}');
  print('Caused by: ${e.cause}');
}
```

---

## Requirements

- Flutter >= 3.10.0
- Dart >= 3.0.0
- cloud_firestore >= 5.0.0

---

## Contributing

Contributions are welcome! Please open an issue or pull request on GitHub.

---

## License

MIT — see [LICENSE](LICENSE)
