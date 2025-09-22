import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../errors/exceptions.dart';
import '../constants/app_constants.dart';

class NetworkService {
  late final Dio _dio;
  static NetworkService? _instance;
  
  NetworkService._() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    
    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: false,
        responseHeader: false,
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token if available
          final token = await _getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle token refresh
          if (error.response?.statusCode == 401) {
            try {
              await _refreshToken();
              final newToken = await _getAuthToken();
              if (newToken != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final response = await _dio.request(
                  error.requestOptions.path,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  ),
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                );
                handler.resolve(response);
                return;
              }
            } catch (e) {
              // Token refresh failed, proceed with original error
            }
          }
          handler.next(error);
        },
      ),
    ]);
  }
  
  static NetworkService get instance {
    _instance ??= NetworkService._();
    return _instance!;
  }
  
  Future<String?> _getAuthToken() async {
    // TODO: Implement token retrieval from secure storage
    return null;
  }
  
  Future<void> _refreshToken() async {
    // TODO: Implement token refresh logic
  }
  
  Future<bool> get isConnected async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      if (!await isConnected) {
        throw const NetworkException('No internet connection');
      }
      
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
  
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      if (!await isConnected) {
        throw const NetworkException('No internet connection');
      }
      
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
  
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      if (!await isConnected) {
        throw const NetworkException('No internet connection');
      }
      
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
  
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      if (!await isConnected) {
        throw const NetworkException('No internet connection');
      }
      
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
  
  Future<Response> download(
    String path,
    String savePath, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      if (!await isConnected) {
        throw const NetworkException('No internet connection');
      }
      
      final response = await _dio.download(
        path,
        savePath,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
  
  Future<Response<T>> upload<T>(
    String path,
    FormData formData, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      if (!await isConnected) {
        throw const NetworkException('No internet connection');
      }
      
      final response = await _dio.post<T>(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      
      return response;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw NetworkException(e.toString());
    }
  }
  
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException('Connection timeout');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Server error';
        
        switch (statusCode) {
          case 400:
            return ValidationException(message);
          case 401:
            return const AuthenticationException('Authentication failed');
          case 403:
            return const AuthenticationException('Access denied');
          case 404:
            return ServerException('Resource not found');
          case 500:
            return const ServerException('Internal server error');
          default:
            return ServerException(message);
        }
      
      case DioExceptionType.cancel:
        return const NetworkException('Request cancelled');
      
      case DioExceptionType.connectionError:
        return const NetworkException('Connection error');
      
      case DioExceptionType.badCertificate:
        return const NetworkException('Certificate error');
      
      case DioExceptionType.unknown:
      default:
        return NetworkException(error.message ?? 'Unknown network error');
    }
  }
  
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }
  
  void removeInterceptor(Interceptor interceptor) {
    _dio.interceptors.remove(interceptor);
  }
  
  void clearInterceptors() {
    _dio.interceptors.clear();
  }
}