import 'dart:convert';

import 'package:chatroom/room_list.dart';
import 'package:chatroom/schema/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:http/http.dart' as http;

// ignore: non_constant_identifier_names
User? user_authenticated;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  Duration get loginTime => const Duration(milliseconds: 2250);

  Future<User> fetchUser(LoginData data) async {
    final response = await http.post(
        Uri.parse('http://138.3.243.70:3080/api/login'),
        body: {"username": data.name, "password": data.password});
    var userTemp = jsonDecode(response.body);
    userTemp['email'] = data.name;
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return User.fromJson(userTemp);
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load User');
    }
  }

  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');

    return fetchUser(data).then((value) {
      user_authenticated = value;
      return null;
    });
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
    return FlutterLogin(
      title: 'ECORP',
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
