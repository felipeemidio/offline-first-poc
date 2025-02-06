import 'package:dio/dio.dart';
import 'package:offline_first_poc/models/storable_request.dart';
import 'package:offline_first_poc/services/local_storage_service.dart';

class RequestQueueInterceptor extends Interceptor {
  static const String kListKey = 'request-queue';
  final LocalStorageService _localStorage;
  const RequestQueueInterceptor(this._localStorage);

  bool _hasNoConnection(DioException err) {
    return err.response == null;
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    // Remove the request from the queue
    if (response.requestOptions.method != "GET") {
      final storableRequest = StorableRequest.fromDio(response.requestOptions);
      await _localStorage.removeFromList(kListKey, storableRequest.toStorableString());
    }
    handler.next(response);
  }

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Insert a request in the pendency queue if it fails
    if (_hasNoConnection(err) && err.requestOptions.method != "GET") {
      final storableRequest = StorableRequest.fromDio(err.requestOptions);
      final list = (await _localStorage.getList(kListKey)).map((e) => StorableRequest.fromStorableString(e)).toList();
      if (!list.contains(storableRequest)) {
        await _localStorage.addInList(kListKey, storableRequest.toStorableString());
      }
    }

    handler.next(err);
  }
}
