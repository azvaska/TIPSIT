import 'dart:ffi';

import 'package:flutter/material.dart';

import '../schema/message.dart';

class ChatBubble extends StatelessWidget {
  String text;
  bool isCurrentUser;
  String userid;
  bool sent;
  String timestamp;
  ChatBubble({
    Key? key,
    required this.text,
    required this.isCurrentUser,
    required this.userid,
    required this.sent,
    required this.timestamp,
  }) : super(key: key);
  factory ChatBubble.fromMessage(Message message, bool isCurrentUser_in) {
    return ChatBubble(
      text: message.content,
      isCurrentUser: isCurrentUser_in,
      sent: message.sent,
      userid: message.senderId,
      timestamp: message.timestamp,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // asymmetric padding
      padding: EdgeInsets.fromLTRB(
        isCurrentUser ? 64.0 : 16.0,
        4,
        isCurrentUser ? 16.0 : 64.0,
        4,
      ),
      child: Align(
        // align the child within the container
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: DecoratedBox(
          // chat bubble decoration
          decoration: BoxDecoration(
            color: sent
                ? isCurrentUser
                    ? Colors.blue
                    : Colors.grey[300]
                : Colors.grey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  userid,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 12),
                ),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 15),
                ),
                Text(
                  timestamp.isNotEmpty
                      ? DateTime.fromMillisecondsSinceEpoch(
                              int.parse(timestamp) * 1000)
                          .toString()
                      : "Sending...",
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                      fontSize: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
