import 'package:flutter/material.dart';

class Message {
  String id;
  String roomId;
  String senderId;
  String content;
  String timestamp;
  String username;
  Message(
      {required this.id,
      required this.roomId,
      required this.senderId,
      required this.content,
      required this.timestamp,
      required this.username});
}
