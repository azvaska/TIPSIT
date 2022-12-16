import 'package:chatroom/room_login.dart';
import 'package:chatroom/schema/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class RoomList extends StatefulWidget {
  final User user;
  const RoomList({super.key, required this.user});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Room List",
        home: Scaffold(
          appBar: AppBar(
            title: const Text("Room List"),
          ),
          body: SingleChildScrollView(
              child: Column(children: [
            Container(
              height: 50,
              width: 1000,
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RoomLogin()),
                  );
                },
                child: const Text(
                  "Create/Join Room",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ])),
        ));
  }
}
