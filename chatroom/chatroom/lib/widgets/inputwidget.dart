import 'package:chatroom/schema/room.dart';
import 'package:chatroom/schema/user.dart';
import 'package:flutter/material.dart';

class InputWidget extends StatelessWidget {
  final TextEditingController controller;
  void Function() sendMessage;
  InputWidget({super.key, required this.controller, required this.sendMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50.0,
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(width: 0.5)), color: Colors.white),
      child: Row(
        children: <Widget>[
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                onPressed: () {},
              ),
            ),
          ),

          // Text input
          Flexible(
            child: TextField(
              style: const TextStyle(fontSize: 15.0),
              controller: controller,
              decoration: const InputDecoration.collapsed(
                hintText: 'Type a message',
              ),
            ),
          ),

          // Send Message Button
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  sendMessage();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
