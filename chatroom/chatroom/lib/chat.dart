import 'dart:async';

import 'package:chatroom/schema/message.dart';
import 'package:chatroom/schema/room.dart';
import 'package:chatroom/schema/user.dart';
import 'package:chatroom/widgets/chatbubble.dart';
import 'package:chatroom/widgets/inputwidget.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/src/socket.dart';

import 'cripto.dart';

class Chat extends StatefulWidget {
  Socket socketIo;
  Room room;
  Stream<Message> new_messages;
  User user;
  Chat(
      {super.key,
      required this.room,
      required this.user,
      required this.new_messages,
      required this.socketIo});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  StreamSubscription<Message>? sus;
  TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Message> waiting_to_aknowledge = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 1),
          curve: Curves.fastOutSlowIn);
    });
    sus = widget.new_messages.listen((event) {
      setState(() {
        waiting_to_aknowledge.removeWhere((element) =>
            element.content == event.content &&
            element.senderId == event.senderId);
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    sus!.cancel();
    super.dispose();
  }

  void sendMessage() async {
    if (controller.text.isNotEmpty) {
      var message = {
        "userId": widget.user.userId,
        "roomId": widget.room.roomid,
        "content": await Aes256Gcm.encrypt(widget.room, controller.text)
        // "timestamp": Math.floor(new Date().getTime() / 1000)
      };

      widget.socketIo.emit('message', message);
      message["content"] = controller.text;
      message["_id"] = "";
      message["timestamp"] = "";
      message["sent"] = "false";
      Message messageTmp = Message.fromJson(message);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 1),
            curve: Curves.fastOutSlowIn);
      });
      setState(() {
        waiting_to_aknowledge.add(messageTmp);
        controller.text = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var messageRender = [...widget.room.messages, ...waiting_to_aknowledge];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.room.name),
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, widget.room);
          return false;
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 70),
              child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(children: [
                    ...List.generate(messageRender.length, (index) {
                      return ChatBubble.fromMessage(messageRender[index],
                          messageRender[index].senderId == widget.user.userId);
                    }),
                  ])),
            ),
            Align(
                alignment: Alignment.bottomLeft,
                child: IntrinsicHeight(
                  child: Container(
                      padding:
                          const EdgeInsets.only(left: 10, bottom: 5, top: 0),
                      width: double.infinity,
                      color: Colors.white,
                      child: InputWidget(
                          controller: controller, sendMessage: sendMessage)),
                )),
          ],
        ),
      ),
    );
  }
}
