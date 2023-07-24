import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class ApiProvider extends ChangeNotifier {
  // late String jwtToken;
  static const storage = FlutterSecureStorage();

  String host = 'http://204.216.223.6:3000/';
  Map<String, String>? headers;

  ApiProvider() {
    setHeader();
  }

  Future<String?> setHeader() async {
    final jwtToken = await storage.read(key: "jwt_token");
    if (jwtToken != null) {
      headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${jwtToken.replaceAll('"', '')}',
      };
    }
  }

  Future<dynamic> makeBackendCall(String url, var body) async {
    final response = await http.get(Uri.parse('$host$url'), headers: headers);
    return response;
  }

  Future<dynamic> recognize(String url, var body, data, _image) async {
    final response = await http.post(Uri.parse('$host$url'),
        headers: {"Content-Type": "application/json"}, body: jsonEncode(body));

    // await http.Response.fromStream(response);
    if (response.statusCode == 200) {
      storage.write(key: 'jwt_token', value: response.body);
      if (url == 'signup') {
        if (_image == null) {
          return response;
        }
        var request = http.MultipartRequest(
            'POST', Uri.parse('http://204.216.223.6:3000/upload'));

        request.headers.addAll({
          'Content-Type': 'image/jpg',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${response.body.replaceAll('"', '')}',
        });
        var stream = http.ByteStream(Stream.castFrom(_image!.openRead()));
        var length = await _image!.length();
        var multipartFile =
            http.MultipartFile('file', stream, length, filename: _image!.path);
        request.files.add(multipartFile);
        var imageResponse = await request.send();
      }
      headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${response.body.replaceAll('"', '')}',
      };
    }
    return response;
  }

  Future<dynamic> uploadImage(Map<String, String> data, _image) async {

  }
}
