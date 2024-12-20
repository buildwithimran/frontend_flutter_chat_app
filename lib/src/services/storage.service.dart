// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

FlutterSecureStorage storage = FlutterSecureStorage();

class StorageService {
  static Future setLogin(data) async {
    await storage.write(key: 'user', value: jsonEncode(data));
    return true;
  }

  static Future<dynamic> getLogin() async {
    dynamic value = await storage.read(key: 'user');
    if (value != null) {
      return jsonDecode(value);
    } else {
      return false;
    }
  }

  static Future setObject(key, data) async {
    await storage.write(key: key, value: jsonEncode(data));
    return true;
  }

  static Future getObject(key) async {
    dynamic value = await storage.read(key: key);
    if (value != null) {
      return jsonDecode(value);
    } else {
      return false;
    }
  }

  static Future<dynamic> setToken(token) async {
    await storage.write(key: 'token', value: token);
    return true;
  }

  static Future<dynamic> getToken() async {
    dynamic value = await storage.read(key: 'token');
    if (value != null) {
      return value;
    } else {
      return false;
    }
  }

  static Future setString(key, value) async {
    await storage.write(key: key, value: value);
    return true;
  }

  static Future getString(value) async {
    return await storage.read(key: value);
  }

  static Future<bool> logout() async {
    await storage.deleteAll();
    // await setString('onboarding_shown', 'YES');
    return true;
  }
}
