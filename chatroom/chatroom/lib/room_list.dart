import 'package:chatroom/config.dart';
import 'package:chatroom/room_login.dart';
import 'package:chatroom/schema/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'chat.dart';
import 'schema/room.dart';
import 'widgets/room_list.dart';

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
    IO.Socket socket = IO.io(
        'http://${Settings.ip}:3000',
        OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
            .setExtraHeaders({'foo': 'bar'}) // optional
            .build());
  }

  List<Room> rooms = [];
  void open_room() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoomLogin(user: widget.user)),
    ).then((value) => {
          if (value != null)
            {
              setState(() {
                rooms.add(value);
              })
            }
        });
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
              child: Column(
            children: [
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
                      MaterialPageRoute(
                          builder: (context) => RoomLogin(user: widget.user)),
                    ).then((value) => {
                          if (value != null)
                            {
                              setState(() {
                                rooms.add(value);
                              })
                            }
                        });
                  },
                  child: const Text(
                    "Create/Join Room",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
              ),
              ...List.generate(rooms.length, (index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Chat(
                                user: widget.user,
                                room: rooms[index],
                              )),
                    ).then((value) => {
                          if (value != null)
                            {
                              setState(() {
                                rooms[index] = value;
                              })
                            }
                        });
                  },
                  child: RoomList_widget(
                      name: rooms[index].name,
                      time: rooms[index].timestamp,
                      lastMessage: rooms[index].lastMessage),
                );
              })
            ],
          )),
        ));
  }
}
