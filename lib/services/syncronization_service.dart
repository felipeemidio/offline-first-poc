import 'package:offline_first_poc/datasources/api_datasource.dart';
import 'package:offline_first_poc/datasources/request_queue_interceptor.dart';
import 'package:offline_first_poc/models/storable_request.dart';
import 'package:offline_first_poc/services/local_storage_service.dart';

class SyncronizationService {
  final ApiDatasource api;
  final LocalStorageService _localStorageService;
  const SyncronizationService(this._localStorageService, this.api);

  Future<void> sync() async {
    final pendencyQueue = await _localStorageService.getList(RequestQueueInterceptor.kListKey);
    final pendentRequests = pendencyQueue.map((e) => StorableRequest.fromStorableString(e)).toList();

    for (final request in pendentRequests) {
      try {
        switch (request.method) {
          case "POST":
            await api.httpClient.post(request.path, data: request.body);
          case "PUT":
            await api.httpClient.put(request.path, data: request.body);
          case "DELETE":
            await api.httpClient.delete(request.path);
            break;
          default:
            continue;
        }
        await _localStorageService.removeFromList(RequestQueueInterceptor.kListKey, request.toStorableString());
      } catch (e) {
        final index = pendentRequests.indexOf(request);
        request.attempts += 1;
        await _localStorageService.updateAtList(request.toStorableString(), index, request.toStorableString());
      }
    }
  }
}
