import 'dart:convert';

import 'package:chatroom/room_list.dart';
import 'package:chatroom/schema/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';
import 'package:jwt_decode/jwt_decode.dart';

// ignore: non_constant_identifier_names
User? user_authenticated;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<User> fetchUser(LoginData data) async {
    final response = await http.post(
        Uri.parse('http://${Settings.ip}:3080/api/login'),
        body: {"username": data.name, "password": data.password}).timeout(
      const Duration(seconds: 4),
      onTimeout: () {
        // Time has run out, do what you wanted to do.
        return http.Response('Error in contecting to the server',
            408); // Request Timeout response status code
      },
    );
    ;

    if (response.statusCode == 200) {
      var userTemp = jsonDecode(response.body);
      userTemp['email'] = data.name;
      AndroidOptions _getAndroidOptions() => const AndroidOptions(
            encryptedSharedPreferences: true,
          );
      final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
      // If the server did return a 200 OK response,
      // then parse the JSON.
      await storage.write(key: "userToken", value: userTemp['token']);
      return User.fromJson(userTemp);
    } else {
      if (response.statusCode == 408) {
        throw Exception(response.body);
      }
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load User');
    }
  }

  Future<String?> _authUser(LoginData data) async {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    try {
      user_authenticated = await fetchUser(data);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      // if (!users.containsKey(name)) {
      //   return 'User not exists';
      // }
      // return "signed up";
      return "signed up";
    });
  }

  @override
  Widget build(BuildContext context) {
    AndroidOptions _getAndroidOptions() => const AndroidOptions(
          encryptedSharedPreferences: true,
        );
    final storage = FlutterSecureStorage(aOptions: _getAndroidOptions());
    storage.read(key: "userToken").then((value) {
      if (value != null) {
        Map<String, dynamic> payload = Jwt.parseJwt(value);
        user_authenticated = User(token: value, userId: payload['id']);
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => RoomList(user: user_authenticated!),
        ));
      }
    });
    return FlutterLogin(
      title: 'Secure Chat',
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => RoomList(user: user_authenticated!),
        ));
      },
      userValidator: (value) => null,
      passwordValidator: (value) => null,
      onRecoverPassword: _recoverPassword,
    );
  }
}
