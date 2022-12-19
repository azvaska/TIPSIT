import 'package:flutter/material.dart';

class RoomList_widget extends StatefulWidget {
  String name;
  String time;
  String lastMessage;
  RoomList_widget(
      {super.key,
      required this.name,
      required this.time,
      required this.lastMessage});
  @override
  _RoomList_widgetState createState() => _RoomList_widgetState();
}

class _RoomList_widgetState extends State<RoomList_widget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.name,
                          style: const TextStyle(fontSize: 25),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          widget.lastMessage,
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Text(
            widget.time,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
