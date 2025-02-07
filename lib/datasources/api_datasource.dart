import 'package:dio/dio.dart';
import 'package:offline_first_poc/datasources/dio_debug_interceptor.dart';

class ApiDatasource {
  late final Dio httpClient;
  ApiDatasource() {
    httpClient = Dio(BaseOptions(baseUrl: 'https://71ce-177-89-61-164.ngrok-free.app'));
    httpClient.interceptors.add(DioDebugInterceptor());
  }
}
