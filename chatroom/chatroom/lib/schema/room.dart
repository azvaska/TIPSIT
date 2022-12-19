import 'package:flutter/foundation.dart';

import 'message.dart';
import 'package:convert/convert.dart';

class Room {
  Room(
      {required this.roomid,
      required this.name,
      required this.password,
      required this.iv,
      required this.lastMessage,
      required this.messages,
      required this.timestamp});
  final String lastMessage;
  final String roomid;
  final String name;
  final Uint8List password;
  final Uint8List iv;
  final String timestamp;
  List<Message> messages;

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        roomid: json["chatId"],
        name: json["name"],
        password: Uint8List.fromList(hex.decode(json["password"])),
        iv: json["iv"],
        lastMessage: json["lastMessage"] ?? 'Stanza creata!',
        messages: json["messages"] ?? [],
        timestamp: json["timestamp"],
      );

  Map<String, dynamic> toJson() => {
        "id": roomid,
        "name": name,
        "password": password,
        "iv": iv,
        "lastMessage": lastMessage,
      };
}
