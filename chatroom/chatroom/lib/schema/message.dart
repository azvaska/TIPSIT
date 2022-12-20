import 'package:chatroom/schema/room.dart';
import 'package:flutter/material.dart';
import 'package:chatroom/cripto.dart';

class Message {
  String id;
  String roomId;
  String senderId;
  String content;
  String timestamp;
  Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        roomId: json["roomId"],
        id: json["_id"],
        senderId: json["userId"],
        content: json["content"],
        timestamp: json["timestamp"],
      );
}
