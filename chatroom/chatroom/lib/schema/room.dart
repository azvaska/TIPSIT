import 'package:flutter/foundation.dart';

class Room {
  Room({
    required this.roomid,
    required this.name,
    required this.password,
    required this.iv,
    required this.lastMessage,
  });
  final String lastMessage;
  final int roomid;
  final String name;
  final String password;
  final ByteData iv;
  List<String> messages;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        roomid: json["roomid"],
        name: json["name"],
        password: json["password"],
        iv: json["iv"],
        lastMessage: json["lastMessage"],
      );

  Map<String, dynamic> toJson() => {
        "id": roomid,
        "name": name,
        "password": password,
        "iv": iv,
        "lastMessage": lastMessage,
      };
}
