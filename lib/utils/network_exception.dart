class NetworkException implements Exception {
  final int statusCode;
  final String message;

  NetworkException(this.statusCode, this.message);

  @override
  String toString() {
    return '$message';
  }
}