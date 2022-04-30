import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'jsonable.dart';

enum RestCallType { get, post, formPost, put, delete, patch}

class BaseClient {
  Dio _dio = Dio();

  Future<T> delete<T extends Jsonable>(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        T type,
      }) async {
    return _request(
      path,
      RestCallType.delete,
      queryParameters: queryParameters,
      headers: headers,
      type: type,
    );
  }

  Future<dynamic> deleteTypeless(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        Map<String, dynamic> body,
      }) async {
    return _requestTypeless(
      path,
      RestCallType.delete,
      queryParameters: queryParameters,
      data: body,
      headers: headers,
    );
  }

  Future<T> get<T extends Jsonable>(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        T type,
      }) async {
    return _request(
      path,
      RestCallType.get,
      queryParameters: queryParameters,
      headers: headers,
      type: type,
    );
  }

  Future<List<T>> getArray<T extends Jsonable>(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        T type,
      }) async {
    Response response = await _requestTypeless(
      path,
      RestCallType.get,
      queryParameters: queryParameters,
      headers: headers,
    );
    List<dynamic> list = response.data;
    List<Map> maps = list.cast<Map<dynamic, dynamic>>();
    List<T> models = maps.map((Map<dynamic, dynamic> map) {
      return type.fromJson(map) as T;
    }).toList();

    return models;
  }

  Future<dynamic> getTypeless(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
      }) async {
    return _requestTypeless(
      path,
      RestCallType.get,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<Response> patch(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
      }) async {
    return _requestTypeless(
      path,
      RestCallType.patch,
      queryParameters: queryParameters,
      headers: headers,
    );
  }

  Future<dynamic> patchTypeless(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        dynamic body,
      }) async {
    return _requestTypeless(
      path,
      RestCallType.patch,
      queryParameters: queryParameters,
      headers: headers,
      data: body,
    );
  }

  Future<T> post<T extends Jsonable>(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        T type,
        Map<String, dynamic> body,
      }) async {
    return _request(
      path,
      RestCallType.post,
      queryParameters: queryParameters,
      headers: headers,
      type: type,
      data: body,
    );
  }

  Future<dynamic> postForm(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        FormData body,
      }) async {
    return _requestTypeless(
      path,
      RestCallType.formPost,
      queryParameters: queryParameters,
      headers: headers,
      data: body,
    );
  }

  Future<dynamic> postFormTypeless(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        FormData body,
      }) async {
    return _requestTypeless(
      path,
      RestCallType.formPost,
      queryParameters: queryParameters,
      headers: headers,
      data: body,
    );
  }

  Future<dynamic> postTypeLess(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        Map<String, dynamic> body,
      }) async {
    return _requestTypeless(
      path,
      RestCallType.post,
      queryParameters: queryParameters,
      headers: headers,
      data: body,
    );
  }

  Future<T> put<T extends Jsonable>(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        T type,
      }) async {
    return _request(
      path,
      RestCallType.put,
      queryParameters: queryParameters,
      headers: headers,
      type: type,
    );
  }

  Future<dynamic> putTypeless(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        dynamic body,
      }) async {
    return _requestTypeless(
      path,
      RestCallType.put,
      queryParameters: queryParameters,
      headers: headers,
      data: body,
    );
  }

  Future<Response> putJson(
      String path, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        Map<String, dynamic> body,
      }) async {
    return _requestTypeless(
      path,
      RestCallType.put,
      queryParameters: queryParameters,
      data: body,
      headers: headers,
    );
  }

  Future<T> _request<T extends Jsonable>(
      String path,
      RestCallType callType, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        T type,
        Map<String, dynamic> data,
      }) async {
    bool reAuthRequired = false;
    T model;
    do {
      if (headers == null) {
        headers = {};
      }
//      List<String> cookies = await CookieUtils.getCookies();
//      if (cookies != null) {
//        Map<String, List<String>> cookieHeaders = {'cookie': cookies};
//        headers.addAll(cookieHeaders);
//      }

      Response response;
      try {
        if (callType == RestCallType.get) {
          response = await _dio.get(
            path,
            queryParameters: queryParameters,
            options: Options(
              headers: headers,
              followRedirects: false,
            ),
          );
        } else if (callType == RestCallType.post) {
          response = await _dio.post(
            path,
            data: data,
            queryParameters: queryParameters,
            options: Options(
              headers: headers,
              followRedirects: false,
            ),
          );
        } else if (callType == RestCallType.put) {
          response = await _dio.put(
            path,
            queryParameters: queryParameters,
            options: Options(
              headers: headers,
              followRedirects: false,
            ),
          );
        } else if (callType == RestCallType.delete) {
          response = await _dio.delete(
            path,
            queryParameters: queryParameters,
            options: Options(
              headers: headers,
              followRedirects: false,
            ),
          );
        }
      } on DioError catch (e) {
        debugPrint('Dio error: $e');
        if (e.response.statusCode == 401 || e.response.statusCode == 302) {
        } else {
          rethrow;
        }
      }
      reAuthRequired = false;
      if (response.statusCode != 204 &&
          (response.data ?? '').toString().isNotEmpty) {
        model = type.fromJson(response.data);
      }
    } while (reAuthRequired);

    return model;
  }

  Future<dynamic> _requestTypeless(
      String path,
      RestCallType callType, {
        Map<String, dynamic> queryParameters,
        Map<String, dynamic> headers,
        dynamic data,
      }) async {
    Response response;

    print(path);
    if (headers == null) {
      headers = {};
    }
    try {
      if (callType == RestCallType.get) {
        print(queryParameters);
        response = await _dio.get(
          path,
          queryParameters: queryParameters,
          options: Options(
            headers: headers,
            followRedirects: false,
          ),
        );
      } else if (callType == RestCallType.formPost) {
        response = await _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: Options(
            headers: headers,
            validateStatus: (int status) {
              return status == HttpStatus.found || status == HttpStatus.ok;
            },
            followRedirects: false,
          ),
        );
      } else if (callType == RestCallType.post) {
        response = await _dio.post(
          path,
          data: data,
          queryParameters: queryParameters,
          options: Options(
            headers: headers,
            followRedirects: false,
          ),
        );
      } else if (callType == RestCallType.put) {
        response = await _dio.put(
          path,
          data: data,
          queryParameters: queryParameters,
          options: Options(
            headers: headers,
            followRedirects: false,
          ),
        );
      } else if (callType == RestCallType.delete) {
        response = await _dio.delete(
          path,
          queryParameters: queryParameters,
          data: data,
          options: Options(
            headers: headers,
            followRedirects: false,
          ),
        );
      } else if (callType == RestCallType.patch) {
        response = await _dio.patch(
          path,
          queryParameters: queryParameters,
          data: data,
          options: Options(
            headers: headers,
            followRedirects: false,
          ),
        );
      }
      print('Response => ${response.data}');
      print('Response Status Code => ${response.statusCode}');
      return response.data;

    } on DioError catch (e) {
      debugPrint('Dio error: $e');
      return e;
    }
  }
}
