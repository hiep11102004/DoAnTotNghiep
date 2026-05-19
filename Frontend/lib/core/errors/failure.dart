abstract class Failure {
  final String message;
  const Failure(this.message);
}

// Lỗi từ phía Server hoặc API trả về lỗi (400, 404, 500...)
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

// Lỗi mất kết nối mạng, timeout
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Lỗi khi đọc/ghi cache hoặc SharedPreferences
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}