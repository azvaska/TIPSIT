class Message {
  String id;
  String roomId;
  String senderId;
  String content;
  String timestamp;
  bool sent = false;
  Message(
      {required this.id,
      required this.roomId,
      required this.senderId,
      required this.content,
      required this.timestamp,
      required this.sent});

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        roomId: json["roomId"],
        id: json["_id"],
        senderId: json["userId"],
        content: json["content"],
        timestamp: json["timestamp"],
        sent: json["sent"] == "false" ? false : true,
      );
}
