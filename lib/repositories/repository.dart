import 'package:dio/dio.dart';

abstract class Repository implements Syncable {
  const Repository();

  bool isNoConnetionError(dynamic error) {
    return error is DioException && error.response == null;
  }
}

abstract class Syncable {
  Future<void> sync();
}
