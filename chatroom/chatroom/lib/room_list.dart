import 'dart:async';

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
import 'cripto.dart';
import 'schema/message.dart';
import 'schema/room.dart';
import 'widgets/room_list.dart';

class RoomList extends StatefulWidget {
  final User user;
  const RoomList({super.key, required this.user});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  IO.Socket socket = IO.io(
      'http://${Settings.ip}:3000',
      OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
          .build());
  bool reload = false;
  late Room selectedRoom;
  StreamController<Message> streamController = StreamController.broadcast();
  @override
  dispose() {
    socket.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    socket.onConnect((_) {
      print('connect SUSSAAAAAAAAAAa');
      for (var room in rooms) {
        socket.emit('join', widget.user.userId);
      }
    });

    socket.on("new-message", (data) async {
      for (var room in rooms) {
        if (room.roomid == data["roomId"]) {
          var message = Message.fromJson(data);
          message.content = await Aes256Gcm.decrypt(room, message.content);
          room.messages.add(message);
          streamController.add(message);
          reload = true;
        }
      }
      setState(() {
        reload = true;
      });
    });
  }

  List<Room> rooms = [];
  bool checkRoomExists(String roomid) {
    for (var room in rooms) {
      if (room.roomid == roomid) {
        return true;
      }
    }
    return false;
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
                          builder: (context) => RoomLogin(
                              user: widget.user,
                              checkRoomExists: checkRoomExists)),
                    ).then((value) => {
                          if (value != null)
                            {
                              setState(() {
                                rooms.add(value);
                                socket.emit('join', {
                                  "roomId": value.roomid,
                                  "userId": widget.user.userId
                                });
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
                  key: UniqueKey(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Chat(
                                new_messages: streamController.stream,
                                user: widget.user,
                                room: rooms[index],
                                socketIo: socket,
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
