import 'package:dio/dio.dart';

class ApiDatasource {
  late final Dio httpClient;
  ApiDatasource() {
    httpClient = Dio(BaseOptions(baseUrl: 'https://71ce-177-89-61-164.ngrok-free.app'));
  }
}
