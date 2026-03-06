import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_query_builder/firebase_query_builder.dart';
import 'package:flutter/material.dart';

/// This example demonstrates common usage patterns for firebase_query_builder.
/// Make sure you have Firebase initialized in your project before running.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FireQuery Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('FireQuery Example')),
        body: const ExampleBody(),
      ),
    );
  }
}

class ExampleBody extends StatefulWidget {
  const ExampleBody({super.key});

  @override
  State<ExampleBody> createState() => _ExampleBodyState();
}

class _ExampleBodyState extends State<ExampleBody> {
  String _output = 'Press a button to run an example.';

  // ─── Example 1: Basic fetch with filters ─────────────────────────
  Future<void> runBasicFetch() async {
    final result = await FireQuery.from('products')
        .where('category')
        .equals('electronics')
        .where('price')
        .lessThan(1000)
        .orderBy('price', descending: false)
        .limit(10)
        .fetch();

    setState(() {
      _output = 'Found ${result.count} products:\n'
          '${result.data.map((d) => d['name']).join(', ')}';
    });
  }

  // ─── Example 2: fetchOne ─────────────────────────────────────────
  Future<void> runFetchOne() async {
    final doc = await FireQuery.from('users')
        .where('email')
        .equals('admin@example.com')
        .fetchOne();

    setState(() {
      _output =
          doc != null ? 'Found user: ${doc.data()['name']}' : 'User not found.';
    });
  }

  // ─── Example 3: Pagination ───────────────────────────────────────
  Future<void> runPagination() async {
    final paginator = FireQuery.from('orders')
        .where('status')
        .equals('pending')
        .orderBy('createdAt', descending: true)
        .paginate(pageSize: 5);

    final buffer = StringBuffer();
    int pageNum = 1;

    while (paginator.hasMore) {
      final page = await paginator.nextPage();
      if (page == null) break;
      buffer.writeln('Page $pageNum: ${page.count} orders');
      pageNum++;
    }

    setState(() => _output = buffer.toString());
  }

  // ─── Example 4: Real-time stream ─────────────────────────────────
  void runStream() {
    FireQuery.from('messages')
        .where('roomId')
        .equals('room_001')
        .orderBy('sentAt', descending: true)
        .limit(20)
        .stream()
        .listen((result) {
      setState(() {
        _output = 'Live: ${result.count} messages in room';
      });
    });
  }

  // ─── Example 5: Count without fetching ───────────────────────────
  Future<void> runCount() async {
    final count = await FireQuery.from('orders')
        .where('status')
        .whereIn(['pending', 'processing']).count();

    setState(() => _output = 'Active orders: $count');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
              onPressed: runBasicFetch, child: const Text('Basic Fetch')),
          ElevatedButton(
              onPressed: runFetchOne, child: const Text('Fetch One')),
          ElevatedButton(
              onPressed: runPagination, child: const Text('Pagination')),
          ElevatedButton(
              onPressed: runStream, child: const Text('Live Stream')),
          ElevatedButton(onPressed: runCount, child: const Text('Count Docs')),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[100],
              child: Text(_output),
            ),
          ),
        ],
      ),
    );
  }
}
