// ignore_for_file: file_names

import 'package:chat_app/main.dart';
import 'package:chat_app/src/helper/globals.dart';
import 'package:chat_app/src/services/storage.service.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class DioConfig {
  var dio = Dio();
  DioConfig() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers['Content-Type'] = "application/json";
          options.headers['Authorization'] =
              "Bearer ${await StorageService.getToken()}";
          return handler.next(options);
        },
        onResponse: (e, handler) async {
          return handler.next(e);
        },
        onError: (e, handler) async {
          print(e);
          return handler.next(e);
        },
      ),
    );
  }
}

class Req {
  var interceptor = DioConfig();
  get(url) async {
    try {
      var resp = await interceptor.dio.get(url);
      return resp.data;
    } on DioException catch (e) {
      if (e.response?.statusCode.toString() == '403') {
        await StorageService.logout();
        userSD = false;
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/signin', (Route<dynamic> route) => false);
      }
      return {"status": e.response?.statusCode.toString()};
    }
  }

  post(url, data) async {
    try {
      var resp = await interceptor.dio.post(url, data: data);
      return resp.data;
    } on DioException catch (e) {
      if (e.response?.statusCode.toString() == '403') {
        await StorageService.logout();
        userSD = false;
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
            '/signin', (Route<dynamic> route) => false);
      }
      return {"status": e.response?.statusCode.toString()};
    }
  }
}
