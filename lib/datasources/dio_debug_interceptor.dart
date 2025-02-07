// ignore_for_file: avoid_print

import 'package:dio/dio.dart';

class DioDebugInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('_dio: Request ${options.method} - ${options.path}\nheaders: ${options.headers}\n'
        'params: ${options.queryParameters}\nbody: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('_dio: Response for ${response.requestOptions.method} -'
        ' ${response.requestOptions.path}\nstatusCode: ${response.statusCode}\nResponse body: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    print('_dio: Error for ${err.requestOptions.method} -'
        ' ${err.requestOptions.path}\nstatusCode: ${err.response?.statusCode}'
        '\nResponse body: ${err.response?.data}');
    super.onError(err, handler);
  }
}
