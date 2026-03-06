/// Thrown when a [FireQuery] operation fails.
///
/// Wraps Firestore errors with cleaner messages.
class FireQueryException implements Exception {
  /// Human-readable error message.
  final String message;

  /// The underlying cause, if any.
  final Object? cause;

  FireQueryException(this.message, {this.cause});

  @override
  String toString() {
    if (cause != null) {
      return 'FireQueryException: $message\nCaused by: $cause';
    }
    return 'FireQueryException: $message';
  }
}
