import 'dart:convert';

import 'package:chatroom/schema/user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'config.dart';
import 'cripto.dart';
import 'schema/message.dart';
import 'schema/room.dart';

class RoomLogin extends StatefulWidget {
  final User user;
  final bool Function(String) checkRoomExists;
  const RoomLogin(
      {super.key, required this.user, required this.checkRoomExists});

  @override
  State<RoomLogin> createState() => _RoomLoginState();
}

class _RoomLoginState extends State<RoomLogin> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String ErrorText = "";

  Future<Room?> createRoom() async {
    final response = await http
        .post(Uri.parse('http://${Settings.ip}:3080/api/create-room'), body: {
      "userId": widget.user.userId,
      "password": passwordController.text,
      "name": nameController.text
    });
    var roomTemp = jsonDecode(response.body);
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
      return Future.error(Exception(roomTemp["message"]));
      ;
    }
  }

  Future<Room?> joinRoom() async {
    final response = await http
        .post(Uri.parse('http://${Settings.ip}:3080/api/get-room'), body: {
      "userId": widget.user.userId,
      "password": passwordController.text,
      "name": nameController.text
    });
    var roomTemp = jsonDecode(response.body);
    print(roomTemp);
    if (response.statusCode == 200) {
      if (widget.checkRoomExists(roomTemp['chatId'])) {
        return Future.error(Exception('Room already joined'));
      }
      final DateTime now = DateTime.now();
      final DateFormat formatter = DateFormat('HH:mm');
      final String formatted = formatter.format(now);
      List<Message> messages = [];

      roomTemp['timestamp'] = formatted;
      roomTemp['name'] = nameController.text;
      roomTemp['iv'] = base64.decode(roomTemp['iv']);
      roomTemp['lastMessage'] = "";
      // If the server did return a 200 OK response,
      // then parse the JSON.
      Room r = Room.fromJson(roomTemp);
      for (var message in roomTemp['messages']) {
        message = Message.fromJson(message);
        try {
          message.content = await Aes256Gcm.decrypt(r, message.content);
          messages.add(message);
        } catch (e) {
          print(e);
        }
      }
      r.messages = messages;
      r.messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      r.lastMessage =
          messages.isEmpty ? "Stanza creata!" : messages.last.content;
      return r;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      return Future.error(Exception(roomTemp["message"]));
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
              Text(ErrorText),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    // height: 50,
                    width: 100,
                    decoration: const BoxDecoration(color: Colors.blue),
                    child: TextButton(
                      onPressed: () {
                        createRoom()
                            .then((value) => {
                                  Navigator.pop(context, value),
                                })
                            .catchError((error, stackTrace) => {
                                  setState(() {
                                    ErrorText = error.message;
                                  })
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
                        joinRoom()
                            .then((value) => {
                                  Navigator.pop(context, value),
                                })
                            .catchError((error, stackTrace) => {
                                  setState(() {
                                    try {
                                      ErrorText = error.message;
                                    } catch (e) {
                                      ErrorText = "Error in joining room";
                                    }
                                  })
                                });
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
