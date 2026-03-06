import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_query_builder/firebase_query_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();

    // Seed test data
    final collection = fakeFirestore.collection('products');
    await collection.add({
      'name': 'Laptop',
      'price': 1200,
      'category': 'electronics',
      'inStock': true,
      'tags': ['tech', 'laptop']
    });
    await collection.add({
      'name': 'Phone',
      'price': 800,
      'category': 'electronics',
      'inStock': true,
      'tags': ['tech', 'mobile']
    });
    await collection.add({
      'name': 'Chair',
      'price': 250,
      'category': 'furniture',
      'inStock': false,
      'tags': ['home']
    });
    await collection.add({
      'name': 'Desk',
      'price': 400,
      'category': 'furniture',
      'inStock': true,
      'tags': ['home', 'office']
    });
    await collection.add({
      'name': 'Headphones',
      'price': 150,
      'category': 'electronics',
      'inStock': true,
      'tags': ['tech', 'audio']
    });
  });

  group('FireQuery - Basic Fetch', () {
    test('fetches all documents', () async {
      final result =
          await FireQuery.from('products', firestore: fakeFirestore).fetch();
      expect(result.count, 5);
    });

    test('result.isEmpty returns false when docs exist', () async {
      final result =
          await FireQuery.from('products', firestore: fakeFirestore).fetch();
      expect(result.isEmpty, false);
      expect(result.isNotEmpty, true);
    });

    test('result.ids returns document IDs', () async {
      final result =
          await FireQuery.from('products', firestore: fakeFirestore).fetch();
      expect(result.ids.length, 5);
      expect(result.ids.first, isA<String>());
    });
  });

  group('FireQuery - where().equals()', () {
    test('filters by exact match', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('category')
          .equals('electronics')
          .fetch();
      expect(result.count, 3);
    });

    test('returns empty when no match', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('category')
          .equals('nonexistent')
          .fetch();
      expect(result.isEmpty, true);
    });
  });

  group('FireQuery - where().notEquals()', () {
    test('excludes matching documents', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('category')
          .notEquals('electronics')
          .fetch();
      expect(result.count, 2);
    });
  });

  group('FireQuery - Comparison filters', () {
    test('greaterThan filters correctly', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('price')
          .greaterThan(500)
          .fetch();
      expect(result.count, 2); // Laptop 1200, Phone 800
    });

    test('lessThan filters correctly', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('price')
          .lessThan(300)
          .fetch();
      expect(result.count, 2); // Chair 250, Headphones 150
    });

    test('lessThanOrEqual filters correctly', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('price')
          .lessThanOrEqual(250)
          .fetch();
      expect(result.count, 2);
    });

    test('greaterThanOrEqual filters correctly', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('price')
          .greaterThanOrEqual(400)
          .fetch();
      expect(result.count, 3); // Laptop, Phone, Desk
    });
  });

  group('FireQuery - Array filters', () {
    test('contains filters by array value', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('tags')
          .contains('tech')
          .fetch();
      expect(result.count, 3); // Laptop, Phone, Headphones
    });

    test('containsAny filters by any array value', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('tags')
          .containsAny(['audio', 'office']).fetch();
      expect(result.count, 2); // Headphones, Desk
    });
  });

  group('FireQuery - whereIn / whereNotIn', () {
    test('whereIn filters correctly', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('category')
          .whereIn(['electronics', 'furniture']).fetch();
      expect(result.count, 5);
    });

    test('whereNotIn excludes correctly', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('category')
          .whereNotIn(['furniture']).fetch();
      expect(result.count, 3);
    });
  });

  group('FireQuery - Chained filters', () {
    test('chains multiple conditions', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('category')
          .equals('electronics')
          .where('inStock')
          .equals(true)
          .where('price')
          .greaterThan(200)
          .fetch();
      expect(result.count, 2); // Laptop, Phone
    });
  });

  group('FireQuery - limit()', () {
    test('limits result count', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .limit(2)
          .fetch();
      expect(result.count, 2);
    });

    test('throws on invalid limit', () {
      expect(
        () => FireQuery.from('products', firestore: fakeFirestore).limit(0),
        throwsA(isA<FireQueryException>()),
      );
    });
  });

  group('FireQuery - fetchOne()', () {
    test('returns a single document', () async {
      final doc = await FireQuery.from('products', firestore: fakeFirestore)
          .where('name')
          .equals('Laptop')
          .fetchOne();
      expect(doc, isNotNull);
      expect(doc!.data()['name'], 'Laptop');
    });

    test('returns null when not found', () async {
      final doc = await FireQuery.from('products', firestore: fakeFirestore)
          .where('name')
          .equals('NonExistent')
          .fetchOne();
      expect(doc, isNull);
    });
  });

  group('FireQuery - mapTo()', () {
    test('maps documents to typed objects', () async {
      final result = await FireQuery.from('products', firestore: fakeFirestore)
          .where('category')
          .equals('electronics')
          .fetch();

      final names = result.mapTo((doc) => doc.data()['name'] as String);
      expect(names, containsAll(['Laptop', 'Phone', 'Headphones']));
    });
  });

  group('FireQuery - stream()', () {
    test('emits results as a stream', () async {
      final stream = FireQuery.from('products', firestore: fakeFirestore)
          .where('inStock')
          .equals(true)
          .stream();

      final result = await stream.first;
      expect(result.count, 4); // Laptop, Phone, Desk, Headphones
    });
  });

  group('FireQuery - Pagination', () {
    test('paginates correctly', () async {
      final paginator = FireQuery.from('products', firestore: fakeFirestore)
          .paginate(pageSize: 2);

      final page1 = await paginator.nextPage();
      expect(page1!.count, 2);
      expect(paginator.currentPage, 1);

      final page2 = await paginator.nextPage();
      expect(page2!.count, 2);
      expect(paginator.currentPage, 2);

      final page3 = await paginator.nextPage();
      expect(page3!.count, 1);
      expect(paginator.hasMore, false);
    });

    test('returns null after all pages exhausted', () async {
      final paginator = FireQuery.from('products', firestore: fakeFirestore)
          .paginate(pageSize: 10);

      await paginator.nextPage();
      expect(paginator.hasMore, false);

      final extraPage = await paginator.nextPage();
      expect(extraPage, isNull);
    });

    test('reset() restarts pagination', () async {
      final paginator = FireQuery.from('products', firestore: fakeFirestore)
          .paginate(pageSize: 10);

      await paginator.nextPage();
      expect(paginator.currentPage, 1);

      paginator.reset();
      expect(paginator.currentPage, 0);
      expect(paginator.hasMore, true);
    });

    test('fetchAll() returns all documents', () async {
      final paginator = FireQuery.from('products', firestore: fakeFirestore)
          .paginate(pageSize: 2);

      final all = await paginator.fetchAll();
      expect(all.length, 5);
    });
  });
}
