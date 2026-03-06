import 'fire_query.dart';

/// Represents a field in a [FireQuery] and provides
/// fluent methods to apply filter conditions.
///
/// Obtained via [FireQuery.where]:
/// ```dart
/// FireQuery.from('users').where('age').greaterThan(18)
/// ```
class FireQueryField {
  final String _field;
  final FireQuery _parent;

  FireQueryField(this._field, this._parent);

  // ─── Equality ────────────────────────────────────────────────────

  /// Matches documents where [_field] equals [value].
  ///
  /// ```dart
  /// .where('status').equals('active')
  /// ```
  FireQuery equals(Object? value) {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, isEqualTo: value),
    );
  }

  /// Matches documents where [_field] does NOT equal [value].
  ///
  /// ```dart
  /// .where('status').notEquals('deleted')
  /// ```
  FireQuery notEquals(Object? value) {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, isNotEqualTo: value),
    );
  }

  // ─── Comparison ──────────────────────────────────────────────────

  /// Matches documents where [_field] is less than [value].
  ///
  /// ```dart
  /// .where('price').lessThan(100)
  /// ```
  FireQuery lessThan(Object value) {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, isLessThan: value),
    );
  }

  /// Matches documents where [_field] is less than or equal to [value].
  ///
  /// ```dart
  /// .where('price').lessThanOrEqual(100)
  /// ```
  FireQuery lessThanOrEqual(Object value) {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, isLessThanOrEqualTo: value),
    );
  }

  /// Matches documents where [_field] is greater than [value].
  ///
  /// ```dart
  /// .where('age').greaterThan(18)
  /// ```
  FireQuery greaterThan(Object value) {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, isGreaterThan: value),
    );
  }

  /// Matches documents where [_field] is greater than or equal to [value].
  ///
  /// ```dart
  /// .where('rating').greaterThanOrEqual(4.0)
  /// ```
  FireQuery greaterThanOrEqual(Object value) {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, isGreaterThanOrEqualTo: value),
    );
  }

  // ─── Null ────────────────────────────────────────────────────────

  /// Matches documents where [_field] is null.
  ///
  /// ```dart
  /// .where('deletedAt').isNull()
  /// ```
  FireQuery isNull() {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, isNull: true),
    );
  }

  /// Matches documents where [_field] is not null.
  ///
  /// ```dart
  /// .where('profilePhoto').isNotNull()
  /// ```
  FireQuery isNotNull() {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, isNull: false),
    );
  }

  // ─── Array ───────────────────────────────────────────────────────

  /// Matches documents where [_field] array contains [value].
  ///
  /// ```dart
  /// .where('tags').contains('flutter')
  /// ```
  FireQuery contains(Object value) {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, arrayContains: value),
    );
  }

  /// Matches documents where [_field] array contains any of [values].
  ///
  /// ```dart
  /// .where('tags').containsAny(['flutter', 'dart'])
  /// ```
  FireQuery containsAny(List<Object> values) {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, arrayContainsAny: values),
    );
  }

  // ─── In / Not In ─────────────────────────────────────────────────

  /// Matches documents where [_field] is one of [values].
  ///
  /// ```dart
  /// .where('status').whereIn(['pending', 'processing'])
  /// ```
  FireQuery whereIn(List<Object?> values) {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, whereIn: values),
    );
  }

  /// Matches documents where [_field] is NOT one of [values].
  ///
  /// ```dart
  /// .where('status').whereNotIn(['cancelled', 'deleted'])
  /// ```
  FireQuery whereNotIn(List<Object?> values) {
    return _parent.applyCondition(
      _parent.rawQuery.where(_field, whereNotIn: values),
    );
  }

  // ─── String ──────────────────────────────────────────────────────

  /// Matches documents where [_field] string starts with [prefix].
  ///
  /// Useful for basic search-like queries.
  ///
  /// ```dart
  /// .where('name').startsWith('Jo')
  /// ```
  FireQuery startsWith(String prefix) {
    if (prefix.isEmpty) {
      return _parent;
    }
    final end = prefix.substring(0, prefix.length - 1) +
        String.fromCharCode(prefix.codeUnitAt(prefix.length - 1) + 1);
    return _parent.applyCondition(
      _parent.rawQuery
          .where(_field, isGreaterThanOrEqualTo: prefix)
          .where(_field, isLessThan: end),
    );
  }
}
