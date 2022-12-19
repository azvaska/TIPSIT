import 'dart:convert';

import 'package:chatroom/schema/user.dart';
import 'package:flutter/material.dart';
import 'package:cryptography/cryptography.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'config.dart';
import 'schema/room.dart';

class RoomLogin extends StatefulWidget {
  final User user;
  const RoomLogin({super.key, required this.user});

  @override
  State<RoomLogin> createState() => _RoomLoginState();
}

class _RoomLoginState extends State<RoomLogin> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<Room?> createRoom() async {
    try {
      final response = await http
          .post(Uri.parse('http://${Settings.ip}:3080/api/create-room'), body: {
        "userId": widget.user.userId,
        "password": passwordController.text,
        "name": nameController.text
      });
      var roomTemp = jsonDecode(response.body);
      print(roomTemp);
      if (response.statusCode == 200) {
        final DateTime now = DateTime.now();
        final DateFormat formatter = DateFormat('HH:mm');
        final String formatted = formatter.format(now);
        roomTemp['timestamp'] = formatted;
        roomTemp['name'] = nameController.text;
        roomTemp['iv'] = base64.decode(roomTemp['iv']);
        // If the server did return a 200 OK response,
        // then parse the JSON.
        return Room.fromJson(roomTemp);
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load Room');
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, null);
          return false;
        },
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 50, bottom: 25),
                child: Text(
                  "Creare/Join Room",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Name',
                      hintText: 'The name of the room'),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 20),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      hintText: 'Enter secure password for the room'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    // height: 50,
                    width: 100,
                    decoration: const BoxDecoration(color: Colors.blue),
                    child: TextButton(
                      onPressed: () {
                        createRoom().then((value) => {
                              Navigator.pop(context, value),
                            });
                      },
                      child: const Text(
                        'Create',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                  ),
                  Container(
                    // height: 50,
                    width: 100,

                    decoration: const BoxDecoration(color: Colors.blue),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Join',
                        style: TextStyle(color: Colors.white, fontSize: 25),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 130,
              ),
              const Text('New User? Create Account')
            ],
          ),
        ),
      ),
    );
  }
}
