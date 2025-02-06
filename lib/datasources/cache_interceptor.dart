import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:offline_first_poc/models/storable_request.dart';
import 'package:offline_first_poc/services/local_storage_service.dart';

class CacheQueryInterceptor extends Interceptor {
  final LocalStorageService _localStorage;
  const CacheQueryInterceptor(this._localStorage);

  bool _hasNoConnection(DioException err) {
    return err.response == null;
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Store response for GETs
    if (response.requestOptions.method == "GET") {
      final storableRequest = StorableRequest.fromDio(response.requestOptions);
      await _localStorage.save(storableRequest.toStorableString(), jsonEncode(response.data));
    }
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // If GETs fails, we retrieve the previously stored response
    if (_hasNoConnection(err) && err.requestOptions.method == "GET") {
      final request = err.requestOptions;
      final storableRequest = StorableRequest.fromDio(err.requestOptions);

      final storedResponse = await _localStorage.get(storableRequest.toStorableString());
      if (storedResponse != null) {
        handler.resolve(Response(requestOptions: request, data: jsonDecode(storedResponse)));
        return;
      }
    }

    handler.next(err);
  }
}
