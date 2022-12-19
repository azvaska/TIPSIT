import 'dart:async';

import 'package:chatroom/schema/message.dart';
import 'package:chatroom/schema/room.dart';
import 'package:chatroom/schema/user.dart';
import 'package:chatroom/widgets/chatbubble.dart';
import 'package:chatroom/widgets/inputwidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class Chat extends StatefulWidget {
  Room room;
  Stream<Message> new_messages;
  User user;
  Chat(
      {super.key,
      required this.room,
      required this.user,
      required this.new_messages});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  StreamSubscription<Message>? sus;
  @override
  void initState() {
    // TODO: implement initState
    sus = widget.new_messages.listen((event) {
      setState(() {
        widget.room.messages.add(event);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    sus!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textEditingController;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Login Page"),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, widget.room);
          return false;
        },
        child: Stack(
          children: [
            ...List.generate(widget.room.messages.length, (index) {
              return ChatBubble(
                text: widget.room.messages[index].content,
                isCurrentUser:
                    widget.room.messages[index].senderId == widget.user.userId,
              );
            }),
            Center(
                child: Align(
              alignment: Alignment.bottomCenter,
              child: InputWidget(
                textEditingController: textEditingController,
                room: widget.room,
                user: widget.user,
              ),
            )),
          ],
        ),
      ),
    );
  }
}
