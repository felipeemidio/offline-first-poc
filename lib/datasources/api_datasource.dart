import 'package:dio/dio.dart';
import 'package:offline_first_poc/datasources/dio_debug_interceptor.dart';

class ApiDatasource {
  late final Dio httpClient;
  ApiDatasource() {
    // TODO: Insert your base url here
    httpClient = Dio(BaseOptions(baseUrl: 'BASE_URL'));
    httpClient.interceptors.add(DioDebugInterceptor());
  }
}
