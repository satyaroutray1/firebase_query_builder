## 0.0.1

* Initial release
* Fluent chainable query builder for Firestore
* Support for: equals, notEquals, lessThan, greaterThan, contains, containsAny, whereIn, whereNotIn, startsWith, isNull, isNotNull
* Built-in cursor-based pagination via `FireQueryPaginator`
* Real-time stream support
* `fetchOne()` for single document retrieval
* `count()` for efficient document counting without fetching
* `mapTo<T>()` helper for typed document mapping
* Full test coverage with `fake_cloud_firestore`
