import 'package:dio/dio.dart';
import 'package:offline_first_poc/datasources/cache_interceptor.dart';
import 'package:offline_first_poc/datasources/dio_debug_interceptor.dart';
import 'package:offline_first_poc/datasources/request_queue_interceptor.dart';
import 'package:offline_first_poc/services/local_storage_service.dart';

class ApiDatasource {
  late final Dio httpClient;
  ApiDatasource() {
    httpClient = Dio(BaseOptions(baseUrl: 'https://6bcd-187-61-152-203.ngrok-free.app'));
    final localStorage = LocalStorageService();
    httpClient.interceptors.addAll([
      CacheQueryInterceptor(localStorage),
      RequestQueueInterceptor(localStorage),
      DioDebugInterceptor(),
    ]);
  }
}
