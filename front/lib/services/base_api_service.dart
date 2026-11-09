import 'package:dio/dio.dart';

/// Base class for all API services
final class BaseApiService {
  
  BaseApiService(this.baseUrl) {
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(milliseconds: 50000),
    );
    httpClient = Dio(options);
  }
  
  final String baseUrl;

  late final Dio httpClient;

  Future<Response<T>> get<T>(String endpoint) async {
    try {
      return await httpClient.get('$baseUrl$endpoint');
    } on DioException catch (ex) {
      if (ex.response != null &&
          ex.response?.data != null &&
          ex.response?.data.MensagemErro != null) {
        var error = ex.response?.data;
        throw error['exception'];
      }

      rethrow;
    } catch (ex) {
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
    String endpoint, { required Map<String, dynamic> body }) async {
    try {
      return await httpClient.post(
        '$baseUrl$endpoint',
        data: body,
      );
    } on DioException catch (ex) {
      if (ex.response != null &&
          ex.response?.data != null &&
          ex.response?.data.exception != null) {
        var error = ex.response?.data;
        throw error['mensagemErro'];
      }

      rethrow;
    } catch (ex) {
      rethrow;
    }
  }

  Future<Response<T>> put<T>(String endpoint, { required Map<String, dynamic> body }) async {
    try {
      return await httpClient.put(
        '$baseUrl$endpoint',
        data: body,
      );
    } on DioException catch (ex) {
      if (ex.response != null &&
          ex.response?.data != null &&
          ex.response?.data.exception != null) {
        var error = ex.response?.data;
        throw error['exception'];
      }

      rethrow;
    } catch (ex) {
      rethrow;
    }
  }
}
