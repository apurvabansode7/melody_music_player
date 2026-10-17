class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
    this.isNetworkError = false,
  });

  final String message;
  final int? statusCode;

  /// True when the server could not be reached. Repositories use this
  /// to decide whether to fall back to cached data.
  final bool isNetworkError;

  @override
  String toString() => message;
}