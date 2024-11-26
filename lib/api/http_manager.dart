import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:listar_flutter_pro/blocs/bloc.dart';
import 'package:listar_flutter_pro/configs/config.dart';
import 'package:listar_flutter_pro/utils/logger.dart';

class HTTPManager {
  final exceptionCode = ['jwt_auth_bad_iss', 'jwt_auth_invalid_token'];
  late final Dio _dio;

  HTTPManager() {
    // Initialize Dio with base options
    _dio = Dio(
      BaseOptions(
        baseUrl: '${Application.domain}/index.php/wp-json',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        contentType: Headers.formUrlEncodedContentType,
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors for handling requests and errors
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) {
          Map<String, dynamic> headers = {
            "Device-Id": Application.device?.uuid,
            "Device-Model": Application.device?.model,
            "Device-Version": Application.device?.version,
            "Type": Application.device?.type,
            "Device-Token": Application.device?.token,
          };

          String? token = AppBloc.userCubit.state?.token;
          if (token != null) {
            headers["Authorization"] = "Bearer $token";
          }
          options.headers.addAll(headers);
          _printRequest(options);
          handler.next(options); // Proceed with the request
        },
        onError: (DioException error, handler) async {
          if (exceptionCode.contains(error.response?.data['code'])) {
            AppBloc.loginCubit.onLogout();
          }

          if (error.response?.data is Map) {
            final response = Response(
              requestOptions: error.requestOptions,
              data: error.response?.data,
            );
            return handler.resolve(response); // Resolve with the error response
          }

          handler.next(error); // Continue with the error
        },
      ),
    );
  }

  /// POST method
  Future<dynamic> post({
    required String url,
    dynamic data,
    FormData? formData,
    Options? options,
    Function(num)? progress,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }

    try {
      final response = await _dio.post(
        url,
        data: data ?? formData,
        options: options,
        onSendProgress: (received, total) {
          if (progress != null && total != 0) {
            progress((received / total) * 100);
          }
        },
      );
      return response.data;
    } on DioException catch (error) {
      return _errorHandle(error);
    } finally {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
    }
  }

  /// GET method
  Future<dynamic> get({
    required String url,
    dynamic params,
    Options? options,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }

    try {
      final response = await _dio.get(
        url,
        queryParameters: params,
        options: options,
      );
      return response.data;
    } on DioException catch (error) {
      return _errorHandle(error);
    } finally {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
    }
  }

  /// PUT method
  Future<dynamic> put({
    required String url,
    dynamic data,
    Options? options,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }

    try {
      final response = await _dio.put(
        url,
        data: data,
        options: options,
      );
      return response.data;
    } on DioException catch (error) {
      return _errorHandle(error);
    } finally {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
    }
  }

  /// DOWNLOAD method
  Future<dynamic> download({
    required String url,
    required String filePath,
    dynamic params,
    Options? options,
    Function(num)? progress,
    bool? loading,
  }) async {
    if (loading == true) {
      SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.light);
      SVProgressHUD.show();
    }

    try {
      final response = await _dio.download(
        url,
        filePath,
        options: options,
        queryParameters: params,
        onReceiveProgress: (received, total) {
          if (progress != null && total != 0) {
            progress((received / total) * 100);
          }
        },
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "data": File(filePath),
          "message": 'download_success',
        };
      }

      return {
        "success": false,
        "message": 'download_fail',
      };
    } on DioException catch (error) {
      return _errorHandle(error);
    } finally {
      if (loading == true) {
        SVProgressHUD.dismiss();
      }
    }
  }

  /// Change API domain
  void changeDomain(String domain) {
    _dio.options.baseUrl = '$domain/index.php/wp-json';
  }

  /// Log request details
  void _printRequest(RequestOptions options) {
    UtilLogger.log("BEFORE REQUEST ====================================");
    UtilLogger.log("${options.method} URL", options.uri);
    UtilLogger.log("HEADERS", options.headers);
    if (options.method == 'GET') {
      UtilLogger.log("PARAMS", options.queryParameters);
    } else {
      UtilLogger.log("DATA", options.data);
    }
  }

  /// Handle errors
  Map<String, dynamic> _errorHandle(DioException error) {
    String message = "unknown_error";
    Map<String, dynamic> data = {};

    switch (error.type) {
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = "request_time_out";
        break;

      case DioExceptionType.connectionError:
      case DioExceptionType.badResponse:
        if (error.response?.data is Map) {
          data = error.response?.data ?? {};
          message = data['message'] ?? message;
        }
        break;

      default:
        message = "cannot_connect_server";
        break;
    }

    return {
      "success": false,
      "message": message,
      "data": data,
    };
  }
}
